# 任務單：verify-setup 補 MCP 註冊檢查

## 背景

2026-08-03 發現 codex MCP server 只註冊在舊測試資料夾的 local scope，搬移專案後
`codex` / `codex-reply` 工具實際不可用，但 `verify-setup.sh` 五項檢查全過——
腳本驗了 codex CLI 與登入狀態，卻沒驗 Claude Code 端的 MCP 註冊，漏掉了真正的斷點。

## 需求

在 `scripts/verify-setup.sh` 現有五項檢查之後新增第 6 項：

6. codex MCP server 已在 Claude Code 註冊且健康檢查通過
   （`claude mcp list` 輸出包含 `codex` 且狀態為 Connected）

輸出格式與既有檢查一致（`[OK]` / `[FAIL] <原因>`），總結行的檢查數同步改為 6。

## 設計約束

- 純 bash，沿用既有腳本的風格（`one_line`、`failures` 計數）
- 單一 FAIL 不中斷後續檢查的既有原則不變
- MCP 檢查依賴 `claude` 指令；`claude` 不存在時此項應印 FAIL 而非讓腳本掛掉

## 完成標準

- 在本 repo 執行 `bash scripts/verify-setup.sh` exit 0，六項全 `[OK]`，
  MCP 那行能看到 codex Connected
- 模擬未註冊時（例如以 `CLAUDE_CONFIG_DIR` 指向空目錄執行）該項印 `[FAIL]`
  且腳本 exit 非零
