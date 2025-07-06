<#
.SYNOPSIS
Script om foto's en video's te organiseren, duplicaten te vinden, en bestanden in de 'GEEN EXIF' map te sorteren op basis van datums in de naamgeving.

.DESCRIPTION
Dit script scant een opgegeven map en submappen om foto's en video's te organiseren op basis van EXIF-data en duplicaten te vinden op basis van hun hashwaarden. 
Bestanden zonder EXIF-data kunnen worden gesorteerd op basis van datums in hun naamgeving. Het script controleert en installeert indien nodig PowerShell 7 of hoger en stelt de juiste throttle limiet in op basis van de processorcapaciteit.

.AUTHOR
Dixie Wanner
11-12-2024

.PARAMETER SourceFolder
Het pad naar de hoofdmap die de te scannen bestanden bevat.

.EXAMPLE
Voorbeeld : Organiseer foto's en video's in submappen op basis van jaar en maand.
.\OrganiseerFotosEnVideos.ps1 
#>


param (
    [string]$SourceFolder = (Get-Location),
    [string]$scriptPath = $PSScriptRoot
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Functie om een folder te selecteren
function Select-FolderDialog {
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Selecteer de bronmap die foto's en video's bevat"
    $folderBrowser.ShowNewFolderButton = $true
	
    $result = $folderBrowser.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    } else {
        Write-Host "Geen map geselecteerd."
        return $null
    }
}

# Functie om ExifTool.exe te vinden
function Find-ExifTool {
    $exeName = "exiftool.exe"
    $downloadUrl = "https://www.sno.phy.queensu.ca/~phil/exiftool/$exeName"
    try {
        $scriptPathTool = Join-Path -Path $scriptPath -ChildPath $exeName
        Write-Host "Zoeken in: $scriptPathTool"
    }
    catch {
        write-error $_.Exception.Message
    }
    $foundPath = $null

    # Zoeken in de map van het script
    if (Test-Path -Path $scriptPathTool -PathType Leaf) {
        $foundPath = $scriptPathTool
    }

    # Zoeken in de PATH omgevingsvariabele
    if (-not $foundPath) {
        $envPath = [System.Environment]::GetEnvironmentVariable('PATH')
        foreach ($path in $envPath.Split(';')) {
            $toolPath = Join-Path -Path $path -ChildPath $exeName
            Write-Host "Zoeken in: $toolPath"
            if (Test-Path -Path $toolPath -PathType Leaf) {
                $foundPath = $toolPath
                break
            }
        }
    }

    # Zoeken in andere veelgebruikte directories
    if (-not $foundPath) {
        $commonDirs = @("C:\Program Files", "C:\Program Files (x86)", "C:\Windows\System32")
        foreach ($dir in $commonDirs) {
            $toolPath = Get-ChildItem -Path $dir -Filter $exeName -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($toolPath) {
                $foundPath = $toolPath.FullName
                break
            }
        }
    }

    # Switch statement op basis van gevonden pad
    switch ($foundPath) {
        {$_ -eq $null} {
            Write-Host "ExifTool niet gevonden op de computer. Downloaden van $downloadUrl..."
            try {
                # Download ExifTool.exe van de officiële website
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile($downloadUrl, $scriptPathTool)
                Write-Host "ExifTool gedownload naar: $scriptPathTool"
                return $scriptPathTool
            } catch {
                Write-Host "Fout bij het downloaden van ExifTool: $_"
                return $null
            }
        }
        default {
            Write-Host "ExifTool gevonden in: $foundPath"
            return $foundPath
        }
    }
}

# Functie voor het berekenen van een hash van een bestand.
function Calculate-FileHash {
    param ([string]$filePath)

    try {
        if (-not (Test-Path -Path $filePath)) {
            Write-Host "Bestand niet gevonden: $filePath" -ForegroundColor Red
            return $null
        }

        # Gebruik ingebouwde Get-FileHash cmdlet
        $hash = Get-FileHash -Path $filePath -Algorithm SHA256
        return $hash.Hash
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Fout bij het berekenen van de hash voor bestand $($filePath): $errorMessage" -ForegroundColor Red
        return $null
    }
}

# Maak het hoofdform aan
$form = New-Object System.Windows.Forms.Form
$form.Text = "Organiseer Foto's en Video's"
$form.Size = New-Object System.Drawing.Size(400, 400)
$form.StartPosition = "CenterScreen"

# pad naar icoon
$iconPath = Join-Path -Path $scriptPath -ChildPath "unicorn.ico"
# Controleer of het icoonbestand bestaat en stel het icoon in, anders negeer 
if (Test-Path -Path $iconPath) { 
	$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
}

# Voeg een afbeelding toe rechtsbovenin het formulier 
if (Test-Path -Path $iconPath) { 
	$pictureBoxIcon = New-Object System.Windows.Forms.PictureBox 
	$pictureBoxIcon.Size = New-Object System.Drawing.Size(60, 60) 
	$pictureBoxIcon.Location = New-Object System.Drawing.Point(($form.Width - 95), 20) # 60 to account for padding 
	$pictureBoxIcon.Image = [System.Drawing.Image]::FromFile($iconPath) 
	$pictureBoxIcon.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage 
	$form.Controls.Add($pictureBoxIcon) 
}

# Voeg een afsluiten-knop toe aan je formulier
$buttonExit = New-Object System.Windows.Forms.Button
$buttonExit.Text = "Afsluiten"
$buttonExit.Size = New-Object System.Drawing.Size(75, 20)
$buttonExit.Location = New-Object System.Drawing.Point(280, 320)
$buttonExit.BackColor = [System.Drawing.Color]::Pink
$buttonExit.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonExit.FlatAppearance.BorderColor = [System.Drawing.Color]::DeepPink
$buttonExit.FlatAppearance.BorderSize = 2
$buttonExit.ForeColor = [System.Drawing.Color]::DeepPink
$form.Controls.Add($buttonExit)

# Voeg een voortgangsbalk toe aan je formulier
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10, 280)
$progressBar.Size = New-Object System.Drawing.Size(360, 30)
$form.Controls.Add($progressBar)

# Stel de achtergrondkleur in op roze 
$form.BackColor = [System.Drawing.Color]::Pink

# Maak een functie om knoppen aan te maken met aangepaste stijlen
function CreateButton {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width,
        [int]$height
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Size = New-Object System.Drawing.Size($width, $height)
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.BackColor = [System.Drawing.Color]::Pink
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.FlatAppearance.BorderColor = [System.Drawing.Color]::DeepPink
    $button.FlatAppearance.BorderSize = 2
    $button.ForeColor = [System.Drawing.Color]::DeepPink
    return $button
}

# Maak een label aan
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(360, 20)
$label.Text = "Selecteer de bronmap:"
$label.ForeColor = [System.Drawing.Color]::DeepPink # Tekst kleur aanpassen naar deeppink
$form.Controls.Add($label)

# Maak een knop om de map te selecteren
$buttonSelectFolder = CreateButton "Selecteer Map" 10 50 150 30
$form.Controls.Add($buttonSelectFolder)

# Maak een label aan om de geselecteerde map weer te geven
$labelSelectedFolder = New-Object System.Windows.Forms.Label
$labelSelectedFolder.Location = New-Object System.Drawing.Point(10, 90)
$labelSelectedFolder.Size = New-Object System.Drawing.Size(360, 20)
$labelSelectedFolder.ForeColor = [System.Drawing.Color]::DeepPink # Tekst kleur aanpassen naar deeppink
$form.Controls.Add($labelSelectedFolder)

# Maak een knop aan om het sorteerproces te starten
$buttonSort = CreateButton "Start Sorteren" 10 120 150 40
$form.Controls.Add($buttonSort)

# Maak een knop aan om het duplicaten zoekproces te starten
$buttonDuplicates = CreateButton "Zoek Duplicaten" 170 120 150 40
$form.Controls.Add($buttonDuplicates)

# Maak een knop aan om het proces van het verwijderen van niet-ondersteunde tekens te starten
$buttonCharCorrection = CreateButton "Verwijder Niet-Ondersteunde Tekens" 10 170 150 40
$form.Controls.Add($buttonCharCorrection)

# Maak een knop aan om bestanden in de 'GEEN EXIF' map te sorteren op basis van datums in de bestandsnamen
$buttonSortNoExif = CreateButton "Sorteer GEEN EXIF" 170 170 150 40
$form.Controls.Add($buttonSortNoExif)

# Maak een knop aan om bestanden in de 'GEEN EXIF' map te sorteren op basis van datums in de bestandsnamen
$buttonSortByDateInTitle = CreateButton "Sorteer Datum in Titel" 10 220 150 40
$form.Controls.Add($buttonSortByDateInTitle)

# Creeër variable voor geselecteerde folder
$global:SourceFolder = ""

# Define button click actions

# Map selecteren functie
$buttonSelectFolder.Add_Click({
    $selectedFolder = Select-FolderDialog
    if ($selectedFolder -ne $null) {  # Controleer of de geselecteerde map niet null is
        $global:SourceFolder = $selectedFolder

        # Bepaal de bovenliggende folder en de geselecteerde folder
        $parentFolder = Split-Path -Parent $global:SourceFolder
        $selectedFolderName = Split-Path -Leaf $global:SourceFolder
        $grandParentFolder = Split-Path -Leaf $parentFolder
        $displayPath = "..\$grandParentFolder\$selectedFolderName"

        $labelSelectedFolder.Text = "Geselecteerde map: $displayPath"
        $labelSelectedFolder.Refresh()  # Zorg ervoor dat het label wordt ververst
        Write-Host "Geselecteerde map: $global:SourceFolder"  # Log de geselecteerde map
    } else {
        $global:SourceFolder = $null  # Wis de vorige selectie als geen map is geselecteerd
        $labelSelectedFolder.Text = "Geen map geselecteerd"
        $labelSelectedFolder.Refresh()  # Zorg ervoor dat het label wordt ververst
        Write-Host "Geen map geselecteerd."  # Log geen selectie
    }
})

$buttonSort.Add_Click({
    if (-not $global:SourceFolder) {
        [System.Windows.Forms.MessageBox]::Show("Selecteer eerst een map.", "Fout", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        $SourceFolder = $global:SourceFolder
        
        # Zoek naar ExifTool.exe
        $exifToolPath = Find-ExifTool

        # Controleer of de exiftool aanwezig is
        if (-not $exifToolPath) {
            [System.Windows.Forms.MessageBox]::Show("ExifTool (exiftool.exe) is niet gevonden. Plaats exiftool.exe in dezelfde map als dit script of voeg het toe aan de PATH omgevingsvariabele.", "Fout", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            exit
        } else {
            Write-Host "ExifTool gevonden op: $exifToolPath"
        }

        # Creeër the 'GEEN EXIF' folder
        $noExifFolder = Join-Path -Path $SourceFolder -ChildPath "GEEN EXIF"
        if (-not (Test-Path -Path $noExifFolder)) {
            New-Item -Path $noExifFolder -ItemType Directory   | Out-Null 
        }

        # Get a list of all files in the source folder, excluding subfolders
        $files = Get-ChildItem -Path $SourceFolder -File

        # Initialize counters for processed files and no EXIF
        $totalFiles = $files.Count
        $processedFiles = 0
        $noExifFiles = 0
		$newFolderCreated = 0
		
		# update the progress bar maximum value
		$progressBar.Maximum = $totalFiles
		$progressBar.Value = $filesProcessed

        # Loop through each file and organize them by year and month based on EXIF date
        foreach ($file in $files) {
            # Display the current file being processed
            Write-Host "Processing file: $($file.FullName)"
			
			# Store the baseName in a variable
			$baseName = $file.BaseName
			
            # Check if the file is a photo or video (you can add more extensions if needed)
            if ($file.Extension -match ".jpg|.jpeg|.png|.gif|.bmp|.mp4|.avi|.mov|.mkv|.wmv|.heic|.aae|.3gp") {

                # Use ExifTool to extract the date taken from the file
                $exifDate = & $exifToolPath "-DateTimeOriginal" "-S" "-d" "%Y-%m-%d_%H-%M-%S" $file.FullName
                Write-Host "Extracted EXIF date: $exifDate"

                if (-not [string]::IsNullOrWhiteSpace($exifDate)) {
                    # Remove the "DateTimeOriginal:" prefix
                    $exifDate = $exifDate -replace "DateTimeOriginal:\s*", ""
                    Write-Host "Formatted EXIF date: $exifDate"

                    # Define the destination folder based on the EXIF date
                    $yearMonth = $exifDate.Substring(0, 7) # Extract the YYYY-MM part
                    $destinationFolder = Join-Path -Path $SourceFolder -ChildPath $yearMonth  

                    # Create the destination folder if it doesn't exist
                    if (-not (Test-Path -Path $destinationFolder)) {
                        New-Item -Path $destinationFolder -ItemType Directory   | Out-Null
                        Write-Host "Created destination folder: $destinationFolder"
						$newFolderCreated++
                    }

                    # Define the new file name with baseName
                    $newFileName = "${exifDate}-${baseName}$($file.Extension)"
                    $newFilePath = Join-Path -Path $destinationFolder -ChildPath $newFileName  

                    # Check if the new file name already exists and make it unique
                    $counter = 1
                    while (Test-Path -Path $newFilePath) {
                        $newFileName = "${exifDate}-${baseName}($counter)$($file.Extension)"
                        $newFilePath = Join-Path -Path $destinationFolder -ChildPath $newFileName  
                        $counter++
                    }

                    # Move and rename the file
                    try {
                        Move-Item -Path $file.FullName -Destination $newFilePath -Force -ErrorAction Stop  
                        Write-Host "Moved and renamed file: $($file.FullName) to: $newFilePath"
                        if (Test-Path -Path $newFilePath -PathType Leaf) {
                            Write-Host "Verified file exists at destination: $newFilePath" -ForegroundColor Green
                        } else {
                            Write-Host "File does not exist at destination after move: $newFilePath" -ForegroundColor Red
                        }
                    } catch {
                        Write-Host "Error moving file: $($file.FullName) - $_" -ForegroundColor Red
                    }
                } else {
                    # Log file moving to 'GEEN EXIF' folder for files without EXIF date
                    Write-Host "No EXIF date found for file: $($file.FullName) - Moving to 'GEEN EXIF' folder" -ForegroundColor Yellow
                    # Move the file to the 'GEEN EXIF' folder
                    try {
                        Move-Item -Path $file.FullName -Destination $noExifFolder -Force -ErrorAction Stop  
                        Write-Host "No EXIF date found - Moved file: $($file.FullName) (Type: $($file.Extension)) to: $noExifFolder" -ForegroundColor Cyan
                        $noExifFiles++
                        if (Test-Path -Path (Join-Path -Path $noExifFolder -ChildPath $file.Name  ) -PathType Leaf) {
                            Write-Host "Verified file exists at destination: $(Join-Path -Path $noExifFolder -ChildPath $file.Name)" -ForegroundColor Green
                        } else {
                            Write-Host "File does not exist at destination after move: $(Join-Path -Path $noExifFolder -ChildPath $file.Name)" -ForegroundColor Red
                        }
                    } catch {
                        Write-Host "Error moving file: $($file.FullName) - $_" -ForegroundColor Red
                    }
                }
            } else {
                Write-Host "File is not a supported photo or video: $($file.FullName)"
            }

            # Update and display the progress
            $processedFiles++
            Write-Host "Processed $processedFiles of $totalFiles files."
        }

        # Display the results
        Write-Host "Total files processed: $processedFiles"
        Write-Host "Files moved to 'GEEN EXIF': $noExifFiles"
		Write-host "Folders created : $newFolderCreated"
        Write-Host "Organizing complete."
        
        # Show a message box when done
        [System.Windows.Forms.MessageBox]::Show("Bestanden zijn gesorteerd.", "Gereed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})

$buttonDuplicates.Add_Click({
    if (-not $global:SourceFolder) {
        [System.Windows.Forms.MessageBox]::Show("Selecteer eerst een map.", "Fout", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        $SourceFolder = $global:SourceFolder

        # Create the 'Duplicates' folder
        $duplicateFolder = Join-Path -Path $SourceFolder -ChildPath "Duplicates"
        if (-not (Test-Path -Path $duplicateFolder)) {
            New-Item -Path $duplicateFolder -ItemType Directory | Out-Null
        }

        $filesSourcefolder = @()
        $filesSubfolder = @()

        # Get a list of all files in the source folder and its subfolders, excluding the 'Duplicates' folder
        $filesSourcefolder = Get-ChildItem -Path $SourceFolder -File | Where-Object { $_.FullName -notlike "*\Duplicates\*" }
        $filesSubfolder = Get-ChildItem -Path $SourceFolder -Recurse -File | Where-Object { $_.DirectoryName -ne $SourceFolder -and $_.FullName -notlike "*\Duplicates\*" }

        # Initialize counters for processed files and duplicates
        $totalFiles = $filesSourcefolder.Count + $filesSubfolder.Count
        $processedFiles = 0
        $duplicateFiles = 0

        # Initialize a dictionary to keep track of file hashes
        $hashTable = @{}

        # Update the progress bar maximum value
        $progressBar.Maximum = $filesSourcefolder.Count
        $progressBar.Value = $processedFiles
        
        # Build hash table for subfolder files
        foreach ($subFile in $filesSubfolder) {
            if ($subFile.Extension -match ".jpg|.jpeg|.png|.gif|.bmp|.mp4|.avi|.mov|.mkv|.wmv|.heic|.aae|.3gp") {
                $hash = Calculate-FileHash $subFile.FullName
            if ($hash -ne $null -and -not $hashTable.ContainsKey($hash)) {
                $hashTable[$hash] = $subFile.FullName
                }
            }
        }

        # Loop through each file and check for duplicates
        foreach ($file in $filesSourcefolder) {
            # Display the current file being processed
            Write-Host "Processing file: $($file.FullName)"

            # Check if the file is a photo or video (you can add more extensions if needed)
            if ($file.Extension -match ".jpg|.jpeg|.png|.gif|.bmp|.mp4|.avi|.mov|.mkv|.wmv|.heic|.aae|.3gp") {
                # Calculate the hash of the current file
                $fileHash = Calculate-FileHash $file.FullName

                # Check if the hash already exists in the hashTable
                if ($fileHash -ne $null -and $hashTable.ContainsKey($fileHash)) {
                    # Duplicate found, move the file to the 'Duplicates' folder
                    $duplicatePath = Join-Path -Path $duplicateFolder -ChildPath $file.Name
                    $counter = 1
                    while (Test-Path -Path $duplicatePath) {
                        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                        $extension = [System.IO.Path]::GetExtension($file.Name)
                        $duplicatePath = Join-Path -Path $duplicateFolder -ChildPath "${baseName}_duplicate_$counter${extension}"
                        $counter++
                    }

                    Move-Item -Path $file.FullName -Destination $duplicatePath
                    Write-Host "Duplicate file found: $($file.FullName) - Moved to: $duplicatePath" -ForegroundColor Yellow
                    $duplicateFiles++
                } elseif ($fileHash -ne $null) {
                    # Add the hash and file path to the hashTable
                    $hashTable[$fileHash] = $file.FullName
                }
            } else {
                Write-Host "File is not a supported photo or video: $($file.FullName)"
            }

            # Update and display the progress
            $processedFiles++
            Write-Host "Processed $processedFiles of $($filesSourcefolder.Count) files."
            
        }

        # Display the results
        Write-Host "Total files processed: $processedFiles"
        Write-Host "Duplicate files found: $duplicateFiles"
        Write-Host "Duplicate search complete."

        # Show a message box when done
        [System.Windows.Forms.MessageBox]::Show("Duplicaten zijn gevonden.", "Gereed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})


$buttonCharCorrection.Add_Click({
	if (-not $global:SourceFolder) {
        [System.Windows.Forms.MessageBox]::Show("Selecteer eerst een map.", "Fout", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        $SourceFolder = $global:SourceFolder
		# Get a list of all files in the source folder, excluding subfolders
		$files = Get-ChildItem -Path $SourceFolder -File
		$totalfiles = $files.Count
		
		$processedFiles = 0
		$filesRenamed = 0
		
		# Update the progress bar maximum value
		$progressBar.Maximum = $totalFiles
		$progressBar.Value = $processedFiles
		
		# Loop through each file and rename based on the regex filter
		foreach ($file in $files) {
			# Check if the file has the specified extensions
			if ($file.Extension -match ".jpg|.jpeg|.png|.gif|.bmp|.mp4|.avi|.mov|.mkv|.wmv|.heic|.aae|.3gp") {
				# Define the new file name
				$baseName = $file.BaseName -replace '[\[\]\(\)\.\,]', '' # Apply the regex filter
				$newFileName = "${baseName}$($file.Extension)"
				$newFilePath = Join-Path -Path $SourceFolder -ChildPath $newFileName

				# Rename the file
				try {
					Rename-Item -Path $file.FullName -NewName $newFileName -Force -ErrorAction Stop
					Write-Host "Hernoemd bestand: $($file.FullName) naar: $newFilePath" -ForegroundColor Green
					$filesRenamed++
				} catch {
					Write-Host "Fout bij het hernoemen van bestand: $($file.FullName) - $_" -ForegroundColor Red
				}
			} else {
				Write-Host "Bestand niet hernoemd (niet ondersteunde extensie): $($file.FullName)"
			}
			$processedFiles++
			Write-Host "Processed $processedFiles of $totalFiles files."		
		}

		Write-Host "Hernoemen voltooid."
		
	}
	# Display the results
		Write-Host "Total files count: $totalFiles"
        Write-Host "Total files processed: $processedFiles"
        Write-Host "Files renamed : $filesRenamed"
})

$buttonSortNoExif.Add_Click({
    if (-not $global:SourceFolder) {
        [System.Windows.Forms.MessageBox]::Show("Selecteer eerst een map.", "Fout", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        $SourceFolder = $global:SourceFolder
        $noExifFolder = Join-Path -Path $SourceFolder -ChildPath "GEEN EXIF"

        if (-not (Test-Path -Path $noExifFolder)) {
            [System.Windows.Forms.MessageBox]::Show("De 'GEEN EXIF' map bestaat niet.", "Fout", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        $currentYear = (Get-Date).Year
        $files = Get-ChildItem -Path $noExifFolder -File
        
        $totalFiles = $files.Count
        $filesProcessed = 0
        $filesSortedByName = 0
        $foldersCreated = 0
        
        $progressBar.Maximum = $totalFiles
        $progressBar.Value = $filesProcessed

        foreach ($file in $files) {
            Write-Host "Processing file: $($file.FullName)"
            $matches = [regex]::Matches($file.BaseName, '(?<![\d])((20[0-9]{2})[-]?(0[1-9]|1[0-2])[-]?(0[1-9]|[12][0-9]|3[01]))(?![\d])|(?<![\d])((0[1-9]|[12][0-9]|3[01])[-]?(0[1-9]|1[0-2])[-]?(20[0-9]{2}))(?![\d])|(?<![\d])((20[0-9]{2})[-]?(0[1-9]|1[0-2]))(?![\d])|(?<![\d])((0[1-9]|1[0-2])[-]?(20[0-9]{2}))(?![\d])')

            if ($matches.Count -eq 0) {
                Write-Host "No matches found in filename: $($file.FullName)"
            }

            $dates = @()
            foreach ($match in $matches) {
                Write-Host "Match found: $($match.Value)"
                if ($match.Groups[2].Success) {
                    $year = $match.Groups[2].Value
                    $month = $match.Groups[3].Value
                    $day = $match.Groups[4].Value
                } elseif ($match.Groups[6].Success) {
                    $day = $match.Groups[6].Value
                    $month = $match.Groups[7].Value
                    $year = $match.Groups[8].Value
                } elseif ($match.Groups[10].Success) {
                    $year = $match.Groups[10].Value
                    $month = $match.Groups[11].Value
                    $day = $null
                } elseif ($match.Groups[13].Success) {
                    $month = $match.Groups[13].Value
                    $year = $match.Groups[14].Value
                    $day = $null
                }
                
                Write-Host "Extracted date - Year: $year, Month: $month, Day: $day"
                
                # Controleer of de gevonden datum geen deel uitmaakt van een langere cijferreeks
                $fullMatch = $match.Value
                $preMatch = $file.BaseName.Substring(0, $file.BaseName.IndexOf($fullMatch))
                $postMatch = $file.BaseName.Substring($file.BaseName.IndexOf($fullMatch) + $fullMatch.Length)
                
                if ($preMatch -notmatch '\d$' -and $postMatch -notmatch '^\d') {
                    if ($year -ge 1900 -and $year -le $currentYear) {
                        $dates += [PSCustomObject]@{ Year = $year; Month = $month; Day = $day }
                        Write-Host "Valid date found: $($match.Value)"
                    }
                } else {
                    Write-Host "Invalid date found due to surrounding digits: $($match.Value)"
                }
            }

            if ($dates.Count -gt 0) {
                foreach ($date in $dates) {
                    $destinationFolder = Join-Path -Path $SourceFolder -ChildPath "$($date.Year)-$($date.Month)"
                    if (-not (Test-Path -Path $destinationFolder)) {
                        New-Item -Path $destinationFolder -ItemType Directory | Out-Null
                        Write-Host "Created destination folder: $destinationFolder"
                        $foldersCreated++
                    }

                    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                    $extension = [System.IO.Path]::GetExtension($file.Name)
                    $newFilePath = Join-Path -Path $destinationFolder -ChildPath $file.Name

                    $counter = 1
                    while (Test-Path -Path $newFilePath) {
                        $newFileName = "${baseName}_duplicate_$counter${extension}"
                        $newFilePath = Join-Path -Path $destinationFolder -ChildPath $newFileName
                        $counter++
                    }

                    try {
                        Move-Item -Path $file.FullName -Destination $newFilePath -Force -ErrorAction Stop
                        if (Test-Path -Path $newFilePath) {
                            Write-Host "Moved file: $($file.FullName) to: $newFilePath" -ForegroundColor Green
                            $filesSortedByName++
                        } else {
                            Write-Host "Failed to verify move: $newFilePath does not exist" -ForegroundColor Red
                        }
                    } catch {
                        Write-Host "Error moving file: $($file.FullName) - $_" -ForegroundColor Red
                    }
                }
            } else {
                Write-Host "No valid date found in filename: $($file.FullName)"
            }
            $filesProcessed++
            Write-Host "Processed $filesProcessed of $totalFiles files."
            
        }

        [System.Windows.Forms.MessageBox]::Show("Bestanden in 'GEEN EXIF' zijn gesorteerd.", "Gereed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Write-Host "Total files count: $totalFiles"
        Write-Host "Total files processed: $filesProcessed"
        Write-Host "Files renamed : $filesSortedByName"
        Write-Host "New folders created : $foldersCreated"
    }
})

$buttonSortByDateInTitle.Add_Click({
    if (-not $global:SourceFolder) {
        [System.Windows.Forms.MessageBox]::Show("Selecteer eerst een map.", "Fout", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        $SourceFolder = $global:SourceFolder
        
        $currentYear = (Get-Date).Year
        $files = Get-ChildItem -Path $SourceFolder -File
        
        $totalFiles = $files.Count
        $filesProcessed = 0
        $filesSortedByName = 0
        $foldersCreated = 0
        
        $progressBar.Maximum = $totalFiles
        $progressBar.Value = $filesProcessed

        foreach ($file in $files) {
            Write-Host "Processing file: $($file.FullName)"
            $matches = [regex]::Matches($file.BaseName, '(?<![\d])((20[0-9]{2})[-]?(0[1-9]|1[0-2])[-]?(0[1-9]|[12][0-9]|3[01]))(?![\d])|(?<![\d])((0[1-9]|[12][0-9]|3[01])[-]?(0[1-9]|1[0-2])[-]?(20[0-9]{2}))(?![\d])|(?<![\d])((20[0-9]{2})[-]?(0[1-9]|1[0-2]))(?![\d])|(?<![\d])((0[1-9]|1[0-2])[-]?(20[0-9]{2}))(?![\d])')

            if ($matches.Count -eq 0) {
                Write-Host "No matches found in filename: $($file.FullName)"
            }

            $dates = @()
            foreach ($match in $matches) {
                Write-Host "Match found: $($match.Value)"
                if ($match.Groups[2].Success) {
                    $year = $match.Groups[2].Value
                    $month = $match.Groups[3].Value
                    $day = $match.Groups[4].Value
                } elseif ($match.Groups[6].Success) {
                    $day = $match.Groups[6].Value
                    $month = $match.Groups[7].Value
                    $year = $match.Groups[8].Value
                } elseif ($match.Groups[10].Success) {
                    $year = $match.Groups[10].Value
                    $month = $match.Groups[11].Value
                    $day = $null
                } elseif ($match.Groups[13].Success) {
                    $month = $match.Groups[13].Value
                    $year = $match.Groups[14].Value
                    $day = $null
                }
                
                Write-Host "Extracted date - Year: $year, Month: $month, Day: $day"
                
                # Controleer of de gevonden datum geen deel uitmaakt van een langere cijferreeks
                $fullMatch = $match.Value
                $preMatch = $file.BaseName.Substring(0, $file.BaseName.IndexOf($fullMatch))
                $postMatch = $file.BaseName.Substring($file.BaseName.IndexOf($fullMatch) + $fullMatch.Length)
                
                if ($preMatch -notmatch '\d$' -and $postMatch -notmatch '^\d') {
                    if ($year -ge 1900 -and $year -le $currentYear) {
                        $dates += [PSCustomObject]@{ Year = $year; Month = $month; Day = $day }
                        Write-Host "Valid date found: $($match.Value)"
                    }
                } else {
                    Write-Host "Invalid date found due to surrounding digits: $($match.Value)"
                }
            }

            if ($dates.Count -gt 0) {
                foreach ($date in $dates) {
                    $destinationFolder = Join-Path -Path $SourceFolder -ChildPath "$($date.Year)-$($date.Month)"
                    if (-not (Test-Path -Path $destinationFolder)) {
                        New-Item -Path $destinationFolder -ItemType Directory | Out-Null
                        Write-Host "Created destination folder: $destinationFolder"
                        $foldersCreated++
                    }

                    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
                    $extension = [System.IO.Path]::GetExtension($file.Name)
                    $newFilePath = Join-Path -Path $destinationFolder -ChildPath $file.Name

                    $counter = 0
                    $newFileName = "${baseName}${extension}"
                    while (Test-Path -Path $newFilePath) {
                        $counter++
                        $newFileName = "${baseName}$counter${extension}"
                        $newFilePath = Join-Path -Path $destinationFolder -ChildPath $newFileName
                    }

                    try {
                        Move-Item -Path $file.FullName -Destination $newFilePath -Force -ErrorAction Stop
                        if (Test-Path -Path $newFilePath) {
                            Write-Host "Moved file: $($file.FullName) to: $newFilePath" -ForegroundColor Green
                            $filesSortedByName++
                        } else {
                            Write-Host "Failed to verify move: $newFilePath does not exist" -ForegroundColor Red
                        }
                    } catch {
                        Write-Host "Error moving file: $($file.FullName) - $_" -ForegroundColor Red
                    }
                }
            } else {
                Write-Host "No valid date found in filename: $($file.FullName)"
            }
            $filesProcessed++
            Write-Host "Processed $filesProcessed of $totalFiles files."
        }

        [System.Windows.Forms.MessageBox]::Show("Bestanden zijn gesorteerd op basis van datum in titel.", "Gereed", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        Write-Host "Total files count: $totalFiles"
        Write-Host "Total files processed: $filesProcessed"
        Write-Host "Files sorted by title : $filesSortedByName"
        Write-Host "New folders created : $foldersCreated"
    }
})
# Voeg een actie toe aan de afsluiten-knop
$buttonExit.Add_Click({
    $form.Close()
})

# Show the form
$form.ShowDialog()
