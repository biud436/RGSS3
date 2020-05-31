#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# ** Rotate_Menu 1.2 (RPG Maker VX Ace)
#==============================================================================
# Name       : Rotate Title Menu
# Author     : biud436
# Version    : 1.2
#==============================================================================
# ** 업데이트 로그
#==============================================================================
# 2015.08.12 - 스테이터스 메뉴 추가
# 2015.08.11 - 누적된 각도를 초기화하는 코드를 추가했으며 일부 코드를 정리했습니다.
# 2014.08.13 - 스크립트 최초 작성일
#==============================================================================
# ** RS_MENU_COMMAND
#==============================================================================
# ■ 스크립트 소개
# 인게임 메뉴를 원형으로 배치되어있는 텍스트 버튼으로 표시할 수 있는 스크립트입니다
#
# ■ 스크린샷
# http://postfiles13.naver.net/20150812_92/biud436_1439359399930SMSYY_PNG/0.PNG?type=w1
#
# ■ 설치
# Main 위 소재 밑 사이의 빈 공간에 추가 삽입해주세요.
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_RotateMenu"] = true

module RS_MENU_COMMAND

  # 기본 위치
  X = Graphics.width/2
  Y = Graphics.height/2 + 100

  ITEM = "아이템"
  SAVE = "저장"
  EXIT = "끝내기"
  STAT = "스테이터스"

  # 원점과의 거리
  DIST = 80

  # 메뉴 갯수
  MENU_SIZE = 4

  # 최대 각도
  MAX_ANGLE = 360.0 / MENU_SIZE

  # 각속도
  ANGLE_SPEED = 200.0

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
# ** Window_Rotate
#------------------------------------------------------------------------------
#
#==============================================================================
class Window_Rotate < Window_Base
  include RS_MENU_COMMAND

  attr_accessor   :origin
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize
    super(0,0,Graphics.width,Graphics.height)
    @angle = @max = 0.0
    @rotate_left = false
    @rotate_right = false
    @origin = $game_player
    @r = 3
    make_method
    @call = false
    self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    super
    update_method if @bText
    SceneManager.call(Scene_Map) if Input.trigger?(:B)
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
      when 0
        SceneManager.call(Scene_Item)
      when 1
        Sound.play_ok
        SceneManager.call(Scene_Save)
      when 2
        Sound.play_ok
        SceneManager.call(Scene_End)
      when 3
        Sound.play_ok
        SceneManager.call(Scene_Status)
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
      wrap_max(@max -= MAX_ANGLE / 2)
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
      wrap_max(@max += MAX_ANGLE / 2)
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
    move(@text1, @r + DIST, @angle+45)
    move(@text2, @r + DIST, @angle+90)
    move(@text3, @r + DIST, @angle+135)
    move(@text4, @r + DIST, @angle+180)
  end
  #--------------------------------------------------------------------------
  # * 인스턴스 획득
  #--------------------------------------------------------------------------
  def get(i)
    self.instance_variable_get(i)
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

    move_menu

    @text1.opacity, @text2.opacity, @text3.opacity, @text4.opacity  = opacity_return

    zoom

  end
  #--------------------------------------------------------------------------
  # * 투명
  #--------------------------------------------------------------------------
  def opacity_return
    [255,128,128,128].rotate(-menu_index)
  end
  #--------------------------------------------------------------------------
  # * 줌
  #--------------------------------------------------------------------------
  def zoom
    inst = [@text1, @text2, @text3, @text4]
    [:big,:normal,:normal,:normal].rotate(-menu_index).each_with_index do |sym,index|
      method(sym).call(inst[index])
    end
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
    a = @text1.y - $game_player.screen_y
    b = @text2.y - $game_player.screen_y
    c = @text3.y - $game_player.screen_y
    d = @text4.y - $game_player.screen_y
    return [a,b,c,d]
  end
  #--------------------------------------------------------------------------
  # * 메뉴 이동
  #--------------------------------------------------------------------------
  def move(method,r,angle)
    method.x = @origin.screen_x + r * Math.cos(angle) - method.bitmap.width/2
    method.y = @origin.screen_y + r * Math.sin(angle) - method.bitmap.height/2
    return method
  end
  #--------------------------------------------------------------------------
  # * 검정색
  #--------------------------------------------------------------------------
  def color_black
    Color.new(0,0,0,0)
  end
  #--------------------------------------------------------------------------
  # * 빨간색
  #--------------------------------------------------------------------------
  def color_red
    Color.new(255,0,0,0)
  end
  #--------------------------------------------------------------------------
  # * 메소드 만들기
  #--------------------------------------------------------------------------
  def make_method
    @text1 = make_text(ITEM)
    @text2 = make_text(SAVE)
    @text3 = make_text(EXIT)
    @text4 = make_text(STAT)
    @bText = true
  end
  #--------------------------------------------------------------------------
  # * 문자 묘화
  #--------------------------------------------------------------------------
  def make_text(str)
    text = Sprite.new
    text.opacity = 0
    text.bitmap = Bitmap.new(100,20)
    text.bitmap.draw_text(text.bitmap.rect,str.to_s,1)
    return text
  end
  #--------------------------------------------------------------------------
  # * 그림 묘화
  #--------------------------------------------------------------------------
  def make_cache(str,*args)
    text = Sprite.new
    text.opacity = 0
    text.bitmap = Cache.picture(str.to_s)
    text.src_rect.set(args[0],args[1],args[2],args[3])
    text.oy = -args[3]
    return text
  end
  #--------------------------------------------------------------------------
  # * 해방
  #--------------------------------------------------------------------------
  def dispose
    super
    dispose_method
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
    @text4.bitmap.dispose
    @text4.dispose
  end
end

#==============================================================================
# ** Scene_Custom_Menu
#------------------------------------------------------------------------------
#
#==============================================================================
class Scene_Custom_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * 시작
  #--------------------------------------------------------------------------
  def start
    super
    @window_rotate = Window_Rotate.new
  end
  #--------------------------------------------------------------------------
  # * Create Background
  #--------------------------------------------------------------------------
  def create_background
    @background_sprite = Sprite.new
    @background_sprite.bitmap = SceneManager.background_bitmap
  end
  #--------------------------------------------------------------------------
  # * 제거
  #--------------------------------------------------------------------------
  def terminate
    super
    @window_rotate.dispose
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    super
    @window_rotate.update
  end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
#
#==============================================================================
class Scene_Map
  #--------------------------------------------------------------------------
  # * 메뉴 부르기
  #--------------------------------------------------------------------------
  def call_menu
    Sound.play_ok
    SceneManager.call(Scene_Custom_Menu)
  end
end
