##############################################################
# @Author     Aaron Wamsley                                  #                 
# @Date       5/15/18                                        #
# @Purpose    Check for the presence of specific KBs on PCs  #
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

##############################################################
# Main Execution                                             #
##############################################################
# Main Loop
foreach ($Computer in $Computers){
    TRY{
        $sess = New-PSSession $Computer
        $kb = Invoke-Command -Session $sess -ScriptBlock{"get-hotfix -id $Patch -ErrorAction SilentlyContinue"}
        if($kb){  
            Write-Log "$patch is installed on $Computer"  
        }else{        
            Write-Log "$patch is not installed on $Computer" $true
        }#end if/else for $kb
        Remove-PSSession $sess
    }CATCH{  
        Write-Log "Error occurred processing $computer" $true
        Write-Log "Error: $_.Exception.Message" $true
    } #end try/catch
}#end main loop
