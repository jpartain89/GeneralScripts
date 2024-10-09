import unittest
import os
import shutil
import json
from file_mover import match_studio, get_studio_folder, move_video_file, save_studio_mapping, load_studio_mapping

# Mock data for test directories and files
TEST_SOURCE_DIR = 'test_source_dir'
TEST_TARGET_DIR = 'test_target_dir'
DATABASE_FILE = 'test_studio_mapping.json'
VIDEO_FILE = 'Test Studio - Test Video.mp4'

class TestFileMover(unittest.TestCase):
    """
    Unit test class for testing the file_mover.py script.
    """

    def setUp(self):
        """
        Setup method to create necessary test directories, files, and mock data.
        Runs before every test case.
        """
        # Create test directories
        os.makedirs(TEST_SOURCE_DIR, exist_ok=True)
        os.makedirs(TEST_TARGET_DIR, exist_ok=True)

        # Create a mock video file
        self.video_file_path = os.path.join(TEST_SOURCE_DIR, VIDEO_FILE)
        with open(self.video_file_path, 'w') as f:
            f.write('test')

        # Setup a sample studio mapping JSON file
        studio_mapping = {
            "Test Studio": ["Test Studio", "AnotherPattern"]
        }
        with open(DATABASE_FILE, 'w') as f:
            json.dump(studio_mapping, f)

    def tearDown(self):
        """
        Tear down method to clean up test directories and files.
        Runs after every test case.
        """
        # Remove test directories and files
        if os.path.exists(TEST_SOURCE_DIR):
            shutil.rmtree(TEST_SOURCE_DIR)
        if os.path.exists(TEST_TARGET_DIR):
            shutil.rmtree(TEST_TARGET_DIR)
        if os.path.exists(DATABASE_FILE):
            os.remove(DATABASE_FILE)

    def test_match_studio(self):
        """
        Test case for matching a filename to a studio based on patterns in the database.
        """
        studio_mapping = load_studio_mapping()
        result = match_studio(VIDEO_FILE, studio_mapping)
        self.assertEqual(result, 'Test Studio', 'Studio should be matched based on filename')

    def test_get_studio_folder_existing(self):
        """
        Test case for retrieving an existing studio folder from the mapping without user input.
        """
        studio_mapping = load_studio_mapping()
        result = get_studio_folder(VIDEO_FILE, studio_mapping)
        self.assertEqual(result, 'Test Studio', 'Should return existing studio without prompt')

    def test_save_studio_mapping(self):
        """
        Test case for saving a new studio mapping to the JSON database.
        """
        studio_mapping = load_studio_mapping()
        new_studio = "New Studio"
        patterns = ["New Pattern"]

        save_studio_mapping(new_studio, patterns)
        updated_mapping = load_studio_mapping()

        self.assertIn(new_studio, updated_mapping, 'New studio should be added to the mapping')
        self.assertEqual(updated_mapping[new_studio], patterns, 'Patterns should match the saved data')

    def test_move_video_file(self):
        """
        Test case for moving a video file to the correct studio folder.
        """
        studio_folder = "Test Studio"
        move_video_file(self.video_file_path, studio_folder)

        destination_file = os.path.join(TEST_TARGET_DIR, studio_folder, VIDEO_FILE)
        self.assertTrue(os.path.exists(destination_file), 'File should be moved to the target directory')

    def test_move_duplicate_file(self):
        """
        Test case for handling duplicate files and moving them to the 'duplicates' folder.
        """
        studio_folder = "Test Studio"
        move_video_file(self.video_file_path, studio_folder)

        # Create a duplicate file and move it again
        duplicate_file_path = os.path.join(TEST_SOURCE_DIR, VIDEO_FILE)
        with open(duplicate_file_path, 'w') as f:
            f.write('duplicate test')

        move_video_file(duplicate_file_path, studio_folder)

        duplicate_folder = os.path.join(TEST_TARGET_DIR, studio_folder, 'duplicates')
        duplicate_file = os.path.join(duplicate_folder, VIDEO_FILE)
        self.assertTrue(os.path.exists(duplicate_file), 'Duplicate file should be moved to the duplicates folder')

    def test_invalid_file_move(self):
        """
        Test case for handling invalid file moves (e.g., non-existent files).
        """
        invalid_file = os.path.join(TEST_SOURCE_DIR, 'non_existent_file.mp4')
        with self.assertRaises(Exception):
            move_video_file(invalid_file, "Test Studio")

if __name__ == '__main__':
    unittest.main()
