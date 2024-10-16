import os
import re
import signal
import sys
import yaml
import subprocess
from pathlib import Path
import logging

# Setup logging for file movements and errors
logging.basicConfig(filename='file_move.log', level=logging.INFO, format='%(asctime)s - %(message)s')
error_log = logging.getLogger('error_logger')
error_handler = logging.FileHandler('file_move_errors.log')
error_handler.setLevel(logging.ERROR)
error_log.addHandler(error_handler)

# Global flag and counter to track interruptions and number of moved files
interrupted = False
files_moved = 0
CONFIG_FILE = 'config.yml'
current_rsync_process = None  # To track the current rsync process

def handle_signal(signum, frame):
    """
    Signal handler for clean shutdown.
    Sets the global 'interrupted' flag to True when a signal is caught.
    Terminates the current rsync process if it is running.

    Args:
        signum (int): The signal number received.
        frame (frame object): The current stack frame (not used).
    """
    global interrupted
    global current_rsync_process

    interrupted = True  # Mark that we've been interrupted

    if current_rsync_process:
        print("\nTerminating rsync process...")
        current_rsync_process.terminate()  # Gracefully terminate the rsync process
        current_rsync_process.wait()  # Wait for rsync to exit
        print("rsync process terminated.")

    print("\nProcess interrupted. Cleaning up...")

def load_config():
    """
    Loads the configuration from the YAML file. 
    This includes the FROM/TO directories and studio mappings.

    Returns:
        dict: The configuration containing directory paths and studio mappings.
    """
    if not os.path.exists(CONFIG_FILE):
        raise FileNotFoundError(f"Configuration file '{CONFIG_FILE}' not found.")
    
    with open(CONFIG_FILE, 'r') as f:
        config = yaml.safe_load(f)
    
    return config

def save_studio_mapping(studio_mapping):
    """
    Updates the studio mappings in the YAML configuration file.

    Args:
        studio_mapping (dict): Updated studio-to-pattern mappings.
    """
    with open(CONFIG_FILE, 'r') as f:
        config = yaml.safe_load(f)

    # Update studio mappings in the config
    config['studio_mappings'] = studio_mapping

    # Save the updated config back to the file
    with open(CONFIG_FILE, 'w') as f:
        yaml.dump(config, f, default_flow_style=False)

def match_studio(file_name, studio_mapping):
    """
    Matches a filename to a studio based on patterns stored in the studio mapping.

    Args:
        file_name (str): The name of the file to match against.
        studio_mapping (dict): The dictionary of studio names and patterns.

    Returns:
        str: The name of the studio if a match is found, otherwise None.
    """
    file_name_lower = file_name.lower()  # Convert the file name to lowercase for case-insensitive matching
    for studio, patterns in studio_mapping.items():
        for pattern in patterns:
            # Use regex search to match patterns (both keyword and regex)
            if re.search(pattern.lower(), file_name_lower):
                return studio
    return None

def get_studio_folder(file_name, studio_mapping):
    """
    Determines the appropriate studio folder for a given file.
    If the studio isn't found in the mapping, prompts the user for input and updates the mapping.

    Args:
        file_name (str): The name of the file to process.
        studio_mapping (dict): A dictionary of studio-to-pattern mappings.

    Returns:
        str: The name of the studio folder where the file should be moved.
    """
    # Try to match the file name with an existing studio pattern
    matched_studio = match_studio(file_name, studio_mapping)
    if matched_studio:
        return matched_studio

    # If no studio match is found, prompt the user for the correct studio folder
    print(f"Studio not found for file '{file_name}'. Please specify the target folder (or type 'unsorted'): ")
    folder = input().strip()

    # Ask the user to provide patterns for future matching
    print(f"Enter keywords or patterns (comma-separated) that should match '{folder}' in the future:")
    patterns = input().strip().split(',')

    # Update the studio mapping with the new studio and its patterns
    studio_mapping[folder] = patterns
    save_studio_mapping(studio_mapping)

    return folder

def move_video_file(file_path, studio_folder, target_directory):
    """
    Moves a video file to the appropriate studio folder using rsync.
    Rsync will copy the file, display progress, and then delete the source file (effectively moving it).

    Args:
        file_path (str): The path to the file to be moved.
        studio_folder (str): The studio folder to move the file into.
        target_directory (str): The root target directory.

    Raises:
        Exception: If an error occurs during the rsync process.
    """
    global files_moved
    global current_rsync_process  # Track the current rsync process for termination

    try:
        # Construct the full destination folder path
        destination_folder = os.path.join(target_directory, studio_folder)
        os.makedirs(destination_folder, exist_ok=True)  # Ensure the folder exists

        # Use rsync to move the file with progress display and remove the source file after transfer
        rsync_command = [
            'rsync', 
            '--remove-source-files',   # Remove the source file after transfer
            '--progress',              # Show progress during the move
            file_path,                 # Source file path
            destination_folder         # Destination folder path
        ]

        # Execute the rsync command using subprocess.Popen (allows us to terminate)
        current_rsync_process = subprocess.Popen(rsync_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # Capture and print rsync output to the console in real-time
        for line in current_rsync_process.stdout:
            print(line, end='')

        # Wait for rsync to finish
        current_rsync_process.wait()

        if current_rsync_process.returncode == 0:
            logging.info(f"File successfully moved to: {destination_folder}/{os.path.basename(file_path)}")
            files_moved += 1
        else:
            error_log.error(f"Error moving file {file_path} with rsync: {current_rsync_process.stderr.read()}")
            raise Exception(f"Error moving file {file_path}: {current_rsync_process.stderr.read()}")

    except Exception as e:
        # Log any errors that occur during the rsync process
        error_log.error(f"Error moving file {file_path}: {str(e)}")
        raise
    finally:
        current_rsync_process = None  # Reset the current rsync process

def show_progress(current, total, file_name):
    """
    Displays the progress of the file move process in percentage along with the file being moved.

    Args:
        current (int): The current number of files processed.
        total (int): The total number of files to process.
        file_name (str): The name of the file currently being processed.
    """
    percentage = (current / total) * 100
    sys.stdout.write(f"\rMoving file: {file_name} ({current}/{total}) [{percentage:.2f}% complete]")
    sys.stdout.flush()

def log_interruption():
    """
    Logs the interruption of the process, including how many files were moved before the interruption.
    """
    logging.info(f"Process interrupted. {files_moved} files were moved before interruption.")
    print(f"\nProcess interrupted. {files_moved} files were successfully moved before stopping.")

def process_files():
    """
    Processes all video files in the source directory and moves them to the correct target directories
    based on the studio mapping. Displays real-time progress of the move process. Handles clean exit
    in case of signal interruptions.
    """
    global interrupted  # Use the global 'interrupted' flag to track interruptions

    # Load configuration and studio mapping from the YAML file
    config = load_config()
    source_directory = config['directories']['FROM']
    target_directory = config['directories']['TO']
    studio_mapping = config['studio_mappings']

    # Gather all the video files to be processed
    video_files = []
    for root, _, files in os.walk(source_directory):
        for file in files:
            if any(file.endswith(ext) for ext in VIDEO_EXTENSIONS):
                video_files.append((root, file))

    # Track the total number of video files
    total_files = len(video_files)
    current_file = 0

    # Process each video file and track progress
    for root, file in video_files:
        if interrupted:
            log_interruption()  # Log and notify the user about the interruption
            break

        current_file += 1
        file_path = os.path.join(root, file)

        # Show progress for the current file
        show_progress(current_file, total_files, file)

        # Determine the appropriate studio folder for the file
        studio_folder = get_studio_folder(file, studio_mapping)

        # Move the file to the correct folder using rsync
        move_video_file(file_path, studio_folder, target_directory)

    # Ensure the progress bar completes to 100%
    sys.stdout.write("\n")

if __name__ == "__main__":
    # Register signal handlers for SIGINT and SIGTERM
    signal.signal(signal.SIGINT, handle_signal)  # Handle Ctrl+C
    signal.signal(signal.SIGTERM, handle_signal)  # Handle termination signal

    try:
        process_files()  # Start processing files
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        error_log.error(f"Unexpected error: {str(e)}")
