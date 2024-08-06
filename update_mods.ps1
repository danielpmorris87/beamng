# Define the URL of the text file containing the list of files
$textFileUrl = "http://yourserver.com/files.txt"

# Define the local directory within the AppData folder for the current user
$localDirectory = Join-Path -Path $env:APPDATA -ChildPath "Roaming\BeamMP-Launcher\Resources"

# Ensure the local directory exists
if (-not (Test-Path -Path $localDirectory)) {
    New-Item -ItemType Directory -Path $localDirectory -Force
}

# Download the text file
$textFileContent = Invoke-WebRequest -Uri $textFileUrl -UseBasicParsing

# Split the content by newlines to get an array of file URLs
$fileUrls = $textFileContent.Content -split "`n"

# Loop through each file URL and sync the file
foreach ($fileUrl in $fileUrls) {
    # Trim any whitespace or newline characters
    $fileUrl = $fileUrl.Trim()
    
    if ($fileUrl) {
        # Get the file name from the URL
        $fileName = [System.IO.Path]::GetFileName($fileUrl)
        
        # Define the local file path
        $localFilePath = Join-Path -Path $localDirectory -ChildPath $fileName

        # Check if the file exists locally
        $fileExists = Test-Path -Path $localFilePath
        
        # Download the file if it doesn't exist locally or if the sizes are different
        $downloadFile = $false
        if ($fileExists) {
            # Compare the file sizes
            $localFileSize = (Get-Item $localFilePath).Length
            $remoteFileSize = (Invoke-WebRequest -Uri $fileUrl -Method Head -UseBasicParsing).Headers["Content-Length"]
            
            if ($localFileSize -ne $remoteFileSize) {
                $downloadFile = $true
            }
        } else {
            $downloadFile = $true
        }

        if ($downloadFile) {
            # Download the file
            Invoke-WebRequest -Uri $fileUrl -OutFile $localFilePath -UseBasicParsing
            Write-Host "Downloaded: $fileUrl to $localFilePath"
        } else {
            Write-Host "File already up-to-date: $localFilePath"
        }
    }
}