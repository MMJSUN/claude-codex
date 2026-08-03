# 架構決策紀錄（Decision Log）

> 格式：每條含日期、決定、理由。新決定往上加。AI agent 不得違反本檔內的決定；要推翻須經人類核准並在此記錄。

## 2026-08-03 — 使用官方 codex mcp-server，不自建委派層

**決定**：Phase 0 驗證後，採用官方 `codex mcp-server`（`claude mcp add codex -- ~/.local/bin/codex mcp-server`）。原設計文件中的自建 `claude-codex-bridge-mcp` 降級為「官方能力不足時的加值層」選項。

**理由**：官方 server 已提供 `codex`（新 session）與 `codex-reply`（threadId 續談）工具，session 管理由官方維護；自建版本重複造輪子且需長期跟隨 Codex CLI 的變動。

## 2026-08-03 — 刪除 codex_git 工具構想；git 由 Claude Code 單一負責

**決定**：Codex 不執行任何 git 操作（commit/branch/push）。所有 git 操作由 Claude Code（orchestrator）執行。

**理由**：兩個 agent 都能 commit 會造成變更歸屬混亂；Claude Code 本身就能執行 git，包給 Codex 是多餘的一層。

## 2026-08-03 — Codex 規範檔用 AGENTS.md，不用 CODEX.md

**決定**：Codex 的行為規範寫在專案根目錄 `AGENTS.md`。

**理由**：Codex CLI 實際讀取的檔名是 `AGENTS.md`；原設計文件寫的 `CODEX.md` 不會被讀到。

## 2026-08-03 — sandbox 底線：workspace-write

**決定**：所有委派一律 `sandbox: workspace-write`；禁止 `danger-full-access`。環境需安裝 bubblewrap（已於 2026-08-03 安裝，bwrap 0.9.0，驗證通過）。

**理由**：Codex 具檔案寫入與指令執行能力，必須有 sandbox 隔離。

## 2026-08-03 — 斷路器：連續失敗 2 次即停

**決定**：同一任務委派連續失敗 2 次，Claude 必須停止委派，回頭重新蒐證分析根因，必要時回報人類。

**理由**：避免 AI 互相猜需求的無限迴圈燒掉額度；連續失敗代表任務描述或根因理解有誤，換花樣硬試無效。

## 2026-08-03 — AI 永不直接改 main

**決定**：任何 AI 寫入類任務必須在 feature branch（或獨立 worktree）上進行，經審查後才 merge。

**理由**：main 是人類最終核准的成果；保留 AI 改動的可拋棄性（要嘛全收、要嘛整個丟棄）。
