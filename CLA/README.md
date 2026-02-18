# CLA - Claude Code Universal Config Module

Claude Code CLI에서 `claude`를 실행할 때 자동으로 로드되는 글로벌 설정 모듈.
프로젝트 종류(Rust, Flutter, React 등)와 무관하게 일관된 품질 규칙, 스킬, 유틸리티를 제공한다.

## 설치

```bash
git clone <repo-url> ~/CLA && bash ~/CLA/CLA/install.sh
```

이후 새 Claude Code 세션을 시작하면 자동 적용.

## 동작 원리

Claude Code가 시작되면 아래 순서로 설정을 읽는다:

```
1. $CLAUDE_CONFIG_DIR/CLAUDE.md        ← 글로벌 행동 규칙 (항상 로드)
2. $CLAUDE_CONFIG_DIR/skills/*/SKILL.md ← 스킬 description만 컨텍스트에 등록
3. $CLAUDE_CONFIG_DIR/settings.json     ← hooks, 권한 등
4. ./CLAUDE.md (프로젝트 루트)          ← 프로젝트별 규칙 (있으면 추가 로드)
```

**핵심**: `$CLAUDE_CONFIG_DIR` 환경변수가 설정되면 `~/.claude` 대신 그 경로를 사용한다.
미설정 시 기본값은 `~/.claude/`.

### 설정 누적 방식

Claude Code는 설정을 **덮어쓰지 않고 누적**한다:

```
글로벌 CLAUDE.md (CLA가 설치한 것)
    + 프로젝트 CLAUDE.md (/cla-init으로 생성한 것)
    + .claude/rules/*.md (있으면)
    = Claude가 보는 전체 규칙
```

프로젝트별 CLAUDE.md를 만들면 글로벌 규칙 위에 **추가**되는 것이지, 대체하는 게 아니다.

### 스킬 로딩 방식

스킬은 2단계로 로드된다:

1. **세션 시작**: SKILL.md의 YAML frontmatter(`name`, `description`)만 읽어서 Claude 컨텍스트에 등록.
   Claude는 "이런 스킬이 있다"는 것만 앎. 본문은 아직 안 읽음.
2. **호출 시**: 사용자가 `/skill-name`을 입력하면 그때 SKILL.md 전체 본문을 로드.
   Claude가 본문의 지시대로 실행.

따라서 스킬이 8개여도 상시 컨텍스트 소비는 description 텍스트 정도(~수백 토큰).

### hooks 동작 방식

`settings.json`의 `hooks.Stop` 배열에 등록된 명령은 Claude가 대화를 끝내려 할 때마다 실행된다.

```
Claude가 Stop 하려 함
    → check-context.sh 실행
    → transcript에서 현재 토큰 사용량 계산
    → 85% 이상이면 {"decision": "block"} 출력 → Claude에게 /half-clone 지시
    → 85% 미만이면 아무 출력 없음 → 정상 종료
```

## 디렉토리 구조

```
CLA/
├── README.md                         ← 이 파일
├── install.sh                        ← 설치 스크립트
├── CLAUDE.md                         ← 글로벌 행동 규칙 (6개 섹션)
├── skills/                           ← 글로벌 스킬 (8개)
│   ├── handoff/SKILL.md              ← /handoff: HANDOFF.md 작성
│   ├── half-clone/SKILL.md           ← /half-clone: 대화 후반부만 복제
│   ├── clone/SKILL.md                ← /clone: 대화 전체 복제
│   ├── gha/SKILL.md                  ← /gha <url>: GitHub Actions 실패 분석
│   ├── karpathy-guidelines/SKILL.md  ← /karpathy-guidelines: LLM 코딩 실수 방지
│   ├── reddit-fetch/SKILL.md         ← /reddit-fetch: Gemini로 Reddit 접근
│   ├── review-claudemd/SKILL.md      ← /review-claudemd: CLAUDE.md 개선안 도출
│   └── cla-init/SKILL.md             ← /cla-init <type>: 프로젝트 CLAUDE.md 생성
├── scripts/                          ← 유틸리티 스크립트 (4개)
│   ├── context-bar.sh                ← 상태바: 모델, 브랜치, 컨텍스트 % 표시
│   ├── check-context.sh              ← Stop hook: 85% 초과 시 half-clone 유도
│   ├── clone-conversation.sh         ← 대화 복제 엔진
│   └── half-clone-conversation.sh    ← 대화 후반부 복제 엔진
└── templates/                        ← 프로젝트 타입별 CLAUDE.md 템플릿 (6개)
    ├── rust.md                       ← cargo build/test/clippy, unwrap 금지
    ├── flutter.md                    ← flutter analyze/test, 위젯 분리
    ├── react.md                      ← npm build/test/lint, hooks 규칙
    ├── unity.md                      ← Unity CLI 빌드, Update 최적화
    ├── backend-node.md               ← npm start/test, async 에러 핸들링
    └── backend-python.md             ← pytest/ruff, type hints, FastAPI/Django
```

## install.sh가 하는 일

```
CLA/                          install.sh 실행           $CLAUDE_CONFIG_DIR/
├── CLAUDE.md          ─── diff -q로 비교 후 복사 ──→  ├── CLAUDE.md
├── skills/8개         ─── 변경분만 복사 ───────────→  ├── skills/8개
├── scripts/4개        ─── 변경분만 복사 + chmod +x ─→ ├── scripts/4개
├── templates/6개      ─── 변경분만 복사 ───────────→  ├── templates/6개
└── (settings.json)    ─── Stop hook만 additive 추가 → └── settings.json
```

- **멱등성**: `diff -q`로 비교해서 동일한 파일은 건너뜀. 몇 번 실행해도 안전.
- **additive**: settings.json의 기존 hooks를 보존하고, check-context.sh hook만 추가.
- **백슬래시 정규화**: Windows 경로(`D:\...`)를 forward slash로 변환해서 bash 호환.

## 사용법

### 새 프로젝트에서 CLAUDE.md 만들기

```
/cla-init                       # 자동 감지 (Cargo.toml, package.json 등 분석)
/cla-init rust                  # 수동 지정 (단일 타입)
/cla-init react backend-node    # 복합 타입 조합
```

**자동 감지 규칙:**

| 마커 파일 | 감지 타입 |
|-----------|-----------|
| `Cargo.toml` | rust |
| `pubspec.yaml` | flutter |
| `package.json` + react dep | react |
| `*.sln` 또는 `Assets/Scripts/` | unity |
| `package.json` + express/fastify/koa/nest | backend-node |
| `requirements.txt`/`pyproject.toml` + fastapi/django/flask | backend-python |

복합 프로젝트(React + Node 백엔드 등)는 여러 타입이 동시에 감지되어 하나의 CLAUDE.md로 합쳐진다.
기존 CLAUDE.md가 있으면 덮어쓰기/추가/취소 선택.

### 컨텍스트 관리

| 상황 | 액션 |
|------|------|
| 컨텍스트 85% 초과 | 자동으로 `/half-clone` 제안 (Stop hook) |
| 수동으로 줄이고 싶을 때 | `/half-clone` 실행 |
| 대화 분기하고 싶을 때 | `/clone` 실행 |
| 세션 넘겨줄 때 | `/handoff` → HANDOFF.md 생성 |

### 템플릿 추가

`CLA/templates/`에 `<이름>.md` 파일을 만들고 `install.sh`의 `TEMPLATES` 배열에 추가하면 됨.
`/cla-init <이름>`으로 사용 가능.

## 환경 변수

| 변수 | 용도 | 기본값 |
|------|------|--------|
| `CLAUDE_CONFIG_DIR` | Claude Code 설정 디렉토리 위치 | `~/.claude` |

`install.sh`와 모든 스크립트/스킬이 이 변수를 참조한다. 미설정 시 `~/.claude` fallback.
