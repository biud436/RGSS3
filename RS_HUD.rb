#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# Name : HUD
# Anthor : biud436
# Description : 
# This script allows you to show up the hud and provides fundamental gauge bars.
# and then it can display hp and mp and exp gauges and the level text fast, 
# until max level value.
#==============================================================================
# ** Change Log
#==============================================================================
# 2018.10.08 : 
# - visible 토글 기능 추가
# 2018.07.17 :
# - 묘화 속도 향상
# - 경험치 바가 잠깐 보이는 현상 제거
# 2018.08.30 : 
# - 화면 크기 변경했을 때 위치가 앵커에 따라 바뀌지 않는 현상 수정
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_HUD"] = true

module HUD
  # This value would set the anchor of the hud in the game screen.
  # You must choose desired anchor in one of below list.
  #   :TOP_RIGHT
  #   :BOTTOM_RIGHT
  #   :BOTTOM_LEFT
  #   :TOP_LEFT
  SCREEN = :BOTTOM_LEFT

  # The width value of hud image from Graphics/pictures folder.
  W = 317

  # The height value of hud iamge from Graphics/pictures folder.
  H = 101

  # This is the padding value between screen border and hud image
  PD = 0

  # Set whether the edge of the face image would change smoothly.
  SmoothEdge = true
  
  # Set the visible value in all hud images
  VISIBLE = true

  # Set the rotation value of the hud, as the radian.
  F_Angle = Math::PI/180

  # This calculates the position of the hud from the one of four hud anchor.
  POS = case SCREEN
  when :TOP_RIGHT then Proc.new{[Graphics.width - W - PD,PD]}
  when :BOTTOM_RIGHT then Proc.new{[Graphics.width - W - PD,Graphics.height - H - PD]}
  when :BOTTOM_LEFT then Proc.new{[PD,Graphics.height - H - PD]}
  when :TOP_LEFT  then Proc.new{[PD,PD]}
  end
end

#==============================================================================
# ** Color
#==============================================================================
class Color
  def add(obj)
    r = [[self.red + obj.red, 255].min,0].max
    g = [[self.green + obj.green, 255].min,0].max
    b = [[self.blue + obj.blue, 255].min,0].max
    a = [[self.alpha + obj.alpha, 255].min,0].max
    return Color.new(r,g,b,a)
  end
end

#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Map
  alias xxxx_start start
  alias xxxx_update update
  alias xxxx_terminate terminate
  attr_accessor :lib_hud
  #--------------------------------------------------------------------------
  # * 시작
  #--------------------------------------------------------------------------
  def start
    xxxx_start
    @lib_hud = Hud.new
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    xxxx_update
    @lib_hud.update
  end
  #--------------------------------------------------------------------------
  # * 파괴
  #--------------------------------------------------------------------------
  def terminate
    xxxx_terminate
    @lib_hud.dispose
  end
end

#~ #==============================================================================
#~ # ** Game_Map
#~ #==============================================================================
#~ class Game_Map
#~   #--------------------------------------------------------------------------
#~   # * 인스턴스 획득
#~   #--------------------------------------------------------------------------
#~   def hud_window
#~     return unless SceneManager.scene_is?(Scene_Map)
#~     SceneManager.scene.lib_hud
#~   end
#~   #--------------------------------------------------------------------------
#~   # * 투명도
#~   #--------------------------------------------------------------------------
#~   def hud_opacity=(var)
#~     return unless SceneManager.scene_is?(Scene_Map)
#~     hud_window.opacity = var
#~   end
#~   #--------------------------------------------------------------------------
#~   # * 가시 상태
#~   #--------------------------------------------------------------------------
#~   def hud_visible=(var)
#~     return unless SceneManager.scene_is?(Scene_Map)
#~     hud_window.visible = var
#~   end
#~ end
  
#==============================================================================
# ** Game_System
#==============================================================================
class Game_System
  attr_reader :hud_visible
  #--------------------------------------------------------------------------
  # * initialize
  #--------------------------------------------------------------------------  
  alias rs_hud_system_initialize initialize
  def initialize
    rs_hud_system_initialize
    @hud_visible = HUD::VISIBLE
  end  
  #--------------------------------------------------------------------------
  # * show_hud
  #--------------------------------------------------------------------------    
  def show_hud
    @hud_visible = true
  end
  #--------------------------------------------------------------------------
  # * invisible_hud
  #--------------------------------------------------------------------------  
  def hide_hud
    @hud_visible = false
  end
end

#==============================================================================
# ** Hud
#==============================================================================
class Hud
  GColor = Struct.new(:red,:blue,:green,:alpha)
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize
    create_hud
    create_hp
    create_mp
    create_exp
    create_text
    set_position
    self.opacity = 230
    self.visible = $game_system.hud_visible
  end
  #--------------------------------------------------------------------------
  # * 틀 생성
  #--------------------------------------------------------------------------
  def create_hud
    @hud = Sprite.new
    @hud.bitmap = Cache.picture("hud_window_empty")
    @hud.x,@hud.y = HUD::POS.call
    @face = Sprite.new
    @face.bitmap = draw_circle(player.face_name, 48, 48, 48)
  end
  #--------------------------------------------------------------------------
  # * 마스크 비트맵 생성
  #--------------------------------------------------------------------------  
  def create_mask_bitmap
    @mask_bitmap = @mask_bitmap || Cache.picture("masking")
  end
  #--------------------------------------------------------------------------
  # * 원 그리기
  # 나눗셈 없이 빠른 속도로 계산합니다.
  # 참고 : http://forum.falinux.com/zbxe/index.php?document_srl=406150
  #--------------------------------------------------------------------------
  def inner_circle(bitmap, face_bitmap, x_center, y_center, x_coor, y_coor)
    
    x_dot = 0
    y_dot = 0
    
    alpha_bitmap = create_mask_bitmap
          
    # 아래
    y_dot = y_center + y_coor
    for x_dot in ((x_center - x_coor)...(x_center + x_coor))
      color = face_bitmap.get_pixel(x_dot, y_dot)
      color.alpha = alpha_bitmap.get_pixel(x_dot, y_dot).alpha if HUD::SmoothEdge
      bitmap.set_pixel(x_dot, y_dot, color)
    end
    
    # 위
    y_dot = y_center - y_coor
    for x_dot in ((x_center - x_coor)...(x_center + x_coor))
      color = face_bitmap.get_pixel(x_dot, y_dot)
      color.alpha = alpha_bitmap.get_pixel(x_dot, y_dot).alpha if HUD::SmoothEdge
      bitmap.set_pixel(x_dot, y_dot, color)
    end
    
    # 중간 아래
    y_dot = y_center + x_coor
    for x_dot in ((x_center - y_coor)...(x_center + y_coor))
      color = face_bitmap.get_pixel(x_dot, y_dot)
      color.alpha = alpha_bitmap.get_pixel(x_dot, y_dot).alpha if HUD::SmoothEdge
      bitmap.set_pixel(x_dot, y_dot, color)
    end
    
    # 중간 위
    y_dot   = y_center - x_coor
    for x_dot in ((x_center - y_coor)...(x_center + y_coor))
      color = face_bitmap.get_pixel(x_dot, y_dot)
      color.alpha = alpha_bitmap.get_pixel(x_dot, y_dot).alpha if HUD::SmoothEdge
      bitmap.set_pixel(x_dot, y_dot, color)
    end

  end
  #--------------------------------------------------------------------------
  # * 원 그리기
  # 나눗셈 없이 빠른 속도로 계산합니다.
  # 참고 : http://forum.falinux.com/zbxe/index.php?document_srl=406150
  #--------------------------------------------------------------------------  
  def draw_circle(face_name, x_center, y_center, radius)
    
    x_coor = 0
    y_coor = radius
    p_value = 3 - 2 * radius
    bitmap = Bitmap.new(96, 96)
    face_bitmap = Cache.face(face_name)

    while ( x_coor < y_coor)
      inner_circle( bitmap, face_bitmap, x_center, y_center, x_coor, y_coor)
      if p_value < 0
        p_value += 4 * x_coor + 6
      else
        p_value += 4 * ( x_coor - y_coor) + 10
        y_coor-=1
      end
      x_coor+=1
    end
    if x_coor == y_coor
      inner_circle( bitmap, face_bitmap, x_center, y_center, x_coor, y_coor)
    end
    
    bitmap
    
  end
  #--------------------------------------------------------------------------
  # * HP 생성
  #--------------------------------------------------------------------------
  def create_hp
    @hp = Spr_Params.new
    @hp.bitmap = Cache.picture("hp")
  end
  #--------------------------------------------------------------------------
  # * MP 생성
  #--------------------------------------------------------------------------
  def create_mp
    @mp = Spr_Params.new
    @mp.bitmap = Cache.picture("mp")
  end
  #--------------------------------------------------------------------------
  # * EXP 생성
  #--------------------------------------------------------------------------
  def create_exp
    @exp = Spr_Params.new
    @exp.visible = false
    @exp.bitmap = Cache.picture("exr")
    @exp_dirty = true
  end
  #--------------------------------------------------------------------------
  # * 텍스트 생성 (주소값 전달)
  #--------------------------------------------------------------------------
  def create_text
    @hp_text = text(method(:hp_str))
    @mp_text = text(method(:mp_str))
    @exp_text = text(method(:exp_str))
    @level_text = text(method(:level_str),16)
  end
  #--------------------------------------------------------------------------
  # * 좌표 설정
  #--------------------------------------------------------------------------
  def set_position
    set_coord(@face,0,0)
    set_coord(@hp,160,43)
    set_coord(@mp,160,69)
    set_coord(@exp,83,91)
    set_coord(@hp_text,160,43)
    set_coord(@mp_text,160,69)
    set_coord(@level_text,60,71)
    set_coord(@exp_text,120.5,83)
  end
  #--------------------------------------------------------------------------
  # * 플레이어의 현재 레벨
  #--------------------------------------------------------------------------
  def set_player
    @actor = $game_party.members[0]
    @level = @actor.level
  end
  #--------------------------------------------------------------------------
  # * 현재 플레이어
  #--------------------------------------------------------------------------
  def player
   $game_party.members[0]
  end
  #--------------------------------------------------------------------------
  # * HP (문자열)
  #--------------------------------------------------------------------------
  def hp_str
    sprintf("%s / %s",player.hp.to_s,player.mhp.to_s)
  end
  #--------------------------------------------------------------------------
  # * MP (문자열)
  #--------------------------------------------------------------------------
  def mp_str
    sprintf("%s / %s",player.mp.to_s,player.mmp.to_s)
  end
  #--------------------------------------------------------------------------
  # * EXP (문자열)
  #--------------------------------------------------------------------------
  def exp_str
    set_player
    exp = player.max_level? ? "----" : @actor.exp - @actor.current_level_exp
    max_exp =  player.max_level? ? "----" : @actor.next_level_exp - @actor.current_level_exp
    return sprintf("%s / %s",exp.to_s,max_exp.to_s)
  end
  #--------------------------------------------------------------------------
  # * 레벨 (문자열)
  #--------------------------------------------------------------------------
  def level_str
    player.level.to_s
  end
  #--------------------------------------------------------------------------
  # * 보이기 / 감추기
  #--------------------------------------------------------------------------
  def visible=(t = true)
    params = [@hud,@face,@hp,@mp,@hp_text,@mp_text,@level_text,@exp,@exp_text]
    params.each {|i| i.visible = t}
  end
  #--------------------------------------------------------------------------
  # * 투명도 설정
  #--------------------------------------------------------------------------
  def opacity=(v = 255)
    v = 255 unless v.between?(0,255)
    params = [@hud,@face,@hp,@mp,@hp_text,@mp_text,@level_text,@exp,@exp_text]
    params.each {|i| i.opacity = v}
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    param_update
    text_update
    self.visible = $game_system.hud_visible
  end
  #--------------------------------------------------------------------------
  # * HP, MP, EXP 업데이트
  #--------------------------------------------------------------------------
  def param_update
    @hp.set_rect(hp_rate,@hp.height)
    @mp.set_rect(mp_rate,@mp.height)
    @exp.set_rect(exp_rate,@exp.height)
    if @exp_dirty
      @exp.visible = true 
      @exp_dirty = false
    end
    [@hp,@mp,@exp].each {|i| i.update }
  end
  #--------------------------------------------------------------------------
  # * 텍스트 업데이트
  #--------------------------------------------------------------------------
  def text_update
    [@hp_text,@mp_text,@level_text,@exp_text].each {|i| i.update}
  end
  #--------------------------------------------------------------------------
  # * HP (비율)
  #--------------------------------------------------------------------------
  def hp_rate
    @hp.bitmap.width * (player.hp.to_f / player.mhp)
  end
  #--------------------------------------------------------------------------
  # * MP (비율)
  #--------------------------------------------------------------------------
  def mp_rate
    @mp.bitmap.width * (player.mp.to_f / player.mmp)
  end
  #--------------------------------------------------------------------------
  # * EXP (비율)
  #--------------------------------------------------------------------------
  def exp_rate
    set_player
    exp = player.max_level? ? @actor.current_level_exp : @actor.exp - @actor.current_level_exp
    max_exp =  player.max_level? ? @actor.current_level_exp : @actor.next_level_exp - @actor.current_level_exp
    return @exp.bitmap.width * (exp.to_f / max_exp)
  end
  #--------------------------------------------------------------------------
  # * 해제
  #--------------------------------------------------------------------------
  def dispose
    params = [@hud,@face,@hp,@mp,@hp_text,@mp_text,@level_text,@exp,@exp_text]
    params.each {|i| bitmap_dispose(i)}
  end
  #--------------------------------------------------------------------------
  # * 비트맵 해제
  #--------------------------------------------------------------------------
  def bitmap_dispose(object)
    object.bitmap.dispose
    object.dispose
  end
  #--------------------------------------------------------------------------
  # * 좌표값 설정
  #--------------------------------------------------------------------------
  def set_coord(s,x,y)
    s.x = @hud.x + x
    s.y = @hud.y + y
  end
  #--------------------------------------------------------------------------
  # * 텍스트 비트맵 생성
  #--------------------------------------------------------------------------
  def text(str,size=14)
    t = Text.new
    t.bitmap = Bitmap.new(120,20)
    t.bitmap.font.size = size
    t.draw_text(str)
    t.z = 101
    return t
  end
end

#==============================================================================
# ** Spr_Params
#==============================================================================
class Spr_Params < Sprite
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize
    super
    @rate = 0.0
  end
  #--------------------------------------------------------------------------
  # * 영역 설정
  #--------------------------------------------------------------------------
  def set_rect(width,height)
    @rate = width
    self.src_rect.set(0,0,@rate,height)
  end
end

#==============================================================================
# ** Text
#==============================================================================
class Text < Sprite
  #--------------------------------------------------------------------------
  # * 텍스트 묘화
  #--------------------------------------------------------------------------
  def draw_text(str)
    @str = str
    @text = str.call
    self.bitmap.draw_text(self.src_rect,str.call,1)
  end
  #--------------------------------------------------------------------------
  # * 묘화
  #--------------------------------------------------------------------------
  def update
    super()
    return if @str.call == @text
    @text = @str.call
    self.bitmap.clear
    self.bitmap.draw_text(self.bitmap.rect,@text,1)
  end
end