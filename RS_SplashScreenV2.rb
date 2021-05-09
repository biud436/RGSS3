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
# Description : 
#
# To use this script, you have to copy and paste the script somewhere above 
# Main script and below Materials section.
#
# and next you should make a new folder to "Graphics/Splash" in the root game 
# directory and place a desired image called "Graphics/Splash/splash.png"
#
# Notice that you could be seen white screen if you didn't place an image 
# at the base folder.
#
#================================================================
module RS; end;
module RS::Slash
  NEXT_SCENE = Scene_Title
  BASE_DIR = "Graphics/Splash/"
  
  Dir.mkdir(File.join(".", BASE_DIR)) if !Dir.exist? File.join(".", BASE_DIR)
  
  IMAGES = {
    # Graphics/Splash/폴더에 로고 이미지를 넣어주세요.
    # 예:) Graphics/Splash/splash.png가 존재해야 합니다.
    # 존재하지 않으면 흰색 화면만 뜹니다.
    :IMAGE1 => "splash"
  }
  
  # 속도입니다
  # 100, 200, 300, 400, 500 까지 적을 수 있습니다
  # step 함수가 기억이 나지 않아서 디테일하진 않습니다 
  ACC = 100
  
  # 결정키를 누르면 빠르게 넘깁니다
  SKIPPING_KEY = :C
  
  # 이미지가 없을 땐 흰색 화면을 뜨게 합니다.
  EMPTY_BITMAP = (->(){
    bitmap = Bitmap.new(Graphics.width, Graphics.height)
    white = Color.new(255, 255, 255, 255)
    bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, white)
    bitmap
  }).call
  
  # 컴포넌트
  class NextSceneComponent
    def execute(&block)
      block.call
      SceneManager.call(NEXT_SCENE)
    end
  end  
  
  # 스프라이트
  class SpriteImpl < ::Sprite
    attr_accessor :dirty
    
    # 초기화
    def initialize(callback)
      super(nil)
      self.opacity = 0
      self.dirty = false
      @ready_next_scene = false
      @callback = callback
      init_with_bitmap
    end
    
    # 업데이트
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
      @ready_next_scene = true if Input.trigger?(SKIPPING_KEY)
      @callback.call if @ready_next_scene
    end
    
    # 비트맵 초기화
    def init_with_bitmap
      file_name = IMAGES[:IMAGE1]
      bitmap = Cache.load_bitmap(BASE_DIR, file_name) rescue EMPTY_BITMAP
      self.bitmap = bitmap
    end
    
    # 투명도 업데이트
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

# 초기 씬 변경
module SceneManager
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_Splash
  end
end

# 스플래시 씬
class Scene_Splash < Scene_Base
  
  def start
    super
    @callback = method(:dispose_sprite)
    
    # 콜백 메소드 전달
    @display = RS::Slash::SpriteImpl.new(@callback)
  end
  
  def update
    super
    @display.update
  end
  
  def dispose_sprite
    
    component = RS::Slash::NextSceneComponent.new
    component.execute do
      if not @display.disposed?
        @display.bitmap.dispose if not @display.bitmap.disposed?
        @display.dispose
        @display = nil
      end
    end
    
  end
end