# 任務單：verify-setup 環境檢查腳本

## 背景

這套 Claude + Codex 協作環境要推廣到其他專案時，第一步是確認環境依賴齊全。
需要一個一鍵檢查腳本，日後複製到任何專案都能快速驗證環境。

## 需求

建立 `scripts/verify-setup.sh`（bash），依序檢查以下項目，每項印出一行
`[OK]` 或 `[FAIL] <原因>`，全部檢查跑完後統一總結；任何一項 FAIL 則以
非零 exit code 結束：

1. `codex` 指令存在且可執行（印出版本）
2. Codex 已登入（`codex login status` 成功）
3. `bwrap`（bubblewrap）存在 — sandbox 依賴
4. `claude` 指令存在（印出版本）
5. 專案根目錄存在 `AGENTS.md` 與 `.ai/` 目錄

## 設計約束

- 純 bash，不引入新依賴
- 單一 FAIL 不得中斷後續檢查（先全部檢查完再總結）
- 腳本可在任意 cwd 執行（以腳本所在位置推導專案根目錄）

## 完成標準

- 在本 repo 執行 `bash scripts/verify-setup.sh` exit 0，五項全 `[OK]`
- 模擬缺項時（例如 `PATH= /bin/bash scripts/verify-setup.sh` 或改壞檢查目標）exit 非零且能看到對應 `[FAIL]` 行
