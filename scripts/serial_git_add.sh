#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
pushd "$SCRIPT_DIR/.."

DATA_DIR="$(pwd)/data"
LOGS_DIR="$(pwd)/logs"
mkdir -p "$LOGS_DIR"
DRYRUN=

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) DRYRUN=1 ;;
        --ext) EXT="$2"; shift ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--ext <extension>] [-h|--help]"
            echo "This script adds, commits, and pushes all files with the specified extension in the current directory to a git repository."
            exit 0
            ;;
        *)
            echo "Unknown parameter passed: $1"
            exit 1
            ;;
    esac
    shift
done


DRYRUN=${DRYRUN:-0}
# remove leading dot from extension if present
EXT=${EXT#.}

if [[ $DRYRUN -eq 1 ]]; then
    OUTPUT_LOG="$LOGS_DIR/dryrun-output.log"
else
    OUTPUT_LOG="$LOGS_DIR/output.log"
fi


# Create and modify .gitignore file
if [[ ! -f .gitignore ]]; then
    touch .gitignore
    echo "*output.log" > .gitignore
    echo "*.tar" >> .gitignore
    echo "*.xz" >> .gitignore
fi

# Function to display progress bar
show_progress() {
    local progress=$1
    local total=$2
    local percent=$((progress * 100 / total))
    local bar_length=50
    local filled_length=$((percent * bar_length / 100))
    local bar=$(printf "%-${filled_length}s" "#" | tr ' ' '#')
    local empty=$(printf "%-$((bar_length - filled_length))s" "-" | tr ' ' '-')
    printf "\rProgress: [${bar}${empty}] ${percent}%%"
}

# Function to format time in hours, minutes, and seconds
format_time() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(( (seconds % 3600) / 60 ))
    local seconds=$((seconds % 60))
    printf "%02dh:%02dm:%02ds" $hours $minutes $seconds
}

# Get the list of files matching *.part*
echo "EXT: $EXT"
files=($DATA_DIR/*.$EXT)
total_files=${#files[@]}

if [[ $DRYRUN -eq 1 ]]; then
    echo "[DRYRUN] total_files: $total_files"
fi
start_time=$(date +%s)
PUSH_BATCH_COUNT=25

# Loop through each file and perform git actions
# show_progress 0 $total_files
for ((i=0; i<total_files; i++)); do
    filepath="${files[i]}"
    echo -e "\n\nAdding $filepath ..." >> $OUTPUT_LOG 2>&1
    if [[ $DRYRUN -eq 0 ]]; then
        git add "$filepath" >/dev/null 2>&1
        git commit -m "Added $filepath" >/dev/null 2>&1
        if (( (i + 1) % PUSH_BATCH_COUNT == 0 )) || [[ $i -eq $((total_files - 1)) ]]; then
            git push
            show_progress $((i + 1)) $total_files
            echo -e "\n" "$((i + 1))" "of $total_files"
            sleep .01
        fi
    fi
  
    echo -e "\n$filepath added" >> $OUTPUT_LOG 2>&1

    
    # Estimate time remaining
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    estimated_total_time=$((elapsed_time * total_files / (i + 1)))
    remaining_time=$((estimated_total_time - elapsed_time))
    formatted_remaining_time=$(format_time $remaining_time)
    files_left=$((total_files - i - 1))
    # printf " - Estimated time remaining: %s - Files left: %d" $formatted_remaining_time $files_left | tee -a $OUTPUT_LOG
done


echo -e "\nAll files processed."

echo "done" > DONEFILE.md
git add DONEFILE.md
git commit -m "done"
git push
