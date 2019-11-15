######################################################
# @Author     Aaron Wamsley                          #                 
# @Date       3/22/18                                #
#                                                    #
# @Purpose    update java on listed machines         #
# @Params                                            #
#     $inputList: txt file containing a newline      #
#                 sperated list of machines.         #
#                                                    #
######################################################

######################################################
# Global Variables                                   #
######################################################

$inputList = "$PSScriptRoot\machineList.txt"
if(!(Test-Path $PSScriptRoot\logs)){
            New-Item -ItemType Directory -Force -Path "$PSScriptRoot\logs" >$null
}
$datetime = Get-Date -Format "yyyy-MM-dd-HH-mm"
$logfile = "$PSScriptRoot\logs\JavaUPdate-$datetime.log"
$sessions

######################################################
# Functions                                          #
######################################################

######################################################
# Main Execution                                     #
######################################################
Write-Log "mapping software share"
try{
    New-PSDrive -Name "P" -PSProvider "FileSystem" -Root "\\path\to\SoftwareShare\oracle\java\jre\versions\Current"
}catch{
    Write-Log "failed to map software share"
    exit 1
}#end share mapping try/catch

Foreach($machine in Get-Content $inputList){
    $sess
    Write-Log "Establishing connection to $machine..."
    try{
        $sess = New-PSSession $machine
        Write-Log "Successfully established connection to $machine"
    }catch{
        Write-Log "Failed to connect to $machine" $true
        Write-Log "Error: $_.Exception.Message" $true
        break;
    }#end connection try/catch
        
    Write-Log "copying jre to $machine\c\windows\temp\..."
    try{
        Copy-Item -Path "P:\current-jre.exe" -tosession $sess "c:\windows\temp\"
        Write-Log "Successfully copied jre to $machine"
    }catch{
        Write-Log "failed to copy file to $machine" $true
        Write-Log "Error: $_.Exception.Message" $true
        break;
    }#end copy try/catch

    Write-Log "executing upgrade on $Machine..."
    try{
        Invoke-Command -Session $sess -command {Start-Process 'c:\windows\temp\current-jre.exe' -ArgumentList '/s removeoutofdatejres=1' -Verb runAs}
        Write-Log "Successfully executed upgrade command on $machine"
    }catch{
        Write-Log "Failed to upgrade $Machine" $true
        Write-Log "Error: $_.Exception.Message" $true
        break;
    }#end invoke-command try/catch   
}#end foreach machine
Start-Sleep -Seconds 360
Remove-PSDrive "p"
foreach($session in Get-PSSession){
    Write-Log "Removing jre installer from $machine..."
    try{
        Enter-PSSession $sess
        Invoke-Command -Session $sess -command {Remove-Item c:\windows\temp\current-jre.exe}
        Write-Log "Successfully removed installer from $machine"
    }catch{
        Write-Log "Failed to remove JRE from temp file on $machine" $true
        Write-Log "Error: $_.Exception.Message" $true
    }#end removal try/catch
    Write-Log "removing connection to $machine"
    Remove-PSSession $session
}#end foreach session
