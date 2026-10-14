# TEAM_PROTOCOL.md — Agent-OS 详细协议

> 本文件是 `AGENTS.md` 骨架的展开版：schema、状态机全转换、降级细节。
> 占位符 `$AGENT_OS_ROOT` = 包根目录；`<AGENT>` = agent 名；`<REVIEWER>` = 评审员名（全大写）。

## 1. 角色与权限矩阵
| 角色 | 出卡 | 接卡 | 评审 | 合并 | 写范围 |
|---|---|---|---|---|---|
| Orchestrator | ✅ 唯一 | ✅ | ❌（不自审） | ✅ 唯一 | 卡片、索引、知识库、自己 Owned |
| Heavy-Impl | ❌ | ✅ | ❌ | ❌ | 卡内 Owned files |
| Fast-Impl(IDE) | ❌ | ✅ | ❌ | ❌ | 卡内 Owned files + 探索报告 |
| Reviewer | ❌ | ✅（只读卡） | ✅ 独立 | ❌ | `review/<REVIEWER>/` |

## 2. Card Schema（任务卡）
```yaml
id: <前缀>-<日期>-<序号>        # 全局唯一，落盘前查重
title: 一句话目标
context: 背景/动机/约束
deliverables: []                # 结果清单（非过程）
owned_files: []                 # 独占路径 glob（防 lost-update）
forbidden_files: []             # 明确禁写路径
base_commit: <hash>             # 工作基线
acceptance: []                  # 全为带退出码的命令
status: OPEN|CLAIMED|IN_PROGRESS|IN_REVIEW|GATED|CLOSED|BLOCKED|REWORK|EXPIRED|ABANDONED
owner: <AGENT>
reviewer: <REVIEWER>
created: <日期>
```
铁律：递卡前作者必须自己跑完 Acceptance 每条命令；没自检的卡不许递出。

## 3. Verdict Schema（评审结论）
```markdown
# VERDICT <卡号>
- 结论: APPROVE | CHANGES_NEEDED | REJECT
- 证据: [文件:行 或 命令输出]
- 阻断项: []            # 必须修才能过
- 条件项: []            # 可带条件通过
- 签名: <REVIEWER> <日期>
- 哈希: <verdict 文件 sha256>
```
正本落 `review/<REVIEWER>/`，**永久留存**；索引只记一行（日期/卡号/结论/路径/哈希）。

## 4. Handoff Schema（临时信）
```json
{ "id":"", "from":"", "to":"", "refs":["卡号/文件"], "expires_at":"", "status":"pending|done|expired" }
```
临时信在正本落库后可删；正本不可删。

## 5. 状态机全转换
```
OPEN ──claim──▶ CLAIMED ──start──▶ IN_PROGRESS ──submit──▶ IN_REVIEW
IN_REVIEW ──approved──▶ GATED ──merge──▶ CLOSED
IN_REVIEW ──changes_requested──▶ REWORK ──resubmit──▶ IN_REVIEW
任意态 ──blocked──▶ BLOCKED ──unblock──▶ 原态
CLAIMED/IN_PROGRESS ──超时──▶ EXPIRED ──重派──▶ OPEN
任意态 ──放弃──▶ ABANDONED
```
- 每次状态转换写 commit；claim 建议带 `lease_until`，超时自动回 OPEN。

## 6. 失败降级细节
- **Orchestrator 挂**：进入停机模式——只允许完成已有卡，禁止开新卡；恢复后先 reconcile 半成品。
- **Reviewer 挂**：高风险卡（安全/数据/生产）一律禁合并；低风险可由负责人人工签收并留痕。
- **Fast-Impl 挂**：卡回 OPEN 重路由；IDE 专属任务标记 BLOCKED 而非强行改派。
- **Heavy-Impl 挂**：大任务拆小后改派；禁止把重装任务强推给 Fast-Impl。

## 7. 冲突消解流程
1. 发现冲突 → 双方停写。
2. Orchestrator 依据 `owned_files` + `base_commit` 判归属。
3. 跨模块接口冲突 → Orchestrator 出/改契约卡，双方按新契约实现。
4. 纪律级冲突 → 交负责人终裁。

## 8. Bootstrap（新 agent 接入）
1. 把本包放到可读位置（或直读 `$AGENT_OS_ROOT`）。
2. 填 `AGENTS.md` 顶部配置表（agent 名、目录）。
3. 读 `AGENTS.md` 全文 + 本文件第 1-5 节。
4. 声明能力（可接什么类型的卡）给 Orchestrator。
5. 第一次接卡走最小任务试跑，评审通过即完成接入。

## 9. 版本同步
- 各项目 AGENTS.md 顶部记 `protocol_version` + 包 hash。
- 每张卡记录所用协议版本。
- 升级走 EVO 卡 + 迁移说明；启动时校验 hash，不一致先停。
