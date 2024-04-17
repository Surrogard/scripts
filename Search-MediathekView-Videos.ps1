$MediathekQuery = @{
    queries = @(
        # fields is casted to array, as some queries require fields to be an array, even if only one value!
        @{fields = @("title"); query = "Hörfassung" }
        @{fields = @("topic"); query = "Schlümpfe" }
        #@{fields = @("channel"); query = "ard" }
    )
    sortBy = "timestamp"
    sortOrder = "desc"
    future = $false # $true or $false
    offset = 0
    size = 5
    #duration_min = 20 # in seconds
    #duration_max = 100 # in seconds
}

if ($PSVersionTable.PSEdition -eq "Desktop") {
    $QueryJSON = $MediathekQuery | ConvertTo-Json -Depth 20
}
else {
    #Powershell Core supports a new escaping, which is needed for umlauts in core, but not in 5.1
    $QueryJSON = $MediathekQuery | ConvertTo-Json -Depth 20 -EscapeHandling EscapeNonAscii
}

$Antwort = Invoke-RestMethod -Method Post -Uri "https://mediathekviewweb.de/api/query" -Body $QueryJSON -ContentType "text/plain"

$Antwort.result.results| Foreach-Object -ThrottleLimit 5 -Parallel {
  #Action that will run in Parallel. Reference the current object via $PSItem and bring in outside variables with $USING:varname
    $basename = "$($_.topic) - $($_.title)"
    $filename = "$basename$(split-path $($_.url_video_low) -Extension)"
    
    Invoke-WebRequest -Uri "$($_.url_video_low)" -OutFile "$filename"
    
    ffmpeg -loglevel quiet -i "$filename" -acodec libmp3lame -vn -b:a 160k "$($basename).mp3"
}

