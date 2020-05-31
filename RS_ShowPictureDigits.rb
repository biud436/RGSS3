#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# Name : Show Picture Digits
# Date : 2020.05.30
# Usage :
# This script allows you to show up digit numbers on the game screen.
# 
# First up, you need to call below script command.
#   $game_map.show_digits(x, y, value)
#   $game_map.show_variables(x, y, var_id)
#
# to remove pictures that is drawn certain value, you need to call below script command.
#   $game_map.remove_digits
#
# Dependency Scripts :
# Zeus81's Bitmap Export
# 
# This script will be automatically downloaded that script when starting the game.
# But is working fine only in Windows 10 or more due to using powershell.
#
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_ShowPictureDigits"] = true
module Settings
  
  BITMAP_TEXT = {
    :WIDTH => 20, # 텍스트 폭
    :HEIGHT => 32 # 텍스트 높이
  }
  
  FONT = Font.new
  FONT.name = ["나눔고딕"]
  FONT.size = 16
  
  # Zeus81님의 스크립트 다운로드
  def self.download_dependency_scripts
    if not File::exists?("Bitmap_Export.rb")
      `powershell wget "https://www.dropbox.com/s/3lqtjvosnrnnet3/Bitmap%20Export.rb?dl=1" -OutFile "Bitmap_Export.rb"`
    end
  end

  def self.digits_export
    return if (0..9).to_a.all? {|i| File::exists?("Graphics/pictures/digits_#{i}.png") }
    w = BITMAP_TEXT[:WIDTH]
    h = BITMAP_TEXT[:HEIGHT]
    for i in (0..9)
      bitmap = Bitmap.new(w, h)
      bitmap.font = FONT
      bitmap.draw_text(0, 0, w, h, i.to_s, 1)
      bitmap.export("Graphics/pictures/digits_#{i}.png")
    end
  end    
  
  download_dependency_scripts
  require "Bitmap_Export.rb"
  digits_export
  
end

module Digits
  
  # 텍스트 크기
  # 간격을 조절하려면 이 크기를 조절하세요.
  DIGITS_TEXT_SIZE = 12
  
  # 시작 그림 ID
  DIGITS_PIC_ID = 10
  
  # 투명도
  DIGITS_OPACITY = 250
  
  def show_digits(x, y, value)
    items = value.to_s.split("").collect! {|i| i.to_i }
    size = items.size
    if !@digits_pic_id
      @digits_pic_id = DIGITS_PIC_ID
    end
    for i in (0...items.length)
      n = size - (i + 1)
      digit_number = (value / (10 ** n)) % 10
      
      $game_map.screen.pictures[@digits_pic_id + n].show(
        "digits_#{digit_number}", 
        0, # 원점
        x + (DIGITS_TEXT_SIZE * i) + 1, # X
        y, # Y
        100, # 줌 X
        100, # 줌 Y
        DIGITS_OPACITY, # 투명도
        0 # 블렌드
      ) 
    end
      
    # 그림의 ID를 증가시킵니다.
    @digits_pic_id += size
    
  end
  
  # 그림을 삭제합니다.
  def remove_digits
    if @digits_pic_id
      for i in (DIGITS_PIC_ID..@digits_pic_id)
        $game_map.screen.pictures[i].erase
      end
      @digits_pic_id = DIGITS_PIC_ID
    end
  end
  
  # 변수 값을 표시합니다.
  def show_variables(x, y, var_id)
    begin 
      show_digits(x, y, $game_variables[var_id])
    rescue => e
    end
  end
end

class Game_Map
  include Digits
end