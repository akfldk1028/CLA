# 30_CLA - Claude Code 업그레이드 키트

Claude Code CLI의 행동을 바꾸는 글로벌 설정 모듈 + 시스템 프롬프트 패치 + 팁 모음.

## 한줄 설치

```bash
git clone <repo-url> ~/CLA && bash ~/CLA/CLA/install.sh
```

이후 `git pull`마다 자동 반영 (git hooks).

## 이 레포가 하는 일

Claude Code CLI 자체는 바뀌지 않는다.
`$CLAUDE_CONFIG_DIR`에 파일을 넣으면 Claude가 매 세션마다 그 파일을 읽고 지시를 따른다.

| 레이어 | 설치 위치 | 효과 |
|--------|----------|------|
| CLAUDE.md | `$CLAUDE_CONFIG_DIR/CLAUDE.md` | 6개 행동 규칙 (Think, Simplicity, Surgical, Goal-driven, Safety, Context) |
| 스킬 10개 | `$CLAUDE_CONFIG_DIR/skills/*/SKILL.md` | /handoff, /half-clone, /clone, /gha, /karpathy-guidelines, /reddit-fetch, /review-claudemd, /cla-init, /ac, /ac-status |
| Stop hook | `$CLAUDE_CONFIG_DIR/settings.json` | 컨텍스트 85% 초과 시 자동 경고 + half-clone 유도 |
| 상태줄 | `$CLAUDE_CONFIG_DIR/scripts/context-bar.sh` | 모델, 브랜치, 컨텍스트 % 표시 |
| 템플릿 7개 | `$CLAUDE_CONFIG_DIR/templates/*.md` | rust, flutter, react, unity, backend-node, backend-python, auto-claude |
| 시스템 프롬프트 패치 | cli.js 직접 수정 | 63개 패치, 매 API 호출마다 ~10.7K 토큰 절감 |

## 디렉토리 구조

| 디렉토리 | 역할 | AI가 알아야 할 것 |
|----------|------|-------------------|
| `CLA/` | **핵심 모듈** - install.sh로 $CLAUDE_CONFIG_DIR에 복사 | [CLA/README.md](./CLA/README.md) 참조 |
| `AC247/` | **Auto-Claude 24/7** - 자율 개발 에이전트 모노레포 | [AC247/README.md](./AC247/README.md) 참조 |
| `claude-code-tips/` | 스킬/스크립트 원산지 + 시스템 프롬프트 패치 | 45개 팁 + system-prompt/ |
| `claude-master/` | CLA의 직접 원본 (통합본) | CLA는 여기서 cla-init 스킬 + 7개 템플릿 추가 |
| `andrej-karpathy-skills/` | Karpathy 4원칙의 근원 | Think, Simplicity, Surgical, Goal-driven |
| `docs/` | 분석 문서 | source-analysis, prompt-effectiveness, tips-ko, patches-ko |

## 자동 반영 (Auto-Sync)

```
최초: git clone → bash CLA/install.sh (1회)
이후: git pull → post-merge hook → CLA/ 변경 감지 → install.sh 자동 실행
      git checkout → post-checkout hook → CLA/ 변경 감지 → install.sh 자동 실행
```

**주의**: `git clone`만으로는 적용되지 않는다. `install.sh`를 최소 1회 실행해야 한다.
이유: Claude Code는 `$CLAUDE_CONFIG_DIR/` (기본 `~/.claude/`)에서만 글로벌 설정을 읽고,
git clone은 레포 디렉토리에 파일을 넣을 뿐 설정 디렉토리에 복사하지 않기 때문이다.

## 시스템 프롬프트 패치 (선택사항)

CLI 번들 내부의 시스템 프롬프트를 축소하여 토큰을 절약한다.
install.sh와 별개로, 수동 적용이 필요하다.

```bash
# npm 설치 필요 (Windows 네이티브 바이너리 미지원)
npm install -g @anthropic-ai/claude-code
cd claude-code-tips/system-prompt/2.1.47
node patch-cli.js  # 63/63 패치, ~10.7K 토큰 절감
```

자세한 내용: [docs/system-prompt-patches-ko.md](./docs/system-prompt-patches-ko.md)

## 동작 원리

```
claude 실행
  → $CLAUDE_CONFIG_DIR/CLAUDE.md 로드 (글로벌 규칙)
  → $CLAUDE_CONFIG_DIR/skills/*/SKILL.md description 등록
  → $CLAUDE_CONFIG_DIR/settings.json hooks 등록
  → ./CLAUDE.md 로드 (프로젝트 규칙, 있으면 누적)
  → 세션 시작
```

`$CLAUDE_CONFIG_DIR`이 미설정이면 `~/.claude/`를 사용.

## CLA ↔ AC247 연동

CLA의 `/ac` 스킬이 AC247 백엔드를 직접 호출하여 자율 빌드를 시작한다.

```
/ac "로그인 기능 구현"
  → CLA/skills/ac/SKILL.md 실행
  → AC247/Auto-Claude/apps/backend/runners/spec_runner.py 호출
  → spec 생성 (status: queue)
  → daemon이 자동 픽업 → planner → coder → QA → merge
```

**AC247 백엔드 탐색 순서** (`/ac` 스킬):
1. `$AC247_BACKEND` 환경변수
2. `../AC247/Auto-Claude/apps/backend` (이 레포 구조)
3. `~/AC247/Auto-Claude/apps/backend`

**관련 스킬**: `/ac` (태스크 생성), `/ac-status` (상태 확인), `/cla-init` (auto-claude 템플릿 감지)

## README 인덱스

| 경로 | 내용 |
|------|------|
| [README.md](./README.md) | 이 파일 (전체 개요) |
| [CLA/README.md](./CLA/README.md) | 핵심 모듈 상세 (10 스킬, 4 스크립트, 7 템플릿) |
| [AC247/README.md](./AC247/README.md) | Auto-Claude 24/7 멀티에이전트 아키텍처 |
| [AC247/PROJECT_GUIDE.md](./AC247/PROJECT_GUIDE.md) | Auto-Claude 프로젝트 완전 가이드 (v2.7.6-beta.2) |
| [AC247/Auto-Claude/README.md](./AC247/Auto-Claude/README.md) | Auto-Claude 모노레포 사용 가이드 |
| [claude-code-tips/README.md](./claude-code-tips/README.md) | 45개 팁 원본 + 시스템 프롬프트 패치 |
| [claude-master/README.md](./claude-master/README.md) | CLA upstream 원본 |
| [andrej-karpathy-skills/README.md](./andrej-karpathy-skills/README.md) | Karpathy 4원칙 원본 |
| [docs/source-analysis.md](./docs/source-analysis.md) | 3개 upstream 소스 분석 |
| [docs/prompt-effectiveness.md](./docs/prompt-effectiveness.md) | 프롬프트가 왜 효과적인지 분석 |
| [docs/system-prompt-patches-ko.md](./docs/system-prompt-patches-ko.md) | 63개 패치 상세 (카테고리별) |
| [docs/claude-code-tips-ko.md](./docs/claude-code-tips-ko.md) | 45개 팁 한국어 요약 |
| [docs/advent-of-claude-2025.md](./docs/advent-of-claude-2025.md) | 31일 가이드 (초급→고급) |
