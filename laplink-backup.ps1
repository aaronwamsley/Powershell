###########################################################
# @Author     Aaron Wamsley                               #                 
# @Date       11/22/17                                    #
# @Purpose    User Laplink PCMover to backup user         #
#             profile settings to NAS                     #
###########################################################

###########################################################
# Global Variables                                        #
###########################################################

$date         = Get-Date -Format "yyyyMMdd"
$name         = "LapLink-Backup"
$scriptDir    = $PSScriptRoot
$logfile      = "$scriptDir\logs\$name$date.txt"
$lapDir       = "\\pnas02fs1\Software\Laplink"
$PCmover      = "$lapDir\PCmover Enterprise\PCmover Client\PCmover.exe"

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
# Filter-User                                             #
# @Purpose - Determine if the user should be backed up.   #
#                                                         #
# @Param $userid - The userid to test                     #
###########################################################
Function Filter-User{
    Param([String]$userid)
    #eliminations
    if($userid.StartsWith('_')){ return $false }
    if($userid.StartsWith('~')){ return $false }
    if($userid.Contains("friartuck")){ return $false }
    if($userid.Contains("MsDtsServer120")) { return $false }
    if($userid.Contains("ReportServer")){ return $false }
    if($userid.Contains("Administrator")){ return $false }
    if($userid.Contains("Support")){ return $false }
    if($userid.Contains("mosbrax")){ return $false }
    if($userid.Contains("public")){ return $false }
    if($userid.Contains("default")){ return $false }

    #else true
    return $true
} #END Filter-User

###########################################################
# Main Execution                                          #
###########################################################

#make sure we have a directory to put logs in.
cd $scriptDir
if(!(Test-Path $scriptDir\logs)){                                                        #if the directory doesn't exist, create it.
            New-Item -ItemType Directory -Force -Path "$scriptdir\logs" >$null
} #END IF

Write-Log $false "Locating user accounts"
$profiles = (Get-WmiObject -Class win32_userprofile -computer $env:computername -ea 0)   #generate a list of all user accounts on the machine
foreach($p in $profiles){
    if($p.special -eq $false){                                                           #filter out special accounts.
        $user = $p.LocalPath.Substring($p.localpath.lastindexof('\')+1)                  #parse account names
        if(Filter-User($user)){                                                      #filter out unwanted accounts
            Write-Log $false "Processing $user"
            try{
                & $PCmover /policyfile "$lapDir\PCmover Enterprise\PCmover Client\policy - source.pol" /env "USERID=$user"
                "$user has been backed up" | Out-File "c:\temp\laplink.log" -Append -Force
                Write-Log $false "$user has been backed up"
            }catch{
                write-host "Caught an exception:" -ForegroundColor Red
                write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
                write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red
                Write-Log $true "$($_.Exception.Message)"
            } #END TRY/CATCH
        } #END IF
    } #END IF
} #END FOREACH
