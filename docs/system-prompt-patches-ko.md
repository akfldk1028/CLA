# 시스템 프롬프트 패치 63개: 각각의 효과 분석

원본: `claude-code-tips/system-prompt/2.1.47/patch-cli.js`
대상: Claude Code v2.1.47 (npm build)

---

## 개요

Claude Code CLI 내부에는 매 API 호출마다 전송되는 **시스템 프롬프트**가 하드코딩되어 있다.
도구 설명, 행동 규칙, 예시 등이 포함되며, 원본 크기는 약 19K 토큰이다.

이 63개 패치는 CLI 번들 내부의 시스템 프롬프트를 **의미를 보존하면서 축소**한다.

| 항목 | Before | After | 절감 |
|------|--------|-------|------|
| 시스템 프롬프트 | ~3.0K 토큰 | ~1.8K | -1,200 |
| 도구 설명 | ~15.6K 토큰 | ~7.4K | -8,200 |
| **합계** | **~19K** | **~9K** | **~10.7K (42,915 bytes)** |

**매 API 호출마다 ~10.7K 토큰을 절약**한다. 같은 200K 컨텍스트 윈도우에서 더 많은 대화를 할 수 있고, 컨텍스트 85% 도달이 늦어져 half-clone 빈도도 줄어든다.

### 왜 줄여도 되는가

Claude는 간결한 지시를 잘 따른다. 장황한 예시와 반복 설명은 사람용 문서에는 유용하지만, LLM에게는 핵심 키워드만 있으면 충분하다. 실제로 축소 후에도 행동 변화가 관찰되지 않는다.

---

## 카테고리 1: Big Wins (1KB+ 절감) — 9개

큰 예시 블록, 장황한 단계별 설명, 중복 지시를 제거하는 패치들이다.

### 1. TodoWrite examples (6KB -> 0.4KB)
- **파일**: `todowrite-examples`
- **무엇을 줄이나**: TodoWrite 도구의 사용 예시 2개(dark mode, rename refactoring)를 각각 20줄 이상에서 3-4줄로 축소. "When NOT to Use" 예시도 최소화.
- **왜 줄여도 되나**: Claude는 "multi-step task -> todo list" 패턴을 이미 이해한다. 상세한 reasoning 블록과 긴 예시는 LLM에게 불필요.
- **절감**: ~5,600 chars

### 2. Task tool Usage notes + examples (~2KB)
- **파일**: `task-usage-notes`
- **무엇을 줄이나**: Task(에이전트) 도구의 Usage notes 섹션 전체를 제거. 에이전트 설명, 백그라운드 실행 옵션, resume 파라미터 등.
- **왜 줄여도 되나**: Task 도구의 핵심은 "서브에이전트를 실행"하는 것이며, 파라미터 이름만으로 사용법이 명확하다.
- **절감**: ~2,000 chars

### 3. Git commit section (~3.4KB)
- **파일**: `git-commit`
- **무엇을 줄이나**: Git 커밋 관련 전체 섹션을 축소. Safety Protocol 7개 항목 -> 1줄 요약. 4단계 커밋 프로세스 -> 3줄. HEREDOC 예시 보존.
- **왜 줄여도 되나**: "NEVER force push", "NEVER amend others' commits" 같은 핵심 금지 규칙은 한 줄로 충분하다. 단계별 세부 지시(parallel calls, draft message)는 Claude가 이미 아는 패턴.
- **절감**: ~3,400 chars

### 4. Bash tool description (3.7KB -> 0.6KB)
- **파일**: `bash-tool`
- **무엇을 줄이나**: Bash 도구 설명에서 Directory Verification 섹션, path quoting 예시 4개, Usage notes 대부분을 제거. 핵심 규칙만 보존.
- **왜 줄여도 되나**: "Quote paths with spaces", "Use dedicated tools for file operations"만 있으면 된다. 각 전용 도구로의 매핑(Glob for find, Grep for grep 등)은 한 줄로 충분.
- **절감**: ~3,100 chars

### 5. PR creation section (~1.7KB)
- **파일**: `pr-creation`
- **무엇을 줄이나**: PR 생성 4단계 프로세스를 3줄로 축소. `gh pr create` HEREDOC 예시는 보존.
- **왜 줄여도 되나**: git status/diff/log 병렬 실행, 커밋 분석, push+create 같은 단계는 Claude가 이미 아는 워크플로우. 예시 하나면 충분.
- **절감**: ~1,700 chars

### 6. EnterPlanMode When to Use (1.2KB -> 200 chars)
- **파일**: `enterplanmode-when-to-use`
- **무엇을 줄이나**: 5개 카테고리(New Feature, Multiple Approaches, Significant Decisions, Large-scale, Unclear Requirements) 각각의 설명과 예시를 한 줄 나열로 축소.
- **왜 줄여도 되나**: "multiple valid approaches exist, architectural decisions needed" 같은 키워드만으로 Claude가 판단할 수 있다.
- **절감**: ~1,000 chars

### 7. TodoWrite states section (1.8KB -> 0.4KB)
- **파일**: `todowrite-states`
- **무엇을 줄이나**: 상태(pending/in_progress/completed) 설명, content/activeForm 필드 설명, 규칙을 압축.
- **왜 줄여도 되나**: 3개 상태와 핵심 규칙("mark complete immediately", "one in_progress at a time")만 있으면 된다.
- **절감**: ~1,400 chars

### 8. Skill tool instructions (887 -> 80 chars)
- **파일**: `skill-tool`
- **무엇을 줄이나**: Skill 도구의 호출 방법, 예시 3개, 주의사항 7개를 "Invoke skills with skill name only"로 축소.
- **왜 줄여도 되나**: Skill 도구는 `skill` 파라미터만 필수이고, 나머지는 Claude가 추론 가능.
- **절감**: ~800 chars

### 9. TodoWrite When to Use (1.2KB -> 200 chars)
- **파일**: `todowrite-when-to-use`
- **무엇을 줄이나**: 7개 사용 시나리오 목록(complex tasks, user requests, after instructions 등)을 2줄로 축소.
- **왜 줄여도 되나**: "3+ step tasks, multiple tasks, user-requested lists"가 핵심이며 나머지는 중복.
- **절감**: ~1,000 chars

---

## 카테고리 2: Medium Wins (200-1000 chars 절감) — 42개

도구 파라미터 설명, 부가 지시문, 중간 크기 예시를 축소하는 패치들이다.

### 10. Over-engineering bullets (~900 -> 200 chars)
- **파일**: `over-engineering`
- **무엇을 줄이나**: "Don't add features beyond what was asked" 관련 4개 긴 문단을 1줄로. 에러 핸들링, 헬퍼 함수, backwards-compatibility 금지 규칙 통합.
- **왜 줄여도 되나**: 핵심은 "요청 범위 밖은 하지 마". 구체적 예시(feature flags, _vars 등)는 CLAUDE.md 규칙과 중복.
- **절감**: ~700 chars

### 11. LSP tool description (~750 -> 150 chars)
- **파일**: `lsp-tool`
- **무엇을 줄이나**: LSP 도구의 상세 설명(언제 사용, 예시, 주의사항)을 한 줄 요약으로 축소.
- **왜 줄여도 되나**: LSP 도구는 파라미터 스키마에 정보가 충분하다.
- **절감**: ~600 chars

### 12. Edit tool description (~900 -> 200 chars)
- **파일**: `edit-tool`
- **무엇을 줄이나**: Edit 도구의 사용 규칙(indentation 보존, 기존 파일 선호, emoji 금지 등) 장황한 설명을 축소.
- **왜 줄여도 되나**: "Read before editing, match exact indentation, prefer editing over writing"이 핵심.
- **절감**: ~700 chars

### 13. EnterPlanMode examples (670 -> 150 chars)
- **파일**: `enterplanmode-examples`
- **무엇을 줄이나**: 계획 모드 사용 예시(user message -> plan -> steps)를 간략화.
- **왜 줄여도 되나**: Claude는 "plan before execute" 패턴을 알고 있다.
- **절감**: ~520 chars

### 14. EnterPlanMode What Happens (~400 -> 120 chars)
- **파일**: `enterplanmode-whathappens`
- **무엇을 줄이나**: 계획 모드 진입 시 일어나는 일에 대한 설명을 축소.
- **왜 줄여도 되나**: 도구 호출 시 동작은 시스템이 처리하므로 상세 설명 불필요.
- **절감**: ~280 chars

### 15. ExitPlanMode description (~1.5KB -> 200 chars)
- **파일**: `exitplanmode`
- **무엇을 줄이나**: 계획 모드 종료 도구의 전체 설명을 축소. 사용 조건, 주의사항 등.
- **왜 줄여도 되나**: "Exit plan mode when plan is complete" 한 줄이면 충분.
- **절감**: ~1,300 chars

### 16. Professional objectivity (762 -> 120 chars)
- **파일**: `professional-objectivity`
- **무엇을 줄이나**: 전문적 객관성에 대한 장황한 지시(아첨 금지, 솔직한 피드백 등)를 축소.
- **왜 줄여도 되나**: CLAUDE.md의 "Push back when warranted"와 중복.
- **절감**: ~640 chars

### 17. WebFetch usage notes (808 -> 120 chars)
- **파일**: `webfetch-usage`
- **무엇을 줄이나**: WebFetch 도구의 Usage notes(HTTP->HTTPS 업그레이드, 캐시 설명, 리다이렉트 처리 등).
- **왜 줄여도 되나**: 도구 동작은 시스템이 처리하며, Claude는 URL만 제공하면 된다.
- **절감**: ~690 chars

### 18. Specialized tools instruction (~500 -> 130 chars)
- **파일**: `specialized-tools`
- **무엇을 줄이나**: "전용 도구 사용" 지시의 상세 설명을 축소.
- **왜 줄여도 되나**: Bash 도구 설명에 이미 매핑 테이블이 있다.
- **절감**: ~370 chars

### 19. Grep tool description (~715 -> 350 chars)
- **파일**: `grep-tool`
- **무엇을 줄이나**: Grep 도구의 상세 사용법(regex 예시, 필터 옵션, 출력 모드)을 축소.
- **왜 줄여도 되나**: 파라미터 스키마에 정보가 충분. 핵심만 남기면 된다.
- **절감**: ~365 chars

### 20. TodoWrite examples v2 (~400 chars)
- **파일**: `todowrite-examples-v2`
- **무엇을 줄이나**: 1번 패치 후 남은 추가 예시를 더 축소.
- **왜 줄여도 되나**: 이미 축소된 예시에서 추가로 줄일 수 있는 부분 제거.
- **절감**: ~400 chars

### 21. Agent claude-code-guide (~500 -> 115 chars)
- **파일**: `agent-claude-code-guide`
- **무엇을 줄이나**: claude-code-guide 에이전트의 설명을 축소.
- **왜 줄여도 되나**: 에이전트 이름이 목적을 이미 설명한다.
- **절감**: ~385 chars

### 22. NotebookEdit (~510 -> 100 chars)
- **파일**: `notebookedit`
- **무엇을 줄이나**: NotebookEdit 도구의 상세 설명(Jupyter notebook이란 무엇인지, 사용 방법 등).
- **왜 줄여도 되나**: Claude는 Jupyter notebook을 이미 알고 있다. 파라미터 스키마면 충분.
- **절감**: ~410 chars

### 23. Task Management examples (~1.2KB -> 130 chars)
- **파일**: `task-management-examples`
- **무엇을 줄이나**: 태스크 관리 예시(워크플로우 시나리오, multi-agent 조율 등) 전체를 축소.
- **왜 줄여도 되나**: 태스크 도구의 핵심은 create/update/list이며, 예시 없이도 명확.
- **절감**: ~1,070 chars

### 24. Write tool description (~550 -> 100 chars)
- **파일**: `write-tool`
- **무엇을 줄이나**: Write 도구의 사용 규칙(기존 파일 읽기 선행, README 금지, emoji 금지).
- **왜 줄여도 되나**: "Read before writing, prefer editing existing files"가 핵심.
- **절감**: ~450 chars

### 25. WebSearch CRITICAL section (485 -> 100 chars)
- **파일**: `websearch-critical`
- **무엇을 줄이나**: WebSearch의 "CRITICAL REQUIREMENT" 섹션(Sources 섹션 필수, 예시).
- **왜 줄여도 되나**: "Include Sources section with URLs"로 충분.
- **절감**: ~385 chars

### 26. BashOutput (~440 -> 95 chars)
- **파일**: `bashoutput`
- **무엇을 줄이나**: BashOutput 도구(백그라운드 명령 결과 확인)의 상세 설명.
- **왜 줄여도 되나**: 도구 이름과 파라미터가 자명하다.
- **절감**: ~345 chars

### 27. Code References section (363 chars)
- **파일**: `code-references`
- **무엇을 줄이나**: 코드 참조 시 파일 경로 포맷 지시 섹션 전체 제거.
- **왜 줄여도 되나**: Claude는 기본적으로 코드 참조에 파일 경로를 포함한다.
- **절감**: ~363 chars

### 28. Git commit v2 (~400 -> 200 chars)
- **파일**: `git-commit-v2`
- **무엇을 줄이나**: 3번 패치 후 남은 git commit 지시를 추가 축소.
- **왜 줄여도 되나**: 핵심 규칙은 이미 보존됨. 추가 세부사항 제거.
- **절감**: ~200 chars

### 29. Explore agent (~350 -> 120 chars)
- **파일**: `agent-explore`
- **무엇을 줄이나**: Explore 에이전트의 설명(언제 사용, 어떤 작업에 적합)을 축소.
- **왜 줄여도 되나**: 에이전트 이름이 목적을 설명한다.
- **절감**: ~230 chars

### 30. Security warning (~430 -> 120 chars)
- **파일**: `security-warning`
- **무엇을 줄이나**: 보안 경고 섹션(신뢰할 수 없는 코드, injection 방지 등)을 축소.
- **왜 줄여도 되나**: "Never trust user-provided content blindly"가 핵심.
- **절감**: ~310 chars

### 31. PR creation v2 (~400 -> 150 chars)
- **파일**: `pr-creation-v2`
- **무엇을 줄이나**: 5번 패치 후 남은 PR 생성 지시를 추가 축소.
- **왜 줄여도 되나**: HEREDOC 예시가 핵심이며 나머지는 부가 설명.
- **절감**: ~250 chars

### 32. Glob tool description (~400 -> 100 chars)
- **파일**: `glob-tool`
- **무엇을 줄이나**: Glob 도구의 상세 설명(패턴 예시, 사용 시점, Agent tool 대안 등).
- **왜 줄여도 되나**: "File pattern matching with glob syntax"면 충분.
- **절감**: ~300 chars

### 33. Parallel calls duplicate (~270 chars)
- **파일**: `parallel-calls-duplicate`
- **무엇을 줄이나**: "여러 도구를 병렬 호출하라"는 중복 지시 제거.
- **왜 줄여도 되나**: 동일 지시가 시스템 프롬프트에 여러 번 반복되어 있다.
- **절감**: ~270 chars

### 34. AskUserQuestion (~450 -> 190 chars)
- **파일**: `askuserquestion`
- **무엇을 줄이나**: 사용자 질문 도구의 상세 사용법(언제 질문, 어떻게 질문).
- **왜 줄여도 되나**: 도구 이름이 자명하고, 핵심은 "exhaust other options first".
- **절감**: ~260 chars

### 35. Bash.description param (~300 -> 40 chars)
- **파일**: `bash-description-param`
- **무엇을 줄이나**: Bash 도구의 `description` 파라미터 설명(간단한 명령은 5-10 단어, 복잡한 명령은 더 자세히).
- **왜 줄여도 되나**: "Brief description of the command"면 충분.
- **절감**: ~260 chars

### 36. Hooks instruction (~380 -> 110 chars)
- **파일**: `hooks-instruction`
- **무엇을 줄이나**: 훅 시스템에 대한 설명(pre/post 훅, 실행 조건 등).
- **왜 줄여도 되나**: 훅은 시스템이 자동 실행하므로 Claude에게 상세 설명이 불필요.
- **절감**: ~270 chars

### 37. Grep -A/-B/-C context params (~300 -> 100 chars)
- **파일**: `grep-params-context`
- **무엇을 줄이나**: Grep의 전후 컨텍스트 파라미터(-A, -B, -C) 설명.
- **왜 줄여도 되나**: 파라미터 이름이 ripgrep 표준이라 Claude가 이미 안다.
- **절감**: ~200 chars

### 38. KillShell (~260 -> 35 chars)
- **파일**: `killshell`
- **무엇을 줄이나**: KillShell 도구의 상세 설명(프로세스 종료, 언제 사용).
- **왜 줄여도 되나**: "Kill a running shell session"이면 충분.
- **절감**: ~225 chars

### 39. Tool usage policy examples (~400 chars)
- **파일**: `tool-usage-examples`
- **무엇을 줄이나**: 도구 사용 정책의 예시(good/bad 패턴)를 제거.
- **왜 줄여도 되나**: 정책 자체는 보존하며, 예시는 불필요한 중복.
- **절감**: ~400 chars

### 40. Planning timelines (~290 -> 50 chars)
- **파일**: `planning-timelines`
- **무엇을 줄이나**: 계획 수립 시 타임라인 관련 지시.
- **왜 줄여도 되나**: 핵심 키워드만 있으면 Claude가 적절히 계획한다.
- **절감**: ~240 chars

### 41. Glob.path param (~255 -> 65 chars)
- **파일**: `glob-path-param`
- **무엇을 줄이나**: Glob의 path 파라미터 설명(기본 디렉토리, undefined/null 금지 등).
- **왜 줄여도 되나**: "Directory to search in. Defaults to cwd."면 충분.
- **절감**: ~190 chars

### 42. Task tool intro (4.1KB -> 0.6KB)
- **파일**: `task-tool-intro`
- **무엇을 줄이나**: Task 도구의 도입부 전체(에이전트란 무엇인지, 사용 시나리오 5개, 세부 설명).
- **왜 줄여도 되나**: "Launch sub-agents for parallel/independent work"가 핵심.
- **절감**: ~3,500 chars

### 43. Task tool when-not-to-use
- **파일**: `task-tool-whennot`
- **무엇을 줄이나**: Task 도구를 사용하지 말아야 할 때의 상세 설명.
- **왜 줄여도 되나**: "When to use" 조건의 역이 자명하다.
- **절감**: ~300 chars

### 44. Grep output_mode param (227 -> 70 chars)
- **파일**: `grep-params-output_mode`
- **무엇을 줄이나**: Grep의 output_mode 파라미터 설명(content, files_with_matches, count 각각의 동작).
- **왜 줄여도 되나**: 파라미터 enum 값이 자명하다.
- **절감**: ~157 chars

### 45. Grep head_limit param (232 -> 30 chars)
- **파일**: `grep-params-head_limit`
- **무엇을 줄이나**: Grep의 head_limit 파라미터 설명(각 모드별 동작, 기본값 등).
- **왜 줄여도 되나**: "Limit output to first N results"면 충분.
- **절감**: ~202 chars

### 46. Doing tasks intro (~230 -> 30 chars)
- **파일**: `doing-tasks-intro`
- **무엇을 줄이나**: "작업 수행" 섹션의 도입 문단.
- **왜 줄여도 되나**: 실제 지시가 아닌 서문.
- **절감**: ~200 chars

### 47. CLI format instruction (~230 -> 35 chars)
- **파일**: `cli-format-instruction`
- **무엇을 줄이나**: CLI 출력 포맷 관련 지시(마크다운 사용법 등).
- **왜 줄여도 되나**: Claude는 기본적으로 적절한 포맷을 사용한다.
- **절감**: ~195 chars

### 48. Read tool intro (292 -> 110 chars)
- **파일**: `read-tool`
- **무엇을 줄이나**: Read 도구의 도입부(파일 시스템 읽기, 접근 가능 범위 등).
- **왜 줄여도 되나**: "Read files from filesystem"이 핵심.
- **절감**: ~182 chars

### 49. Read capabilities (400 -> 80 chars)
- **파일**: `read-capabilities`
- **무엇을 줄이나**: Read 도구의 기능 목록(이미지, PDF, Jupyter notebook 지원 등).
- **왜 줄여도 되나**: 파일 확장자로 기능을 추론 가능.
- **절감**: ~320 chars

### 50. System-reminder instruction (~280 -> 90 chars)
- **파일**: `system-reminder-instruction`
- **무엇을 줄이나**: system-reminder 처리 방법에 대한 장황한 설명.
- **왜 줄여도 되나**: Claude는 system-reminder를 기본적으로 처리할 수 있다.
- **절감**: ~190 chars

### 51. Output text instruction (~230 -> 60 chars)
- **파일**: `output-text-instruction`
- **무엇을 줄이나**: 텍스트 출력 방식에 대한 지시.
- **왜 줄여도 되나**: 기본 출력 규칙은 간단히 표현 가능.
- **절감**: ~170 chars

---

## 카테고리 3: Small Wins (<200 chars 절감) — 12개

파라미터 설명, 짧은 지시문 등을 축소하는 패치들이다. 개별로는 작지만 합치면 의미있다.

### 52. General-purpose agent (~280 -> 100 chars)
- **파일**: `agent-general-purpose`
- **무엇을 줄이나**: 범용 에이전트의 설명을 축소.
- **절감**: ~180 chars

### 53. Explore instruction (~275 -> 105 chars)
- **파일**: `explore-instruction`
- **무엇을 줄이나**: 탐색 행동 관련 지시를 축소.
- **절감**: ~170 chars

### 54. Propose changes (~175 -> 30 chars)
- **파일**: `propose-changes`
- **무엇을 줄이나**: 변경 제안 방식에 대한 지시.
- **절감**: ~145 chars

### 55. URL warning (~220 -> 70 chars)
- **파일**: `url-warning`
- **무엇을 줄이나**: URL 처리 시 경고 메시지.
- **절감**: ~150 chars

### 56. Security vulnerabilities (~200 -> 60 chars)
- **파일**: `security-vulnerabilities`
- **무엇을 줄이나**: 보안 취약점 관련 지시.
- **절감**: ~140 chars

### 57. Plan agent (~210 -> 85 chars)
- **파일**: `agent-plan`
- **무엇을 줄이나**: Plan 에이전트의 설명을 축소.
- **절감**: ~125 chars

### 58. Read offset/limit line (~165 -> 50 chars)
- **파일**: `read-tool-offset`
- **무엇을 줄이나**: Read 도구의 offset/limit 파라미터 설명.
- **절감**: ~115 chars

### 59. Grep offset param (135 -> 35 chars)
- **파일**: `grep-params-offset`
- **무엇을 줄이나**: Grep의 offset 파라미터 설명.
- **절감**: ~100 chars

### 60. Grep type param (114 -> 30 chars)
- **파일**: `grep-params-type`
- **무엇을 줄이나**: Grep의 type 파라미터 설명(js, py, rust 등).
- **절감**: ~84 chars

### 61. Todos mark complete (~150 -> 45 chars)
- **파일**: `todos-mark-complete`
- **무엇을 줄이나**: 할일 완료 표시 관련 지시.
- **절감**: ~105 chars

### 62. TaskUpdate description (~1.8KB -> 150 chars)
- **파일**: `taskupdate`
- **무엇을 줄이나**: TaskUpdate 도구의 전체 설명(사용 시점, 규칙, 상태 전환 등)을 한 줄로 축소.
- **왜 줄여도 되나**: "Update task status/details"와 핵심 규칙만 있으면 된다.
- **절감**: ~1,650 chars

### 63. TaskList description (~1.2KB -> 90 chars)
- **파일**: `tasklist`
- **무엇을 줄이나**: TaskList 도구의 전체 설명(사용 시점, 작업 순서 등)을 한 줄로 축소.
- **왜 줄여도 되나**: "List all tasks"와 출력 필드 목록이면 충분.
- **절감**: ~1,110 chars

---

## 요약 테이블

| 카테고리 | 패치 수 | 총 절감 (추정) |
|---------|--------|---------------|
| Big Wins (1KB+) | 9 | ~20,500 chars |
| Medium Wins (200-1000) | 42 | ~18,000 chars |
| Small Wins (<200) | 12 | ~4,400 chars |
| **합계** | **63** | **~42,915 bytes (~10.7K 토큰)** |

### 비용 효과

| 항목 | 수치 |
|------|------|
| 매 API 호출당 절감 | ~10.7K 토큰 (입력) |
| 일반 대화 (50회 호출) | ~535K 토큰 절감 |
| 월간 (일 10회 대화) | ~160M 토큰 절감 |
| 컨텍스트 200K 대비 | ~5% 추가 공간 확보 |

---

## 적용 방법

```bash
# 1. Claude Code 버전 확인 (2.1.47이어야 함)
claude --version

# 2. 백업 생성
bash backup-cli.sh

# 3. 패치 적용
node patch-cli.js

# 4. 확인: 63/63 패치, ~42,915 bytes 절감 출력
```

복원:
```bash
bash restore-cli.sh
```

### 주의사항

- **버전 고정**: 이 패치는 v2.1.47 전용이다. Claude Code 업데이트 시 패치 재작성 필요.
- **백업 필수**: `patch-cli.js`는 항상 backup에서 복원 후 패치를 적용하므로 idempotent하다.
- **Hash 검증**: backup의 SHA256 해시를 확인하여 올바른 버전인지 검증한다.
- **Native 빌드 지원 (예정)**: Bun 컴파일 바이너리의 Unicode escape 차이도 자동 처리한다. (해시 미등록, npm 빌드만 검증 완료)
- **Bisect 모드**: `node patch-cli.js --max=30`으로 일부 패치만 적용하여 문제 추적 가능.
