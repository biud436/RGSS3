# Name : 관리자 권한 획득
# Author : biud436
# Usage :
#
# 본 스크립트는 Windows 7 (또는 비스타) 이상에서만 동작합니다.
#
# 예:) 
#
# # 관리자 모드가 아니라면 관리자 모드로 게임 재실행
# if not AminMode.valid?
#   AdminMode.run
# end
#
# # 관리자 모드인가?
# if AminMode.valid?
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
  
  # AdminMode.valid?
  def valid?
    return system("net session >nul 2>&1")
  end
  
  # AdminMode.run
  def run
    system(COMMAND)
  end
  
end