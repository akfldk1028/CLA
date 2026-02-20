# 프로젝트: 30_CLA - Claude Code 업그레이드 키트

이 레포는 Claude Code CLI의 행동을 개선하는 글로벌 설정 모듈이다.
CLI 자체를 수정하지 않고, `$CLAUDE_CONFIG_DIR`에 파일을 넣어 매 세션마다 자동 로드되게 한다.

## 레포 구조 (AI가 빠르게 파악할 것)

| 디렉토리 | 역할 | 수정 시 주의사항 |
|----------|------|-----------------|
| `CLA/` | **핵심 모듈** - install.sh로 `$CLAUDE_CONFIG_DIR`에 복사됨 | install.sh의 배열(SKILLS, SCRIPTS, TEMPLATES)에도 반영 필요 |
| `CLA/skills/` | 10개 스킬 (SKILL.md) | YAML frontmatter 형식 유지 |
| `CLA/scripts/` | 4개 스크립트 (context-bar, check-context, clone, half-clone) | bash 3.2+ 호환, jq 의존 |
| `CLA/hooks/` | git hooks (post-merge, post-checkout) | 기존 사용자 hook 보호 로직 있음 |
| `CLA/templates/` | 7개 프로젝트 타입 CLAUDE.md 템플릿 | /cla-init이 자동 감지에 사용 |
| `claude-code-tips/` | 원산지 레포 (upstream) | 직접 수정 자제, CLA/에 반영 |
| `claude-code-tips/system-prompt/2.1.47/` | 시스템 프롬프트 패치 (63개) | 버전별 폴더, UPGRADING.md 참조 |
| `claude-master/` | CLA의 원본 (upstream) | 직접 수정 자제, CLA/에 반영 |
| `andrej-karpathy-skills/` | Karpathy 4원칙 원본 | 참고용, 수정 불필요 |
| `docs/` | 한국어 분석 문서 | source-analysis, prompt-effectiveness, tips-ko, patches-ko |

## 현재 상태 (2025-02-19)

### 완료된 작업

1. **CLA 모듈 완성**: 10 스킬, 4 스크립트, 7 템플릿, Stop hook, git hooks, 상태바
2. **시스템 프롬프트 패치 v2.1.47**: 63/63 패치 적용, 42,915 bytes (~10.7K 토큰) 절감
3. **문서 4개 작성**: source-analysis, prompt-effectiveness, tips-ko, patches-ko
4. **코드 리뷰 완료 + 13개 버그 수정**:

| # | 파일 | 수정 내용 | 심각도 |
|---|------|----------|--------|
| 1 | `backup-cli.sh` | 버전/해시 2.1.42→2.1.47 업데이트 | Critical |
| 2 | `install.sh` | jq `--argjson`→`--arg` (경로 공백 안전) | Critical |
| 3 | `check-context.sh` | jq 미설치 시 block+에러 메시지 (무음 실패 방지) | Critical |
| 4 | `clone-conversation.sh` | project_path JSON 이스케이프 (인젝션 방지) | Major |
| 5 | `half-clone-conversation.sh` | 동일 JSON 이스케이프 | Major |
| 6 | `hooks/post-merge` | REPO_ROOT 빈값 검증 + CLA/ 존재 확인 | Major |
| 7 | `hooks/post-checkout` | 동일 REPO_ROOT 검증 | Major |
| 8 | `install.sh` | 기존 non-CLA hook 덮어쓰기 방지 | Major |
| 9 | `context-bar.sh` | stat 호환성 (MSYS용 `date -r` fallback) | Major |
| 10 | `check-context.sh` | context_length/max_context 숫자 검증 | Major |
| 11 | `context-bar.sh` | context_length 숫자 검증 | Major |
| 12 | `source-analysis.md` | "미적용"→"수동 적용", 구조 비교 정정 | Doc |
| 13 | `prompt-effectiveness.md` | "너무 이름"→"너무 이른 시점" 오타 | Doc |

### 남은 Minor 이슈 (기능에 영향 없음)

- `echo -e` → `printf` 변환 (log 함수에서 백슬래시 이스케이프 해석 방지)
- git worktree 환경에서 `.git/hooks` 경로 감지 (`git rev-parse --git-dir` 사용)
- YAML frontmatter `argument-hint` 인용부호 일관성
- `todowrite-states` 패치가 disabled 상태로 배열에 남아있음 (63개 중 실제 62개 적용)
- `hexdump` UUID 생성이 UUID v4 비트 규격 미충족 (Claude Code가 검증 안 함)
- `system-prompt-patches-ko.md`의 카테고리 분류가 일부 패치의 실제 절감량과 불일치

## 핵심 제약사항

1. **git clone만으로는 적용 안 됨**: `bash CLA/install.sh` 최소 1회 필요. Claude Code는 `$CLAUDE_CONFIG_DIR`에서만 글로벌 설정을 읽음.
2. **시스템 프롬프트 패치는 버전 고정**: v2.1.47 전용. 업데이트 시 `UPGRADING.md` 참조하여 패치 재작성 필요.
3. **Windows 네이티브 바이너리는 패치 불가**: PE32+ 형식 미지원. npm 설치(`cli.js`)만 패치 가능.
4. **패치의 `${__VAR__}` 플레이스홀더**: 번들 내 minified 변수명이 버전마다 바뀌므로, find.txt에서 `${__VAR1__}` 형태로 작성하면 patcher가 자동으로 regex 변환하여 매칭.

## 작업 시 참고

- `CLA/` 수정 후 테스트: `bash CLA/install.sh` 실행하여 `$CLAUDE_CONFIG_DIR`에 반영 확인
- 패치 수정 후 테스트: `node claude-code-tips/system-prompt/2.1.47/patch-cli.js` 실행하여 63/63 확인
- 문서는 한국어로 작성. AI가 읽는 것이 주 목적이므로 구조화된 테이블/리스트 선호.
