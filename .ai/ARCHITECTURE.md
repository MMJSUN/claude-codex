# 系統架構：Claude Code + Codex 協作開發環境

> 完整設計文件見專案根目錄的 `CLAUDE_CODEX_MCP_ARCHITECTURE.md`。
> 本檔是給 AI agent 開工前讀的濃縮版；兩份文件衝突時，以本檔與 `DECISIONS.md` 為準。

## 角色分工

```
Developer（Product Owner：需求、商業邏輯、最終核准）
    │
Claude Code（Tech Lead：需求分析、架構決策、任務拆解、委派、審查、git 操作）
    │  透過官方 codex mcp-server（MCP 工具：codex / codex-reply）
Codex（Implementation Engineer：實作、refactor、測試撰寫與執行、debug）
```

## 關鍵決定（摘要，完整脈絡見 DECISIONS.md）

- **不自建委派層**：直接使用官方 `codex mcp-server`（提供 `codex` 與 `codex-reply` 兩個工具，threadId 維持 session 連續性）。自建 bridge 只在官方能力不足時作為加值層。
- **git 單一來源**：所有 git 操作（branch/commit/PR）由 Claude Code 執行；Codex 只改檔案，不碰 git。
- **sandbox 底線**：委派一律 `sandbox: workspace-write`（依賴 bubblewrap）；禁止 `danger-full-access`。
- **AI 永不直接改 main**：一律 feature branch → 審查 → merge。

## 委派流程

1. Claude 分析需求，寫任務單到 `.ai/tasks/<name>.md`
2. Claude 依 `DELEGATION_TEMPLATE.md` 組 prompt，呼叫 `codex` 工具委派
3. Codex 實作、跑測試、回報
4. Claude 依 `REVIEW_CHECKLIST.md` 親自驗證（跑測試、讀 diff）
5. 通過 → Claude commit；不通過 → 用 `codex-reply` 帶 threadId 要求修正
6. **斷路器**：同一任務連續失敗 2 次 → 停止委派，回頭重新分析根因
