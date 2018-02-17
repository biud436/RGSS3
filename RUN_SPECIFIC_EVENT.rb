# 작성자 : 러닝은빛
# 작성일 : 2018.02.15
 
module SPECIFIC_EVENT
  
  DATA = {
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
    return unless $game_map.map_id == SPECIFIC_EVENT::DATA[:MAP_ID]
    c = $game_map.interpreter.get_character(SPECIFIC_EVENT::DATA[:ID])
    if c and Time.now.to_i - @run_interval >= SPECIFIC_EVENT::DATA[:INTERVAL]
      c.animation_id = SPECIFIC_EVENT::DATA[:ANIMATION_ID]
      @run_interval = Time.now.to_i
    end
  end
end  