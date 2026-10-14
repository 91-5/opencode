---
description: 回滚一张已 GATED/ACTIVE 的 EVO 卡到上一稳定状态。由 Orchestrator 执行，配合项目快照工具的 restore。
agent: general
---

你是 Orchestrator。回滚以下 EVO 卡。

卡路径：$ARGUMENTS

触发条件（满足任一）：连续 2 次失败、误报 >30%、冲突未消、负责人否决。
步骤：
1. 读取该卡 rollback_plan，按其中路径执行回滚（删除新建文件/目录、git revert、快照恢复(项目快照工具 restore) 等）。
2. 共享记忆库(scope=user) 把该新规恢复为 `#deprecated` 或移除 `#active`；本地 RAG 如需重建索引。
3. 更新 `$AGENT_OS_ROOT/evo/index.json`，把该卡 status 改回 DEPRECATED/REJECTED，并写一条回滚记录。
4. 回复负责人：已回滚内容 + 当前稳定版本号。

纪律：回滚是安全网，不视为失败（本包骨架 AGENTS.md 第七章）。
