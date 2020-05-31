#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
# 작성자 : 러닝은빛
# 작성일 : 2018.02.15

$imported = {} if $imported.nil?
$imported["RS_RunSpecificEvent"] = true

class Game_System

  attr_accessor :specific_event_data

  alias xxxx_initialize initialize
  def initialize
    xxxx_initialize
    @specific_event_data = {
      # -1은 플레이어, 0은 이 이벤트, 나머지는 이벤트 ID
      :ID           => -1,
      # 실행 간격
      :INTERVAL     => 1,
      # 애니메이션 ID
      :ANIMATION_ID => 10,
      # 맵 ID
      :MAP_ID       => 2
    }
  end
end

class Scene_Map < Scene_Base
  alias xxxx_start start
  def start
    xxxx_start
    @run_interval = Time.now.to_i
  end

  alias xxxx_update update
  def update
    xxxx_update
    run_specific_event
  end

  def run_specific_event
    return unless $game_map.map_id == $game_system.specific_event_data[:MAP_ID]
    c = $game_map.interpreter.get_character($game_system.specific_event_data[:ID])
    if c and Time.now.to_i - @run_interval >= $game_system.specific_event_data[:INTERVAL]
      c.animation_id = $game_system.specific_event_data[:ANIMATION_ID]
      @run_interval = Time.now.to_i
    end
  end
end
