#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
$imported = {} if $imported.nil?
$imported["RS_SimpleShowEventName"] = true

# ======================================================
# 사용법
# ======================================================
# 이름 색상을 변경하려면 다음과 같은 노트 태그를 삽입하세요.
#
# <NAME_COLOR : r g b a>
#
# r은 빨강이며 0 ~ 255 사이의 BYTE 값입니다.
# g는 초록색이며 0 ~ 255 사이의 BYTE 값입니다.
# b는 파란색이며 0 ~ 255 사이의 BYTE 값입니다.
# a는 알파값이며 0 ~ 255 사이의 BYTE 값입니다.
#
# 노트 태그를 삽입하지 않으면 기본 색상이 적용됩니다.
#
# 이름을 변경하고 싶다면 다음 노트 태그를 삽입하세요.
#
# <NEW_NAME : name>
#
# ======================================================
# 버전 로그
# ======================================================
# 2019.03.23 (v1.0.1) : 
# - Added a new feature that can hide the name layer when opening the message window.
# 2019.05.03 (v1.0.2) :
# - Added the functionality that get the character width and height values from the parent.
# 2019.08.26 (v1.0.3) :
# - Fixed the issue that is not working when the tile graphics had set.
# 2020.06.09 (v1.0.4) :
# - Fixed the bug that can't get the event name.

module EV_NAME_CONFIG
  BW = 32 * 6
  BH = 32 * 3
  OY = 32 * 2
  Z_ADD = 100
  MIN_OPACITY = 64
  MAX_OPACITY = 255
  
  # 폰트명과 폰트 크기
  MY_FONT = Font.new("나눔고딕", 16)
  MY_FONT.outline = true # 텍스트 테두리
  MY_FONT.shadow = true # 텍스트 그림자
end

class Game_Character < Game_CharacterBase
  def name; "" end
  def erased?; false end
  def read_name_comment; "" end
end
  
class Game_Event < Game_Character
  def name
    @event.name rescue ""
  end
  def erased?
    @erased
  end
  def read_name_comment
    return "" if @list.nil?
    comments = []
    @list.each do |param|
      if [108, 408].include?(param.code)
        comments.push(param.parameters[0])
      end
    end
    comments.join('\r\n')
  end
end

module Sprite_Name
  include EV_NAME_CONFIG
  
  def create_name_sprite
    @name_sprite = Sprite.new
    @name_sprite.bitmap = Bitmap.new(BW, BH)
    @name_sprite.bitmap.font = MY_FONT
    @name_sprite.x = self.x - (BW / 2)
    @name_sprite.y = self.y - OY
    @name_sprite.z = self.z + 100
    @name_sprite.visible = false
  end
  
  def update_visibility
    return if not @name_sprite
    @name_sprite.opacity = if $game_message.busy?
      @name_sprite.z = self.z - Z_ADD
      MIN_OPACITY
    else 
      @name_sprite.z = self.z + Z_ADD
      MAX_OPACITY
    end
  end
  
  def update_name_sprite
    return if @name_sprite.nil?
    return if @character.nil?
    return if not @character.is_a?(Game_Event)
  
    if @character.erased? and !self.bitmap
      @name_sprite.visible = false
    else      
      @name_sprite.visible = !@character.find_proper_page.nil?      
      @name_sprite.visible = @character_name.size > 0 and self.bitmap
    end
    
    @name_sprite.update
    @name_sprite.bitmap.clear
    dx = 0
    dy = 0
    tw = BW
    lh = 32
    
    name = @character.name || ""        
    @name_sprite.bitmap.font = MY_FONT
    
    comment = @character.read_name_comment    
    
    if not comment.empty?
      # <NAME_COLOR : r g b a>      
      if comment =~ /\<(?:NAME_COLOR)[ ]*\:[ ]*(\d+)[ ](\d+)[ ](\d+)[ ](\d+)[ ]*\>/im
        c = Color.new($1.to_i, $2.to_i, $3.to_i, $4.to_i)
        @name_sprite.bitmap.font.color = c
      end
      # <NEW_NAME : r g b a>            
      if comment =~ /\<(?:NEW_NAME)[ ]*\:[ ]*(.*)\>/im
        name = $1.to_s
      end      
    end    
    
    @name_sprite.bitmap.draw_text(dx, dy, tw, lh, name, 1)
    
    proc = Proc.new do
      bitmap = Cache.character(@character.character_name)
      sign = name[/^[\!\$]./]
      ch = 0
      if sign && sign.include?('$')
        ch = bitmap.height / 4
      else
        ch = bitmap.height / 8
      end
      ch
    end

    # ch는 캐릭터 폭의 약자
    tile_height = (Graphics.height / 13).round
    ch = @tile_id > 0 ? 32 : proc.call

    @name_sprite.x = @character.screen_x - BW / 2
    @name_sprite.y = @character.screen_y - (ch + lh)
  end
  
  def dispose_name_sprite
    @name_sprite.dispose
    @name_sprite.bitmap.dispose
  end  
  
end
class Sprite_Character < Sprite_Base
  include Sprite_Name
  
  alias thelang_xm3_initialize initialize
  alias thelang_xm3_update update
  alias thelang_xm3_dispose dispose
  
  def initialize(viewport, character = nil)
    thelang_xm3_initialize(viewport, character)
    create_name_sprite
  end
  
  def update
    thelang_xm3_update
    update_name_sprite
    update_visibility
  end
  
  def dispose
    thelang_xm3_dispose
    dispose_name_sprite
  end
  
end