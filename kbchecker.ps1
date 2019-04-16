##############################################################
# @Author     Aaron Wamsley                                  #                 
# @Date       5/15/18                                        #
# @Purpose    Check for the presence of specific KBs on PCs  #
#                                                            #
# @Update     4/16/19                                        #
#             updated logging to new format.                 #
##############################################################

# Enter KB to be checked here  
$Patch = Read-Host 'Enter the KB number - eg: KB3011780 '

##############################################################
# Global Variables                                           #
##############################################################
$date=Get-Date -format "yyyyMMddHHmm"  
$Filename="$Patch-$date.log"  
$Computers = Get-Content "$PSScriptRoot\computers.txt"  
$Global:logfile = "$PSScriptRoot\logs\$filename"
$Global:loggingLevel = $DEBUG

##############################################################
# Main Execution                                             #
############################################################## 
write-host "logging level set to $loggingLevel"

# Main Loop
write-log $DEBUG "beginning main loop"
foreach ($Computer in $Computers){
    write-log $DEBUG "trying $Computer"
    TRY{
        $sess = New-PSSession $Computer
        write-log $INFO "PSSESION to $Computer established"
        $kb = Invoke-Command -Session $sess -ScriptBlock{"get-hotfix -id $Patch -ErrorAction SilentlyContinue"}
        if($kb){  
            Write-Log $INFO "$patch is installed on $Computer"  
        }else{        
            Write-Log $ERROR "$patch is not installed on $Computer"
        }#end if/else for $kb
        Remove-PSSession $sess
        write-log $INFO "terminating PSSESSION to $Computer"
    }CATCH{  
        Write-Log $ERR "Error occurred processing $computer"
        Write-Log $ERR "Error: $_.Exception.Message"
    } #end try/catch
    write-log $DEBUG "finished with $Computer"
}#end main loop
write-log $DEBUG "ending main loop"
