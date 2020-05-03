# Author : biud436

$imported = {} if $imported.nil?
$imported["RS_LayeredGameOverImage"] = true

module SceneManager
  def self.snapshot_for_background
    @background_bitmap.dispose if @background_bitmap
    @background_bitmap = Graphics.snap_to_bitmap
    @background_bitmap.blur if @stack.size > 0 && !@stack[-1].is_a?(Scene_GameOver)
  end  
end
class Sprite_GameOver < Sprite
  def initialize
    super
    @bitmaps = []
  end
  def render
    @bitmaps.each do |bitmap| 
      src_rect = Rect.new(0, 0, bitmap.width, bitmap.height)
      self.bitmap.blt(0, 0, bitmap, src_rect, 255)
    end
    @bitmaps.each { |bitmap| bitmap.dispose }
    @bitmaps = nil
  end
  def layer=(value)
    @bitmaps.push(value)
  end
end
class Scene_Gameover < Scene_Base
  def create_background
    @sprite = Sprite_GameOver.new
    @sprite.bitmap = SceneManager.background_bitmap
    @sprite.layer = Cache.system("GameOver")
    @sprite.render
  end
end