from file_organizer import FileOrganizer
from program_utils import ProgramUtils


class FileOrganizerController:
    def __init__(self):
        self.organizer = None

    def set_source_folder(self, folder_path):
        self.organizer = FileOrganizer(folder_path)

    def organize_files(self):
        if self.organizer:
            files = ProgramUtils.collect_files(self.organizer.source_folder)
            self.organizer.organize_files_by_exif(files)
            return "Files organized successfully!"
        return "No source folder selected."

    def find_duplicates(self):
        if self.organizer:
            files = ProgramUtils.collect_files_with_os_walk(self.organizer.source_folder)
            self.organizer.find_duplicates(files)
            return "Duplicate files found!"
        return "No source folder selected."

    def correct_file_names(self):
        if self.organizer:
            files = ProgramUtils.collect_files(self.organizer.source_folder)
            self.organizer.correct_file_names(files)
            return "File names corrected successfully!"
        return "No source folder selected."

    def sort_no_exif(self):
        if self.organizer:
            files = ProgramUtils.collect_files(self.organizer.source_folder)
            self.organizer.move_no_exif_files(files)
            return "Files sorted in 'NO EXIF' folder successfully!"
        return "No source folder selected."
