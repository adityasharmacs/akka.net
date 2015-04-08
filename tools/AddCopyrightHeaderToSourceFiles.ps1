﻿$noticeTemplate = "//-----------------------------------------------------------------------`n// <copyright file=`"[FileName]`" company=`"Typesafe Inc.`">`n//     Copyright (C) 2009-2015 Typesafe Inc. <http://www.typesafe.com>`n//     Original C# code written by Akka.NET project <http://getakka.net/>`n// </copyright>`n//-----------------------------------------------------------------------`n`n"
$tokenToReplace = [regex]::Escape("[FileName]")

Function CreateFileSpecificNotice($sourcePath){
    $fileName = Split-Path $sourcePath -Leaf
    $fileSpecificNotice = $noticeTemplate -replace $tokenToReplace, $fileName
    return $fileSpecificNotice
}

Function SourceFileContainsNotice($sourcePath){
    $copyrightSnippet = [regex]::Escape("<copyright")

    $fileSpecificNotice = CreateFileSpecificNotice($sourcePath)
    $arrMatchResults = Get-Content $sourcePath | Select-String $copyrightSnippet

    if ($arrMatchResults -ne $null -and $arrMatchResults.count -gt 0){
        return $true 
    }
    else{ 
        return $false 
    }
}

Function AddHeaderToSourceFile($sourcePath) {
    # "Source path is: $sourcePath"
    
    $containsNotice = SourceFileContainsNotice($sourcePath)
    # "Contains notice: $containsNotice"

    if ($containsNotice){
        #"Source file already contains notice -- not adding"
    }
    else {
        #"Source file does not contain notice -- adding"
        $noticeToInsert = CreateFileSpecificNotice($sourcePath)

        $fileLines = (Get-Content $sourcePath) -join "`n"
    
        $content = $noticeToInsert + $fileLines

        $content | Out-File $sourcePath -Encoding utf8

    }
}

$startingPath = "..\src"
Get-ChildItem  $startingPath\*.cs -Recurse | Select FullName | Foreach-Object { AddHeaderToSourceFile($_.FullName)}
