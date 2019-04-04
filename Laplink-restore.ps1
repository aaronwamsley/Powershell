###########################################################
# @Author     Aaron Wamsley                               #                 
# @Date       12/1/17                                     #
# @Purpose    User Laplink PCMover to restore a user's    #
#             desktop profile from NAS to a win10 box.    #
###########################################################

###########################################################
# Global Variables                                        #
###########################################################

$date        = Get-Date -Format "yyyyMMdd"
$name        = "LapLink-Restore"
$scriptDir   = $PSScriptRoot
$logfile     = "$scriptDir\logs\$name$date.txt"
$lapDir      = "\\pnas02fs1\Software\Laplink"
$PCmover     = "$lapDir\PCmover Enterprise\PCmover Client\PCmover.exe"
$inputList   = "$scriptDir\UserList.txt"

###########################################################
# Functions                                               #
###########################################################

###########################################################
# Write-Log                                               #
# @Purpose - Takes messages and writes them to a log file #
#            in a uniform and easy to read fashion        #
#                                                         #
# **If no $logfile variable is defined, will try to create#
#   a file in a folder /logs off of the PWD**             #
#                                                         #
# @Param $error - 0 if this is not an error, 1 if it is   #
# @Param $message - message to be written to the log      #
###########################################################
Function Write-Log{
    Param(
        [bool]$error = $false,
        [String]$message        
    )
    
    $longDate = Get-Date -Format "yyyy-MM-dd HH:mm"
    $output
    if($error){
        $output = $longDate + "  *ERROR*  " + $message
    } #END IF
    else{
        $output = $longDate + "           " + $message
    } #END ELSE

    $output | Out-File $logfile -Append -Force
} #END Write-Log

###########################################################
# Main Execution                                          #
###########################################################

#make sure we have a directory to put logs in.
cd $scriptDir
if(!(Test-Path $scriptDir\logs)){                                                        #if the directory doesn't exist, create it.
            New-Item -ItemType Directory -Force -Path "$scriptdir\logs" >$null
} #END IF

Write-Log $false "Importing user list"
foreach($user in Get-Content $inputList){                                                #inport user list
     Write-Log $false "Processing $user"

    try{                                                                         #start pcmover restore
        Start-Process $PCmover -argumentlist "/policyfile `"$lapDir\PCmover Enterprise\PCmover Client\policy - destination.pol`" /env `"USERID=$user`"" -Wait
        Write-Log $false "$user has been restored"
    }catch{
        write-host "Caught an exception:" -ForegroundColor Red
        write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
        write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log $true "$user received error: $($_.Exception.Message)"
    } #END TRY/CATCH
} #END FOREACH
