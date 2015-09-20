#==============================================================================
# ** HUD 스크립트, biud436
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
  
  # 페이스칩의 가장자리를 다듬어 부드럽게 묘화합니다
  SmoothEdge = true
  
  # 라디안
  F_Angle = Math::PI/180
  
  # 스크린의 좌표
  POS = case SCREEN
  when :TOP_RIGHT then [Graphics.width - W - PD,PD]
  when :BOTTOM_RIGHT then [Graphics.width - W - PD,Graphics.height - H - PD]
  when :BOTTOM_LEFT then [PD,Graphics.height - H - PD]
  when :TOP_LEFT  then [PD,PD]
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

#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # * 인스턴스 획득
  #--------------------------------------------------------------------------   
  def hud_window
    return unless SceneManager.scene_is?(Scene_Map)
    SceneManager.scene.lib_hud
  end
  #--------------------------------------------------------------------------
  # * 투명도
  #--------------------------------------------------------------------------   
  def hud_opacity=(var)
    return unless SceneManager.scene_is?(Scene_Map)
    hud_window.opacity = var
  end
  #--------------------------------------------------------------------------
  # * 가시 상태
  #--------------------------------------------------------------------------   
  def hud_visible=(var)
    return unless SceneManager.scene_is?(Scene_Map)
    hud_window.visible = var
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
  end
  #--------------------------------------------------------------------------
  # * 틀 생성
  #--------------------------------------------------------------------------  
  def create_hud
    @hud = Sprite.new
    @hud.bitmap = Cache.picture("hud_window_empty")
    @hud.x,@hud.y = HUD::POS
    if HUD::SmoothEdge
      draw_face_se(0,1,45,2,player.face_name,player.face_index)
    else
      @face = circle_clipping_mask(0,1,45,2,player.face_name,player.face_index)
    end
  end
  #--------------------------------------------------------------------------
  # * 원형 클리핑 마스크(효과 없음)
  #--------------------------------------------------------------------------  
  def circle_clipping_mask(x,y,r,zoom,face_name,face_index,angle=360)
    sprite = Sprite.new
    
    diameter = r * 2

    sprite.bitmap = Bitmap.new(r * zoom ,r * zoom)
  
    bitmap = Bitmap.new(diameter,diameter)
    
    bt = Cache.face(face_name)
  
    origin_x = r
    origin_y = r
    
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)

    r.times do |distance|
      for i in 0..angle
        dx = origin_x + distance * Math.cos(i * HUD::F_Angle)
        dy = origin_y + distance * Math.sin(i * HUD::F_Angle)
        bitmap.set_pixel(dx,dy,bt.get_pixel(dx + rect.x,dy + rect.y))
        bitmap.set_pixel(dx,dy-1,bt.get_pixel(dx + rect.x,dy - 1 + rect.y))
      end
    end
    
    sprite.bitmap.stretch_blt(sprite.src_rect,bitmap,bitmap.rect) 
    sprite.x = x - sprite.bitmap.rect.width / 2
    sprite.y = y - sprite.bitmap.rect.height / 2
    sprite.z = 102
    sprite
    
  end     
  #--------------------------------------------------------------------------
  # * 원형 페이스칩 묘화(부드러운 가장자리)
  #--------------------------------------------------------------------------    
  def draw_face_se(x,y,r,zoom,face_name,face_index,angle=360)
    sprite = Sprite.new
   
    diameter = r * 2
 
    sprite.bitmap = Bitmap.new(r * zoom ,r * zoom)
 
    bitmap = Bitmap.new(diameter,diameter)
   
    bt = Cache.face(face_name)
 
    origin_x = r
    origin_y = r
   
    rect = Rect.new(face_index % 4 * 96, face_index / 4 * 96, 96, 96)
   
    trr = GColor.new(0,0,0,255)
        
    r.times do |distance|
      for i in 0..angle
        dx = origin_x + distance * Math.cos(i * HUD::F_Angle)
        dy = origin_y + distance * Math.sin(i * HUD::F_Angle)
        trr.alpha = -distance * zoom * (256/diameter) - 80
        bitmap.set_pixel(dx,dy,bt.get_pixel(dx + rect.x,dy + rect.y).add(trr))
        bitmap.set_pixel(dx,dy-1,bt.get_pixel(dx + rect.x,dy - 1 + rect.y).add(trr) )
      end
    end
       
    sprite.bitmap.stretch_blt(sprite.src_rect,bitmap,bitmap.rect)
    sprite.bitmap.stretch_blt(sprite.src_rect,bitmap,bitmap.rect)
    sprite.bitmap.stretch_blt(sprite.src_rect,bitmap,bitmap.rect)
    sprite.bitmap.stretch_blt(sprite.src_rect,bitmap,bitmap.rect)
    
    bitmap.dispose
    
    sprite.x = x - sprite.bitmap.rect.width / 2
    sprite.y = y - sprite.bitmap.rect.height / 2
    sprite.z = 102
    
    @face = sprite 
    
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
    @exp.bitmap = Cache.picture("exr")
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
  end
  #--------------------------------------------------------------------------
  # * HP, MP, EXP 업데이트
  #--------------------------------------------------------------------------   
  def param_update
    @hp.set_rect(hp_rate,@hp.height)
    @mp.set_rect(mp_rate,@mp.height)
    @exp.set_rect(exp_rate,@exp.height)
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