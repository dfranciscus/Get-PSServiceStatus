# Get-PSServiceStatus
Monitor windows services with PowerShell. Use with multiple computers and sends alerts if service status has changed.

Keeps track of last service status by creating text file if service is down, and deleted file if service is up.

Use cases:
- Query service status after patching
- Use for SMB's that do not need full monitoring solution
