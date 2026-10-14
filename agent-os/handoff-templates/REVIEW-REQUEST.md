# REVIEW-REQUEST <卡号>

| 字段 | 值 |
|---|---|
| 卡号 | <前缀>-<日期>-<序号> |
| 作者 | <AGENT> |
| 评审员 | <REVIEWER>（全大写） |
| 目标 | 一句话说明本次交付要解决的问题 |
| 证据路径 | 交付物绝对路径 / diff / commit |
| 验收 | Acceptance 命令清单（作者已自检跑通） |
| 期望 verdict | APPROVE / CHANGES_NEEDED / REJECT |

## 评审重点（可选）
- 1
- 2

---
评审纪律：评审员只读卡 → 写 verdict 至 `review/<REVIEWER>/`，不改作者文件；verdict 正本永久留存。
