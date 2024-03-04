#!/bin/bash
set -e

function get_big_folders() {
    echo 'Get big folders' >&2

    du -sx "$DIR"/* | sort -k1 -h | tail -n3 | awk -F/ '{print $(NF)}'
}

function get_ids() {
    local dir="$1"

    echo "Get containers ID for $dir" >&2

    for c in $($CRI ps -q); do
        $CRI inspect "$c" | grep -q "$dir" && echo "$c" || true
    done
}

# get CRI bin
command -v crictl > /dev/null && CRI=crictl || CRI=docker

DIRS=($(get_big_folders))

for dir in "${DIRS[@]}"; do
    ids=($(get_ids "$dir"))

    crictl inspect -o table "${ids[@]}"   \
        | grep 'io.kubernetes.pod.name\s' \
        | awk -F '->' '{print $2}'
done
