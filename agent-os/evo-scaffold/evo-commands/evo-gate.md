---
description: 将评审+验证通过的 EVO 卡推进到 GATED，并由 Orchestrator 执行写权（改 AGENTS.md 等）。纪律级变更需负责人批准。
agent: general
---

你是 Orchestrator。把以下 EVO 卡从验证通过推进到 GATED 并执行写权。

卡路径：$ARGUMENTS

前置检查：该卡必须已有 `review/evo/EVO-<id>.review.md` 且 verdict=APPROVE，且 `EVO-<id>.verify.md` 含 VERIFIED。
步骤：
1. 若 proposed_change 涉及修改规则文件：先对该项目跑快照保护（项目快照工具 protect）（改 ≥3 文件前必做）；纪律级变更先向负责人申请批准，未批准只能 SHADOW。
2. 应用变更（如增删规则条款、加 command、建目录）。
3. 更新共享记忆库(scope=user)：旧规标 `#deprecated`，新规写 `#active`；如涉长文则本地 RAG 重建索引。
4. 更新 `$AGENT_OS_ROOT/evo/index.json`，把该卡 status 改为 GATED/ACTIVE，rule_version 升版（如 v0.1→v0.2）。
5. 回复负责人：已落地内容 + 版本号。

纪律：未批准不得强推（本包骨架 AGENTS.md 第八章）。
