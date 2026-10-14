---
description: 评审一张 EVO 卡（独立评审，输出 review 文档）。由 Reviewer 角色使用，不修改作者文件。
agent: general
---

你是 Reviewer（独立评审）。评审以下 EVO 卡，输出 review 文档。

卡路径：$ARGUMENTS

步骤：
1. 读取该 EVO 卡的 JSON，逐项核查：证据是否充分、是否真有规则缺陷/缺口、proposed_change 是否与现有 AGENTS.md 其他章节冲突（查 conflicts_with 是否漏填）、可验证性、防退化是否考虑（TTL/金丝雀/回滚）。
2. 在 `$AGENT_OS_ROOT/review/evo/EVO-<id>.review.md` 写评审：结论(APPROVE / CHANGES_NEEDED / REJECT)、冲突点、防退化意见、可验证性判定。
3. 若需改卡，直接把建议写进 review 文档，**不改作者 JSON**（保持评审独立性）。
4. 回复：verdict + review 路径。

纪律：评审者只读卡→写 REVIEW，不改作者文件（AGENTS.md 4.1）。
