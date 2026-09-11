#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Message,
    [switch]$CheckOnly
)

$ErrorActionPreference = 'Stop'
$repo = git rev-parse --show-toplevel
$proj = Join-Path $repo 'AskMyRig'
$conn = 'Server=localhost\MSSQLSERVER01;Database=AskMyRig;Trusted_Connection=True;TrustServerCertificate=True;'

# 1. clear generated folders so dropped objects appear as deletions
Get-ChildItem $proj -Directory |
    Where-Object { $_.Name -ne 'Scripts' } |
    Remove-Item -Recurse -Force

# 2. extract
sqlpackage /a:Extract `
    /scs:"$conn" `
    /tf:"$proj" `
    /p:ExtractTarget=SqlProject `
    /p:ExtractAllTableData=false `
    /p:IgnorePermissions=true `
    /p:IgnoreUserLoginMappings=true `
    /p:IgnoreExtendedProperties=true `
      /p:VerifyExtraction=true
if ($LASTEXITCODE -ne 0) { throw "sqlpackage extract failed ($LASTEXITCODE)" }

# 3. report
git -C $repo add -A -- 'AskMyRig'
$changed = git -C $repo diff --cached --name-status -- 'AskMyRig'
if (-not $changed) {
    Write-Host 'Database matches git. Nothing to sync.'
    git -C $repo reset -q
    return
}

Write-Host "`nChanged:"
$changed | ForEach-Object { Write-Host "  $_" }

if ($CheckOnly) { git -C $repo reset -q; exit 1 }

git -C $repo commit -m $Message
Write-Host "`nCommitted."