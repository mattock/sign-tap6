Param (
    [string]$SourceFile,
    [switch]$VerifyOnly
)

Function Show-Usage {
    Write-Host "Usage: Sign-File.ps1 -SourceFile <file> [-VerifyOnly]"
    Write-Host
    Write-Host "Example 1: Sign tap-windows6 release package"
    Write-Host "    Sign-File.ps1 -SourceFile ..\tap-windows-9.23.2-I601.exe"
    Write-Host
}

Function Verify-Path ([string]$mypath, [string]$msg) {
    if ( ! ($mypath)) {
        Write-Host "ERROR: empty string defined for ${msg}"
        Exit 1
    }
    if (! (Test-Path $mypath)) {
        Write-Host "ERROR: ${msg} not found!"
        Exit 1
    }
}

# Include configuration file
. .\Sign-Tap6.conf.ps1

# Parameter validation
if (! ($SourceFile -and $crosscert)) {
    Show-Usage
    Exit 1
}

Verify-Path $signtool "signtool.exe"
Verify-Path $CrossCert "cross certificate"
Verify-Path $SourceFile "source file"

if ($VerifyOnly) {
    Write-Host "Verification complete"
    Exit 0
}

# Sign the file
$not_signed = ((Get-AuthenticodeSignature $SourceFile).Status -eq "NotSigned")
if ($not_signed) {
	& $signtool sign /v /s My /n $subject /ac $crosscert /as /fd $digest $SourceFile
	& $signtool timestamp /tr $timestamp /td $digest $SourceFile
	& $signtool verify /pa /v $SourceFile
} else {
	Write-Host "${SourceFile} is signed already, not signing it"
}