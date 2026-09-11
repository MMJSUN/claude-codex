# 任務單：README

## 背景

repo 目前只有給 AI agent 讀的規範檔與設計文件，沒有給人類讀的入口。
需要一份 README 說明專案目的、檔案用途、快速開始與工作流程。

## 需求

建立 `README.md`，內容涵蓋：

1. 專案定位（Claude Code 為 Tech Lead、Codex 為 Implementation Engineer、官方 MCP 串接）
2. 架構圖與 `DECISIONS.md` 中的不可違反底線
3. 每個追蹤檔案的讀者與用途
4. 快速開始：依賴、MCP 註冊、`verify-setup.sh`、`bootstrap-project.sh`
5. 委派 → 審查 → commit 的工作流程與斷路器

## 設計約束

- 內容須與 `.ai/` 現有文件一致，不新增任何新規則
- 不含本機路徑、帳號等個人資訊

## 完成標準

- README 中引用的每個檔案路徑與指令都存在於 repo
- 描述的檢查項目數（8）與 `verify-setup.sh` 實際輸出一致
