import os
from program_utils import ProgramUtils

# List of image files to test
image_files = [
    "D:/Users/Dixie/Pictures/Test/176158_190907197615812_4422151_o.jpg",
    "D:/Users/Dixie/Pictures/Test/1060-536x354-blur_2.jpg",
    "D:/Users/Dixie/Pictures/Test/237-536x354.jpg"
]

# Test each image file
for image_file in image_files:
    date_taken = ProgramUtils.get_exif_data(image_file)
    if date_taken:
        print(f"The image '{os.path.basename(image_file)}' has EXIF data.")
    else:
        print(f"The image '{os.path.basename(image_file)}' does NOT have EXIF data.")
