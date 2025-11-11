#!/usr/bin/env bash

ORIGIN_FOLDER="$1"

if [[ -z "$ORIGIN_FOLDER" ]]; then
    echo "Usage: $0 <origin_folder>"
    exit 1
fi

if [[ ! -d "$ORIGIN_FOLDER" ]]; then
    echo "Origin folder does not exist: $ORIGIN_FOLDER"
    exit 1
fi

if ! ls "$ORIGIN_FOLDER"/*.csv.gz 1> /dev/null 2>&1; then
    echo "Error: No .csv.gz files found in the origin folder: $ORIGIN_FOLDER" | tee -a "$LOG_FILE"
    exit 1
fi

DEST=$(get_data_folder)

if [[ ! -d "$DEST" ]]; then
    echo "Destination directory does not exist: $DEST" | tee -a "$LOG_FILE"
    exit 1
fi

LOG_FILE="$(get_log_folder)/$MOVE_FILES_LOG_NAME"

# Initialize log file
echo "File processing started at $(date)" > "$LOG_FILE"

# Process files
for fh in "$ORIGIN_FOLDER"/*; do 
    if [[ -f "$fh" ]]; then  # Ensure it's a file
        if [[ $(stat -c %s "$fh") -gt $MAX_FILE_SIZE_THRESHOLD ]]; then
            echo "Splitting file: $fh" | tee -a "$LOG_FILE"
            split -b 1M "$fh" "$DEST/$(basename "$fh").part_"
        else
            echo "Copying file: $fh" | tee -a "$LOG_FILE"
            cp "$fh" "$DEST/"
        fi
    fi
done

echo "File processing completed at $(date)" >> "$LOG_FILE"