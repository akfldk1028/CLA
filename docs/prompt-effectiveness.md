# CLA 프롬프트가 왜 효과적인가

모든 MD 파일을 분석하고, 각 프롬프트 기법이 **왜** 작동하는지 설명한다.

---

## CLAUDE.md — 글로벌 행동 규칙

### 전체 구조가 효과적인 이유

```
"Bias toward caution over speed - use judgment for trivial tasks."
```

이 한 줄이 전체 톤을 잡는다. LLM은 기본적으로 **빠르게 답하려는 편향**이 있다.
이 문장이 그 편향을 뒤집어서 "신중함 > 속도"로 기본값을 재설정한다.
단, "trivial tasks에는 판단력 사용"이라는 예외를 두어 과도한 질문 루프를 방지한다.

---

### 규칙 1: Think before coding

```
- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
```

**왜 효과적인가:**

| 기법 | 원리 |
|------|------|
| "State assumptions explicitly" | LLM은 가정을 **내부적으로** 처리하고 넘어가는 경향이 강하다. "명시하라"고 강제하면 가정이 출력에 드러나고, 사용자가 잘못된 가정을 잡을 수 있다. |
| "present them - don't pick silently" | LLM은 하나를 **확신 있게** 골라서 진행하는 게 기본이다. "조용히 선택하지 마"라는 **금지형** 지시가 이 패턴을 깨뜨린다. |
| "Push back when warranted" | LLM은 사용자 요청에 순응하는 편향(sycophancy)이 있다. 명시적으로 반론 권한을 부여하면 더 나은 솔루션을 제안한다. |
| "stop. Name what's confusing. Ask." | 3단계 행동 체인(중단→명명→질문)이 구체적이라 모호함이 없다. "불확실하면 물어보세요" 같은 일반적 지시보다 훨씬 강하다. |

**프롬프트 엔지니어링 원리**:
- **Negative instruction** ("don't pick silently") — LLM의 기본 행동을 명시적으로 금지
- **Permission granting** ("Push back") — 기본 순종 모드에서 벗어나게 함
- **Behavioral chain** ("stop → Name → Ask") — 다단계 행동을 순서대로 지시

---

### 규칙 2: Simplicity first

```
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.
```

**왜 효과적인가:**

LLM은 훈련 데이터에서 "좋은 코드 = 추상화, 패턴, 에러 핸들링"을 학습했다.
그래서 간단한 요청에도 **팩토리 패턴, 전략 패턴, 빌더 패턴**을 끼워넣는다.

이 규칙이 4개의 "No"로 시작하는 게 핵심이다:

| 패턴 | 원리 |
|------|------|
| 반복된 "No" | LLM은 반복 패턴에 강하게 반응한다. 4번 연속 "No"는 단일 금지보다 훨씬 강하다. |
| 구체적 금지 대상 | "과복잡하게 하지 마" 대신 "single-use 추상화 금지", "요청 안 한 유연성 금지" 처럼 **정확히 무엇을** 하지 말라는지 명시한다. |
| 정량적 기준 | "200줄 → 50줄" 같은 숫자가 모호함을 제거한다. "간결하게 작성하라"보다 정량 기준이 훨씬 효과적이다. |

**프롬프트 엔지니어링 원리**:
- **Specific negation** — "No X" 패턴이 일반적 지시보다 준수율 높음
- **Concrete threshold** — 숫자 기준이 주관적 판단을 대체

---

### 규칙 3: Surgical changes

```
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.
```

**왜 효과적인가:**

LLM의 가장 흔한 문제 중 하나: **요청한 것 외에 주변 코드도 "개선"해버림.**
이것이 코드 리뷰에서 diff를 복잡하게 만들고, 의도치 않은 버그를 만든다.

| 기법 | 원리 |
|------|------|
| 따옴표로 "improve" 강조 | 큰따옴표가 아이러니를 표현한다. LLM이 개선이라고 생각하는 것이 실제로는 해로울 수 있다는 인식을 심는다. |
| "even if you'd do it differently" | LLM의 선호도를 명시적으로 억제한다. "네가 다르게 하고 싶어도"라는 양보절이 규칙의 절대성을 강화한다. |
| "mention it - don't delete it" | **보고만 하고 행동하지 마라**는 패턴. LLM이 발견→즉시행동 하는 충동을 끊는다. |
| "YOUR changes" 대문자 | 강조된 대문자가 **소유권 범위**를 명확히 한다. "네가 만든 미사용 코드만 제거하라"는 책임 범위를 한정한다. |

**프롬프트 엔지니어링 원리**:
- **Scope limitation** — 행동 범위를 명확히 한정
- **Ironic framing** — 따옴표가 LLM의 "개선" 충동을 의심하게 만듦
- **Report-don't-act** — 관찰과 행동을 분리

---

### 규칙 4: Goal-driven execution

```
- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- For multi-step tasks: `1. [Step] -> verify: [check]`
```

**왜 효과적인가:**

모호한 지시 → 구체적 행동 체인으로 **변환 예시**를 보여준다.
이것이 few-shot prompting의 핵심이다.

| 기법 | 원리 |
|------|------|
| 화살표 변환 패턴 | `모호 -> 구체` 형태가 LLM에게 **변환 규칙**을 가르친다. 유사한 모호한 요청이 오면 같은 패턴으로 변환한다. |
| "then make them pass" | 테스트 실패→수정→통과 라는 TDD 루프를 한 문장에 인코딩. LLM이 검증 없이 코드만 쓰는 패턴을 방지한다. |
| `[Step] -> verify: [check]` | 메타 템플릿. LLM이 어떤 다단계 작업이든 이 형식을 적용하도록 유도한다. |

**프롬프트 엔지니어링 원리**:
- **Few-shot transformation** — 입력→출력 예시로 변환 규칙을 학습시킴
- **Verification loop** — 매 단계마다 검증 포인트를 강제

---

### 규칙 5: Safety

```
- NEVER use --dangerously-skip-permissions on the host machine. Containers only.
- For complex bash commands, break into multiple simple commands.
- Never use 2>&1 in bash commands. Keep stderr and stdout separate.
```

**왜 효과적인가:**

| 기법 | 원리 |
|------|------|
| "NEVER" 대문자 | 절대적 금지. "avoid" 나 "prefer not to" 보다 LLM 준수율이 높다. |
| "Containers only" | 금지와 동시에 대안을 제시. "하지 마"만 있으면 LLM이 우회하려 하지만, 허용 범위를 주면 그 안에서 행동한다. |
| stderr/stdout 분리 규칙 | 매우 구체적인 기술 규칙. LLM은 `2>&1`을 습관적으로 쓰는데, 이를 정확히 집어 금지한다. |

---

### 규칙 6: Context management

```
- Use /handoff to write HANDOFF.md before context runs out.
- Use /half-clone proactively when context exceeds 85%.
- Write concise summaries, not verbose explanations.
```

**왜 효과적인가:**

LLM은 컨텍스트 한계를 인식하지 못한다. 이 규칙이 **자체 도구 사용**을 지시한다.

| 기법 | 원리 |
|------|------|
| 구체적 도구명 제시 | "컨텍스트를 관리하라"가 아니라 `/handoff`, `/half-clone`이라는 정확한 도구를 지명한다. |
| 85% 숫자 기준 | 정량적 트리거 포인트. "많아지면"이 아니라 "85% 넘으면"이라는 명확한 조건. |
| "concise, not verbose" | 대비 구조(A, not B)가 원하는 행동과 원하지 않는 행동을 동시에 명시한다. |

---

## Skills — 각 스킬이 효과적인 이유

### /handoff — 구조화된 인수인계

```
Goal → Current Progress → What Worked → What Didn't Work → Next Steps
```

**왜 효과적인가:**
5개 섹션이 **정보 손실 방지 체크리스트** 역할을 한다.
특히 "What Didn't Work"가 핵심 — 다음 에이전트가 같은 실수를 반복하지 않게 한다.
대부분의 핸드오프 문서에서 빠지는 것이 "실패한 접근"인데, 이것을 구조적으로 강제한다.

### /gha — 5단계 조사 프로토콜

```
1. 실패 식별 → 2. 플래키 확인 → 3. Breaking commit → 4. 근본 원인 → 5. 기존 fix PR 확인
```

**왜 효과적인가:**
LLM에게 "GitHub Actions 분석해"라고만 하면 표면적 답변만 한다.
이 5단계가 **조사 깊이를 강제**한다:
- "THE EXACT SAME failing job" (대문자 강조) — 전체 워크플로우가 아닌 특정 job을 보게 함
- "What's the success rate" — 정량적 답변을 유도
- "Verify by checking" — 가설을 검증하도록 강제
- "skip if fix PR already exists" — 불필요한 작업을 방지

### /clone, /half-clone — 절차적 스킬

단계별 bash 명령을 정확히 지시한다. LLM이 "대화를 복제하겠습니다"라고 추상적으로 대답하는 대신 **구체적 명령 체인**을 실행하게 한다.

`--preview` 단계가 있는 이유: 잘못된 세션을 복제하는 실수 방지.
`sort -V | tail -1`이 있는 이유: 여러 버전의 스크립트가 있을 때 최신을 선택.

### /reddit-fetch — 우회 패턴

WebFetch 차단 → tmux + Gemini CLI 우회.
핵심은 **"Enter가 전송되었는지 확인하는 방법"** 섹션:

```
Enter NOT sent → 쿼리가 박스 안에 있음
Enter WAS sent → 쿼리가 박스 밖에 있음
```

이 시각적 패턴 매칭이 없으면 LLM이 Enter를 보내지 않고 대기하거나, 이미 전송된 것을 다시 보내는 실수를 한다.

### /review-claudemd — 메타 개선 루프

CLAUDE.md → 대화 → 위반 감지 → CLAUDE.md 개선 → 더 나은 대화

이 스킬이 효과적인 이유:
- **Sonnet 서브에이전트를 병렬로 사용** — 비용 절약 + 다각도 분석
- **대화 크기별 배칭** — 토큰 효율
- **4개 분석 카테고리가 정확히 정의됨** — "위반된 규칙", "로컬 추가", "글로벌 추가", "구식 항목"

### /cla-init — 자동 감지 + 조합

마커 파일 기반 자동 감지가 효과적인 이유:
- `Cargo.toml` → rust는 **100% 확실한 매핑**
- `package.json + react dep` → react는 **조합 조건**으로 오탐 방지
- 복합 타입을 지원하여 모노레포(React + Node backend)도 처리

---

## Templates — 프로젝트별 규칙이 효과적인 이유

### 공통 구조: Build & Test → Architecture → Rules

3섹션 구조가 효과적인 이유:
1. **Build & Test**: 코드블록으로 명령어를 제공 → LLM이 복사해서 실행 가능
2. **Architecture**: 디렉토리 구조를 명시 → 파일 생성 위치 혼란 방지
3. **Rules**: 프레임워크별 안티패턴을 금지 → 숙련자 수준의 코드 유도

### 각 규칙의 효과 분석

#### Rust: `.unwrap()` 금지
```
No .unwrap() or .expect() in library code. Use ? with proper error types.
```
LLM은 빠른 예시 코드에서 `.unwrap()`을 학습했기 때문에 기본적으로 사용한다.
금지 + 대안(`?` 사용)을 동시에 제시하여 "어떻게 대체하는지"까지 가르친다.

#### React: `useEffect` 의존성 배열
```
useEffect must have proper dependency arrays. No eslint-disable for exhaustive-deps.
```
두 가지를 동시에 금지: (1) 빈 의존성 배열, (2) eslint 규칙 비활성화.
LLM은 경고를 피하기 위해 `// eslint-disable-next-line`을 쓰는 경향이 있는데, 이를 정확히 차단.

#### Flutter: `setState()` 최소화
```
Minimize setState() usage. Prefer the project's state management solution.
```
"프로젝트의 기존 방식을 따르라"는 지시가 핵심. LLM이 자기 선호(Provider, Riverpod 등)를 강요하지 않게 한다.

#### Unity: `Find()` 금지
```
No Find() or FindObjectOfType() at runtime. Cache references in Awake().
```
Unity 성능의 가장 흔한 함정. LLM은 간단한 예시에서 `Find()`를 학습하기 때문에 명시적 금지가 필수.

#### Backend-Node: "route handler를 얇게"
```
Database queries go in model/repository layer only. No raw queries in route handlers.
```
아키텍처 패턴을 강제. LLM이 route handler에 SQL을 직접 쓰는 것을 방지.

#### Backend-Python: `bare except:` 금지
```
No bare except:. Catch specific exceptions.
```
Python에서 가장 흔한 안티패턴. LLM은 에러 핸들링 코드에서 `except:` 또는 `except Exception:`을 기본으로 쓰는데, 이를 차단.

---

## Stop Hook (check-context.sh) — 자동 컨텍스트 관리가 효과적인 이유

```bash
pct=$((context_length * 100 / max_context))
if [[ $pct -ge 85 ]]; then
    echo '{"decision": "block", "reason": "Context usage is at ${pct}%..."}'
fi
```

**왜 85%인가:**
- 100%: 이미 성능 저하가 시작됨 (너무 늦음)
- 70%: 아직 충분한데 불필요하게 끊김 (너무 이른 시점)
- **85%**: 약 15%의 여유로 half-clone 작업 자체를 수행할 공간이 남아있으면서, 성능 저하 전에 개입

**`{"decision": "block"}` 패턴이 효과적인 이유:**
Claude Code의 hook 시스템은 이 JSON 출력을 읽어서 Stop 동작을 차단한다.
사용자 개입 없이 **자동으로** Claude에게 half-clone을 지시한다.
사용자가 컨텍스트 관리를 잊어도 시스템이 자동으로 처리.

---

## 프롬프트 엔지니어링 원리 종합

전체 CLA 시스템에서 사용된 핵심 기법:

| 원리 | 예시 | 왜 작동하는가 |
|------|------|-------------|
| **Specific Negation** | "No .unwrap()", "Don't improve adjacent code" | 일반적 금지("좋은 코드를 써라")보다 특정 행동 금지가 준수율 높음 |
| **Concrete Thresholds** | "200줄→50줄", "85%", "300줄 초과 시 분리" | 숫자가 주관적 판단을 제거 |
| **Permission Granting** | "Push back when warranted" | 기본 순종 편향을 해제 |
| **Negative Examples** | `모호한 지시 -> 구체적 목표` 변환 | Few-shot으로 원하는 행동 패턴을 학습시킴 |
| **Behavioral Chains** | "stop → Name → Ask" | 다단계 행동을 순서대로 지시하면 빠짐 없이 실행 |
| **Scope Limitation** | "YOUR changes", "THE EXACT SAME job" | 행동 범위를 명확히 한정하여 과잉 행동 방지 |
| **Alternative Provision** | "No .unwrap() → Use ?" | 금지만 하면 LLM이 우회함. 대안을 주면 그것을 따름 |
| **Contrast Framing** | "concise, not verbose" | A not B 구조가 원하는/원하지 않는 행동을 동시에 명시 |
| **Tool Naming** | "/handoff", "/half-clone" | 추상적 지시 대신 구체적 도구명을 제시 |
| **Ironic Quoting** | '"improve"' | 따옴표가 LLM의 "좋은 의도"가 해로울 수 있음을 인식시킴 |

---

## 결론

CLA의 프롬프트가 효과적인 근본적 이유는:

**LLM의 기본 편향을 정확히 파악하고, 각 편향에 대한 구체적 교정 지시를 제공하기 때문이다.**

| LLM 기본 편향 | CLA 교정 |
|-------------|---------|
| 빠르게 답하려 함 | "Bias toward caution over speed" |
| 가정을 숨기고 진행 | "State assumptions explicitly" |
| 과도한 추상화/패턴 적용 | 4개 "No" + 정량 기준 |
| 주변 코드도 "개선" | "Touch only what you must" |
| 사용자에게 순종 | "Push back when warranted" |
| 모호하게 작업 | "Step → verify: check" 템플릿 |
| 컨텍스트 한계 무시 | 85% 자동 감지 + block hook |

이 교정들이 **글로벌 CLAUDE.md + 프로젝트 템플릿 + 스킬 + 자동 훅** 4개 레이어에 분산되어 있어,
모든 세션에서 자동으로 적용된다.
