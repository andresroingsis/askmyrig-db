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

# SqlPackage won't extract into an existing folder, so extract to a fresh
# temp folder and swap the object folders in.
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('extract-' + [guid]::NewGuid().ToString('N'))

try {
    sqlpackage /a:Extract `
        /scs:"$conn" `
        /tf:"$tmp" `
        /p:ExtractTarget=SqlProject `
        /p:ExtractAllTableData=false `
        /p:IgnorePermissions=true `
        /p:IgnoreUserLoginMappings=true `
        /p:IgnoreExtendedProperties=true `
        /p:VerifyExtraction=true
    if ($LASTEXITCODE -ne 0) { throw "sqlpackage extract failed ($LASTEXITCODE)" }

    # clear generated content, keeping Scripts/ and our own .sqlproj
    Get-ChildItem $proj -Directory | Where-Object { $_.Name -ne 'Scripts' } |
        Remove-Item -Recurse -Force
    Get-ChildItem $proj -File -Filter *.sql | Remove-Item -Force

    # bring the fresh objects in, ignoring the .sqlproj SqlPackage generated
    Get-ChildItem $tmp -Directory | Copy-Item -Destination $proj -Recurse -Force
    Get-ChildItem $tmp -File -Filter *.sql | Copy-Item -Destination $proj -Force
}
finally {
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
}

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