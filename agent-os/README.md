# agent-os — 通用 Agent 协同协议包

任何 AI coding agent（Trae / Cursor / 另一台 OpenCode 实例等）拉取本包即可加入多 agent 协同团队。

## 三步接入
1. **挂载**：把本包放到 agent 可读位置（本地同机 → 直接读 `$AGENT_OS_ROOT`；跨机 → 拷贝到自身工作区根）。
2. **填配置表**：打开 `AGENTS.md` 顶部配置表，填 agent 名与各目录。
3. **声明能力**：读 `AGENTS.md` 全文 + `TEAM_PROTOCOL.md` 第 1-5 节，向 Orchestrator 声明可接的卡类型，第一次接卡走最小任务试跑。

## 目录说明
| 路径 | 用途 |
|---|---|
| `AGENTS.md` | 协议骨架（八章程），入口必读 |
| `TEAM_PROTOCOL.md` | 详细协议：schema、状态机、降级、Bootstrap |
| `BOOTSTRAP-PROMPTS.md` | 新 agent 接入提示词（首次 A）+ 每次开工吸收提示词（B） |
| `evo-scaffold/index.json` | 规则进化索引模板 |
| `evo-scaffold/EVO-CARD.template.json` | EVO 卡全字段模板 |
| `evo-scaffold/evo-commands/` | 7 个生命周期命令模板（propose/review/verify/gate/rollback/scan/compact） |
| `handoff-templates/` | 评审请求单 + 任务卡模板 |
| `version.json` | 协议版本 + hash（启动时校验） |
| `verify-hash.js` | 独立复现 hash：`node verify-hash.js` → MATCH 即协议内容与声明一致 |

## 版本同步
- 每次规则进化 GATED 升版，Orchestrator 把变更同步进本包并 bump `version.json`（protocol_version + hash）。
- 各项目 AGENTS.md 顶部记 `protocol_version`；不一致先停再校。
