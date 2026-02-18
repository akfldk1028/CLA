# 30_CLA - Claude Code 설정 & 리소스 모음

Claude Code CLI를 위한 글로벌 설정 모듈, 스킬, 팁, 문서 모음 레포.

## 핵심 모듈

### [CLA/](./CLA/) - Universal Config Module

모든 프로젝트에서 자동 적용되는 Claude Code 글로벌 설정.

```bash
# 설치 (한 줄)
bash CLA/install.sh
```

포함 항목:
- **CLAUDE.md** - 6개 글로벌 행동 규칙 (Think → Simplicity → Surgical → Goal-driven → Safety → Context)
- **스킬 8개** - handoff, half-clone, clone, gha, karpathy-guidelines, reddit-fetch, review-claudemd, cla-init
- **스크립트 4개** - context-bar, check-context (Stop hook), clone/half-clone 엔진
- **템플릿 6개** - rust, flutter, react, unity, backend-node, backend-python

자세한 내용: [CLA/README.md](./CLA/README.md)

## 기타 디렉토리

| 디렉토리 | 내용 |
|----------|------|
| `claude-master/` | CLA의 원본 소스 (claude-master 플러그인) |
| `docs/` | Claude Code 팁, Advent of Claude 정리 |
| `skills/` | 추가 스킬 수집 |
| `claude-code-tips/` | Claude Code 사용 팁 |

## 동작 원리 요약

```
claude 실행
  → $CLAUDE_CONFIG_DIR/CLAUDE.md 로드 (글로벌 규칙)
  → $CLAUDE_CONFIG_DIR/skills/*/SKILL.md description 등록
  → $CLAUDE_CONFIG_DIR/settings.json hooks 등록
  → ./CLAUDE.md 로드 (프로젝트 규칙, 있으면 누적)
  → 세션 시작
```

`$CLAUDE_CONFIG_DIR`이 미설정이면 `~/.claude/`를 사용.
