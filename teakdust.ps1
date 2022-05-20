#setup initial queue
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

$printqueue = New-Object System.Collections.Queue
$foldername = New-Object System.Windows.Forms.FolderBrowserDialog

$foldername.ShowDialog()

#getting a list of all files with .dwg extension
foreach ($file in (Get-ChildItem -Path $foldername.SelectedPath -Filter *.dwg -Name))
{
    Write-Host("Adding $file")
    $printqueue.Enqueue($file)
}

#remember when we started looping to check later if newer files exist
$looptime = Get-Date 

while($true) { #loop until stopped
    if ($printqueue.Count)
    {
        Write-Host("Current Queue: $($printqueue.Count)")
        foreach ($item in $printqueue)
        {
            Write-Host($item)
        }

        #print one item each loop then check for new items
        #put your print command here or right below this line
        Write-Host("Printing: " + $printqueue.Dequeue()) 

    } else 
    {
        Write-Host("Queue Empty")
    }

    #get a new list of files that are newer than the last loop time
    foreach ($newfile in (Get-ChildItem -Path $foldername.SelectedPath -Filter *.dwg |Where-Object {$_.LastWriteTime -gt $looptime}))
    {
        if (!$printqueue.Contains($newfile.Name)) #only enqueue if it isn't already in the queue
        {
            Write-Host("Adding $newfile.Name")
            $printqueue.Enqueue($newfile.Name) 
        }
    }

    $looptime = Get-Date #reset to the latest loop time for next comparison
    Start-Sleep -Seconds 10 #adjust to loop as quickly or slowly as you need
    #kill with ctrl+C
}