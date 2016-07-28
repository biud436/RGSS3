#==============================================================================
# ** Audio_Listener
# Author : biud436
# Date : 2015.10.13
# Version : 1.0
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
module AudioListener

  # SE 설정
  @@se = RPG::SE.new("",80)

  # 대기 시간
  SEC = 2

  class << self
    attr_accessor :t
  end

  #--------------------------------------------------------------------------
  # * SE 설정
  #--------------------------------------------------------------------------
  def self.set_se
    $game_map.map.note.split(/\n/).each do |note|
      @@se.name = (note.gsub!(/<SE>[ ]*(.+)/) { $1.to_s }) || 'Attack1'
    end
  end

  #--------------------------------------------------------------------------
  # * SE 이벤트 루프
  #--------------------------------------------------------------------------
  def self.start
    loop do
      next unless SceneManager.scene.is_a?(Scene_Map)
      AudioEvent.stop unless loop?
      @@se.play
      sleep(SEC)
    end
  end

  #--------------------------------------------------------------------------
  # * 맵 이름 확인
  #--------------------------------------------------------------------------
  def self.loop?
    ($data_mapinfos[$game_map.map_id].name =~ /<SE_LOOP>/i) != nil
  end

end

module AudioEvent
  #--------------------------------------------------------------------------
  # * SE 시작
  #--------------------------------------------------------------------------
  def self.start
    if AudioListener.loop?
      AudioListener.t = Thread.new do
        AudioListener.set_se
        AudioListener.start
      end
    end
  end
  #--------------------------------------------------------------------------
  # * SE 정지
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
