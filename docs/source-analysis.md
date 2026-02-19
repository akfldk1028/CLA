# Claude Code가 "업그레이드"되는 이유

## 핵심 원리

Claude Code CLI 자체는 바뀌지 않는다.
`$CLAUDE_CONFIG_DIR`에 파일을 넣으면 Claude가 **매 세션마다 그 파일을 읽고 지시를 따른다.**
이것이 "업그레이드"의 전부다.

```
바닐라 Claude Code
  = CLI 내장 시스템 프롬프트만 있음
  = Claude가 알아서 코딩 (제약 없음)

CLA 설치 후
  = CLI 내장 시스템 프롬프트 + CLAUDE.md(행동 규칙) + skills(추가 도구) + hooks(자동화)
  = Claude가 규칙을 따르고, 새 도구를 쓰고, 자동으로 컨텍스트를 관리함
```

---

## Before/After: 구체적으로 뭐가 달라지나

### 1. CLAUDE.md → Claude의 코딩 행동이 바뀜

**설치 위치**: `$CLAUDE_CONFIG_DIR/CLAUDE.md`
**로드 시점**: 세션 시작 시 항상 (모든 프로젝트에 적용)
**출처**: `andrej-karpathy-skills/` → `claude-master/` → `CLA/CLAUDE.md`

| Before (바닐라) | After (CLA 설치 후) |
|----------------|-------------------|
| 요청하면 관련 없는 코드도 "개선"해줌 | **Surgical changes**: 요청한 부분만 수정, 인접 코드 건드리지 않음 |
| 200줄 코드를 한번에 생성 | **Simplicity first**: 50줄로 가능하면 50줄로 씀 |
| 가정을 숨기고 바로 구현 | **Think before coding**: 가정을 명시하고 불명확하면 질문 |
| "버그 수정해줘" → 바로 코드 수정 | **Goal-driven**: 테스트 작성 → 통과 확인 루프 |
| 복잡한 bash를 한 줄로 작성 | **Safety**: 여러 단순한 명령으로 분해, `2>&1` 금지 |
| 컨텍스트가 가득 차면 성능 저하 | **Context management**: 85% 넘으면 /half-clone 사용 |

**Karpathy 4원칙이 왜 필요한가:**
Andrej Karpathy가 지적한 LLM 코딩의 공통 문제:
- "가정을 숨기고 진행" → Think before coding으로 해결
- "100줄로 될 걸 1000줄로" → Simplicity first로 해결
- "관련 없는 코드까지 수정" → Surgical changes로 해결
- "목표 없이 작업" → Goal-driven execution으로 해결

### 2. Skills 8개 → Claude에 새 도구가 추가됨

**설치 위치**: `$CLAUDE_CONFIG_DIR/skills/*/SKILL.md`
**로드 시점**: 세션 시작 시 description만 등록 (~수백 토큰). `/명령어` 호출 시 전체 본문 로드.
**출처**: `claude-code-tips/skills/` → `claude-master/skills/` → `CLA/skills/`

| 스킬 | Before (바닐라) | After (CLA) |
|------|----------------|-------------|
| `/handoff` | 없음. 세션 끊기면 컨텍스트 유실 | HANDOFF.md 자동 생성 (목표, 진행, 성공/실패, 다음 단계) |
| `/half-clone` | 없음. 컨텍스트 가득 차면 새 세션에서 처음부터 | 대화 후반부만 새 세션으로 복제. 토큰 절약 |
| `/clone` | 없음 | 현재 대화 전체를 새 세션으로 복제. 다른 접근 시도용 |
| `/gha <url>` | 없음. GitHub Actions 실패 시 수동 로그 분석 | 자동으로 근본 원인 분석 + 패턴 감지 + breaking commit 식별 |
| `/karpathy-guidelines` | 없음 | 현재 작업에 4원칙 체크리스트 적용 |
| `/reddit-fetch` | WebFetch로 Reddit 접근 불가 | Gemini CLI 통해 Reddit 콘텐츠 접근 |
| `/review-claudemd` | 없음 | 최근 15-20개 대화 분석 → CLAUDE.md 개선안 제안 |
| `/cla-init` | 없음 | 프로젝트 타입 자동 감지 → 맞춤 CLAUDE.md 생성 |

### 3. Stop Hook → 컨텍스트 자동 관리

**설치 위치**: `$CLAUDE_CONFIG_DIR/settings.json`의 `hooks.Stop` + `scripts/check-context.sh`
**로드 시점**: Claude가 대화를 끝내려 할 때마다 자동 실행
**출처**: `claude-code-tips/scripts/` → `claude-master/scripts/` → `CLA/scripts/`

| Before (바닐라) | After (CLA) |
|----------------|-------------|
| 컨텍스트 200K 다 차면 자동 압축(compact) 발동 | 85%에서 미리 감지 → `/half-clone` 강제 유도 |
| 압축은 요약이라 정보 손실 있음 | half-clone은 실제 메시지를 그대로 보존 |
| 사용자가 컨텍스트 상태를 모름 | check-context.sh가 정확한 % 계산 후 알려줌 |

**동작 흐름:**
```
Claude가 응답 끝내려 함
  → check-context.sh 실행
  → transcript에서 토큰 사용량 계산
  → 85% 미만: 통과 (정상 종료)
  → 85% 이상: {"decision":"block"} → Claude에게 /half-clone 지시
  → half-clone 실행 → 후반부만 새 세션 → fresh 컨텍스트로 계속
```

### 4. 상태줄 스크립트 → 시각적 정보 제공

**설치 위치**: `$CLAUDE_CONFIG_DIR/scripts/context-bar.sh`
**출처**: `claude-code-tips/scripts/` → `claude-master/scripts/` → `CLA/scripts/`

| Before (바닐라) | After (CLA) |
|----------------|-------------|
| 하단에 기본 상태줄 | 모델명, 브랜치, 변경 파일 수, 동기 상태, 컨텍스트 % 바 표시 |

```
Opus 4.5 | 📁my-project | 🔀main (2 uncommitted, synced) | ██████░░░░ 58% of 200k tokens
```

### 5. 템플릿 6개 → 프로젝트별 맞춤 규칙

**설치 위치**: `$CLAUDE_CONFIG_DIR/templates/*.md`
**사용 시점**: `/cla-init` 호출 시
**출처**: CLA 자체 제작

| Before (바닐라) | After (CLA) |
|----------------|-------------|
| 프로젝트 CLAUDE.md를 직접 작성해야 함 | `/cla-init` → 자동 감지 → 맞춤 CLAUDE.md 생성 |
| Rust/Flutter/React 등 프레임워크별 규칙 없음 | 6개 타입별 빌드/테스트/린트 명령 + 프레임워크 관례 포함 |

---

## 3개 소스 디렉토리: 각각 뭘 기여하나

### andrej-karpathy-skills/ → 행동 원칙의 근원

**기여**: CLAUDE.md의 4원칙 (Think, Simplicity, Surgical, Goal-driven)
**원본**: Andrej Karpathy의 [X 포스트](https://x.com/karpathy/status/2015883857489522876)에서 파생
**파일**: `CLAUDE.md` + `skills/karpathy-guidelines/SKILL.md` + `EXAMPLES.md`

이 원칙이 없으면 Claude는:
- 요청 안 한 기능도 추가함
- 단일 사용 코드에 팩토리 패턴 적용
- 버그 수정하면서 옆 코드도 리팩토링
- "이렇게 하면 될 것 같습니다" → 바로 구현 (확인 없이)

### claude-code-tips/ → 스킬과 스크립트의 원산지

**기여**: 6개 스킬 엔진 + 4개 스크립트 + 시스템 프롬프트 패치(수동 적용)
**원본**: YK(ykdojo)의 2.5년 Claude Code 사용 경험 (10억+ 토큰)
**핵심 파일**:

| 파일 | CLA에 반영? | 기여 내용 |
|------|-----------|----------|
| `skills/clone/SKILL.md` | O | /clone 스킬 |
| `skills/half-clone/SKILL.md` | O | /half-clone 스킬 |
| `skills/handoff/SKILL.md` | O | /handoff 스킬 |
| `skills/gha/SKILL.md` | O | /gha 스킬 |
| `skills/reddit-fetch/SKILL.md` | O | /reddit-fetch 스킬 |
| `skills/review-claudemd/SKILL.md` | O | /review-claudemd 스킬 |
| `scripts/context-bar.sh` | O | 상태줄 스크립트 |
| `scripts/check-context.sh` | O | Stop hook (85% 감지) |
| `scripts/clone-conversation.sh` | O | clone 엔진 |
| `scripts/half-clone-conversation.sh` | O | half-clone 엔진 |
| `system-prompt/*/patch-cli.js` | **X** | 시스템 프롬프트 패치 (아래 별도 설명) |
| `scripts/setup.sh` | **X** | DX 플러그인 + cc-safe + 설정 일괄 구성 |
| `content/*.md` | **X** | 45개 팁 콘텐츠 (학습 참고용) |

### claude-master/ → 통합본 (CLA의 직접 원본)

**기여**: 위 두 소스를 하나로 통합한 완성 패키지
**관계**: CLA는 여기서 파생. CLA가 cla-init 스킬 + 6개 템플릿을 추가.

```
andrej-karpathy-skills/  ──→  4원칙 ──┐
                                       ↓
claude-code-tips/  ──→  스킬+스크립트 ─→ claude-master/ ──→ CLA/ ──→ $CLAUDE_CONFIG_DIR
```

---

## 시스템 프롬프트 패치 (2.1.47 대응 완료)

`claude-code-tips/system-prompt/`에 있는 패치는 **CLI 번들의 시스템 프롬프트를 축소**하는 것이다.
CLA의 CLAUDE.md/skills와는 완전히 다른 레이어.

### 뭘 하는 건가

Claude Code CLI 내부에 하드코딩된 시스템 프롬프트를 63개 패치로 축소:

| 항목 | v2.1.47 결과 |
|------|-------------|
| 적용 패치 | 63/63 |
| 절감량 | 42,915 바이트 (~10.7K 토큰) |
| 효과 | 매 API 호출마다 ~10K 토큰 절약 |

매 API 호출마다 ~10K 토큰을 절약 → 같은 200K 컨텍스트에서 더 많이 대화 가능.

### 지원 버전

| 버전 | 패치 경로 | 상태 |
|------|----------|------|
| 2.1.42 이하 | `system-prompt/2.1.42/` | 원본 (claude-code-tips 제공) |
| **2.1.47** | `system-prompt/2.1.47/` | **CLA에서 추가** (63/63 통과) |

### 적용 방법 (npm 설치 기준)

```bash
# 1. npm으로 Claude Code 설치 (Windows 네이티브 바이너리는 미지원)
npm install -g @anthropic-ai/claude-code

# 2. 백업 생성
cp "$(npm root -g)/@anthropic-ai/claude-code/cli.js" \
   "$(npm root -g)/@anthropic-ai/claude-code/cli.js.backup"

# 3. 패치 적용
cd claude-code-tips/system-prompt/2.1.47
node patch-cli.js "$(npm root -g)/@anthropic-ai/claude-code/cli.js"

# 복원하려면:
cp "$(npm root -g)/@anthropic-ai/claude-code/cli.js.backup" \
   "$(npm root -g)/@anthropic-ai/claude-code/cli.js"
```

### 새 버전 대응

Claude Code가 업데이트되면 패치 재작성이 필요하다:
- `system-prompt/UPGRADING.md` 참조
- 컨테이너에서 Claude Code가 자동으로 패치를 수정하는 워크플로우 제공
- 변수명 변경은 regex로 자동 대응, 텍스트 변경만 수동 수정

### 주의사항

- **Windows 네이티브 바이너리 미지원**: PE 포맷 extract/repack 미구현
- **npm 설치 필수**: 패치는 cli.js 파일을 직접 수정하므로 npm 설치 필요
- **버전 의존**: 새 버전마다 hash 확인 + 패치 갱신 필요
