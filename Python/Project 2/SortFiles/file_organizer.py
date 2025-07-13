import os
from logging import exception

from program_utils import ProgramUtils

"""
This file is used for:
- Moving
- Changing
- Fixing
"""



class FileOrganizer:
    def __init__(self, source_folder):
        self.source_folder = source_folder

    def organize_files_by_exif(self, files):
        """Organize files into folders based on EXIF data."""
        source_folder = self.source_folder

        try:
            for file in files:

                file_path = os.path.join(source_folder, file)
                date_taken = ProgramUtils.get_exif_data(file_path)
                print(f"Processing {file_path}, EXIF date taken: {date_taken}")

                if date_taken:
                    dest_path = ProgramUtils.create_date_folder(source_folder, date_taken, file)
                    print(f"Moving to {dest_path}")
                    ProgramUtils.move_file(file_path, dest_path)
                    ProgramUtils.moved_files += 1
                else:
                    print(f"No EXIF data: {file}")
                    no_exif_folder = ProgramUtils.create_no_exif_folder(source_folder)
                    no_exif_dest_path = os.path.join(no_exif_folder, file)
                    ProgramUtils.move_file(file_path, no_exif_dest_path)
                    ProgramUtils.no_exif_files += 1

            ProgramUtils.present_report(files,
                                        ProgramUtils.folders_created,
                                        ProgramUtils.moved_files,
                                        ProgramUtils.total_files_processed,
                                        ProgramUtils.no_exif_files,
                                        ProgramUtils.duplicates_counter)

        except Exception as e:
            print(f"No files found to sort. {e}")

    def find_duplicates(self, files):
        """Find and move duplicate files to a 'Duplicates' folder."""
        source_folder = self.source_folder

        files_with_hash = {}

        try:

            for file_name in files:

                # Create hash value
                file_hash = ProgramUtils.calculate_file_hash(file_name)

                # Check if hash is already found in the files_with_hash list
                if file_hash in files_with_hash:
                    dest_folder = ProgramUtils.create_duplicates_folder(source_folder)
                    dest_path = os.path.join(dest_folder, os.path.basename(file_name))
                    ProgramUtils.move_file(file_name, dest_path)
                    ProgramUtils.duplicates_counter += 1
                    ProgramUtils.total_files_processed += 1
                    print(f"Moved duplicate {file_name} to 'Duplicates' folder")
                    ProgramUtils.duplicate_report_flag_value = True
                else:
                    files_with_hash[file_hash] = file_name

            ProgramUtils.present_report(files,
                                ProgramUtils.folders_created,
                                ProgramUtils.moved_files,
                                ProgramUtils.total_files_processed,
                                ProgramUtils.no_exif_files,
                                ProgramUtils.duplicates_counter)

        except Exception as e:
            print(f"Could not complete: {e}")


    # def correct_file_names(self, collected_files):
    #     """Correct file names by removing unsupported characters."""
    #     for file in collected_files:
    #         corrected_name = RegexUtils.correct_file_name(file)
    #         original_path = os.path.join(self.source_folder, file)
    #         corrected_path = os.path.join(self.source_folder, corrected_name)
    #         if original_path != corrected_path:
    #             os.rename(original_path, corrected_path)
    #             print(f"Renamed {file} to {corrected_name}")

    # def sort_files_no_exif(self, collected_files):
    #     """Sort files in the 'NO EXIF' folder based on dates in filenames."""
    #     no_exif_folder = os.path.join(self.source_folder, "NO EXIF")
    #     if not os.path.exists(no_exif_folder):
    #         print("The 'NO EXIF' folder does not exist.")
    #         return
    #
    #
    #     for file in collected_files:
    #         file_path = os.path.join(no_exif_folder, file)
    #         extracted_date = RegexUtils.extract_date_from_filename(file)
    #         if extracted_date:
    #             year, month = extracted_date.split("-")[:2]
    #             destination_folder = os.path.join(no_exif_folder, f"{year}-{month}")
    #             if not os.path.exists(destination_folder):
    #                 os.makedirs(destination_folder)
    #             dest_path = os.path.join(destination_folder, os.path.basename(file_path))
    #             shutil.move(file_path, dest_path)
    #             print(f"Moved {file_path} to {dest_path} based on date in filename")
    #         else:
    #             print(f"No valid date found in filename: {file}")

# Example usage:
# organizer = FileOrganizer("/path/to/your/folder")
# organizer.organize_files_by_exif()
# organizer.move_no_exif_files()
# organizer.find_duplicates()
# organizer.correct_file_names()
# organizer.sort_files_no_exif()
