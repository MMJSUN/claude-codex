# Claude Code + Codex MCP Integration Architecture

## Project Goal

建立一套 AI Agent 協作開發環境：

- Claude Code 作為主要 Orchestrator（Tech Lead / Architect）
- Codex 作為 Implementation Engineer（Coding / Testing / Debug）
- MCP 作為兩者之間的橋接層

目標：

1. Claude Code 可以主動呼叫 Codex 處理適合 Codex 的工作
2. Codex 可以執行：
   - 大量程式修改
   - Refactor
   - Test execution
   - Debug
   - Code generation
3. Claude Code 保留：
   - 架構決策
   - Task 分析
   - Code Review
   - 最終決策權


---

# High Level Architecture

```
Developer
    |
    |
Claude Code
(Orchestrator)
    |
    |
MCP Server
(claude-codex-bridge)
    |
    +----------------+
    |                |
    |                |
 Codex CLI       Project Tools
    |                |
    |                |
Implementation   Git/Test/Docker
Testing
Debugging
```

---

# Agent Responsibilities


## Claude Code Role

定位：

> Senior Architect / Team Lead


負責：

- 分析需求
- 理解現有架構
- 建立 Implementation Plan
- 決定技術方向
- 分派 Coding 工作給 Codex
- Review Codex 修改


Claude Code 不應：

- 直接大量修改數十個檔案
- 執行重複性 coding 工作
- 取代 Codex implementation


---

## Codex Role

定位：

> Senior Implementation Engineer


負責：

- Feature implementation
- Large refactor
- Bug fixing
- Test writing
- Running test suite
- CI debugging


Codex 不應：

- 改變核心架構決策
- 自行重新設計系統
- 修改需求


---

# MCP Server Design

Project name:

```
claude-codex-bridge-mcp
```


Recommended stack:

```
Node.js
TypeScript
MCP SDK
```


Directory:

```
claude-codex-bridge-mcp/

├── src/
│
├── tools/
│   ├── codex_execute.ts
│   ├── codex_test.ts
│   ├── codex_review.ts
│   └── codex_git.ts
│
├── services/
│   ├── codex-runner.ts
│   ├── git-service.ts
│   └── project-service.ts
│
├── package.json
└── README.md
```


---

# MCP Tools Specification


# 1. codex_execute


Purpose:

讓 Claude Code 委派 implementation task 給 Codex。


Input:

```json
{
  "task": "Implement authentication API",
  "mode": "implement",
  "working_directory": "/project"
}
```


Modes:

```
implement
debug
refactor
test
```


Expected behavior:

1. 呼叫 Codex CLI
2. 提供 task context
3. 允許修改 project files
4. 執行必要測試
5. 回傳結果


---

# 2. codex_test


Purpose:

讓 Claude Code 要求 Codex 執行測試。


Input:

```json
{
  "command": "npm test",
  "working_directory": "/project"
}
```


Return:

```json
{
  "status": "success",
  "passed": 120,
  "failed":0
}
```


---

# 3. codex_review


Purpose:

讓 Codex 作為第二 reviewer。


Input:

```json
{
  "target":"current changes",
  "focus":[
    "bugs",
    "security",
    "performance"
  ]
}
```


Output:

```
Review Report

Issues:
- Missing validation
- Possible race condition

Suggestions:
- Add transaction handling
```


---

# 4. codex_git


Purpose:

Git automation。


Capabilities:

- git status
- git diff
- create commit
- generate commit message


Example:

```
Create commit:

feat(auth):
add OAuth login support
```


---

# Project AI Context Files


建立：

```
.ai/

├── ARCHITECTURE.md
├── CODING_RULES.md
├── TASK_QUEUE.md
├── DECISIONS.md
└── REVIEW_CHECKLIST.md
```


---

# CLAUDE.md


內容：

```
You are the project technical lead.

Responsibilities:

1. Understand architecture before coding.
2. Create plans before implementation.
3. Delegate large coding tasks to Codex.
4. Review all Codex changes.

Use Codex for:

- Large implementation tasks
- Refactoring
- Test generation
- Debugging
- CI failures

Do not blindly modify architecture.
```


---

# CODEX.md


內容：

```
You are the implementation engineer.

Rules:

1. Follow existing architecture.
2. Do not redesign systems.
3. Modify only required files.
4. Always run tests after changes.
5. Report:
   - changed files
   - tests executed
   - remaining risks
```


---

# Development Workflow


## Feature Development


Step 1:

Claude Code receives requirement.


Example:

```
Add notification system
```


Step 2:

Claude analyzes:

- Existing modules
- Database impact
- API design
- Risks


Create:

```
.ai/tasks/notification.md
```


---

Step 3:

Claude calls:


```
codex_execute
```


with:

```
Implement notification feature.

Requirements:
- Follow notification.md
- Add tests
- Run test suite
```


---

Step 4:

Codex:

- Modify files
- Add tests
- Run tests
- Return result


---

Step 5:

Claude reviews:


```
codex_review
```


Check:

- Architecture
- Security
- Maintainability
- Regression risk


---

# Git Strategy


Never allow AI directly modify main branch.


Recommended:


```
main

 |
 |
feature/payment

 |
 |
Codex Implementation

 |
 |
Pull Request

 |
 |
Claude Review

 |
 |
Merge
```


---

# Team Workflow (7 People)


Recommended:


```
Product Requirement

        |
        |

Claude Code

        |
        |
Implementation Plan

        |
        |

Codex

        |
        |
Pull Request

        |
        |

Claude Review

        |
        |

Merge
```


---

# Future Extensions


Possible additions:

## GitHub Integration

Automatic:

- Issue analysis
- PR review
- Test verification


## CI Integration

Trigger:

```
Pull Request Created

        |

Claude Review

        |

Codex Test Runner
```


## Additional AI Agent

Future:

Research Agent:

- Documentation search
- Technology comparison
- API investigation


---

# Implementation Priority


## Phase 1

完成：

- MCP Server
- codex_execute


## Phase 2

增加：

- codex_test
- codex_review


## Phase 3

增加：

- GitHub automation
- CI integration
- PR workflow


---

# Final Objective

建立 AI Software Team:

```
Human
(Product Owner)

      |

Claude Code
(Architect)

      |

Codex
(Engineer)

      |

Git Repository
```

Human focuses on:
- Product decisions
- Business logic
- Final approval

AI handles:
- Planning
- Implementation
- Testing
- Review
```