import tkinter as tk
from tkinter import filedialog, messagebox
from tkinter.ttk import Progressbar
from tkinter import StringVar
from controller import FileOrganizerController

class AppGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("File Organizer")
        self.root.geometry("600x400")
        self.root.config(bg='pink')

        self.controller = FileOrganizerController()
        self.source_folder_var = StringVar()

        self.setup_ui()

    def setup_ui(self):
        """Set up the user interface."""
        # Select Source Folder Button
        tk.Button(self.root, text="Select Source Folder",
                  command=self.select_source_folder,
                  bg='pink').pack(pady=10)

        # Display Selected Folder
        self.folder_label = tk.Label(self.root, text="", wraplength=500,
                                     bg='pink')
        self.folder_label.pack(pady=10)

        # Progress Bar
        self.progress_bar = Progressbar(self.root, orient="horizontal",
                                        length=500, mode="determinate",
                                        )
        self.progress_bar.pack(pady=10)

        # Action Buttons
        self.organize_button = tk.Button(self.root, text="Start Organizing",
                                         command=self.start_organizing,
                                         bg='pink')
        self.organize_button.pack(pady=10)

        self.duplicate_button = tk.Button(self.root, text="Find Duplicates",
                                          command=self.find_duplicates,
                                          bg='pink')
        self.duplicate_button.pack(pady=10)

        self.correct_button = tk.Button(self.root, text="Correct Characters",
                                        command=self.correct_characters,
                                        bg='pink')
        self.correct_button.pack(pady=10)

        self.sort_no_exif_button = tk.Button(self.root, text="Sort NO EXIF",
                                             command=self.sort_no_exif,
                                             bg='pink')
        self.sort_no_exif_button.pack(pady=10)

    def select_source_folder(self):
        folder_selected = filedialog.askdirectory()
        if folder_selected:
            self.source_folder_var.set(folder_selected)
            self.folder_label.config(text=f"Selected Folder: {folder_selected}")
            self.controller.set_source_folder(folder_selected)

    def start_organizing(self):
        result = self.controller.organize_files()
        messagebox.showinfo("Completed", result)

    def find_duplicates(self):
        result = self.controller.find_duplicates()
        messagebox.showinfo("Completed", result)

    def correct_characters(self):
        result = self.controller.correct_file_names()
        messagebox.showinfo("Completed", result)

    def sort_no_exif(self):
        result = self.controller.sort_no_exif()
        messagebox.showinfo("Completed", result)

def main():
    root = tk.Tk()
    app = AppGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()
