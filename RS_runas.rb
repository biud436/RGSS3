#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
# Name : 관리자 권한 획득 / Obtaining Administrator Rights
# Author : biud436
# Usage :
# This script allows you to run the game as an administrator mode on Windows 7 or more. 
#
# 예:) 
#
# # 관리자 모드가 아니라면 관리자 모드로 게임 재실행
# if not AdminMode.valid?
#   AdminMode.run
# end
#
# # 관리자 모드인가?
# if AdminMode.valid?
#   # "C:\\Program Files (x86)/myfolder"에 새로운 폴더 생성
#   Dir.mkdir File.join(ENV["programfiles"], "myfolder")
# end
#
module AdminMode
  
  COMMAND = [
    "powershell -WindowStyle Hidden -Command",
    "$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator');",
    "if(!$IsAdmin) {",
    "(Get-Process 'Game').Kill();",
    "Start-Sleep -Milliseconds 500;",
    "Start-Process -FilePath Game.exe -Verb runas;",
    "}"
  ].join(" ")
  
  extend self
  
  def valid?
    return system("net session 1>NUL 2>NUL")
  end
  
  def run
    system(COMMAND)
  end
  
end