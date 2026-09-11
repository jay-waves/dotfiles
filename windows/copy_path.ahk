#Requires AutoHotkey v2.0
#SingleInstance Force

paths := []

for arg in A_Args {
    if FileExist(arg)
        paths.Push(arg)
}

if paths.Length = 0
    ExitApp

text := ""
for path in paths
    text .= path "`r`n"

A_Clipboard := RTrim(text, "`r`n")
ExitApp
