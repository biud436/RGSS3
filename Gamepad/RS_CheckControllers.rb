#==============================================================================
# ** Check Game Pad
#==============================================================================
# Name       : RS_CheckControllers
# Author     : 러닝은빛(biud436)
# Version    : 1.0.0 (2018.07.12)
# Desc       : 게임 패드를 체크합니다.
# Functions  : 
# - 조건 분기 - 스크립트에서 RS.check_controllers 또는 RS.gamepad? 를 입력
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_CheckControllers"] = true
if not defined? $NEKO_RUBY # $neko, NekoRGSS, Neko, NekoInput
module RS
  RSCheckControllers = Win32API.new('Controller.dll', 'RSCheckControllers', 'p', 'v')
  def self.check_controllers
    states = "\0" * 4
    RSCheckControllers.call(states)
    states.include?('t')
  end
  def self.gamepad?
    check_controllers
  end
end
end