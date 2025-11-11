#!/usr/bin/env bash

DATA_FOLDER_NAME="data"
LOG_FOLDER_NAME="logs"
SCRIPTS_FOLDER_NAME="scripts"
LOG_FILE=assemble_files.log
MOVE_FILES_LOG_NAME=move_files.log

MAX_FILE_SIZE_THRESHOLD=1048576  # 1MB

function get_parent_path() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(dirname "${SCRIPT_DIR}")"
}

function get_data_folder() {
    data_folder="$(get_parent_path)/${DATA_FOLDER_NAME}"
    [[ -d "$data_folder" ]] || echo "invalid data folder: $data_folder" && exit 1
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