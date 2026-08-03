#!/usr/bin/env bash

failures=0

one_line() {
    REPLY=${1//$'\r'/}
    REPLY=${REPLY//$'\n'/'; '}
}

script_path=${BASH_SOURCE[0]}
if [[ $script_path == */* ]]; then
    script_dir=${script_path%/*}
else
    script_dir=.
fi
project_root=$(cd -- "$script_dir/.." && pwd -P)

codex_path=$(command -v codex 2>/dev/null || true)
if [[ -n $codex_path && -x $codex_path ]]; then
    if codex_version=$(codex --version 2>&1); then
        one_line "$codex_version"
        printf '[OK] codex: %s\n' "$REPLY"
    else
        one_line "$codex_version"
        printf '[FAIL] codex version check failed: %s\n' "$REPLY"
        ((failures += 1))
    fi
else
    printf '[FAIL] codex command not found or not executable\n'
    ((failures += 1))
fi

if login_status=$(codex login status 2>&1); then
    one_line "$login_status"
    printf '[OK] Codex login: %s\n' "$REPLY"
else
    one_line "$login_status"
    printf '[FAIL] Codex login status check failed: %s\n' "$REPLY"
    ((failures += 1))
fi

bwrap_path=$(command -v bwrap 2>/dev/null || true)
if [[ -n $bwrap_path && -x $bwrap_path ]]; then
    printf '[OK] bwrap: %s\n' "$bwrap_path"
else
    printf '[FAIL] bwrap command not found or not executable\n'
    ((failures += 1))
fi

claude_path=$(command -v claude 2>/dev/null || true)
if [[ -n $claude_path && -x $claude_path ]]; then
    if claude_version=$(claude --version 2>&1); then
        one_line "$claude_version"
        printf '[OK] claude: %s\n' "$REPLY"
    else
        one_line "$claude_version"
        printf '[FAIL] claude version check failed: %s\n' "$REPLY"
        ((failures += 1))
    fi
else
    printf '[FAIL] claude command not found or not executable\n'
    ((failures += 1))
fi

if [[ -f $project_root/AGENTS.md && -d $project_root/.ai ]]; then
    printf '[OK] project files: AGENTS.md and .ai/ found in %s\n' "$project_root"
else
    missing=()
    [[ -f $project_root/AGENTS.md ]] || missing+=(AGENTS.md)
    [[ -d $project_root/.ai ]] || missing+=(.ai/)
    printf '[FAIL] project files missing from %s: %s\n' "$project_root" "${missing[*]}"
    ((failures += 1))
fi

if [[ -n $claude_path && -x $claude_path ]]; then
    mcp_list=$(claude mcp list 2>&1)
    codex_line=$(printf '%s\n' "$mcp_list" | grep '^codex:' || true)
    if [[ $codex_line == *Connected* ]]; then
        one_line "$codex_line"
        printf '[OK] codex MCP: %s\n' "$REPLY"
    elif [[ -n $codex_line ]]; then
        one_line "$codex_line"
        printf '[FAIL] codex MCP registered but not connected: %s\n' "$REPLY"
        ((failures += 1))
    else
        printf '[FAIL] codex MCP server not registered (claude mcp add --scope user codex -- codex mcp-server)\n'
        ((failures += 1))
    fi
else
    printf '[FAIL] codex MCP check skipped: claude command not available\n'
    ((failures += 1))
fi

if ((failures == 0)); then
    printf 'Summary: all 6 checks passed.\n'
    exit 0
fi

printf 'Summary: %d of 6 checks failed.\n' "$failures"
exit 1
