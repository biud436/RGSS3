#==============================================================================
# HUD 스크립트
#------------------------------------------------------------------------------
# Author : 러닝은빛(biud436)
# Version : 1.3
#
#------------------------------------------------------------------------------
#  Update
#------------------------------------------------------------------------------
# 2018.07.17 (v1.3.0) - 그리기 작업이 더 빨라집니다.
# 2015.05.14 (v1.2.0) - 부드러운 가장자리
# 2015.02.23 (v1.1.0) - XP 버전 배포
# 2014.09.02 (v1.0.0) - 스크립트 최초 작성
#==============================================================================
 
$imported = {} if $imported.nil?
$imported["RS_HudWindowXP"] = [1.3,"2018-07-17"]
 
#==============================================================================
# ** Graphics
#------------------------------------------------------------------------------
# 윈도우의 폭과 높이를 구합니다
#==============================================================================
module Graphics
  
  GetPrivateProfileString = Win32API.new('kernel32','GetPrivateProfileString',
  'pppplp', 'l')
  FindWindow = Win32API.new('user32', 'FindWindow', 'pp', 'l')
  GetClientRect = Win32API.new('user32', 'GetClientRect', 'lp', 'i')  
  begin
    game_name = "\0" * 256
    GetPrivateProfileString.call('Game', 'Title', '', game_name, 256, ".\\Game.ini")
    game_name.delete!("\0")
    hwnd = FindWindow.call('RGSS Player', game_name)
    if hwnd
      @handle = hwnd
    else
      @handle = FindWindow.call('RGSS Player', nil)
    end    
    rect = [0, 0, 0, 0].pack('l4')
    GetClientRect.call(@handle, rect)
    @width,@height = rect.unpack('l4')[2..3]
  rescue
    @width,@height = 640,480
  end
  #--------------------------------------------------------------------------
  # * 폭
  #--------------------------------------------------------------------------   
  def self.width
    return @width
  end
  #--------------------------------------------------------------------------
  # * 높이
  #-------------------------------------------------------------------------- 
  def self.height
    return @height
  end
end
 
 
#==============================================================================
# ** HUD
#==============================================================================
module HUD
  
  # 스크린
  SCREEN = :BOTTOM_LEFT
  
  # 가로 크기
  W = 317
  
  # 세로 크기
  H = 101
  
  # 간격
  PD = 0
  
  # 부드러운 가장자리
  SmoothEdge = true
  
  # 스크린의 좌표
  POS = case SCREEN
  when :TOP_RIGHT then [Graphics.width - W - PD,PD]
  when :BOTTOM_RIGHT then [Graphics.width - W - PD,Graphics.height - H - PD]
  when :BOTTOM_LEFT then [PD,Graphics.height - H - PD]
  when :TOP_LEFT  then [PD,PD]
  end  
end
#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Map
  alias xxxx_main main
  alias xxxx_update update
  attr_accessor :lib_hud
  #--------------------------------------------------------------------------
  # * 시작
  #--------------------------------------------------------------------------   
  def main
    @lib_hud = Hud.new
    xxxx_main
    @lib_hud.dispose
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------   
  def update
    xxxx_update
    @lib_hud.update
  end
end
 
#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # * 인스턴스 획득
  #--------------------------------------------------------------------------   
  def hud_window
    return unless $scene.is_a?(Scene_Map)
    $scene.lib_hud
  end
  #--------------------------------------------------------------------------
  # * 투명도
  #--------------------------------------------------------------------------   
  def hud_opacity=(var)
    return unless $scene.is_a?(Scene_Map)
    hud_window.opacity = var
    return true
  end
  #--------------------------------------------------------------------------
  # * 가시 상태
  #--------------------------------------------------------------------------   
  def hud_visible=(var)
    return unless $scene.is_a?(Scene_Map)
    hud_window.visible = var
    return true
  end
end
 
#==============================================================================
# ** Game_Actor
#==============================================================================
class Game_Actor
  attr_reader   :exp_list
  def max_level?
    actor = $data_actors[@actor_id]
    return true if level >= actor.final_level 
    return false
  end
end
 
#==============================================================================
# ** GColor
#==============================================================================
class GColor
  attr_accessor :red
  attr_accessor :blue
  attr_accessor :green
  attr_accessor :alpha
  def initialize(r=0,g=0,b=0,a=255)
    @red = r
    @green = g
    @blue = b
    @alpha = a
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
# ** Hud
#==============================================================================
class Hud
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
    player.exp = [player.exp,1].max
  end
  #--------------------------------------------------------------------------
  # * 틀 생성
  #--------------------------------------------------------------------------  
  def create_hud
    @hud = Sprite.new
    @hud.bitmap = RPG::Cache.picture("hud_win")
    @hud.x,@hud.y = HUD::POS
    @hud.z = 149
    @face = Sprite.new
    @face.bitmap =  draw_circle(player.battler_name, 48, 48, 48)
    @face.z = 151
  end
  #--------------------------------------------------------------------------
  # * 마스크 비트맵 생성
  #--------------------------------------------------------------------------  
  def create_mask_bitmap
    @mask_bitmap = @mask_bitmap || RPG::Cache.picture("masking")
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
    face_bitmap = RPG::Cache.battler(face_name, 0)
  
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
    @hp.bitmap = RPG::Cache.picture("hp")    
  end
  #--------------------------------------------------------------------------
  # * MP 생성
  #--------------------------------------------------------------------------  
  def create_mp
    @mp = Spr_Params.new
    @mp.bitmap = RPG::Cache.picture("mp")    
  end
  #--------------------------------------------------------------------------
  # * EXP 생성
  #--------------------------------------------------------------------------  
  def create_exp
    @exp = Spr_Params.new
    @exp.bitmap = RPG::Cache.picture("exr")
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
    @actor = $game_party.actors[0]
    @level = @actor.level       
  end
  #--------------------------------------------------------------------------
  # * 현재 플레이어
  #--------------------------------------------------------------------------   
  def player
   $game_party.actors[0]
  end
  #--------------------------------------------------------------------------
  # * HP (문자열)
  #--------------------------------------------------------------------------   
  def hp_str
    sprintf("%s / %s",player.hp.to_s,player.maxhp.to_s)
  end
  #--------------------------------------------------------------------------
  # * MP (문자열)
  #--------------------------------------------------------------------------   
  def mp_str
    sprintf("%s / %s",player.sp.to_s,player.maxsp.to_s)    
  end 
  #--------------------------------------------------------------------------
  # * EXP (문자열)
  #--------------------------------------------------------------------------   
  def exp_str 
    set_player
    exp = @actor.exp_s
    max_exp =  @actor.next_exp_s 
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
  end
  #--------------------------------------------------------------------------
  # * HP, MP, EXP 업데이트
  #--------------------------------------------------------------------------   
  def param_update
    @hp.set_rect(hp_rate,@hp.bitmap.height)
    @mp.set_rect(mp_rate,@mp.bitmap.height)
    @exp.set_rect(exp_rate,@exp.bitmap.height)
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
    @hp.bitmap.width * (player.hp.to_f / player.maxhp)
  end
  #--------------------------------------------------------------------------
  # * MP (비율)
  #--------------------------------------------------------------------------   
  def mp_rate
    @mp.bitmap.width * (player.sp.to_f / player.maxsp)
  end 
  #--------------------------------------------------------------------------
  # * 현재 경험치
  #--------------------------------------------------------------------------
  def current_exp
    player.exp - player.exp_list[player.level] 
  end
  #--------------------------------------------------------------------------
  # * 최대 경험치
  #--------------------------------------------------------------------------  
  def fc_max_exp 
    player.exp_list[player.level+1] - player.exp_list[player.level]
  end
  #--------------------------------------------------------------------------
  # * EXP (비율)
  #--------------------------------------------------------------------------   
  def exp_rate
    exp, max_exp = if player.exp_list[@actor.level+1] > 0
      [current_exp,fc_max_exp]
    else
      [player.exp_list[-2]] * 2
    end
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
    t.z = 151
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
    self.z = 150
    @rate = 0.0
  end
  #--------------------------------------------------------------------------
  # * 영역 설정
  #--------------------------------------------------------------------------   
  def set_rect(width,height)
    return if @rate == width
    @rate = width
    self.src_rect.set(0,0,@rate,height)
  end
end
 
#==============================================================================
# ** Text
#==============================================================================
class Text < Sprite 
  BLACK = Color.new(0,0,0,255)
  WHITE = Color.new(255,255,255,255)
  #--------------------------------------------------------------------------
  # * 텍스트 묘화
  #--------------------------------------------------------------------------   
  def draw_text(str)
    @str = str
    @text = str.call
    rect = self.src_rect
    self.bitmap.font.color = BLACK
    self.bitmap.draw_text(rect, str.call,1)
    self.bitmap.font.color = WHITE
    self.bitmap.draw_text(shadow_rect(rect),str.call,1)
  end
  #--------------------------------------------------------------------------
  # * 그림자
  #--------------------------------------------------------------------------  
  def shadow_rect(rect)
    sh_rect = rect.dup
    sh_rect.width -= 1
    sh_rect.height -= 1 
    sh_rect
  end
  #--------------------------------------------------------------------------
  # * 묘화
  #--------------------------------------------------------------------------   
  def update
    super()
    return if @str.call == @text
    @text = @str.call
    self.bitmap.clear
    self.bitmap.font.color = BLACK
    self.bitmap.draw_text(self.bitmap.rect,@text,1)  
    self.bitmap.font.color = WHITE
    self.bitmap.draw_text(shadow_rect(self.bitmap.rect),@text,1)
  end
end