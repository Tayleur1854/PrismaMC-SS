cmd.exe /c "fsutil usn readjournal C: csv | findstr /i /c:0x00002000 >> C:\newnamefiles.txt"
cmd.exe /c "fsutil usn readjournal C: csv | findstr /i /c:0x80000200 >> C:\DeletedFiles.txt"

$newFiles = Get-Content "C:\newnamefiles.txt" | ForEach-Object {
    if ($_ -match ',"([^"]+)"') {
        $matches[1]
    }
}

$deletedFiles = Get-Content "C:\DeletedFiles.txt" | ForEach-Object {
    if ($_ -match ',"([^"]+)"') {
        $matches[1]
    }
}

$deletedSet = @{}
foreach ($file in $deletedFiles) {
    $deletedSet[$file] = $true
}

$newFileCounts = @{}
foreach ($file in $newFiles) {
    if ($newFileCounts.ContainsKey($file)) {
        $newFileCounts[$file]++
    } else {
        $newFileCounts[$file] = 1
    }
}

foreach ($entry in $bamEntries) {
    $fileName = $entry.Executables
    $replaces = $false

    if ($newFileCounts.ContainsKey($fileName) -and $newFileCounts[$fileName] -ge 2 -and $deletedSet.ContainsKey($fileName)) {
        $replaces = $true
    }

    $entry | Add-Member -MemberType NoteProperty -Name "Replaces" -Value $replaces
}