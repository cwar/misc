$Computername = $env:COMPUTERNAME
$updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$Computername))
$UpdateSearcher = $updatesession.CreateUpdateSearcher()
$searchresult = $updatesearcher.Search("IsInstalled=0")  # 0 = NotInstalled | 1 = Installed

$Updates = If ($searchresult.Updates.Count  -gt 0) {
  #Updates are  waiting to be installed

  $count  = $searchresult.Updates.Count
  Write-Verbose  "Found $Count update\s!"

  #Cache the  count to make the For loop run faster   
  For ($i=0; $i -lt $Count; $i++) {

    #Create  object holding update
    $Update  = $searchresult.Updates.Item($i)

    [pscustomobject]@{
        Title =  $Update.Title
        KB =  $($Update.KBArticleIDs)
        SecurityBulletin = $($Update.SecurityBulletinIDs)
        MsrcSeverity = $Update.MsrcSeverity
        IsDownloaded = $Update.IsDownloaded
        Url =  $Update.MoreInfoUrls
        Categories =  ($Update.Categories  | Select-Object  -ExpandProperty Name)

        BundledUpdates = @($Update.BundledUpdates)|ForEach-Object{
            [pscustomobject]@{
                Title = $_.Title
                DownloadUrl = @($_.DownloadContents).DownloadUrl
            }
        }
    }      
  }
}

$Updates >> missing_updates.txt