# CHANGELOG — agent-os

## 2026-10-05 v1.0.0
- 初始可移植包：AGENTS.md 骨架（八章程）+ TEAM_PROTOCOL.md + evo-scaffold（索引/卡模板/7 命令模板）+ handoff-templates（评审请求单/任务卡模板）。
- 源自贾维斯团队操作系统 AGENTS.md v0.4 泛化（EVO-20261005-001），剥离全部本机与厂商专属路径。

### pack 2026-10-05.2
- 新增 `BOOTSTRAP-PROMPTS.md`（接入提示词 A/B）。

### pack 2026-10-05.3
- 第三章加花名说明；全包零硬编码回归通过。

### pack 2026-10-05.4（浮香接入反馈修复）
- **hash 可复现**：新增 `verify-hash.js`，`hash_scope` 改为可执行定义（明确剥 BOM + LF 分隔符）。
- **Reviewer 边界澄清**（反馈 b）：Reviewer 可做侦察/红队/spike，但须另开探索卡、报告走评审、不得自评自合。
- **正本根唯一**（反馈 c）：4.2 增「按前缀判定落点 + 每团队唯一正本根 + 禁止同前缀双投」；配置表加 `verdict 正本根` 字段。
- **记忆检索降级通道**（反馈 d）：无宿主记忆工具时走共享记忆 REST 检索端点或采用宿主注入。
