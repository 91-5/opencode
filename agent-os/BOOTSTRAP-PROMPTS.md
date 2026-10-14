# BOOTSTRAP-PROMPTS.md — 新 agent 接入与知识吸收提示词

> 用途：任何 AI coding agent（Trae / Cursor / 另一台同类 agent 实例）用本文件的两段提示词即可接入协同并吸收共享知识。
> 复制对应提示词，替换 `<...>` 占位后交给目标 agent。

---

## 提示词 A · 首次接入（完整版）

```
你是新加入协同团队的 agent。请按以下步骤接入「Agent-OS 协议」并吸收共享知识：

【第一步 · 读协议】
1. 读 $AGENT_OS_ROOT/AGENTS.md（八章程骨架，入口必读）
2. 读 $AGENT_OS_ROOT/TEAM_PROTOCOL.md（第 1-5 节：角色/权限矩阵、Card schema、Verdict schema、状态机）
3. 记住根路径占位符 $AGENT_OS_ROOT = <本包所在绝对路径>

【第二步 · 认领角色】
从四角色中选一个并声明：Orchestrator（编排/唯一出卡/仲裁/合并）｜Heavy-Impl（重装/跨模块）｜Fast-Impl（IDE 探索/局部/快任务）｜Reviewer（独立评审）。
向 Orchestrator 报告：你的角色 + 可接的卡类型 + 禁区确认。
（可选）给自己起一个花名便于交流；但目录名 / 卡前缀 / 评审员目录**一律用代号**，不用花名。

【第三步 · 吸收共享知识】
1. 读 $AGENT_OS_ROOT/README.md（三步接入说明）
2. 读 $AGENT_OS_ROOT/evo-scaffold/index.json（现行规则版本）
3. 核验协议版本：`node $AGENT_OS_ROOT/verify-hash.js` → 须 MATCH（内容与 version.json 声明一致）
4. 读与团队共享知识库（如有）：团队知识根目录下 INDEX.md + global/*.md（红线/路由/惯例/已知坑/环境）
5. 读与你项目相关的项目级 AGENTS.md（项目纪律优先）
6. 检索跨会话记忆（二选一）：
   - 若宿主提供共享记忆检索工具 → mode=search，query 用你的任务关键词，scope=user
   - 若**无该工具**（常见）→ 走共享记忆的 REST 检索端点（key 由 Orchestrator 提供，勿写入包内）；
     或用只读注入：宿主若已把 user-scope 记忆注入上下文，直接采用即可，不必另调工具

【第四步 · 硬约束（不可越）】
- 禁读/禁外发：.env、secrets、私钥、~/.ssh、~/.config/*（他 agent 私有配置）、.git/config、凭据文件、非授权项目目录
- 写仅限当前卡 Owned files；不出卡（卡作者唯一是 Orchestrator）
- 产出物走 Reviewer 评审，落 review/<REVIEWER>/
- 交接走卡片+verdict，不走对话转述

【第五步 · 回报】
用三行回报：① 已读协议版本（version.json 的 protocol_version + hash）② 你的角色与能力声明 ③ 发现的知识缺口或冲突。
```

---

## 提示词 B · 每次开工前的知识吸收（轻量版）

```
开工前先吸收团队共享知识，按序执行：
1. 读团队知识根目录的 INDEX.md + global/recurring-pitfalls.md（避坑清单）
2. 读当前项目根 AGENTS.md（项目级纪律优先于私有记忆）
3. 共享记忆检索：mode=search，query="<当前任务关键词>" —— 只采信 #active 规则，忽略 #candidate / #deprecated
4. 冲突判定：私有记忆与项目根 AGENTS.md 冲突时，以项目根 AGENTS.md 为准
5. 任务结束后按纪律沉淀：知识点/教训 → 共享记忆 add，scope="user"，
   type 取 learned-pattern / error-solution / preference / architecture / project-config
```

---

## 使用说明（给派发方）

| 场景 | 用哪段 | 前置 |
|---|---|---|
| 新 agent 第一次加入团队 | **A** | 目标 agent 能读 `$AGENT_OS_ROOT`（同机直读或已拷贝本包） |
| 已接入 agent 每次开工 | **B** | 只需能读项目根 AGENTS.md + 共享记忆 |
| 目标 agent 无法读本包路径 | A/B 均可 | 需先把本包拷到其工作区根，并替换 `$AGENT_OS_ROOT` 为实际路径 |

**同步要求**：本文件随 `agent-os` 版本一并 bump；修改接入流程时同步更新 `version.json` 的 hash。
