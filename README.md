Monitor-HFS
===========

Checks if HFS is running. Tries to read spooler_root.log. If this file can't be downloaded, a email notification is sent to alert users in Settings.

Requirements
============
PowerShell 5.x or higher. The template use a class and only PowerShell from this version onwards support this functionality.

Usage
=====
No parameters are required for the script. All of the options are defined in Settings.xml.

./Monitor-HFS