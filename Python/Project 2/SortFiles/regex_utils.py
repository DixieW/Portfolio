import re


class RegexUtils:
    @staticmethod
    def correct_file(file):
        """
        Correct the file name by removing unsupported characters.
        """
        corrected_name = re.sub(r'[{}\[\],.()/\\|]', '', file)
        return corrected_name

    @staticmethod
    def regex_date_filter(file):
        """
        Extract date from the filename using regex.
        """
        # Add your regex patterns here
        date_patterns = [
            r'(?<![\d])((20[0-9]{2})[-]?(0[1-9]|1[0-2])[-]?(0[1-9]|[12][0-9]|3[01]))(?![\d])',
            r'(?<![\d])((0[1-9]|[12][0-9]|3[01])[-]?(0[1-9]|1[0-2])[-]?(20[0-9]{2}))(?![\d])',
            r'(?<![\d])((20[0-9]{2})[-]?(0[1-9]|1[0-2]))(?![\d])',
            r'(?<![\d])((0[1-9]|1[0-2])[-]?(20[0-9]{2}))(?![\d])',
        ]
        for pattern in date_patterns:
            match = re.search(pattern, file)
            if match:
                return match.group()
        return None



# Example usage:
# corrected_name = RegexUtils.correct_file("example[123].jpg")
# extracted_date = RegexUtils.extract_date_from_filename("2022-12-25_example.jpg")
