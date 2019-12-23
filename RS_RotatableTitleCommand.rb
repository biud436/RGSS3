#==============================================================================
# ** Rotatable Title Command (RPG Maker VX Ace)
#==============================================================================
# Name       : Rotatable Title Command (RPG Maker VX Ace)
# Author     : biud436
# Version    : 1.1.0
#==============================================================================
# ** 업데이트 로그
#==============================================================================
# 2015.08.11 (v1.1.0) - 누적된 각도를 초기화하는 코드를 추가했으며 일부 코드를 정리했습니다.
# 2014.06.30 (v1.0.0) - 스크립트 작성일
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
imported = {} if imported.nil?
imported["RS_RotatableTitleCommand"] = true

module RS_TITLE_COMMAND
  
  # 기본 위치
  X = Graphics.width/2
  Y = Graphics.height/2 + 100
  
  # 원점과의 거리
  DIST = 80
  
  # 메뉴 갯수
  MENU_SIZE = 3
  
  # 최대 각도
  MAX_ANGLE = 360.0 / MENU_SIZE
  
  # 각속도
  ANGLE_SPEED = 120.0
  
  # 파이 기본값
  PI = Math::PI
  
  #--------------------------------------------------------------------------
  # * 라디안 단위로 변환
  #--------------------------------------------------------------------------    
  def convert_to_radian(_angle)
    (Math::PI / 180) * _angle
  end
  #--------------------------------------------------------------------------
  # * 각도 누적값 초기화
  #--------------------------------------------------------------------------     
  def wrap_max(angle)
    angle -= 360.0 while angle > 360.0
    angle += 360.0 while angle < -360.0
    return angle
  end  
  #--------------------------------------------------------------------------
  # * 각도 누적값 초기화
  #--------------------------------------------------------------------------     
  def wrap_angle(angle)
    angle -= 360.0 while angle > 180.0
    angle += 360.0 while angle < -180.0
    return angle
  end
end
 
#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  This class performs the title screen processing.
#============================================================================== 
class Scene_Title < Scene_Base
  include RS_TITLE_COMMAND
  alias xxxx_create_command_window create_command_window
  alias xxxx_start start
  alias xxxx_terminate terminate
  #--------------------------------------------------------------------------
  # * 시작
  #--------------------------------------------------------------------------    
  def start
    xxxx_start
    @max = 1
    @rotate_left = false
    @rotate_right = false
    @origin = [X,Y]
    @r = 3
    @angle = 0.0
    @call = false
    make_method
  end
  #--------------------------------------------------------------------------
  # * 제거
  #--------------------------------------------------------------------------    
  def terminate
    xxxx_terminate
    dispose_method
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------    
  def update
    super
    update_method if @bText
    left(Input.trigger?(:LEFT)) if Input.repeat?(:LEFT)
    right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    select_menu if Input.trigger?(:C)    
  end
  #--------------------------------------------------------------------------
  # * 메뉴 선택
  #--------------------------------------------------------------------------   
  def select_menu
    if @call == false
      case menu_index
      when 0; command_new_game
      when 1; command_continue
      when 2; command_shutdown
      end
      @call = true
    end
  end
  #--------------------------------------------------------------------------
  # * 왼쪽
  #--------------------------------------------------------------------------   
  def left(wrap = false,sound = true)
    if wrap
      Sound.play_cursor if sound
      @rotate_left = true 
      @rotate_right = false  
      wrap_max(@max -= MAX_ANGLE)
    end
  end
  #--------------------------------------------------------------------------
  # * 오른쪽
  #--------------------------------------------------------------------------   
  def right(wrap = false, sound = true)
    if wrap
      Sound.play_cursor if sound
      @rotate_left = false
      @rotate_right = true
      wrap_max(@max += MAX_ANGLE)
    end
  end
  #--------------------------------------------------------------------------
  # * 각도 증가
  #--------------------------------------------------------------------------     
  def up_angle
    (2.0 * PI) / ANGLE_SPEED
  end
  #--------------------------------------------------------------------------
  # * 메뉴 이동
  #--------------------------------------------------------------------------   
  def move_menu
    move(@text1, @r + DIST, @angle+180)
    move(@text2, @r + DIST, @angle)
    move(@text3, @r + DIST, @angle+90)
  end
  #--------------------------------------------------------------------------
  # * 투명도 처리
  #--------------------------------------------------------------------------  
  def update_opacity
    @text1.opacity,@text2.opacity,@text3.opacity = opacity_return
  end
  #--------------------------------------------------------------------------
  # * 톤 처리
  #--------------------------------------------------------------------------  
  def update_tone
    @text1.tone,@text2.tone,@text3.tone = tone_set
  end
  #--------------------------------------------------------------------------
  # * 메뉴 위치 업데이트
  #--------------------------------------------------------------------------   
  def update_method
      
    # 왼쪽
    if !@rotate_right && @rotate_left && @angle > convert_to_radian(@max)
      wrap_angle(@angle -= up_angle)
    end        
    
    # 오른쪽
    if @rotate_right && !@rotate_left && @angle < convert_to_radian(@max)
      wrap_angle(@angle += up_angle)
    end
    
    # 메뉴 이동 처리
    move_menu
    
    # 투명도 업데이트
    update_opacity
    
    # 톤 업데이트
    update_tone    
    
    # 줌 처리
    zoom
  end
  #--------------------------------------------------------------------------
  # * 투명
  #-------------------------------------------------------------------------- 
  def opacity_return
    [255,128,128].rotate(-menu_index)
  end
  #--------------------------------------------------------------------------
  # * 줌
  #-------------------------------------------------------------------------- 
  def zoom
    inst = [@text1, @text2, @text3]
    [:big,:normal,:normal].rotate(-menu_index).each_with_index do |sym,index|
      method(sym).call(inst[index])
    end
  end
  #--------------------------------------------------------------------------
  # * 회색
  #--------------------------------------------------------------------------    
  def normal_tone
    Tone.new(-10,-10,0,255)
  end
  #--------------------------------------------------------------------------
  # * 기본색
  #--------------------------------------------------------------------------  
  def over_tone
    Tone.new
  end
  #--------------------------------------------------------------------------
  # * 톤
  #--------------------------------------------------------------------------    
  def tone_set
    [over_tone,normal_tone,normal_tone].rotate(-menu_index)
  end
  #--------------------------------------------------------------------------
  # * 크게 확대
  #--------------------------------------------------------------------------  
  def big(method)
    while 1.5 > method.zoom_x && 1.5 > method.zoom_y 
      method.zoom_x += 0.01667
      method.zoom_y += 0.01667
    end
  end
  #--------------------------------------------------------------------------
  # * 보통 크기로
  #--------------------------------------------------------------------------  
  def normal(method)
    while 1.0 < method.zoom_x && 1.0 < method.zoom_y 
      method.zoom_x -= 0.01667
      method.zoom_y -= 0.01667
    end
  end
  #--------------------------------------------------------------------------
  # * 현재 메뉴
  #--------------------------------------------------------------------------   
  def menu_index
    n = method_distance
    return n.index(n.min)
  end
  #--------------------------------------------------------------------------
  # * 현재 메뉴의 위치값
  #--------------------------------------------------------------------------   
  def method_distance
    a = @text1.y - @origin[1]
    b = @text2.y - @origin[1]
    c = @text3.y - @origin[1]
    return [a,b,c]
  end  
  #--------------------------------------------------------------------------
  # * 메뉴 이동
  #--------------------------------------------------------------------------   
  def move(method,r,angle)
    method.x = @origin[0] + r * Math.cos(angle) - method.bitmap.width/2
    method.y = @origin[1] + r * Math.sin(angle) - method.bitmap.height/2
    return method
  end
  #--------------------------------------------------------------------------
  # * 메소드 만들기
  #--------------------------------------------------------------------------     
  def make_method
    @text1 = make_cache("game_start")
    @text2 = make_cache("game_load")
    @text3 = make_cache("game_exit")
    @bText = true
  end
  #--------------------------------------------------------------------------
  # * 문자 묘화
  #--------------------------------------------------------------------------     
  def make_text(str)
    text = Sprite.new
    text.bitmap = Bitmap.new(100,20)
    text.bitmap.draw_text(text.bitmap.rect,str.to_s,1)
    return text
  end
  #--------------------------------------------------------------------------
  # * 그림 묘화
  #--------------------------------------------------------------------------     
  def make_cache(str)
    text = Sprite.new
    text.bitmap = Cache.picture(str)
    return text
  end  
  #--------------------------------------------------------------------------
  # * 비트맵 만들기
  #--------------------------------------------------------------------------     
  def make_bitmap
    px = Sprite.new
    px.bitmap = Bitmap.new(1,1)
    px.bitmap.fill_rect(px.bitmap.rect, Color.new(0,0,0,0))
    return px
  end
  #--------------------------------------------------------------------------
  # * 비트맵 해방
  #--------------------------------------------------------------------------     
  def dispose_method
    @text1.bitmap.dispose
    @text1.dispose
    @text2.bitmap.dispose
    @text2.dispose    
    @text3.bitmap.dispose
    @text3.dispose        
  end
  #--------------------------------------------------------------------------
  # * command_window
  #--------------------------------------------------------------------------       
  def create_command_window
    xxxx_create_command_window    
    @command_window.x = (Graphics.width - @command_window.width) - 20
    @command_window.opacity = 0
    @command_window.contents_opacity = 0
    @command_window.close
  end
end