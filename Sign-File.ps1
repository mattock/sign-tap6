# Sign the (installer) file and verify it using non-kernel mode validation
Param (
    [string]$SourceFile
)

Function Show-Usage {
    Write-Host "Usage: Sign-File.ps1 -SourceFile <file>"
    Write-Host
    Write-Host "Example 1: Sign tap-windows6 release package"
    Write-Host "    Sign-File.ps1 -SourceFile ..\tap-windows-9.23.2-I601.exe"
    Write-Host
}

. "${PSScriptRoot}\Sign-Tap6.conf.ps1"
. "${PSScriptRoot}\Verify-Path.ps1"

# Parameter validation
if (! ($SourceFile -and $crosscert)) {
    Show-Usage
    Exit 1
}

Verify-Path $signtool "signtool.exe"
Verify-Path $CrossCert "cross certificate"
Verify-Path $SourceFile "source file"

$not_signed = ((Get-AuthenticodeSignature $SourceFile).Status -eq "NotSigned")
if ($not_signed) {
    & $signtool sign /v /s My /n $subject /ac $crosscert /fd $digest $SourceFile
    & $signtool timestamp /tr $timestamp /td $digest $SourceFile
    & $signtool verify /pa /v $SourceFile
} else {
    Write-Host "${SourceFile} is signed already, not signing it"
}