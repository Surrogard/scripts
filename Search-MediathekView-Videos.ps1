# base code taken from https://gist.github.com/bagbag/a2888478d27de0e989cf777f81fb33de?permalink_comment_id=3976416#gistcomment-3976416
# added conversion to MP3 via ffmpeg to generate Audiobooks for the kids

$MediathekQuery = @{
    queries = @(
        # fields is cast to array, as some queries require fields to be an array, even if only one value!
        @{fields = @("title"); query = "Hörfassung" }
        @{fields = @("topic"); query = "Schlümpfe" }
        #@{fields = @("channel"); query = "ard" }
    )
    sortBy = "timestamp"
    sortOrder = "desc"
    future = $false # $true or $false
    offset = 0
    size = 10
    #duration_min = 20 # in seconds
    #duration_max = 100 # in seconds
}

if ($PSVersionTable.PSEdition -eq "Desktop") {
    $QueryJSON = $MediathekQuery | ConvertTo-Json -Depth 20
} else {
    #Powershell Core supports a new escaping, which is needed for umlauts in core, but not in 5.1
    $QueryJSON = $MediathekQuery | ConvertTo-Json -Depth 20 -EscapeHandling EscapeNonAscii
}
# Download json results
$Antwort = Invoke-RestMethod -Method Post -Uri "https://mediathekviewweb.de/api/query" -Body $QueryJSON -ContentType "text/plain"
# Setup loop to handle results, be aware that, because of the parallel aproach, messages being written to stdout might not appear.
# If you need status output remove "-ThrottleLimit 5 -Parallel" and add your status messages
# I might change this to a more async aproach later
$Antwort.result.results | Foreach-Object -ThrottleLimit 5 -Parallel {
    $basename = "$($_.topic) - $($_.title)"
    $filename = "$basename$(split-path $($_.url_video_low) -Extension)"
    # Download each file; for my purposes url_video_low is enough quality but you might want to change that to url_video or url_video_hd if you need more
    Invoke-WebRequest -Uri "$($_.url_video_low)" -OutFile "$filename"
    # converting each video to MP3
    ffmpeg -loglevel error -i "$filename" -acodec libmp3lame -vn -b:a 160k "$($basename).mp3"
}

