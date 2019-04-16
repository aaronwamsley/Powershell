##############################################################
# @Author     Aaron Wamsley                                  #                 
# @Date       5/15/18                                        #
# @Purpose    Check for the presence of specific KBs on PCs  #
#                                                            #
# @Update     4/16/19                                        #
#             updated logging to new format.                 #
##############################################################

##############################################################
# Global Variables                                           #
##############################################################
$date=Get-Date -format "yyyy-MM-d"  
$Filename="Patchinfo-$($date)"  
$Computers = Get-Content "c:\scripts\powershell\kbchecker\computers.txt"  
$logdir = "c:\scripts\powershell\kbchecker\logs"
# Enter KB to be checked here  
$Patch = Read-Host 'Enter the KB number - eg: KB3011780 ' 
$loggingLevel = $WARNING

##############################################################
# Main Execution                                             #
##############################################################
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
        Write-Log $ERROR "Error occurred processing $computer"
        Write-Log $ERROR "Error: $_.Exception.Message"
    } #end try/catch
    write-log $DEBUG "finished with $Computer"
}#end main loop
write-log $DEBUG "ending main loop"
