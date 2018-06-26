#==============================================================================
# ** RS_PauseIconPosition
#==============================================================================
# Name        : RS_PauseIconPosition
# Author      : biud436
# Version     : 1.0.0
#==============================================================================
# ** Version Log
#==============================================================================
# 2018.06.26 (v1.0.0) - First Release.
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_PauseIconPosition"] = true

class Window_Message
  alias rs_window_initialize initialize
  alias origin_pause= pause=
  def initialize
    rs_window_initialize
    @animation_count = 0
    @pub_pause = false
    @pause_ox, @pause_oy = "self.width / 2", "self.height"
    self.origin_pause = false
    refresh_pause_sign
  end
  alias rs_window_update update
  def update
    rs_window_update
    @animation_count += 1
    update_pause_sign
  end
  def move_pause_sign(x, y)
    p = 16
    ox = self.width / 2
    oy = self.height
    x = x || 0
    y = y || 0
    @pause_ox = x.to_s + "+ ox - p/2"
    @pause_oy = y.to_s + "+ oy - p"
  end
  def refresh_pause_sign
    sx = 96
    sy = 64
    p = 16
    ox = self.width / 2
    oy = self.height
    @window_pause_sign_sprite = Sprite.new
    sprite = @window_pause_sign_sprite
    sprite.bitmap = self.windowskin
    sprite.x = self.x + eval(@pause_ox)
    sprite.y = self.y + eval(@pause_oy)
    sprite.z = self.z + 1
    sprite.src_rect.set(sx, sy, p, p)
    sprite.opacity = 0
  end
  def update_pause_sign
    sprite = @window_pause_sign_sprite
    x = (@animation_count / 16).floor % 2
    y = (@animation_count / 16 / 2).floor % 2
    sx = 96
    sy = 64
    p = 16
    sprite.x = self.x + eval(@pause_ox)
    sprite.y = self.y + eval(@pause_oy)
    if !@pub_pause
      sprite.opacity = 0
    elsif sprite.opacity < 255
      sprite.opacity = [sprite.opacity + 25, 255].min
    end
    sprite.src_rect.set(sx+x*p, sy+y*p, p, p)
    sprite.visible = self.open?
  end
  def pause=(val)
    @pub_pause = val
  end
  def pause
    @pub_pause
  end
  alias rs_window_message_process_normal_character process_normal_character
  if defined?(RS::BALLOON)
    def process_normal_character(c, pos, text)
      rs_window_message_process_normal_character(c, pos, text)
      mx = standard_padding + pos[:x] + 8
      my = standard_padding + pos[:y] + pos[:height]
      move_pause_sign(mx, my)
    end
  else
    def process_normal_character(c, pos)
      rs_window_message_process_normal_character(c, pos)
      mx = standard_padding + pos[:x] + 8
      my = standard_padding + pos[:y] + pos[:height]
      move_pause_sign(mx, my)
    end
  end
end
