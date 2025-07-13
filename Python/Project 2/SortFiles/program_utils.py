import os
import shutil
import time
from datetime import datetime
from hashlib import md5
from logging import exception

from PIL import Image


### Gather data ###
class ProgramUtils:
    folders_created = 0
    moved_files = 0
    total_files_processed = 0
    no_exif_files = 0
    duplicates_counter = 0
    folders_created_flag_value = False
    duplicate_report_flag_value = False
    no_exif_report_flag_value = False

    ### Reporting ###
    @staticmethod
    def reset_report():
        ProgramUtils.folders_created = 0
        ProgramUtils.moved_files = 0
        ProgramUtils.total_files_processed = 0
        ProgramUtils.no_exif_files = 0
        ProgramUtils.duplicates_counter = 0
        # return (ProgramUtils.folders_created,
        #         ProgramUtils.moved_files,
        #         ProgramUtils.total_files_processed,
        #         ProgramUtils.no_exif_files,
        #         ProgramUtils.duplicates_counter)

    @staticmethod
    def check_folders_created_report_flag():
        return ProgramUtils.folders_created_flag_value

    @staticmethod
    def duplicate_report_flag():
        return ProgramUtils.duplicate_report_flag_value

    @staticmethod
    def no_exif_report_flag():
        return ProgramUtils.no_exif_report_flag_value

    @staticmethod
    def reset_bool_value_for_flags():
        ProgramUtils.folders_created_flag_value = False
        ProgramUtils.duplicate_report_flag_value = False
        ProgramUtils.no_exif_report_flag_value = False

    @staticmethod
    def present_report(files, folders_created, moved_files, total_files_processed, no_exif_files, duplicates_counter):
        file_status = ""

        file_status += f"total files found: {ProgramUtils.total_files(files)}\n"
        file_status += f"Total files processed: {total_files_processed}\n"
        if ProgramUtils.duplicate_report_flag() is True:
            file_status += f"Files moved to Duplicates folder: {moved_files}\n"
            file_status += f"Duplicate files found: {duplicates_counter}\n"
        if ProgramUtils.no_exif_report_flag() is True:
            file_status += f"Files moved to 'NO EXIF'  folder: {no_exif_files}\n"
        if ProgramUtils.check_folders_created_report_flag() is True:
            file_status += f"Folders created: {folders_created}\n"

        print(f"Rapport:\n{file_status}")
        ProgramUtils.reset_report()
        ProgramUtils.reset_bool_value_for_flags()


    @staticmethod
    def has_exif(file_path):
        """Check if an image has EXIF data."""
        try:
            image = Image.open(file_path)
            exif_data = image.getexif()
            return exif_data is not None
        except Exception as e:
            print(f"Error reading EXIF data for {file_path}: {e}")
        return False

    @staticmethod
    def exif_data_tags(exif_data):
        """Check specific EXIF date tags."""
        date_tags = [36867, 36868, 306]  # DateTimeOriginal, DateTimeDigitized, DateTime
        for tag in date_tags:
            date_taken = exif_data.get(tag)
            if date_taken:
                print(f"Found EXIF data for tag {tag}: {date_taken}")
                return date_taken.replace(":", "-").split(" ")[0]
        print(f"Available EXIF data: {exif_data}")
        return None

    @staticmethod
    def get_exif_data(file_path):
        """Extract EXIF data."""
        try:
            with Image.open(file_path) as image:
                exif_data = image.getexif()
                if exif_data:
                    ProgramUtils.total_files_processed += 1
                    ProgramUtils.no_exif_report_flag_value = True
                    return ProgramUtils.exif_data_tags(exif_data)
        except Exception as e:
            print(f"Error getting EXIF data from {file_path}: {e}")
        return None

    @staticmethod
    def calculate_file_hash(file_name):
        """Calculate the hash of a file for duplicate detection."""
        hash_obj = md5()
        try:
            with open(file_name, 'rb') as file:
                while chunk := file.read(8192):
                    hash_obj.update(chunk)
            return hash_obj.hexdigest()
        except Exception as e:
            print(f"Error calculating hash for {file_name}: {e}")
            return None

    ### Gather files ###

    @staticmethod
    def collect_files(source_folder):
        files = [f for f in os.listdir(source_folder) if os.path.isfile(os.path.join(source_folder, f))]
        return files

    @staticmethod
    def total_files(files):
        """Count the total amount of files in the folder."""
        return len(files)

    ### Move files ###

    @staticmethod
    def move_file(file_path, dest_path):
        try:
            shutil.move(file_path, dest_path)
            print(f"Moved {file_path} to {dest_path}")
            ProgramUtils.moved_files += 1
        except Exception as e:
            (print(f"Error moving file to {dest_path}: {e}"))

    @staticmethod
    def collect_files_with_os_walk(source_folder):

        file_list = []

        try:
            for root, dirs, files in os.walk(source_folder):

                if "Duplicates" in dirs:
                    dirs.remove("Duplicates")

                for file in files:
                    file_path = os.path.join(root, file)
                    file_list.append(file_path)

            return file_list
        except (PermissionError, FileNotFoundError) as e:
            print(f"Cannot access {source_folder}: {e}")
        except Exception as e:
            print(f"Unexpected error at {source_folder}: {e}")


    ### Create folders ###

    @staticmethod
    def create_date_folder(source_folder, date_taken, file):
        """Create a folder based on the EXIF date if valid."""
        if ProgramUtils.validate_date(date_taken):
            try:
                year, month = date_taken.split("-")[:2]
                destination_folder = os.path.join(source_folder, f"{year}-{month}")
                if not os.path.exists(destination_folder):
                    os.makedirs(destination_folder)
                    time.sleep(1)
                    print(f"Created folder: {destination_folder}")
                    ProgramUtils.folders_created += 1
                    ProgramUtils.folders_created_flag_value = True
                dest_path = os.path.join(destination_folder, file)
                return dest_path
            except exception as e:
                print(f"Unable to create folder based on Year and Month: {e}")
        return None

    @staticmethod
    def validate_date(date_taken):
        """Validate the date to ensure it's between 1950 and now, and month is between 1 and 12."""
        try:
            year, month = map(int, date_taken.split("-")[:2])
            current_year = ProgramUtils.date_limit().year
            if 1950 <= year <= current_year and 1 <= month <= 12:
                return True
            else:
                print(f"Invalid date: {date_taken}")
                return False
        except exception as e:
            print(f"Error validating date: {e}")
            return False

    @staticmethod
    def create_no_exif_folder(source_folder):
        no_exif_folder = os.path.join(source_folder, "NO EXIF")
        if not os.path.exists(no_exif_folder):
            os.makedirs(no_exif_folder)
            time.sleep(1)
            print(f"Created 'NO EXIF' folder at {no_exif_folder}")
            ProgramUtils.folders_created += 1
            ProgramUtils.folders_created_flag_value = True
        return no_exif_folder

    @staticmethod
    def create_duplicates_folder(source_folder):
        duplicates_folder = os.path.join(source_folder, "Duplicates")
        if not os.path.exists(duplicates_folder):
            os.makedirs(duplicates_folder)
            time.sleep(1)
            print(f"Created 'duplicates' folder at {duplicates_folder}")
            ProgramUtils.folders_created += 1
            ProgramUtils.folders_created_flag_value = True
        return duplicates_folder


    ### Datetime specific ###

    @staticmethod
    def date_limit():
        return datetime.today()

