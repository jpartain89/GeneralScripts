import os
import shutil
import json
import re
from pathlib import Path
import logging

# Setup logging for file movements and errors
logging.basicConfig(filename='/media/Porn/file_move.log', level=logging.INFO, format='%(asctime)s - %(message)s')
error_log = logging.getLogger('error_logger')
error_handler = logging.FileHandler('/media/Porn/file_move_errors.log')
error_handler.setLevel(logging.ERROR)
error_log.addHandler(error_handler)

# Configuration variables
SOURCE_DIR = '/media/Downloads/syncthing'  # Source directory where the video files are downloaded
TARGET_DIR = '/media/Porn'  # Target directory where videos will be organized by studio
DATABASE_FILE = '/media/Porn/studio_mapping.json'  # JSON database to map studio names to patterns
VIDEO_EXTENSIONS = ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.mpg']  # Supported video file extensions

def load_studio_mapping():
    """
    Loads the studio-to-pattern mapping from the JSON database file.

    Returns:
        dict: A dictionary containing studio names as keys and a list of patterns (keywords/regex) as values.
    """
    if os.path.exists(DATABASE_FILE):
        with open(DATABASE_FILE, 'r') as f:
            return json.load(f)
    return {}

def save_studio_mapping(studio_mapping):
    """
    Saves the updated studio-to-pattern mapping to the JSON database file.

    Args:
        studio_mapping (dict): A dictionary containing updated studio-to-pattern mappings.
    """
    with open(DATABASE_FILE, 'w') as f:
        json.dump(studio_mapping, f, indent=4)

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

def move_video_file(file_path, studio_folder):
    """
    Moves a video file to the appropriate studio folder. Handles duplicate files by moving them to a "duplicates" folder.

    Args:
        file_path (str): The path to the file to be moved.
        studio_folder (str): The studio folder to move the file into.

    Raises:
        Exception: If an error occurs during the file move process (e.g., permissions, invalid paths).
    """
    try:
        # Construct the full destination folder path
        destination_folder = os.path.join(TARGET_DIR, studio_folder)
        os.makedirs(destination_folder, exist_ok=True)  # Ensure the folder exists

        # Determine the destination file path
        destination_file = os.path.join(destination_folder, os.path.basename(file_path))

        # If the file already exists, move it to a "duplicates" folder
        if os.path.exists(destination_file):
            duplicate_folder = os.path.join(destination_folder, 'duplicates')
            os.makedirs(duplicate_folder, exist_ok=True)
            shutil.move(file_path, os.path.join(duplicate_folder, os.path.basename(file_path)))
            logging.info(f"Duplicate file moved to: {duplicate_folder}/{os.path.basename(file_path)}")
        else:
            # Move the file to the destination folder
            shutil.move(file_path, destination_file)
            logging.info(f"File moved to: {destination_file}")
    except Exception as e:
        # Log any errors that occur during the move
        error_log.error(f"Error moving file {file_path}: {str(e)}")
        raise

def process_files():
    """
    Processes all video files in the source directory and moves them to the correct target directories
    based on the studio mapping.
    """
    # Load the studio-to-pattern mapping from the database
    studio_mapping = load_studio_mapping()

    # Walk through the source directory to find all video files
    for root, _, files in os.walk(SOURCE_DIR):
        for file in files:
            # Process only video files based on the supported extensions
            if any(file.endswith(ext) for ext in VIDEO_EXTENSIONS):
                file_path = os.path.join(root, file)  # Get the full path to the file
                print(f"Processing file: {file_path}")

                # Determine the appropriate studio folder for the file
                studio_folder = get_studio_folder(file, studio_mapping)

                # Move the file to the correct folder
                move_video_file(file_path, studio_folder)

if __name__ == "__main__":
    process_files()
