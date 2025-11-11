#!/usr/bin/env bash

export DATA_FOLDER_NAME="data"
export LOG_FOLDER_NAME="logs"
export SCRIPTS_FOLDER_NAME="scripts"
export LOG_FILE="assemble_files.log"
export MOVE_FILES_LOG_NAME="move_files.log"
export DRYRUN_OUTPUT_LOG_NAME="dryrun-output.log"
export OUTPUT_LOG_NAME="output.log"

export MAX_FILE_SIZE_THRESHOLD=1048576  # 1MB

function get_parent_path() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(dirname "${SCRIPT_DIR}")"
}

function get_data_folder() {
    data_folder="$(get_parent_path)/${DATA_FOLDER_NAME}"
    [[ -d "$data_folder" ]] || { echo "invalid data folder: $data_folder" >&2; exit 1; }
    echo $data_folder
}

function get_log_folder() {
    log_path="$(get_parent_path)/${LOG_FOLDER_NAME}"
    mkdir -p "$log_path"
    echo "$log_path"
}

function get_scripts_folder() {
    echo "$(get_parent_path)/${SCRIPTS_FOLDER_NAME}"
}


echo $(get_data_folder)