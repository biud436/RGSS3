#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================

$imported = {} if $imported.nil?
$imported["RS_CircleRendering"] = true

class Scene_Map
  alias xxxx_start start
  def start
    xxxx_start
    @sprite = Sprite.new
    @sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprite.blend_type = 1
    draw_circle_blur
  end
  alias xxxx_update update
  def update
    xxxx_update
    if @sprite
      @sprite.update
    end
  end
  alias xxxx_terminate terminate
  def terminate
    xxxx_terminate
    @sprite.dispose if @sprite
  end

  def draw_circle_blur
    rad1 = 100
    rad2 = 200
    rad3 = 400
    for y in 0..Graphics.height
      for x in 0..Graphics.width
        dx = x - Graphics.width / 2
        dy = y - Graphics.height / 2
        rc = Math.sqrt( dx * dx + dy * dy )
        if rc > rad1 and rc < rad3
          if rc < rad2
            bright = (rc - rad1) / (rad2 - rad1) * 255.0
          else
            bright = 255.0 - (rc - rad2) / (rad3 - rad2) * 255.0
          end
            c = Color.new(bright, bright, bright, 200)
            @sprite.bitmap.set_pixel(x, y, c)
        end
      end
    end
  end

end
