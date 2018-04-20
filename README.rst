sign-tap6
=========

A Powershell script for signing or adding signatures to tap-windows6_ drivers. While tap-windows6 buildsystem supports signing catalog files, having a single signature is typically not enough to keep all Windows versions from Vista to 10 happy. Therefore a secondary set of signatures is needed, and that is what script is primarily aimed for. That said, it can handle the entire tap-windows6 signing process by itself, if required.

Usage
=====

First you should be familiar with Windows Authenticode and kernel-mode code-signing requirements. A good place to start is the 
`building tap-windows6 <https://community.openvpn.net/openvpn/wiki/BuildingTapWindows6>`_ page on the OpenVPN community wiki.

Once you're confident that you understand the basics, adapt the *Sign-Tap6.conf.ps* to suit you environment. Then you can run the script with the desired parameters. Usage details from the script's help:

::

    Usage: Sign-Tap6.ps1 -SourceDir <sourcedir> [-Force] [-VerifyOnly] [-Append]

    Example 1: Sign for OpenVPN (OSS)
        Sign-Tap6.ps1 -SourceDir tap6 -Force
    
    Example 2: Sign for OpenVPN Connect (Access Server)
        Sign-Tap6.ps1 -SourceDir tapoas6 -Force
    
    Example 3: Append a signature to a signed driver
        Sign-Tap6.ps1 -SourceDir tap6 -Append

You can view these instructions at any time by running script without parameters. Note that according to Microsoft documentation Inf2Cat, which this script uses to create the (unsigned) catalog files, needs to be run with administrator privileges. I have not verified if this is still the case.

**IMPORTANT:** If you're not appending a signature you **must** use the -Force 
flag. Otherwise the file hashes in the security catalog (.cat) file will not 
match the driver files, which prevents driver installation even though the 
digital signature of the catalog file is valid. The -Force flag removes the 
security catalogs and recreates them, which ensures that they're in sync with 
the actual driver files.

This script is pretty good at validating its environment and bailing out if things have been misconfigured. It will not take any action on already signed files, unless the -Force parameter is given. It also won't append signatures unless -Append is defined.

License
=======

This project uses the BSD license. See the LICENSE file for details.

.. _tap-windows6: https://github.com/OpenVPN/tap-windows6
