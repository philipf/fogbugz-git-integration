' Fix FogBugz util.asp for use with gitweb
'
' Usage:
' 	cscript FixFogBugzUtilAsp.vbs <fb install dir>
'	If <fb install dir> is not specified it will look for the file in the default FB install directory: 
'		C:\Program Files\FogBugz\
'
' Author : Philip Fourie
' Created: 2009/01/10
' Version: 1.0
' Location: http://softwarerealisations.com/fbgit.html
'
' Important:  
'	When upgrading FogBugz this script these changes will be lost and the script needs to be ran again.
'
' Function:
' Replaces two occurrences of URL encoding that is required for calls gitweb to work.  
' FogBugz unfortunately URL encode ^R1 and ^R2 and gitweb can't parse the query parameters.
'
' The text to be replaced are found in FogBugz\website\util.asp for following methods:
'	 GetSourceControlViewFileURL
'			GetSourceControlViewFileURL = Replace(ReplaceInUrl(ReplaceInUrl(ReplaceInUrl(g_config.sCVSView, "^FILE", sFile), "^R1", r1), "^R2", r2), "^REPO", sRepo)
'		should be changed to:
'			GetSourceControlViewFileURL = Replace(Replace(Replace(ReplaceInUrl(g_config.sCVSView, "^FILE", sFile), "^R1", r1), "^R2", r2), "^REPO", sRepo)
'
'	
'   - GetSourceControlDiffFileURL
'			GetSourceControlDiffFileURL = Replace(ReplaceInUrl(ReplaceInUrl(ReplaceInUrl(g_config.sCVSDiff, "^FILE", sFile), "^R1", r1), "^R2", r2), "^REPO", sRepo)
'		should be changed to:
'       	GetSourceControlDiffFileURL = Replace(Replace(Replace(ReplaceInUrl(g_config.sCVSDiff, "^FILE", sFile), "^R1", r1), "^R2", r2), "^REPO", sRepo)
'
' Tested against:
' 	FogBugz version 6.1.41 and git 1.6.1
'
'

' Use default install location if script wasn't called with a FB location argument
If WScript.Arguments.Count = 0 Then
	installDir = "c:\Program Files\FogBugz"
Else
	installDir = WScript.Arguments(0)	
End If

' This the absolute location of the file that needs to change
utilFile = installDir & "\website\util.asp" 

Set objFSO = CreateObject("Scripting.FileSystemObject")

If (objFSO.FileExists(utilFile) = False) Then
	WScript.Echo ("Failed. Could not find file: " & utilFile)
	WScript.Quit(1)
End If

WScript.Echo "Replacing contents of: " + utilFile

' New code to swap in 
oldViewFileLine = "GetSourceControlViewFileURL = Replace(ReplaceInUrl(ReplaceInUrl(ReplaceInUrl(g_config.sCVSView, ""^FILE"", sFile), ""^R1"", r1), ""^R2"", r2), ""^REPO"", sRepo)"
newViewFileLine = "GetSourceControlViewFileURL = Replace(Replace(Replace(ReplaceInUrl(g_config.sCVSView, ""^FILE"", sFile), ""^R1"", r1), ""^R2"", r2), ""^REPO"", sRepo)"

oldDiffFileLine = "GetSourceControlDiffFileURL = Replace(ReplaceInUrl(ReplaceInUrl(ReplaceInUrl(g_config.sCVSDiff, ""^FILE"", sFile), ""^R1"", r1), ""^R2"", r2), ""^REPO"", sRepo)"
newDiffFileLine = "GetSourceControlDiffFileURL = Replace(Replace(Replace(ReplaceInUrl(g_config.sCVSDiff, ""^FILE"", sFile), ""^R1"", r1), ""^R2"", r2), ""^REPO"", sRepo)"

Const ForReading = 1
Const ForWriting = 2

Set objFile = objFSO.OpenTextFile(utilFile, ForReading)

oldText = objFile.ReadAll
objFile.Close
newText1 = Replace(oldText, oldViewFileLine, newViewFileLine)
If (oldText = newText1) Then
	WScript.Echo ("Did not find anything to replace for ViewFile logic. Maybe the script was already run (not serious) or FogBugz code has changed since writing the fix (serious)")
End If

newText2 = Replace(newText1, oldDiffFileLine, newDiffFileLine)
If (newText1 = newText2) Then
	WScript.Echo ("Did not find anything to replace for DiffFile logic. Maybe the script was already run (not serious) or FogBugz code has changed since writing the fix (serious)")
End If

Set objFile = objFSO.OpenTextFile(utilFile, ForWriting)
objFile.WriteLine newText2
objFile.Close


WScript.Echo ("Completed")


' EOF