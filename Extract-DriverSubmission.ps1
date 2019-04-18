# Produce a tap-windows6 dist directory from attestation signed driver packages
Param (
    [parameter(Mandatory = $true, ValueFromPipeline = $true)] $DriverPackage,
    [string]$DistDir = "${PSScriptRoot}\..\dist"
)

Begin {

    . "${PSScriptRoot}\Verify-Path.ps1"
    . "${PSScriptRoot}\Sign-Tap6.conf.ps1"
    # Get UNIX epoch-style timestamp
    $timestamp = (New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds

    
    # Backup old dist directory
    if (Test-Path $DistDir) {
        Copy-Item $DistDir "${DistDir}.${timestamp}"
    }

    # Check if a signed tapinstall.exe is found. Attestation signing massacres it
    # even if it is included in the submission cabinet file, but signed
    # versions might be available from a previous cross-signing run. If not,
    # they will need to be copied back in.
    # sure that tapinstall.exe is signed.
    $dist_dirs = ((Get-ChildItem -Path $DistDir -Directory)|Where-Object { $_Name -match "^(amd64|arm64|i386)$" }).FullName
    ForEach ($dist_dir in $dist_dirs) {
        Write-Host $dist_dir
        $tapinstall = "${dist_dir}\tapinstall.exe"
        if (! (Test-Path $tapinstall)) {
            Write-Host "ERROR: ${tapinstall} not found!"
            Exit 1
        } else {
            if ((Get-AuthenticodeSignature $tapinstall).Status -ne "Valid") {
                Write-Host "ERROR: No valid authenticode signature found for ${tapinstall}!"
                Exit 1
            }
        }
    }
}

Process {
    # Extract the attestation signed zip file into a temporary directory and
    # copy its contents into the "dist" directory, overwrite any existing files
    # with the same name. This leaves the cross-signed tapinstall.exe intact,
    # but replaces the driver files with attestation-signed versions.
    ForEach ($input in $DriverPackage) {
        Verify-Path $input "driver package"
        $basename = ($DriverPackage).BaseName
        if (Test-Path $basename) {
            Remove-Item -Recurse $basename
        }
        Expand-Archive -Path $DriverPackage -DestinationPath $basename
        Get-ChildItem "${basename}\drivers"|Copy-Item -Force -Recurse -Destination $DistDir
        Remove-Item -Recurse $basename
    }
}