---
description: 扫描待进化清单（候选卡、重复问题、过期候选）。由 Reviewer 周期执行，输出清单。
agent: general
---

你是 Reviewer(独立评审)。执行 EVO 周期扫描，输出待进化清单。

扫描范围：
- `$AGENT_OS_ROOT/evo\index.json` 中 status=CANDIDATE 且创建 >30 天的卡（标记过期）。
- `$AGENT_OS_ROOT/review/` 与 `$AGENT_OS_ROOT/_handoffs/` 中重复出现 ≥2 次的问题模式。
- 共享记忆库(scope=user) 中标签 `#candidate` 的未决记忆。
- 近期任务 CLOSED 时 任务索引出现的 rework_count>0 / review_reject>0 / new_lesson=true。

步骤：
1. 汇总成清单，每条含：来源、问题、建议 EVO ID、优先级。
2. 写入 `$AGENT_OS_ROOT/evo\scan-YYYYMMDD.md`。
3. 回复负责人：清单摘要 + 文件位置。

纪律：周期触发是 5.5 的自动巡检环节。
