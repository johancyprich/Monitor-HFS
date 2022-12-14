### APPLICATION: DiskIO Library
### VERSION: 1.0.0
### DATE: January 3, 2017
### AUTHOR: Johan Cyprich
### AUTHOR EMAIL: jcyprich@live.com
###   
### LICENSE:
### The MIT License (MIT)
### http://opensource.org/licenses/MIT
###
### Copyright (c) 2014 Johan Cyprich. All rights reserved.
###
### Permission is hereby granted, free of charge, to any person obtaining a copy 
### of this software and associated documentation files (the "Software"), to deal
### in the Software without restriction, including without limitation the rights
### to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
### copies of the Software, and to permit persons to whom the Software is
### furnished to do so, subject to the following conditions:
###
### The above copyright notice and this permission notice shall be included in
### all copies or substantial portions of the Software.
###
### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
### IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
### FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
### AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
### LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
### OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
### THE SOFTWARE.
###
### SUMMARY:
### Disk utilities.

#=[ FUNCTIONS ]=====================================================================================


####################################################################################################
### SUMMARY:
### Deletes files from a folder based on creation date. Set $days to 0 to delete all of the files
### in the folder.
###
### PARAMETERS:
### path (in): Path of folder to delete.
### keep (in): Number of days from the current date to keep the files.
####################################################################################################

function Clean-Folder
{
  param
  (
    [string] $path,
    [int] $keep
  )
  
  Get-Item $path | where { ((Get-Date)-$_.creationTime).days -ge $keep } | Remove-Item -Force -Recurse
}


####################################################################################################
### SUMMARY:
### Moves file to recycle bin.
###
### https://stackoverflow.com/questions/502002/how-do-i-move-a-file-to-the-recycle-bin-using-powershell
####################################################################################################

Add-Type -AssemblyName Microsoft.VisualBasic

function Remove-Item-ToRecycleBin($Path) {
    $item = Get-Item -Path $Path -ErrorAction SilentlyContinue
    if ($item -eq $null)
    {
        Write-Error("'{0}' not found" -f $Path)
    }
    else
    {
        $fullpath=$item.FullName
        Write-Verbose ("Moving '{0}' to the Recycle Bin" -f $fullpath)
        if (Test-Path -Path $fullpath -PathType Container)
        {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($fullpath,'OnlyErrorDialogs','SendToRecycleBin')
        }
        else
        {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($fullpath,'OnlyErrorDialogs','SendToRecycleBin')
        }
    }
}