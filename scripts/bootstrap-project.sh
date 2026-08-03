#!/usr/bin/env bash

usage() {
    printf 'Usage: %s <target-dir> [--force]\n' "${0##*/}" >&2
}

if (($# < 1 || $# > 2)); then
    usage
    exit 2
fi

target_dir=$1
force=false

if (($# == 2)); then
    if [[ $2 != --force ]]; then
        usage
        exit 2
    fi
    force=true
fi

if [[ ! -d $target_dir ]]; then
    printf 'Error: target directory does not exist: %s\n' "$target_dir" >&2
    exit 2
fi

script_path=${BASH_SOURCE[0]}
if [[ $script_path == */* ]]; then
    script_dir=${script_path%/*}
else
    script_dir=.
fi
project_root=$(cd -- "$script_dir/.." && pwd -P)

processed=0
skipped=0
failures=0

fail_item() {
    local relative_path=$1
    local reason=$2

    reason=${reason//$'\r'/}
    reason=${reason//$'\n'/'; '}
    printf '[FAIL] %s: %s\n' "$relative_path" "$reason" >&2
    ((failures += 1))
}

copy_file() {
    local relative_path=$1
    local source_path=$project_root/$relative_path
    local destination_path=$target_dir/$relative_path

    local error
    if ! error=$(mkdir -p -- "${destination_path%/*}" 2>&1); then
        fail_item "$relative_path" "$error"
        ((processed += 1))
        return
    fi
    if [[ -e $destination_path ]]; then
        if [[ $force == true ]]; then
            if error=$(cp -- "$source_path" "$destination_path" 2>&1); then
                printf '[OVERWRITE] %s\n' "$relative_path"
            else
                fail_item "$relative_path" "$error"
            fi
        else
            printf '[SKIP] %s（已存在）\n' "$relative_path"
            ((skipped += 1))
        fi
    else
        if error=$(cp -- "$source_path" "$destination_path" 2>&1); then
            printf '[COPY] %s\n' "$relative_path"
        else
            fail_item "$relative_path" "$error"
        fi
    fi
    ((processed += 1))
}

new_task_queue() {
    local relative_path=.ai/TASK_QUEUE.md
    local destination_path=$target_dir/$relative_path

    if [[ -e $destination_path && $force == false ]]; then
        printf '[SKIP] %s（已存在）\n' "$relative_path"
        ((skipped += 1))
    else
        local error
        local success_label=NEW
        [[ -e $destination_path ]] && success_label=OVERWRITE
        if ! error=$(mkdir -p -- "${destination_path%/*}" 2>&1); then
            fail_item "$relative_path" "$error"
            ((processed += 1))
            return
        fi
        if ! error=$({
            printf '%s\n' \
                '# Task Queue' \
                '' \
                '> Tech Lead（Claude）維護。每個任務一行，詳細任務單放 `.ai/tasks/<name>.md`。' \
                '> 狀態：`todo` → `in-progress` → `review` → `done`（或 `blocked`，需註明原因）' \
                '' \
                '| # | 任務 | 狀態 | 任務單 | 備註 |' \
                '|---|------|------|--------|------|' \
                > "$destination_path"
        } 2>&1); then
            fail_item "$relative_path" "$error"
            ((processed += 1))
            return
        fi
        printf '[%s] %s\n' "$success_label" "$relative_path"
    fi
    ((processed += 1))
}

ensure_tasks_directory() {
    local relative_path=.ai/tasks/
    local destination_path=$target_dir/.ai/tasks

    if [[ -d $destination_path ]]; then
        printf '[SKIP] %s（已存在）\n' "$relative_path"
        ((skipped += 1))
    else
        local error
        if error=$(mkdir -p -- "$destination_path" 2>&1); then
            printf '[NEW] %s\n' "$relative_path"
        else
            fail_item "$relative_path" "$error"
        fi
    fi
    ((processed += 1))
}

copy_file CLAUDE.md
copy_file AGENTS.md
copy_file .ai/ARCHITECTURE.md
copy_file .ai/DECISIONS.md
copy_file .ai/CODING_RULES.md
copy_file .ai/DELEGATION_TEMPLATE.md
copy_file .ai/REVIEW_CHECKLIST.md
new_task_queue
ensure_tasks_directory

if ((failures == 0)); then
    printf 'Summary: processed %d items; skipped %d.\n' "$processed" "$skipped"
    exit 0
fi

printf 'Summary: processed %d items; skipped %d; failed %d.\n' \
    "$processed" "$skipped" "$failures"
exit 1
