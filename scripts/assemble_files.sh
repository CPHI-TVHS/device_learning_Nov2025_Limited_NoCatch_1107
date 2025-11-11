#!/usr/bin/env bash

source "$(dirname "$0")/config.sh"

SRC=$(get_data_folder)

mapfile -t FILES < <(find "$SRC" -type f -name '*.part*' | sed 's|.*/||; s|\.[^.]*$||' | sort -u)

echo "File assembly started at $(date)" > "$LOG_FILE"

for split_file in "${FILES[@]}"; do
    echo "Assembling file: $split_file" | tee -a "$LOG_FILE"
    cat "$SRC/${split_file}".part_* > "$SRC/${split_file}"
    if [[ $? -eq 0 ]]; then
        echo "Successfully assembled: $split_file" | tee -a "$LOG_FILE"
        rm "$SRC/${split_file}".part_*
    else
        echo "Failed to assemble: $split_file" | tee -a "$LOG_FILE"
    fi
done

echo "File assembly completed at $(date)" >> "$LOG_FILE"
