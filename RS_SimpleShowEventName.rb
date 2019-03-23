=begin
이름 표시를 테스트 하기 위해 즉각 작성한 것으로
폰트 설정, 오프셋 변경 등의 기능은 없습니다.
개인적인 용도라 이러한 기능들이 사실 필요 없습니다.
=end
$imported = {} if $imported.nil?
$imported["RS_SimpleShowEventName"] = true

# 2019.03.23 (v1.0.1) : 
# - added a new feature that can hide the name layer when opening the message window.

class Game_Event
  def erased?
    @erased
  end
end
module Sprite_Name
  def create_name_sprite
    @name_sprite = Sprite.new
    @name_sprite.bitmap = Bitmap.new(32 * 6, 32 * 3)
    @name_sprite.x = self.x - (32 * 6) / 2
    @name_sprite.y = self.y - 32 * 2
    @name_sprite.z = self.z + 100
    @name_sprite.visible = false
  end
  def update_visibility
    return if not @name_sprite
    @name_sprite.opacity = if $game_message.busy?
      @name_sprite.z = self.z - 100
      64
    else 
      @name_sprite.z = self.z + 100
      255
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
    tw = 32 * 6
    lh = 32
    name = @character.name || ""
    @name_sprite.bitmap.draw_text(dx, dy, tw, lh, name, 1)
    @name_sprite.x = @character.screen_x - (32 * 6) / 2
    @name_sprite.y = @character.screen_y - 32 * 2
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