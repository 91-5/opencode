---
description: 压缩/归档 EVO 历史，整理 active 规则清单与指标快照。由 Orchestrator 每月 compaction 时执行。
agent: general
---

你是 Orchestrator。执行 EVO 月度压缩整理。

步骤：
1. 读取 `$AGENT_OS_ROOT/evo\index.json`。
2. 把 ACTIVE 规则整理为 `active_rules` 清单（rule_id + 版本 + 引用次数估算）。
3. 把 180 天未引用且非核心的 ACTIVE 卡标 DEPRECATED；把已 DEPRECATED 且无冲突的移入归档区（不改历史 JSON，仅追加状态）。
4. 生成指标快照（采纳率/回滚率/冲突数/候选过期率）写入 `$AGENT_OS_ROOT/evo\metrics-YYYYMM.md`。
5. 回复负责人：本月 active 规则数、归档数、指标摘要。

纪律：对应 AGENTS.md 5.5 周期触发 + 5.11 指标看板。
