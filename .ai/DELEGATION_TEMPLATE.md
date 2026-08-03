# 委派 Prompt 範本

> Claude 每次呼叫 `codex` 工具委派任務時，prompt **必須**包含以下五節，缺一不可。
> 工具參數固定帶：`cwd`（絕對路徑）、`sandbox: "workspace-write"`、`approval-policy: "never"`。
> 修正輪使用 `codex-reply` + 上一輪回傳的 `threadId`，不要重開 session。

---

```markdown
## Task
（一段話講清楚要做什麼、為什麼。對應的任務單：.ai/tasks/<name>.md，有就引用）

## Scope
（允許改動的檔案／目錄清單。清單外的檔案一律不准動）

## Forbidden
（明確列出不准做的事。至少包含：
- 不執行任何 git 操作
- 不新增依賴（除非本節明確允許）
- 不修改公開介面／不重新設計架構
- 不改動 Scope 外的檔案
- 任務描述含糊時停下回報，不自行腦補需求）

## Done criteria
（可觀察的完成標準，逐條列出。例：
- `npm test` 全綠，且新增至少 N 條涵蓋 edge case 的測試
- 某指令的實際輸出符合 X）

## Report format
（要求回報：
1. Changed files（逐一列出）
2. Tests executed 與實際輸出（貼原文，不是轉述）
3. Remaining risks / 未完成事項 / 你做過的假設）
```

---

## 委派前 Claude 自檢

- [ ] 任務夠小嗎？（預期改動 ≤ ~10 檔案；更大就先拆）
- [ ] 目前在 feature branch / 獨立 worktree 上？（在 main 上不准委派寫入任務）
- [ ] Done criteria 是可觀察的（指令＋預期輸出），不是「看起來對」？
