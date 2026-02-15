# Advent of Claude 2025 - Claude Code 31일 완전 가이드

> 출처: https://adocomplete.com/advent-of-claude-2025/
> 작성자: Ado Kukic
> 정리일: 2026-02-15

---

## 목차

1. [시작하기](#1-시작하기)
2. [필수 단축키](#2-필수-단축키)
3. [세션 관리](#3-세션-관리)
4. [생산성 기능](#4-생산성-기능)
5. [사고 & 계획 모드](#5-사고--계획-모드)
6. [권한 & 안전](#6-권한--안전)
7. [자동화 & CI/CD](#7-자동화--cicd)
8. [브라우저 연동](#8-브라우저-연동)
9. [고급: 에이전트 & 확장성](#9-고급-에이전트--확장성)
10. [빠른 참조표](#10-빠른-참조표)

---

## 1. 시작하기

### `/init` 명령어

Claude가 코드베이스를 읽고 `CLAUDE.md` 파일을 자동 생성한다.

포함 내용:
- 빌드 명령어
- 주요 디렉터리
- 코드 컨벤션
- 아키텍처 결정 사항

**대규모 프로젝트의 경우:**
`.claude/rules/` 디렉터리에 모듈화된 주제별 규칙 파일 생성 가능.
YAML frontmatter로 파일 경로 기반 조건부 적용 가능.

### 메모리 업데이트

`CLAUDE.md`를 수동 편집하지 않아도 된다:
```
"Update Claude.md: 이 프로젝트에서 항상 bun을 npm 대신 사용해"
```

### `@` 멘션 (컨텍스트 추가)

| 문법 | 용도 |
|------|------|
| `@src/auth.ts` | 특정 파일 추가 |
| `@src/components/` | 디렉터리 참조 |
| `@mcp:github` | MCP 서버 활성화/비활성화 |

- Git 저장소에서 **퍼지 매칭** 지원, 약 3배 빠름

---

## 2. 필수 단축키

### `!` 접두사 (즉시 Bash 실행)

토큰 처리 없이 바로 실행:
```
! git status
! npm test
! ls -la src/
```

### 핵심 네비게이션

| 단축키 | 동작 |
|--------|------|
| `Esc Esc` (더블) | 되감기 - 대화와 코드 변경을 깨끗한 체크포인트로 되돌림 (bash 명령은 제외) |
| `Ctrl+R` | 이전 프롬프트 역방향 검색 (순환 + 편집 가능) |
| `Ctrl+S` | 프롬프트 임시저장 (stash), 준비되면 자동 복원 |
| `Tab` / `Enter` | 프롬프트 제안 수락 (편집 또는 즉시 실행) |

---

## 3. 세션 관리

### 세션 이어가기

```bash
claude --continue          # 마지막 대화 즉시 재개
claude --resume            # 과거 세션 목록에서 선택
```

- `cleanupPeriodDays` 설정으로 보존 기간 조절 (기본 30일, 0으로 설정 가능)

### 이름 붙인 세션

```bash
/rename api-migration              # 현재 세션에 이름 부여
/resume api-migration              # 이름으로 세션 재개
claude --resume api-migration      # 커맨드라인에서도 작동
```

### Claude Code Remote (텔레포트)

웹에서 시작, 터미널에서 마무리:
```bash
# 1. claude.ai/code 에서 세션 시작
# 2. 나중에 터미널에서:
claude --teleport session_abc123
```
- Claude 모바일 앱, 데스크탑 앱에서도 사용 가능

### `/export`

전체 대화를 마크다운으로 덤프 (프롬프트, 응답, 도구 호출 출력 포함)

---

## 4. 생산성 기능

### Vim 모드

`/vim` 입력으로 활성화:

| 키 | 동작 |
|----|------|
| `h j k l` | 방향 이동 |
| `ciw` | 단어 변경 |
| `dd` | 줄 삭제 |
| `w b` | 단어 단위 점프 |
| `A` | 줄 끝에 추가 |
| `/vim` | 다시 입력하면 비활성화 |

### `/statusline`

상태 바 커스터마이징:
- Git 브랜치
- 현재 모델
- 토큰 사용량
- 컨텍스트 윈도우 비율
- 커스텀 스크립트

### `/context`

토큰 소비 X-Ray 뷰:
- 시스템 프롬프트 크기
- MCP 서버 프롬프트
- 메모리 파일 (CLAUDE.md)
- 로드된 스킬 & 에이전트
- 대화 히스토리

### `/stats` & `/usage`

- `/stats` - 사용 패턴, 즐겨쓰는 모델, 연속 사용 기록
- `/usage` - 현재 사용량 시각 프로그레스 바
- `/extra-usage` - 추가 용량 구매

---

## 5. 사고 & 계획 모드

### Ultrathink (확장 사고)

```
ultrathink: API용 캐싱 레이어를 설계해줘
```

- 내부 추론에 최대 **32k 토큰** 할당
- `MAX_THINKING_TOKENS` 미설정 시 `ultrathink` 키워드로 트리거
- `MAX_THINKING_TOKENS` 설정 시 해당 값이 우선

### Plan Mode (계획 모드)

**`Shift+Tab` 두 번** 눌러서 진입

Plan 모드에서 Claude가 할 수 있는 것:
- 코드베이스 읽기
- 아키텍처 분석
- 의존성 탐색
- 계획 초안 작성

**승인 전까지 코드 편집 없음.** 최신 버전에서는 계획 거부 시 피드백 제공 가능.

### Extended Thinking (API 사용 시)

```json
{
  "thinking": {
    "type": "enabled",
    "budget_tokens": 5000
  }
}
```

---

## 6. 권한 & 안전

### Sandbox 모드

```
/sandbox
```

한 번 경계를 정의하면, Claude가 그 안에서 자유롭게 작업.
- 와일드카드 문법 지원: `mcp__server__*` (전체 MCP 서버)

### YOLO 모드

```bash
claude --dangerously-skip-permissions
```

모든 것에 자동 승인. **격리된 환경 또는 신뢰할 수 있는 작업에만 사용.**

### Hooks (생명주기 훅)

실행 시점별 셸 명령어:

| 훅 | 시점 |
|----|------|
| `PreToolUse` | 도구 사용 전 |
| `PostToolUse` | 도구 사용 후 |
| `PermissionRequest` | 권한 요청 시 |
| `Notification` | 알림 발생 시 |
| `SubagentStart` | 서브에이전트 시작 |
| `SubagentStop` | 서브에이전트 종료 |

설정: `/hooks` 또는 `.claude/settings.json`

> "확률적 AI에 대한 결정론적 제어를 제공"

---

## 7. 자동화 & CI/CD

### Headless 모드 (`-p` 플래그)

비대화형 CLI 사용:

```bash
claude -p "린트 에러 수정해"
claude -p "모든 함수 나열" | grep "async"
git diff | claude -p "변경 사항 설명해"
echo "PR 리뷰" | claude -p --json
```

`-p` 플래그는 stdout으로 직접 출력.

### Commands (재사용 명령어)

마크다운 파일로 저장된 재사용 프롬프트:

```
/daily-standup          # 아침 루틴 프롬프트
/explain $ARGUMENTS     # /explain src/auth.ts
```

---

## 8. 브라우저 연동

### Claude Code + Chrome

Chrome과 직접 상호작용:
- 페이지 이동
- 버튼 클릭 & 폼 작성
- 콘솔 에러 읽기
- DOM 검사
- 스크린샷 촬영

**설치:** claude.ai/chrome 에서 Chrome 확장 프로그램

---

## 9. 고급: 에이전트 & 확장성

### Subagents (서브에이전트)

- 각각 **독립된 200k 컨텍스트 윈도우**
- 특수 작업 수행
- **병렬 실행** 가능
- 결과를 메인 에이전트에 병합
- 모든 MCP 도구 접근 가능

### Agent Skills

폴더 형태의 지시사항, 스크립트, 리소스 묶음.
호환 도구 전반에서 사용 가능한 **오픈 표준**.

### Plugins

명령어, 에이전트, 스킬, 훅, MCP 서버를 번들로 묶음:
```
/plugin install my-setup
```
마켓플레이스에서 검색 필터링으로 발견 가능.

### LSP (Language Server Protocol) 통합

- 즉각적인 진단
- 코드 네비게이션 (정의로 이동, 참조 찾기)
- 호버 정보
- 타입 정보 & 문서

### Claude Agent SDK

```javascript
import { query } from '@anthropic-ai/claude-agent-sdk';

for await (const msg of query({
  prompt: "마크다운 API 문서 생성",
  options: {
    allowedTools: ["Read", "Write", "Glob"],
    permissionMode: "acceptEdits"
  }
})) {
  if (msg.type === 'result') console.log(msg.result);
}
```

---

## 10. 빠른 참조표

### 키보드 단축키

| 단축키 | 동작 |
|--------|------|
| `!command` | Bash 즉시 실행 |
| `Esc Esc` | 되감기 |
| `Ctrl+R` | 역방향 검색 |
| `Ctrl+S` | 프롬프트 임시저장 |
| `Shift+Tab` x2 | Plan 모드 토글 |
| `Alt/Option+P` | 모델 전환 |
| `Ctrl+O` | Verbose 모드 토글 |

### 필수 명령어

| 명령어 | 용도 |
|--------|------|
| `/init` | CLAUDE.md 생성 |
| `/context` | 토큰 소비 확인 |
| `/stats` | 사용 통계 |
| `/vim` | Vim 모드 활성화 |
| `/hooks` | 생명주기 훅 설정 |
| `/sandbox` | 권한 경계 설정 |
| `/export` | 대화 마크다운 내보내기 |
| `/rename` | 세션 이름 부여 |
| `/resume` | 세션 재개 |

### CLI 플래그

| 플래그 | 용도 |
|--------|------|
| `-p "prompt"` | Headless/print 모드 |
| `--continue` | 마지막 세션 재개 |
| `--resume` | 세션 선택 |
| `--teleport id` | 웹 세션 재개 |
| `--dangerously-skip-permissions` | YOLO 모드 |

---

## 핵심 철학

> "Claude Code에서 가장 많은 것을 얻는 개발자는 '모든 걸 해줘'라고 타이핑하는 사람이 아니다.
> Plan 모드를 언제 쓰는지, 프롬프트를 어떻게 구조화하는지, ultrathink를 언제 호출하는지를 배운 사람이다."
