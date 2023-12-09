#================================================================
# The MIT License
# Copyright (c) 2023 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================

$imported = {} if $imported.nil?
$imported["RS_GlareEffect"] = true

#================================================================
# Description
#----------------------------------------------------------------
# This script allows you to add the glare effect to the screen.
# The glare effect is visible when the switch is ON.
#================================================================
# How to Install
#----------------------------------------------------------------
# Insert this script into the Materials section of the script
# editor.
#================================================================
# Usage
#----------------------------------------------------------------
# To turn on the glare effect, you must set the switch ID to
# RS::GlareEffect::SWITCH_ID. and turn on the switch in the event 
# command.
#================================================================
# Change Log
#----------------------------------------------------------------
# 2023-12-09 (v1.0.0) - First Release.
#================================================================

module RS; end
module RS::GlareEffect
  # Radius of the glare effect
  RAD1 = 100
  RAD2 = 200
  RAD3 = 700

  SWITCH_ID = 1
end

class Glare_Effect < Sprite
  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    self.blend_type = 1

    @flag = false
  end

  def update
    super

    # if the switch is ON, the glare effect is visible.
    if $game_switches[RS::GlareEffect::SWITCH_ID]
      self.visible = true
    else
      self.visible = false
    end

    if !@flag and self.visible
      draw_glare_effect
    end

  end

  def draw_glare_effect
    rad1 = RS::GlareEffect::RAD1
    rad2 = RS::GlareEffect::RAD2
    rad3 = RS::GlareEffect::RAD3

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
            self.bitmap.set_pixel(x, y, c)
        end
      end
    end

    @flag = true
  end
end

class Scene_Map
  alias rs_glare_effect_start start
  def start
    rs_glare_effect_start
    @glare_effect = Glare_Effect.new
  end
  alias rs_glare_effect_update update
  def update
    rs_glare_effect_update
    @glare_effect.update if @glare_effect
  end
  alias rs_glare_effect_terminate terminate
  def terminate
    rs_glare_effect_terminate
    @glare_effect.dispose if @glare_effect
  end
end
