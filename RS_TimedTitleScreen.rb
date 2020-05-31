#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# Name : Timed Title Screen
# Author : biud436
# Date : 2019.12.23 (v1.0.0)
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

imported = {} if imported.nil?
imported["RS_TimedTitleScreen"] = true

module Title
  # 움짤을 만들고 싶은 타이틀의 그래픽명을 기입하세요(띄어쓰기로 구분됨)
  FILE = %W(Book Castle CrossedSwords Crystal DemonCastle)
  TIME = 2
end

class Scene_Title < Scene_Base

  alias rs_timed_title_screen_start start
  def start
    rs_timed_title_screen_start
    @sprite_index = 0
  end

  def update
    super
    choose_index
  end

  def change_sprite(sprite)
    sprite.bitmap = Cache.title1(Title::FILE[@sprite_index])
    center_sprite(sprite)
  end

  def time
    Graphics.frame_count / Graphics.frame_rate
  end

  def choose_index
    return unless (time % Title::TIME) == 0
    @sprite_index = time % Title::FILE.size
    change_sprite(@sprite1)
  end
  
end
