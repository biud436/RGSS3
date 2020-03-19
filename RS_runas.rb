# Name : 관리자 권한 획득
# Author : biud436

command = [
  "powershell -WindowStyle Hidden -Command",
  "$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator');",
  "if(!$IsAdmin) {",
  "(Get-Process 'Game').Kill();",
  "Start-Sleep -Milliseconds 500;",
  "Start-Process -FilePath Game.exe -Verb runas;",
  "}"
].join(" ")

system(command)

# 여기에 관리자 권한 이후 실행될 스크립트 추가
# 예:) Dir.mkdir File.join(ENV["programfiles"], "myfolder")