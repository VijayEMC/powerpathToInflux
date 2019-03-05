#$driveOutput = powermt display dev=all
$driveOutput = Get-Content ./driveOutput.txt
$arrayType = $null
$driveName = $null
$arrayId = $null
$pathToDrive = $null
$newDisk = 0

$config = Get-Content -Raw -Path ./powerpathToInflux.json | ConvertFrom-Json

$influxURL = "https://" + $config.influx.ip + ":" + $config.influx.port + "/write?db=" + $config.influx.table 


foreach($line in $driveOutput){

    If($line.StartsWith("Pseudo")){
        If($newDisk){
            $postBody = 'drive_health,arrayType=' + $arrayType + ',arrayId=' + $arrayId + ' value=' + $pathToDrive
            Invoke-WebRequest $influxURL -Method POST -Body $postBody 
            If(!($pathToDrive)){
                Send-MailMessage - From $fromEmail -To $toEmail -Subject $emailSubject -Body $emailBody -SmtpServer $smtpServer
            }
            
        }
        $pos = $line.IndexOf("=")
        $driveName = $line.Substring($pos+1)
        $newDisk=1
        $pathToDrive = 1
        continue
    }
    
    If($line.StartsWith("Symmetrix")){
        $arrayType = "sym"
        $pos = $line.IndexOf("=")
        $arrayId = $line.Substring($pos+1)
        continue
    }
    
    If($line.StartsWith("XtremIO")){
        $arrayType = "xio"
        $pos = $line.IndexOf("=")
        $arrayId = $line.Substring($pos+1)
        continue
    }

    
    If($line | Select-String -Pattern "port" -Quiet){
        if(-Not($line | Select-String -Pattern "active", "alive")){
            $pathtoDrive = 0
            continue
        }
        
    }
    
    
}


