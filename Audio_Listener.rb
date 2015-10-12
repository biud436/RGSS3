#==============================================================================
# ** Audio Listener
# Author : biud436
# Date : 2015.10.13
# Version : 1.0
#==============================================================================
module AudioListener
    
  # BGS 설정
  @@bgs = RPG::SE.new("",80)
  
  # 대기 시간
  SEC = 2

  class << self
    attr_accessor :t
  end 

  #--------------------------------------------------------------------------
  # * BGS 설정
  #--------------------------------------------------------------------------   
  def self.set_bgs
    $game_map.map.note.split(/\n/).each do |note|
      @@bgs.name = (note.gsub!(/<BGS>[ ]*(.+)/) { $1.to_s }) || 'Attack1' 
    end    
  end

  #--------------------------------------------------------------------------
  # * BGS 이벤트 루프
  #--------------------------------------------------------------------------     
  def self.start
    loop do
      next unless SceneManager.scene.is_a?(Scene_Map)
      AudioEvent.stop unless loop?
      @@bgs.play 
      sleep(SEC)
    end
  end
  
  #--------------------------------------------------------------------------
  # * 맵 이름 확인
  #--------------------------------------------------------------------------     
  def self.loop?
    ($data_mapinfos[$game_map.map_id].name =~ /<BGS_LOOP>/i) != nil
  end

end

module AudioEvent
  #--------------------------------------------------------------------------
  # * BGS 시작
  #--------------------------------------------------------------------------     
  def self.start
    if AudioListener.loop?
      AudioListener.t = Thread.new do
        AudioListener.set_bgs
        AudioListener.start 
      end
    end
  end
  #--------------------------------------------------------------------------
  # * BGS 정지
  #--------------------------------------------------------------------------     
  def self.stop
    Thread.stop
    AudioListener.t.kill if AudioListener.t.alive?
  end
end

class Game_Map
  
  attr_reader :map
  
  #--------------------------------------------------------------------------
  # * 맵 설정
  #--------------------------------------------------------------------------     
  alias audio_setup setup
  def setup(map_id)
    audio_setup(map_id)
    AudioEvent.start
  end

end