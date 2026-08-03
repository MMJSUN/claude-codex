# 任務單：bootstrap-project 移植腳本

## 背景

這套 Claude + Codex 協作規範要能一鍵移植到其他專案。需要一個腳本把本 repo 的
規範檔複製到目標專案，讓新專案立刻具備相同的委派/審查框架。

## 需求

建立 `scripts/bootstrap-project.sh <target-dir> [--force]`（純 bash）：

1. **逐字複製**到 `<target-dir>`：
   - `CLAUDE.md`、`AGENTS.md`
   - `.ai/ARCHITECTURE.md`、`.ai/DECISIONS.md`、`.ai/CODING_RULES.md`、
     `.ai/DELEGATION_TEMPLATE.md`、`.ai/REVIEW_CHECKLIST.md`
2. **重新生成（不是複製）**：`.ai/TASK_QUEUE.md` 用空白範本（保留表頭與狀態說明，
   不含本 repo 的任務紀錄）；建立空的 `.ai/tasks/` 目錄。
3. 每個檔案印一行 `[COPY]` / `[NEW]` / `[SKIP]（已存在）`；`--force` 時覆蓋既有檔案並印 `[OVERWRITE]`。
4. 結尾總結：處理了幾個檔案、略過幾個。

## 設計約束

- 純 bash、無新依賴；來源路徑以腳本所在位置推導（參考 `scripts/verify-setup.sh` 的做法）
- `<target-dir>` 必須已存在（不存在 → 印錯誤、exit 2）；無參數 → 印 usage、exit 2
- 預設不覆蓋既有檔案（idempotent，重跑安全），只有 `--force` 才覆蓋
- 目標路徑含空白必須正常運作

## 完成標準

- 對全新空目錄執行 → exit 0，9 個項目全數建立，TASK_QUEUE.md 是空白範本（無本 repo 任務紀錄）
- 立刻重跑（無 --force）→ exit 0，全部 `[SKIP]`，檔案內容不變
- 目標目錄先放一個修改過的 CLAUDE.md，加 `--force` 重跑 → 該檔被覆蓋回範本內容
- 無參數 → usage、exit 2；目標目錄不存在 → 錯誤訊息、exit 2
- 以上在含空白的目標路徑下驗證
