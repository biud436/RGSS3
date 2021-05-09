#================================================================
# The MIT License
# Copyright (c) 2021 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
$imported = {} if $imported.nil?
$imported["RS_SplashScreenV2"] = true
#================================================================
# Name : RS_SplashScreenV2
# Author : biud436
# Date : 2021.05.09
# Change Log : 
# 2021.05.09 (v1.0.0) : First Release.
#================================================================
module RS; end;
module RS::Slash
  NEXT_SCENE = Scene_Title
  BASE_DIR = "Graphics/Splash/"
  
  Dir.mkdir(File.join(".", BASE_DIR)) if !Dir.exist? File.join(".", BASE_DIR)
  
  IMAGES = {
    :IMAGE1 => "Gates"
  }
  
  ACC = 100
  
  class NextSceneCompoenent
    def execute(&block)
      block.call
      SceneManager.call(NEXT_SCENE)
    end
  end  
  
  class SpriteImpl < ::Sprite
    attr_accessor :dirty
    
    def initialize(callback)
      super(nil)
      self.opacity = 0
      self.dirty = false
      @ready_next_scene = false
      @callback = callback
      init_with_bitmap
    end
    
    def update
      super
      if not self.dirty
        update_opacity(:+)
        if self.opacity >= 255
          self.dirty = true
        end        
      else
        update_opacity(:-)
        if self.opacity <= 0
          self.dirty = false
          @ready_next_scene = true
        end                
      end
      @ready_next_scene = true if Input.trigger?(:C)
      @callback.call if @ready_next_scene
    end
    
    def init_with_bitmap
      file_name = IMAGES[:IMAGE1]
      bitmap = Cache.load_bitmap(BASE_DIR, file_name)
      self.bitmap = bitmap
    end
    
    def update_opacity(op)
      accel = ([[ACC, 100].max, 500].min / 100.0).floor
      case op
      when :+
        self.opacity += accel
      when :-
        self.opacity -= accel
      end
    end
  end
end

module SceneManager
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_Splash
  end
end

class Scene_Splash < Scene_Base
  
  def start
    super
    @callback = method(:dispose_sprite)
    @display = RS::Slash::SpriteImpl.new(@callback)
  end
  
  def update
    super
    @display.update
  end
  
  def dispose_sprite
    
    component = RS::Slash::NextSceneCompoenent.new
    component.execute do
      if not @display.disposed?
        @display.bitmap.dispose if not @display.bitmap.disposed?
        @display.dispose
        @display = nil
      end
    end
    
  end
end