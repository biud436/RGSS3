#==============================================================================
# ** Hangul Message System (RPG Maker VX Ace)
#==============================================================================
# Name       : 한글 메시지 시스템 - 대화중 캐릭터 이동
# Author     : 러닝은빛(biud436)
# Version    : 1.0.0 (2018.07.10)
# Desc       : 대화중에도 캐릭터가 이동 가능합니다.
#
# - 이동 불가능 설정
# $game_system.msg_busy_character_move_enabled = false
#
# - 이동 가능 설정
# $game_system.msg_busy_character_move_enabled = true
#
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_HMS_CharacterExtension"] = true
class Window_Message < Window_Base
  alias rs_hms_character_extension_update update
  def update
    update_balloon_position
    rs_hms_character_extension_update
  end
end

class Game_System
  attr_accessor :msg_busy_character_move_enabled
  alias rs_hms_character_extension_initialize initialize
  def initialize
    rs_hms_character_extension_initialize
    @msg_busy_character_move_enabled = true
  end
end

class Game_Event < Game_Character
  alias xxxx_lock lock
  def lock
    return xxxx_lock if not $game_system.msg_busy_character_move_enabled
  end
end