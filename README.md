# jarvis-opencode-framework

一套**去个人化**的 [opencode](https://opencode.ai) 通用框架，开箱即用的规则体系 + 多 agent 编排 + 可移植协同包 + 通用技能。

> 这是框架，不是个人配置。所有个人化内容（称呼、密钥、本地端点、具体模型）都已抽掉或改成示例，你填自己的。

## 第一步：先装 opencode 本体（本包不含）

opencode 官方仓库（活跃、213k★、含桌面端）：**https://github.com/anomalyco/opencode**

- **桌面端（推荐新手）**：进 [Releases](https://github.com/anomalyco/opencode/releases)，下载 `opencode-desktop-win-x64.exe` 双击安装。
- **终端版**：同一 Releases 页下载 `opencode-windows-x64.zip` 解压，或 `winget install opencode` / `npm i -g opencode-ai`。

> 注意：旧仓库 `opencode-ai/opencode`（Go 版）已 archived 停更，且只有终端版，**不要从那里下**。

## 包含什么

| 组件 | 说明 |
|---|---|
| `config/AGENTS.md` | 通用纪律框架：安全底线 / 知识沉淀 / 工程严谨性(L0-L3) / 四 agent 协同 / EVO 自我进化机制。 |
| `config/opencode.jsonc` | opencode 配置（带示例 provider + 详细注释）。模型/密钥由你改。 |
| `config/tui.json` | TUI 偏好。 |
| `slim/` | oh-my-opencode-slim 多 agent 编排框架（explorer/librarian/oracle/designer/fixer 等路由）。 |
| `agent-os/` | 通用可移植协同包：角色定义、交接单模板、EVO 进化脚手架。 |
| `skills/` | 通用技能：superpowers(16个) / worktrees / simplify / reflect / codemap / clonedeps / jailbreak-master / oh-my-opencode-slim。 |

## 不包含（刻意排除）

- 具体模型 ID（各家的免费池实测模型）——框架只留结构，模型你自己定。
- 任何真实 API Key / 本地端点实址。
- 个人专属技能：`impeccable`(20MB 设计资源)、`iot-job-hunter`(求职专用)、`tencentdb-memory`(私有记忆)。

## 第二步：注入本框架（假设你已装好 opencode）

```powershell
# 1. 拿到本仓库
git clone <本仓库地址> jarvis-opencode-framework
cd jarvis-opencode-framework

# 2. 注入框架到 ~/.config/opencode（会自动备份已有配置，已有真实密钥不覆盖）
powershell -ExecutionPolicy Bypass -File install.ps1
```

安装器会：
1. 备份已有 `~/.config/opencode` 到带时间戳的 `.backup-*`。
2. **密钥守卫**：若你已有含真实 key 的 `opencode.jsonc`，不会覆盖，改写入 `.pending-merge` 让你手动合并。
3. 落位 `config/` `slim/` `agent-os/` `skills/`。
4. 写 `install-receipt.json` 回执。

> 桌面端与终端版共用同一个配置目录（`%USERPROFILE%\.config\opencode`），所以无论你装哪种，本注入脚本都适用。

## 之后要改什么才能跑起来

最少改一处：`~/.config\opencode\opencode.jsonc` 里的 `model` / `small_model`，换成你的 provider + 模型（格式 `"<provider-id>/<model-id>"`）。文件里已有一个 `my-provider` 示例，照着改 `baseURL` 和 `apiKey`（用 `{env:你的环境变量}` 引用 key，别把 key 明文写进文件）即可。其余（dp-brain / ollama / local-rag / 网关）都是**可选**，保持 `enabled:false` 或不填不影响启动。

改完启动 opencode（桌面端点图标 / 终端输入 `opencode`）即可。

## 自定义

- `config/AGENTS.md` 是纯框架文档，角色用"主控编排/重装实现/IDE实现/独立评审"等通称，路径写成"你的工作区根目录"等描述——无需填写，直接可用。
- `slim/`、`agent-os/` 里的多 agent 编排与 EVO 进化机制，按 `agent-os/TEAM_PROTOCOL.md` 自行启用。
- 想加自己的技能？直接丢进 `~/.config/opencode/skills/`。

## 卸载

删除 `~/.config/opencode`（如需可先恢复 `.backup-*`）。本包不写注册表、不污染系统。

## License

MIT
