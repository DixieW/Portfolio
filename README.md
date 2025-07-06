# Portfolio
Personal projects I've been working on over the years

## ⚠️ Disclaimer
This code is intended for demonstration purposes only and may not be reused without permission.

Use at your own risk. This project is part of a personal learning journey.


# Project 1 : 

## 📁 OrganiseerFotosEnVideos.ps1

A PowerShell script with a graphical interface that intelligently sorts photos and videos based on metadata and file naming conventions. Developed as a personal learning project to enhance PowerShell and automation skills.

---

## ⚙️ Features

- Sorts files based on **EXIF date**
- Files without EXIF data are moved to a **`no_exif`** folder
- **Duplicate detection** across main and subfolders:
  - Automatically creates a `duplicates` folder
  - Moves the second occurrence of a duplicate file
- **Regex-based title sorting** using complex date patterns
- **Filename correction** for special characters
- **Graphical User Interface (GUI)**:
  - Browse to source and destination folders
  - Start sorting with a button click

---

## ▶️ Example Usage

Run the script in PowerShell:

```powershell
.\FotoSorter.ps1
