#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# Script Name : Graphics Menu
# Author : biud436
# Date : 2014-08-13
# Version : 1.1 (2015-02-18)
# Description : 
# This script allows you to show up the simple menu image in the menu scene.
#==============================================================================
# ** Introduction
#==============================================================================
# This script allows you to chnage the in-game menu as graphics image.
#
#==============================================================================
# ** Needs to install resources
#==============================================================================
# http://cafe.naver.com/sonnysoft2004/47269 (By 제스킨)
#
#==============================================================================
# ** How to install script and resources.
#==============================================================================
# Add the script after there is to add a new section in between below materials 
# below and above the main section. Next, you need to download a one sprite 
# sheet and then its name sets as the filename called 'inter' and place it 
# in your Graphics/pictures folder.
#==============================================================================
# ** How to use
#==============================================================================
#
# - How to create a sprite sheet.
# The value named 'W' is to the width value of the image and 'H' is the height value of it.
# The image consists of 5 cols x 2 rows.
# in case of the first row in the sprite sheet, it means the image is not selected by user.
# In other cases, it means the image is a selected as current menu index by user.
#
# - How to modify the scene class.
# You have to change the MENU constant of RECT_SRC module.
#
# - How to set the initial area.
# You have to change constant values called 'START_X' and START_Y.
#
#==============================================================================
# ** 버전 로그
#==============================================================================
# 1.1 (2015-02-18) - Fixed bugs and has been completed the refactoring.
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_GraphicsMenu"] = true

module RECT_SRC
  W = 78
  H = 78
  START_X = Graphics.width / 2 - ((W*5) / 2)
  START_Y = Graphics.height / 2 - H/2
  RECT = []
  RECT[0] = {:x => 0, :y => [0,W], :w => W, :h => H}
  RECT[1] = {:x => W, :y => [0,W], :w => W, :h => H}
  RECT[2] = {:x => W * 2, :y => [0,W], :w => W, :h => H}
  RECT[3] = {:x => W * 3, :y => [0,W], :w => W, :h => H}
  RECT[4] = {:x => W * 4, :y => [0,W], :w => W, :h => H}
  MENU = [Scene_Status,Scene_Item,Scene_Skill,Scene_Map,Scene_Map]
end

class Game_Map
  attr_accessor :linear_menu
  #--------------------------------------------------------------------------
  # * 메뉴 상태 변수 설정
  #--------------------------------------------------------------------------
  alias linear_menu_initialize initialize
  def initialize
    linear_menu_initialize
    @linear_menu = false
  end
end


class Scene_Linear_Menu < Scene_MenuBase
  include RECT_SRC
  attr_accessor :visible
  @@index = 0
  #--------------------------------------------------------------------------
  # * 시작
  #--------------------------------------------------------------------------
  def start
    super
    create_rect
  end
  #--------------------------------------------------------------------------
  # * create_help_window (오버라이딩)
  #--------------------------------------------------------------------------
  def create_help_window
  end
  #--------------------------------------------------------------------------
  # * 파괴
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_bitmap
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    super
    update_index
    process_exit
  end
  #--------------------------------------------------------------------------
  # * 인덱스의 증가
  #--------------------------------------------------------------------------
  def up
    @@index = (@@index + 1) % 5
    Sound.play_cursor
  end
  #--------------------------------------------------------------------------
  # * 인덱스의 감소
  #--------------------------------------------------------------------------
  def down
    @@index = (@@index - 1) % 5
    Sound.play_cursor
  end
  #--------------------------------------------------------------------------
  # * 메뉴 처리
  #--------------------------------------------------------------------------
  def update_index
    up if Input.trigger?(:RIGHT)
    down if Input.trigger?(:LEFT)
    select_scene if Input.trigger?(:C)
    set_rect(@rect[@@index],@@index)
  end
  #--------------------------------------------------------------------------
  # * 씬 호출
  #--------------------------------------------------------------------------
  def select_scene
    SceneManager.call(MENU[@@index])
  end
  #--------------------------------------------------------------------------
  # * 메뉴 나가기
  #--------------------------------------------------------------------------
  def process_exit
    SceneManager.call(Scene_Map) if Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # * 메뉴 생성
  #--------------------------------------------------------------------------
  def create_cache(*args)
    sprite = Sprite.new
    sprite.bitmap = Cache.picture("inter")
    sprite.src_rect.set(*args)
    return sprite
  end
  #------------------- -------------------------------------------------------
  # * 영역 생성
  #--------------------------------------------------------------------------
  def create_rect
    @rect = []
    for i in (0..4)
      @rect[i] = create_cache(RECT[i][:x],RECT[i][:y][0],RECT[i][:w],RECT[i][:h])
      @rect[i].x = START_X + RECT[i][:x]
      @rect[i].y = START_Y + RECT[i][:y][0]
    end
    set_rect(@rect[@@index],@@index)
  end
  #--------------------------------------------------------------------------
  # * 영역 설정
  #--------------------------------------------------------------------------
  def set_rect(rect,i)
    rect.src_rect.set(RECT[i][:x],RECT[i][:y][1],RECT[i][:w],RECT[i][:h])
    for j in (0..4)
      next if j == @@index
      @rect[j].src_rect.set(RECT[j][:x],RECT[j][:y][0],RECT[j][:w],RECT[j][:h])
    end
  end
  #--------------------------------------------------------------------------
  # * 비트맵 메모리 해제
  #--------------------------------------------------------------------------
  def dispose_bitmap
    @rect.each {|i| i.bitmap.dispose; i.dispose }
  end
end


class Scene_Map < Scene_Base
  def call_menu
    Sound.play_ok
    SceneManager.call(Scene_Linear_Menu)
  end
end
