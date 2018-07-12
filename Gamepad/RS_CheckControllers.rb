#==============================================================================
# ** Check Game Pad
#==============================================================================
# Name       : RS_CheckControllers
# Author     : 러닝은빛(biud436)
# Version    : 1.0.0 (2018.07.12)
# Desc       : 게임 패드를 체크합니다.
# Functions  : 조건 분기 - 스크립트에서 RS.check_controllers를 체크하십시오.
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_CheckControllers"] = true
module RS
  RSCheckControllers = Win32API.new('Controller.dll', 'RSCheckControllers', 'p', 'v')
  def self.check_controllers
    states = "\0" * 4
    RSCheckControllers.call(states)
    states.include?('t')
  end
end