#===============================================================================
# Name : RS_InputExCallObjects
# Author : biud436
#-------------------------------------------------------------------------------
# 사용법
#-------------------------------------------------------------------------------
# 이 스크립트는 RS_Input이라는 선행 전체키 스크립트가 있어야 동작합니다.
#
# 이 스크립트는 주로 마우스 커서의 움직임을 관찰하여 마우스 오버, 마우스 클릭, 마우스 아웃
# 이벤트를 발생시킵니다.
#
# 그림 위에 마우스 커서가 있을 때, (마우스 오버시),
# 그림을 마우스로 클릭할 때,
# 그림이 마우스 위에 오버되고 빠져나갈 때, (마우스 아웃 시)
#
# 특정 커먼 이벤트를 발생시킵니다.
#
#-------------------------------------------------------------------------------
# Version Log
#-------------------------------------------------------------------------------
# 2020.01.29 (v1.0.0) - First Release.
#===============================================================================
$imported = {} if $imported.nil?
$imported["RS_InputExCallObjects"] = true

if !$imported["RS_Input"]
  `start https://biud436.blog.me/220289463681`
  raise %Q(
    전체키 스크립트를 찾을 수 없습니다. 
    의존성 스크립트를 모두 설치해주시기 바랍니다.
  )
end

module RS::Input
  module Pictures
    
    # 마우스 오버 시
    OVER = {
      # 그림 번호 => 커먼 이벤트 ID, 
      1 => 1
    }
    
    # 마우스 클릭 시
    CLICK = {
      # 그림 번호 => 커먼 이벤트 ID, 
      1 => 2
    }
    
    # 마우스가 오버되고 빠져나갈 때
    OUT = {
      # 그림 번호 => 커먼 이벤트 ID, 
      1 => 3,
    }
    
    # 마우스 커서의 크기
    CURSOR_SIZE = 24
    
    # 기본 클래스
    BASE_CLASS = Sprite
    
  end
end

#==============================================================================
# ** Sprite
#==============================================================================
class RS::Input::Pictures::BASE_CLASS
  attr_reader :mouse_over, :mouse_clicked
  
  alias rs_mb_sprite_initialize initialize
  def initialize(viewport=nil)
    rs_mb_sprite_initialize(viewport)
    @mouse_over = false
    @prev_mouse_over = false
    @mouse_clicked = false
  end          
  
  def update_mouse
    return if !self.bitmap
    return if !self.visible

    f = RS::Input::Pictures::CURSOR_SIZE / 2
    mx = TouchInput.x + f
    my = TouchInput.y + f
    cx = self.x
    cy = self.y
    cw = self.width
    ch = self.height
    
    return if cw <= 0 || ch <= 0
    
    if mx.between?(cx, cx + cw) and my.between?(cy, cy + ch)
      @mouse_over = true
    else
      @mouse_over = false
    end
    
    if @mouse_over
      @mouse_clicked = TouchInput.trigger?(:LEFT)
      on_mouse_over
    else
      if @prev_mouse_over
        on_mouse_out
      end
    end
    
    if @mouse_clicked
      on_mouse_click
    end
      
  end 
  def on_mouse_out
    @prev_mouse_over = false
  end
  def on_mouse_over
    @prev_mouse_over = true
  end
  def on_mouse_click
    @mouse_clicked = false
  end
  alias rs_mb_sprite_update update
  def update
    rs_mb_sprite_update
    update_mouse
  end
end

#==============================================================================
# ** Window
#==============================================================================
class Window
  alias rs_mb_window_initialize initialize
  def initialize(*args)
    
    if args.length == 1
      viewport = args[0]
    elsif args.length == 4
      x, y, width, height = args
    end
    
    rs_mb_window_initialize(*args)
    
    @mouse_over = false
    @prev_mouse_over = false
    @mouse_clicked = false
  end
  
  def update_mouse
    return if !self.contents
    return if !self.visible

    f = RS::Input::Pictures::CURSOR_SIZE / 2
    mx = TouchInput.x - f
    my = TouchInput.y - f
    cx = self.x
    cy = self.y
    cw = self.width
    ch = self.height
    
    return if cw <= 0 || ch <= 0
    
    if mx.between?(cx, cx + cw) and my.between?(cy, cy + ch)
      @mouse_over = true
    else
      @mouse_over = false
    end
    
    if @mouse_over
      @mouse_clicked = TouchInput.trigger?(:LEFT)
      on_mouse_over
    else
      on_mouse_out
    end
    
    if @mouse_clicked
      on_mouse_click
    end
      
  end  
  
  def on_mouse_out
    @prev_mouse_over = false
  end
  def on_mouse_over
    @prev_mouse_over = true
  end
  def on_mouse_click
    @mouse_clicked = false
  end  
  
  alias rs_mb_window_update update
  def update
    rs_mb_window_update
    update_mouse
  end
  
end

#==============================================================================
# ** Sprite_Picture
#==============================================================================
class Sprite_Picture

  def on_mouse_over
    if @picture.name
      common_event_id = RS::Input::Pictures::OVER[@picture.number]
      if !common_event_id.nil?
        $game_temp.reserve_common_event(common_event_id)
      end
    end
    super
  end
  def on_mouse_out
    if @picture.name
      common_event_id = RS::Input::Pictures::OUT[@picture.number]
      if !common_event_id.nil?
        $game_temp.reserve_common_event(common_event_id)
      end
    end
    super
  end  
  def on_mouse_click
    if @picture.name
      common_event_id = RS::Input::Pictures::CLICK[@picture.number]
      if !common_event_id.nil?
        $game_temp.reserve_common_event(common_event_id)
      end
    end
    super
  end
end
