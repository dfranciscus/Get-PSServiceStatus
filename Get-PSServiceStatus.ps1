function Get-PSServiceStatus {

param (
    [string[]]$ComputerName,
    [string[]]$ServiceName
)

    foreach ($Computer in $ComputerName)
    {
    #Ping computer

    #Get previous status

    #Get current status

    #Compare current and previous status

    #If change in status send mail

    #Write current status to file
    }
}