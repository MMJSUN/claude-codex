# 任務單：verify-setup 補 gh CLI 檢查

## 背景

2026-08-03 建立 PR 流程時發現環境沒有 `gh`，臨時改走 GitHub API。之後已將
gh 裝到 `~/.local/bin` 並以既有 token 完成認證。PR 流程（Tech Lead 的 git
職責之一）依賴 gh，應納入環境檢查，移植到新機器時才能提早發現。

## 需求

在 `scripts/verify-setup.sh` 的 MCP 檢查之後新增兩項，風格比照 codex 的
版本／登入兩段式：

7. `gh` 指令存在且可執行（印出版本）
8. gh 已認證（`gh auth status` 成功；缺 scope 的警告不算失敗，以 exit code 為準）

輸出格式與既有檢查一致（`[OK]` / `[FAIL] <原因>`），總結行檢查數改為 8。

## 設計約束

- 純 bash，沿用既有 `one_line` / `failures` 模式
- 單一 FAIL 不中斷後續檢查
- `gh auth status` 輸出可能含 token 片段——FAIL 訊息只取第一行摘要，
  不得把 token 印進報告

## 完成標準

- 在本 repo 執行 `bash scripts/verify-setup.sh` exit 0，八項全 `[OK]`
- 模擬 gh 不存在（`PATH` 移除 `~/.local/bin`）時兩項印 `[FAIL]` 且 exit 非零
- 模擬未認證（`GH_CONFIG_DIR` 指向空目錄且無 `GH_TOKEN`）時第 8 項 `[FAIL]`
