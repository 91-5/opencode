# jarvis-opencode-framework

一套**去个人化**的 [opencode](https://opencode.ai) 通用框架，开箱即用的规则体系 + 多 agent 编排 + 可移植协同包 + 通用技能。

> 这是框架，不是我的个人配置。所有个人化内容（称呼、密钥、本地端点、具体模型）都已抽成占位符，你填自己的。

## 包含什么

| 组件 | 说明 |
|---|---|
| `config/AGENTS.md` | 通用纪律框架：安全底线 / 知识沉淀 / 工程严谨性(L0-L3) / 四 agent 协同 / EVO 自我进化机制。 |
| `config/opencode.template.jsonc` | opencode 配置模板，带详细注释。模型/密钥由你填。 |
| `config/tui.json` | TUI 偏好。 |
| `config/.env.example` | 你需要填写的所有环境变量清单。 |
| `slim/` | oh-my-opencode-slim 多 agent 编排框架（explorer/librarian/oracle/designer/fixer 等路由）。 |
| `agent-os/` | 通用可移植协同包：角色定义、交接单模板、EVO 进化脚手架。 |
| `skills/` | 通用技能：superpowers(16个) / worktrees / simplify / reflect / codemap / clonedeps / jailbreak-master / oh-my-opencode-slim。 |

## 不包含（刻意排除，避免塞私人东西）

- 具体模型 ID（如各家的免费池实测模型）——框架只留路由结构，模型你自己定。
- 任何真实 API Key / 本地端点实址。
- 个人专属技能：`impeccable`(20MB 设计资源)、`iot-job-hunter`(求职专用)、`tencentdb-memory`(私有记忆)。

## 安装（Windows，opencode 未装也能用）

```powershell
# 1. 拿到仓库
git clone <本仓库地址> jarvis-opencode-framework
cd jarvis-opencode-framework

# 2. 填你的密钥与路径
copy config\.env.example config\.env
#   用记事本打开 config\.env，填 MAIN_MODEL、MY_PROVIDER_API_KEY 等

# 3. 运行安装器（会自动装 opencode + 注入配置）
powershell -ExecutionPolicy Bypass -File install.ps1
```

安装器会：
1. 检测/全局安装 opencode（`npm i -g opencode-ai@latest`）。
2. 备份已有 `~/.config/opencode` 到带时间戳的 `.backup-*`。
3. **密钥守卫**：若你已有含真实 key 的 `opencode.jsonc`，不会覆盖，改写入 `.pending-render` 让你手动合并。
4. 渲染 `$XXX` 占位符（读 `config/.env`），落位全部框架文件。
5. 写 `install-receipt.json` 回执。

### 仅注入配置（已装好 opencode）

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -SkipOpenCodeInstall
```

### 预演（不碰真实配置，在临时目录试跑）

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -DryRun
```

## 填什么才能跑起来

最少填一个主力模型：`config/.env` 里的 `MAIN_MODEL`（格式 `provider/model-id`）+ 对应 provider 的 API Key。其余（dp-brain / ollama / local-rag / 网关）都是**可选**，留空不影响启动。

## 自定义

- 改 `AGENTS.md` 里的 `$USER` 等占位符为你自己的称呼与角色名（首次安装由 `.env` 渲染；之后可手改）。
- `slim/`、`agent-os/` 里的多 agent 编排与 EVO 进化机制，按 `agent-os/TEAM_PROTOCOL.md` 自行启用。
- 想加自己的技能？直接丢进 `~/.config/opencode/skills/`。

## 卸载

删除 `~/.config/opencode`（如需可先恢复 `.backup-*`）。本包不写注册表、不污染系统。

## License

MIT
