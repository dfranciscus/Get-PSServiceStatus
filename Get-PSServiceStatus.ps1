function Get-PSServiceStatus {

param (
    [string[]]$ComputerName,
    [string]$ServiceName,
    [string]$Path,
    [string]$FromAddress,
    [string]$ToAddress,
    [string]$SmtpServer
)
    # Test ping
    workflow Test-Ping 
    {
        param( 
            [Parameter(Mandatory=$true)] 
            [string[]]$Computers
        )
            foreach -parallel -throttlelimit 150 ($Computer in $Computers) 
            {
                if (Test-Connection -Count 1 $Computer -Quiet -ErrorAction SilentlyContinue) 
                {    
                    $Computer
                }
                else
                {
                    Write-Warning -Message "$Computer not online"
                }
            }
        }
    $ComputerName = Test-Ping -Computers $ComputerName 

    foreach ($Computer in $ComputerName)
    {
    $NewPath = Join-Path -Path $Path -ChildPath $Computer
        #Get previous status
        if (Test-Path -Path $NewPath)
        {
            $PreviousStatus = 'Not Running'
        }
        else 
        {
            $PreviousStatus = 'Running'    
        }

        #Get current status
        $CurrentStatus = Get-Service -Name $ServiceName -ComputerName $Computer | Where-Object {$_.Status -eq 'Running'}
        if ($CurrentStatus)
        {
            $CurrentStatus = 'Running'
        }
        else 
        {
            $CurrentStatus = 'Not Running'    
        }
        
        #Current status running and previous up
        if ($PreviousStatus -eq 'Running' -and $CurrentStatus -eq 'Running')
        {
            Write-Output "$Computer $ServiceName still running"
            Continue
        }

        #Current status running and previous down
        if ($PreviousStatus -eq 'Not Running' -and $CurrentStatus -eq 'Running')
        {
            Write-Warning -Message "$Computer $ServiceName now running"
            Remove-Item -Path $NewPath -Force | Out-Null
            Send-MailMessage -Body ' ' -From $FromAddress -SmtpServer $SmtpServer -Subject "$Computer $ServiceName is now running" -To $ToAddress 
            Continue
        }

        #Current status down and previous down 
        if ($PreviousStatus -eq 'Not Running' -and $CurrentStatus -eq 'Not Running')
        {
            Write-Warning -Message "$Computer $ServiceName still not running"
            New-Item -Path $NewPath -ItemType File -Force | Out-Null
            Continue
        }

        #Current status down and previous up 
        if ($PreviousStatus -eq 'Running' -and $CurrentStatus -eq 'Not Running')
        {
            Write-Warning -Message "$Computer $ServiceName is not running"
            New-Item -Path $NewPath -ItemType File -Force | Out-Null
            Send-MailMessage -Body ' ' -From $FromAddress -SmtpServer $SmtpServer -Subject "$Computer $ServiceName is not running" -To $ToAddress 
            Continue
        }
    }
}