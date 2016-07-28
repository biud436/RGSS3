#==============================================================================
# ** Logo
# Author : biud436
# Date : 2015.04.12
# Version : 1.0
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
module Logo

  # 볼륨 조절 (0 ~ 100)
  ME_Volume = 70

  # 타이틀 음악
  TITLE_MUSIC = true

  Source = [
  [120,"Graphics/Titles1/Book","ME/Inn"],
  [120,"Graphics/Titles1/DemonCastle","SE/Cow"],
  # 로고를 계속 추가할 수 있습니다
  ]

  module_function
  def pre_main(duration,path,snd)
    Graphics.freeze
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(path)
    play_sound(snd) if snd.size > 0
    Graphics.transition(duration>>1)
    Graphics.update
    Graphics.fadeout(duration>>1)
    sprite.dispose
  end

  def start
    Source.each {|v| pre_main(*v) }
  end

  def play_sound(path)
    c = path.scan(/[^\/]+/)
    case c[0]
    when "ME" then Audio.me_play('Audio/ME/'+c[1],ME_Volume)
    when "SE" then Audio.se_play('Audio/SE/'+c[1],70,100)
    else
      Audio.me_play('Audio/ME/'+c[0])
    end
  end
end

def rgss_main(&block)
  Logo.start if not $BTEST
  block.call
end

if not Logo::TITLE_MUSIC
  class Scene_Title < Scene_Base
    def play_title_music
    end
  end
end
