#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# Name : Character_Contoroller
# Author : biud436
# Version : 1.0
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_CharacterContoroller"] = true

module R
  # 이벤트 ID
  @@id = 2
  # 스위치 번호
  SWITCH = 100
  #--------------------------------------------------------------------------
  # * 이벤트 ID 반환
  #--------------------------------------------------------------------------
  def self.id
    @@id
  end
  #--------------------------------------------------------------------------
  # * 이벤트 ID 설정
  #--------------------------------------------------------------------------
  def self.set_id(set)
    @@id = set
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # * 카메라 위치 설정
  #--------------------------------------------------------------------------
  def set_camera_pos
    if $game_switches[R::SWITCH]
      $game_player.center($game_player.x,$game_player.y)
      $game_switches[R::SWITCH] = false
    else
      $game_switches[R::SWITCH] = true
      $game_player.center(get_character(R.id).x,get_character(R.id).y)
    end
  end
end

class Game_Switches
  #--------------------------------------------------------------------------
  # * 스위치의 값에 따라 플레이어를 투명도가 변경됩니다
  #--------------------------------------------------------------------------
  def []=(switch_id, value)
    @data[switch_id] = value
    on_change
    if switch_id == R::SWITCH
      $game_player.transparent = @data[switch_id]
    end
  end
end

class Game_Map
  def ev_update_scroll(ev,last_real_x, last_real_y)
    ax1 = adjust_x(last_real_x)
    ay1 = adjust_y(last_real_y)
    ax2 = adjust_x(ev.real_x)
    ay2 = adjust_y(ev.real_y)
    scroll_down (ay2 - ay1) if ay2 > ay1 && ay2 > $game_player.center_y
    scroll_left (ax1 - ax2) if ax2 < ax1 && ax2 < $game_player.center_x
    scroll_right(ax2 - ax1) if ax2 > ax1 && ax2 > $game_player.center_x
    scroll_up (ay1 - ay2) if ay2 < ay1 && ay2 < $game_player.center_y
  end
  def set_real_xy(id)
    $game_variables[99] = @events[id].real_x
    $game_variables[100] = @events[id].real_y
  end
  def set_input(id)
    unless @events[id].moving?
    @events[id].move_straight(Input.dir4) if Input.dir4 > 0
    end
  end
  #--------------------------------------------------------------------------
  # * 이벤트 캐릭터의 이동
  #--------------------------------------------------------------------------
  def display_move_update(id)
    return unless $game_switches[R::SWITCH]
    set_real_xy(id)
    set_input(id)
  end
  #--------------------------------------------------------------------------
  # * 이벤트 캐릭터의 카메라 업데이트
  #--------------------------------------------------------------------------
  def display_update_scroll(id)
    return unless $game_switches[R::SWITCH]
    ev_update_scroll(@events[id],$game_variables[99],$game_variables[100])
  end
end

class Game_Player
  alias running_move_by_input move_by_input
  alias running_reserve_transfer reserve_transfer
  #--------------------------------------------------------------------------
  # * 플레이어 이동의 제한
  #--------------------------------------------------------------------------
  def move_by_input
    return if $game_switches[R::SWITCH]
    running_move_by_input
  end
  #--------------------------------------------------------------------------
  # * 플레이어 카메라 업데이트 금지 설정
  #--------------------------------------------------------------------------
  def update_scroll(last_real_x, last_real_y)
    return if $game_switches[R::SWITCH]
    ax1 = $game_map.adjust_x(last_real_x)
    ay1 = $game_map.adjust_y(last_real_y)
    ax2 = $game_map.adjust_x(@real_x)
    ay2 = $game_map.adjust_y(@real_y)
    $game_map.scroll_down (ay2 - ay1) if ay2 > ay1 && ay2 > center_y
    $game_map.scroll_left (ax1 - ax2) if ax2 < ax1 && ax2 < center_x
    $game_map.scroll_right(ax2 - ax1) if ax2 > ax1 && ax2 > center_x
    $game_map.scroll_up (ay1 - ay2) if ay2 < ay1 && ay2 < center_y
  end
  #--------------------------------------------------------------------------
  # * 장소이동 시에 카메라를 플레이어가 소유
  #--------------------------------------------------------------------------
  def reserve_transfer(map_id, x, y, d = 2)
    center(@x,@y)
    $game_switches[R::SWITCH] = false
    running_reserve_transfer(map_id, x, y, d = 2)
  end
end

class Game_Event
  def update
    $game_map.display_move_update(R.id)
    super
    $game_map.display_update_scroll(R.id)
    check_event_trigger_auto
    return unless @interpreter
    @interpreter.setup(@list, @event.id) unless @interpreter.running?
    @interpreter.update
  end
end
