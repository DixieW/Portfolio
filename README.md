# Portfolio
Personal projects I've been working on over the years

## ⚠️ Disclaimer
This code is intended for demonstration purposes only and may not be reused without permission.

Use at your own risk. This project is part of a personal learning journey. This applies to all in the root directory.


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
```

## 📦 Dependencies
This script requires ExifTool to extract metadata from media files.
Make sure the exiftool(-k).exe file is located in the same folder as the PowerShell script for it to function properly.
Rename exiftool(-k).exe --> exiftool.exe before use.


# Project 2 : 

## 📁 SortFiles python classes

This is a remake of project 1 (work in progress).
The goal of the project is to work on OOP techniques and to make the previous tool more efficient. 
Also this version does not have dependencies.

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

# UtilityClasses : 

## 📁 Some C# utility static classes 

--- 

# Powershell Functions : 

## 📁 Powershell Functions for specific purpose

---

# Python Functions 

## 📁 Python Functions for utility

---
