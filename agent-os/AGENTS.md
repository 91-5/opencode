# Agent-OS 通用协同协议 v1.0（可移植包）

> 任何 AI coding agent 拉取本包即可加入多 agent 协同团队。
> 根路径占位符 `$AGENT_OS_ROOT` = 本包所在目录，消费者按下方配置表填写。

## 配置表（消费者填写）
| 配置项 | 说明 |
|---|---|
| `$AGENT_OS_ROOT` | 本包根目录绝对路径 |
| Orchestrator 名 | 主控 agent（唯一出卡者），如 OpenCode |
| Heavy-Impl 名 | 重装实现 agent，如 ZCode |
| Fast-Impl 名 | IDE 内快任务 agent，如 Trae |
| Reviewer 名 | 独立评审 agent（目录名全大写），如 AGNES |
| **verdict 正本根** | 评审正本的唯一落点（接入时由 Orchestrator 写入）；默认 `$AGENT_OS_ROOT/review/`，已接入外部信封体系者填该体系根 |
| 评审目录 | 见「verdict 正本根」；`$AGENT_OS_ROOT/review/` 仅为默认示例 |
| 收件箱 | `$AGENT_OS_ROOT/inbox/<AGENT>/`（作者侧产物） |
| 交接区 | `$AGENT_OS_ROOT/_handoffs/`（实现类交接） |

---

## 第一章 安全底线
- **denylist（禁读/禁外发）**：`.env`、`secrets`、私钥、`~/.ssh`、`~/.config/*`（他 agent 私有配置）、`.git/config`、凭据文件、非授权项目目录。
- **写权限**：仅限当前卡 `Owned files` 列出的路径；禁止越卡写文件。
- 任何文件出现明文密钥/密码 → 停下，提醒改用环境变量。
- 删库 / force push / 改 git 历史 → 列出影响面，等负责人确认。

## 第二章 知识共享
- 所有沉淀的知识点/教训**默认共享**（共享记忆库 scope=user）。
- 仅三类留项目级：① 明文密钥/隐私；② 纯实时工作态（open threads、当前 HEAD、未合并分支）；③ 仅当前项目用得上的临时状态。
- 长文/原理类写进 RAG 语料库并重建索引；引用出处必须真实，查不到就明说，禁止编造。

## 第三章 四角色协同
> 花名可选：给每个角色起一个花名便于交流，但**目录名 / 卡前缀 / 评审员目录一律用代号**。

| 角色（代号） | 主责 | 硬边界 |
|---|---|---|
| **Orchestrator** | 编排、唯一出卡、仲裁、合并门禁、知识库管家 | 不自审自己写的卡；不绕卡派活；不直接改他人 Owned files |
| **Heavy-Impl** | 重装主攻（大型/多模块/长链路） | 接卡实现侧；不出卡、不自审、不跨卡改文件 |
| **Fast-Impl (IDE)** | IDE 内探索/局部实现/快任务 | 接卡不出卡；产出走 Reviewer 评审；受第一章 denylist 约束 |
| **Reviewer** | 独立评审 + 红队 | 只读卡 → 写 verdict；不改作者文件 |
| **Reviewer（侦察/探索侧）** | 可做侦察、红队、复现、spike 探索 | **须另开探索卡**；探索报告走评审；**不得自评自合**（评审与探索不可同卡同签） |

**能力路由（防撞车）**：
- Heavy-Impl 接「重装/跨模块/长链路」，Fast-Impl 接「探索/局部/IDE 感知/快任务」。
- 探索卡与实现卡分离：Fast-Impl 可先做 spike 出报告，真正改码必须另开实现卡。
- 同文件同一时刻单写者；跨模块接口先由 Orchestrator 出契约卡，各方只实现各自侧。
- 任务指纹去重：`repo+base+owned_files+acceptance` 相同只允许一张 active 卡。
- **仅 Orchestrator 执行合并**；Reviewer approved 才可合并。

## 第四章 交接与目录
### 4.1 目录布局
```
$AGENT_OS_ROOT/
  cards/              # 任务卡（open/claimed/review/done）
  inbox/<AGENT>/      # 作者侧产物
  work/<AGENT>/       # 作者侧工作区
  review/<REVIEWER>/  # 评审正本（verdict），按评审员组织
  review/evo/         # EVO- 卡评审产出专属区（见 4.2 例外）
  _handoffs/          # 实现类交接单（回收方是作者自己）
  evo/                # EVO 卡片与索引工作区（index.json、EVO-*.json）
```

### 4.2 目录语义（关键，防审计丢失）
- **评审正本落点（按卡前缀判定，避免双轨分裂）**：
  1. **本包自治任务**（卡前缀非 EVO/DFB/OC 等既有域，或未接入外部信封体系）→ 落 `$AGENT_OS_ROOT/review/<REVIEWER>/`
  2. **已接入外部信封体系的团队**（如团队自有的评审正本根）→ **以该体系的既有正本根为准**，`$AGENT_OS_ROOT/review/` 仅作包内示例布局
  3. `EVO-` 前缀卡的评审产出 → 该体系的 EVO 专属评审区（见下方 EVO 例外）
  - **判定规则**：一个团队/项目同一时刻只允许**一个** verdict 正本根，由 Orchestrator 在接入时写入配置表，禁止同一前缀双投。
- 评审正本一律按**评审员**落 `review/<REVIEWER>/`；**作者侧**产物落 `inbox/<AGENT>/` 或 `work/<AGENT>/`。**严禁**用作者名当评审目录（如 `review/<作者>/`）。
- **规则进化（EVO）例外**：`EVO-` 前缀卡的评审产出可落专属评审区 `review/evo/EVO-*.review.md`；其派发单仍按评审员目录。其他前缀不受影响。
- **verdict 正本永久留存，禁止删除**；AGENTS.md 与索引只记索引行（日期/卡号/结论/路径/哈希），防止丢审计与规则文件膨胀。
- 判定：回收方是评审员 → `review/`；否则 → `_handoffs/` 或 `inbox/`。
- 命名：`<项目前缀>-REVIEW-REQUEST-<REVIEWER>-<日期>-<序号>.md`；评审员目录名**全大写归一**（避免大小写混用导致检索歧义）。

### 4.3 交接纪律
- git 是唯一交接媒介：完成即 commit（message 写为什么）。
- 交接走卡片 + verdict，不走对话转述。
- 并行用分支/worktree，合并前看 verdict。

## 第五章 状态机与旁路
- 任务卡主链：`OPEN → CLAIMED → IN_PROGRESS → IN_REVIEW → GATED → CLOSED`
- 旁路：`BLOCKED`（等外部）/ `REWORK`（评审驳回返工）/ `EXPIRED`（超时释放）/ `ABANDONED`（放弃）
- 规则进化状态机：`DRAFT → CANDIDATE → IN_REVIEW → SHADOW → GATED → ACTIVE`；旁路 `REJECTED / DEPRECATED`；同一 rule_id 同一时间只能一个 ACTIVE。

## 第六章 冲突消解
- Owned files 独占路径防 lost-update；卡里写清精确 glob、Forbidden files、Base commit。
- 跨模块接口先出契约卡，双方只实现各自侧。
- 争议由 Orchestrator 仲裁；纪律级争议交负责人终裁。

## 第七章 失败降级预案
| 故障 | 立即动作 | 降级 | 禁止 |
|---|---|---|---|
| Orchestrator 挂 | 冻结新卡 | 停机模式：只完成存量卡 | 无卡直接改 |
| Reviewer 挂 | 高风险卡禁合并 | 低风险由负责人签收 | 作者自审后合并 |
| Fast-Impl 挂 | 任务回 ready | 重路由 Heavy-Impl / Orchestrator | 卡永久卡死 |
| Heavy-Impl 挂 | 大任务拆小 | Fast-Impl / Orchestrator 接局部 | 强推快任务 agent 做重装 |

## 第八章 规则进化（EVO）
- 规则进化必走 EVO 卡：模板 `evo-scaffold/EVO-CARD.template.json`，索引 `evo-scaffold/index.json`。
- 生命周期命令模板：`evo-scaffold/evo-commands/`（propose / review / verify / gate / rollback / scan / compact）。
- 版本同步：每次 GATED 升版，Orchestrator 把新规则同步进本包并 bump `version.json`（protocol_version + hash）。
