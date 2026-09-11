# claude-codex

Claude Code + Codex 的 AI 協作開發環境範本。Claude Code 擔任 Tech Lead（分析、決策、委派、審查、git），Codex 擔任 Implementation Engineer（實作、refactor、測試、debug），兩者透過官方 `codex mcp-server` 串接。

本 repo 本身沒有應用程式碼；它提供的是一套**規範檔 + 檢查／移植腳本**，讓任何專案一鍵套上相同的委派與審查框架。

## 架構

```
Developer（Product Owner：需求、商業邏輯、最終核准）
    │
Claude Code（Tech Lead：需求分析、架構決策、任務拆解、委派、審查、git 操作）
    │  MCP 工具：codex（新 session）/ codex-reply（帶 threadId 續談）
Codex（Implementation Engineer：實作、refactor、測試撰寫與執行、debug）
```

四條不可違反的底線（完整脈絡見 [`.ai/DECISIONS.md`](.ai/DECISIONS.md)）：

| 底線 | 內容 |
|------|------|
| 不自建委派層 | 直接用官方 `codex mcp-server`，不維護自己的 bridge |
| git 單一來源 | 所有 git 操作由 Claude Code 執行，Codex 不碰 git |
| sandbox | 委派一律 `sandbox: workspace-write`（依賴 bubblewrap），禁止 `danger-full-access` |
| AI 永不直接改 main | 一律 feature branch → 審查 → merge |

## 檔案說明

| 路徑 | 讀者 | 用途 |
|------|------|------|
| `CLAUDE.md` | Claude Code | Tech Lead 角色定義：分工、委派規則、審查規則、git 紀律 |
| `AGENTS.md` | Codex | Implementation Engineer 角色定義：範圍限制、禁止事項、回報格式 |
| `.ai/ARCHITECTURE.md` | 兩者 | 系統架構濃縮版與委派流程 |
| `.ai/DECISIONS.md` | 兩者 | 架構決策紀錄；AI 不得違反，推翻須人類核准 |
| `.ai/CODING_RULES.md` | 兩者 | 程式碼規範（最小改動、測試規格、安全） |
| `.ai/DELEGATION_TEMPLATE.md` | Claude Code | 委派 prompt 的五節固定格式與委派前自檢 |
| `.ai/REVIEW_CHECKLIST.md` | Claude Code | 審查 Codex 產出的逐項清單 |
| `.ai/TASK_QUEUE.md` | Claude Code | 任務狀態總表，每個任務一行 |
| `.ai/tasks/<name>.md` | 兩者 | 個別任務單（背景、需求、約束、完成標準） |
| `scripts/verify-setup.sh` | 人類 | 環境檢查：codex、登入、bwrap、claude、專案檔、MCP 註冊、gh、gh 登入 |
| `scripts/bootstrap-project.sh` | 人類 | 把規範檔移植到其他專案 |
| `CLAUDE_CODEX_MCP_ARCHITECTURE.md` | 人類 | 最初的完整設計文件；與 `.ai/` 衝突時以 `.ai/` 為準 |

## 快速開始

### 1. 安裝依賴

- [Claude Code](https://claude.com/claude-code) CLI
- [Codex CLI](https://github.com/openai/codex)，並完成 `codex login`
- bubblewrap（`bwrap`），Codex `workspace-write` sandbox 需要
- [GitHub CLI](https://cli.github.com/)（`gh`），並完成 `gh auth login`

### 2. 註冊 Codex MCP server

```bash
claude mcp add --scope user codex -- codex mcp-server
```

### 3. 驗證環境

```bash
bash scripts/verify-setup.sh
```

八項檢查每項印一行 `[OK]` 或 `[FAIL] <原因>`，任一失敗則 exit 非零。單項失敗不會中斷後續檢查。

### 4. 移植到其他專案

```bash
bash scripts/bootstrap-project.sh /path/to/your-project
```

會複製 `CLAUDE.md`、`AGENTS.md` 與 `.ai/` 下的五份規範檔，並生成空白的 `.ai/TASK_QUEUE.md` 與 `.ai/tasks/` 目錄。預設不覆蓋既有檔案（重跑安全）；加 `--force` 才覆蓋。

## 工作流程

1. Claude 分析需求，寫任務單到 `.ai/tasks/<name>.md`，在 `TASK_QUEUE.md` 登記
2. Claude 切到 feature branch，依 `DELEGATION_TEMPLATE.md` 組 prompt，呼叫 `codex` 工具委派
3. Codex 在 sandbox 內實作、跑測試，依 `AGENTS.md` 的格式回報
4. Claude 依 `REVIEW_CHECKLIST.md` 親自驗證：跑測試、讀 diff、探測測試沒涵蓋的 edge case
5. 通過 → Claude commit、開 PR；不通過 → `codex-reply` 帶 threadId 要求修正
6. **斷路器**：同一任務連續 2 次不通過 → 停止委派，重新蒐證分析根因，必要時回報人類

小型修改（單檔、幾行）Claude 可自行實作，不必為瑣事委派。

## 授權

尚未指定。
