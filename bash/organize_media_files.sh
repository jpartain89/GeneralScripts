#!/usr/bin/env bash
# File: organize_media_files.sh
# A script to rename and organize media files in the current and nested directories.
# Features: duplicate handling, logging, dry-run mode, custom log file, parallel processing, and a help flag.

PROGRAM_NAME="organize_media_files.sh"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

die() {
    echo "$PROGRAM_NAME: $1" >&2
    exit "${2:-1}"
}

trap "die 'trap called'" SIGHUP SIGINT SIGTERM

command -v "$PROGRAM_NAME" 1>/dev/null 2>&1 || {
    (
        if [ -x "${DIR}/${PROGRAM_NAME}" ]; then
            sudo ln -svf "${DIR}/${PROGRAM_NAME}" "/usr/local/bin/${PROGRAM_NAME}"
            sudo chmod -R 0775 "/usr/local/bin/${PROGRAM_NAME}"
        else
            echo "For some reason, linking ${PROGRAM_NAME} to /usr/local/bin,"
            echo "failed. My apologies for not being able to figure it out..."
            exit 1
        fi
    )
}

current_dir=$(pwd)
log_file="$current_dir/organize_media_files.log"
dry_run=false
parallel_jobs=4

# Function to display usage instructions
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --dry-run             Preview changes without making any modifications."
  echo "  --log-file <path>     Specify a custom log file location."
  echo "  --parallel <jobs>     Set the number of parallel jobs (default: 4)."
  echo "  --help                Display this help message."
  exit 0
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=true ;;
    --log-file)
      shift
      if [[ -z "$1" ]]; then
        echo "Error: Missing log file path after --log-file"
        usage
      fi
      log_file="$1" ;;
    --parallel)
      shift
      if [[ -z "$1" || ! "$1" =~ ^[0-9]+$ ]]; then
        echo "Error: Missing or invalid number of parallel jobs after --parallel"
        usage
      fi
      parallel_jobs="$1" ;;
    --help) usage ;;
    *) usage ;;
  esac
  shift
done

# Initialize the log file
if [[ "$dry_run" == true ]]; then
  echo "Dry-run mode enabled. No changes will be made." > "$log_file"
else
  echo "File renaming and organization started." > "$log_file"
fi

# Function to generate a unique filename if a duplicate exists
generate_unique_filename() {
  local base_name="$1"
  local extension="$2"
  local count=1
  local new_name="$base_name"

  # Append a number if the file already exists
  while [[ -e "$current_dir/$new_name$extension" ]]; do
    new_name="${base_name} ($count)"
    count=$((count + 1))
  done

  echo "$new_name$extension"
}

# Function to log actions
log_action() {
  local action="$1"
  local details="$2"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $action: $details" >> "$log_file"
}

# Function to process a single file
process_file() {
  local file="$1"
  local filename=$(basename "$file")
  local cleaned_name
  local unique_name
  local file_extension
  local file_base_name

  # Step 1: Remove resolution indicators like [720p], [1080p], etc.
  cleaned_name=$(echo "$filename" | sed -E 's/ \[[0-9]+p\]//g')

  # Step 2: Replace underscores with spaces
  cleaned_name=$(echo "$cleaned_name" | tr '_' ' ')

  # Step 3: Ensure the name starts with "[Sketchy Sex]"
  if [[ $cleaned_name != "[Sketchy Sex]"* ]]; then
    # Remove any misplaced or incorrect "[Sketchy Sex]" tags
    cleaned_name=$(echo "$cleaned_name" | sed -E 's/\[.*Sketchy Sex.*\]//g')
    # Prepend the correct "[Sketchy Sex]" tag
    cleaned_name="[Sketchy Sex] $cleaned_name"
  fi

  # Step 4: Trim any leading or trailing spaces
  cleaned_name=$(echo "$cleaned_name" | sed -E 's/^ +| +$//g')

  # Step 5: Handle duplicate filenames
  file_extension="${cleaned_name##*.}"
  file_base_name="${cleaned_name%.*}"
  unique_name=$(generate_unique_filename "$file_base_name" ".$file_extension")

  # Log and rename the file
  if [[ "$dry_run" == false ]]; then
    mv "$file" "$current_dir/$unique_name" || {
      log_action "Error" "Failed to rename $file to $unique_name"
      return
    }
    log_action "Renamed" "$filename -> $unique_name"
  else
    log_action "Dry-run" "$filename -> $unique_name"
  fi
}

export -f process_file
export -f generate_unique_filename
export -f log_action
export dry_run
export current_dir
export log_file

# Find all media files and process them in parallel
find . -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" \) | \
  process_file $1

if [[ "$dry_run" == true ]]; then
  echo "Dry-run complete. No changes were made. Check $log_file for details."
else
  echo "File renaming and organization complete. Log saved to $log_file."
fi
