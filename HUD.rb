#==============================================================================
# ** HUD ��ũ��Ʈ, biud436
#==============================================================================
module HUD
  # ��ũ��
  SCREEN = :BOTTOM_LEFT
  
  # ���� ũ��
  W = 317
  
  # ���� ũ��
  H = 101
  
  # ����
  PD = 0
  
  # ���̽�Ĩ�� �����ڸ��� �ٵ�� �ε巴�� ��ȭ�մϴ�
  SmoothEdge = true
  
  # ����
  F_Angle = Math::PI/180
  
  # ��ũ���� ��ǥ
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
  # * ����
  #--------------------------------------------------------------------------   
  def start
    xxxx_start
    @lib_hud = Hud.new
  end
  #--------------------------------------------------------------------------
  # * ������Ʈ
  #--------------------------------------------------------------------------   
  def update
    xxxx_update
    @lib_hud.update
  end
  #--------------------------------------------------------------------------
  # * �ı�
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
  # * �ν��Ͻ� ȹ��
  #--------------------------------------------------------------------------   
  def hud_window
    return unless SceneManager.scene_is?(Scene_Map)
    SceneManager.scene.lib_hud
  end
  #--------------------------------------------------------------------------
  # * ����
  #--------------------------------------------------------------------------   
  def hud_opacity=(var)
    return unless SceneManager.scene_is?(Scene_Map)
    hud_window.opacity = var
  end
  #--------------------------------------------------------------------------
  # * ���� ����
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
  # * �ʱ�ȭ
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
  # * Ʋ ����
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
  # * ���� Ŭ���� ����ũ(ȿ�� ����)
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
  # * ���� ���̽�Ĩ ��ȭ(�ε巯�� �����ڸ�)
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
  # * HP ����
  #--------------------------------------------------------------------------  
  def create_hp
    @hp = Spr_Params.new
    @hp.bitmap = Cache.picture("hp")    
  end
  #--------------------------------------------------------------------------
  # * MP ����
  #--------------------------------------------------------------------------  
  def create_mp
    @mp = Spr_Params.new
    @mp.bitmap = Cache.picture("mp")    
  end
  #--------------------------------------------------------------------------
  # * EXP ����
  #--------------------------------------------------------------------------  
  def create_exp
    @exp = Spr_Params.new
    @exp.bitmap = Cache.picture("exr")
  end
  #--------------------------------------------------------------------------
  # * �ؽ�Ʈ ���� (�ּҰ� ����)
  #--------------------------------------------------------------------------
  def create_text
    @hp_text = text(method(:hp_str))
    @mp_text = text(method(:mp_str))  
    @exp_text = text(method(:exp_str))
    @level_text = text(method(:level_str),16)
  end
  #--------------------------------------------------------------------------
  # * ��ǥ ����
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
  # * �÷��̾��� ���� ����
  #--------------------------------------------------------------------------   
  def set_player
    @actor = $game_party.members[0]
    @level = @actor.level       
  end
  #--------------------------------------------------------------------------
  # * ���� �÷��̾�
  #--------------------------------------------------------------------------   
  def player
   $game_party.members[0] 
  end
  #--------------------------------------------------------------------------
  # * HP (���ڿ�)
  #--------------------------------------------------------------------------   
  def hp_str
    sprintf("%s / %s",player.hp.to_s,player.mhp.to_s)
  end
  #--------------------------------------------------------------------------
  # * MP (���ڿ�)
  #--------------------------------------------------------------------------   
  def mp_str
    sprintf("%s / %s",player.mp.to_s,player.mmp.to_s)    
  end
  #--------------------------------------------------------------------------
  # * EXP (���ڿ�)
  #--------------------------------------------------------------------------   
  def exp_str 
    set_player
    exp = player.max_level? ? "----" : @actor.exp - @actor.current_level_exp
    max_exp =  player.max_level? ? "----" : @actor.next_level_exp - @actor.current_level_exp
    return sprintf("%s / %s",exp.to_s,max_exp.to_s)    
  end
  #--------------------------------------------------------------------------
  # * ���� (���ڿ�)
  #--------------------------------------------------------------------------   
  def level_str
    player.level.to_s
  end
  #--------------------------------------------------------------------------
  # * ���̱� / ���߱�
  #--------------------------------------------------------------------------   
  def visible=(t = true)
    params = [@hud,@face,@hp,@mp,@hp_text,@mp_text,@level_text,@exp,@exp_text]
    params.each {|i| i.visible = t}
  end
  #--------------------------------------------------------------------------
  # * ���� ����
  #--------------------------------------------------------------------------   
  def opacity=(v = 255)
    v = 255 unless v.between?(0,255)
    params = [@hud,@face,@hp,@mp,@hp_text,@mp_text,@level_text,@exp,@exp_text]
    params.each {|i| i.opacity = v}
  end
  #--------------------------------------------------------------------------
  # * ������Ʈ
  #--------------------------------------------------------------------------   
  def update
    param_update
    text_update
  end
  #--------------------------------------------------------------------------
  # * HP, MP, EXP ������Ʈ
  #--------------------------------------------------------------------------   
  def param_update
    @hp.set_rect(hp_rate,@hp.height)
    @mp.set_rect(mp_rate,@mp.height)
    @exp.set_rect(exp_rate,@exp.height)
    [@hp,@mp,@exp].each {|i| i.update }
  end
  #--------------------------------------------------------------------------
  # * �ؽ�Ʈ ������Ʈ
  #--------------------------------------------------------------------------   
  def text_update
    [@hp_text,@mp_text,@level_text,@exp_text].each {|i| i.update}
  end
  #--------------------------------------------------------------------------
  # * HP (����)
  #--------------------------------------------------------------------------   
  def hp_rate
    @hp.bitmap.width * (player.hp.to_f / player.mhp)
  end
  #--------------------------------------------------------------------------
  # * MP (����)
  #--------------------------------------------------------------------------   
  def mp_rate
    @mp.bitmap.width * (player.mp.to_f / player.mmp)
  end 
  #--------------------------------------------------------------------------
  # * EXP (����)
  #--------------------------------------------------------------------------   
  def exp_rate
    set_player
    exp = player.max_level? ? @actor.current_level_exp : @actor.exp - @actor.current_level_exp
    max_exp =  player.max_level? ? @actor.current_level_exp : @actor.next_level_exp - @actor.current_level_exp
    return @exp.bitmap.width * (exp.to_f / max_exp)
  end
  #--------------------------------------------------------------------------
  # * ����
  #--------------------------------------------------------------------------   
  def dispose
    params = [@hud,@face,@hp,@mp,@hp_text,@mp_text,@level_text,@exp,@exp_text]
    params.each {|i| bitmap_dispose(i)}
  end
  #--------------------------------------------------------------------------
  # * ��Ʈ�� ����
  #--------------------------------------------------------------------------    
  def bitmap_dispose(object)
    object.bitmap.dispose
    object.dispose    
  end
  #--------------------------------------------------------------------------
  # * ��ǥ�� ����
  #--------------------------------------------------------------------------   
  def set_coord(s,x,y)
    s.x = @hud.x + x
    s.y = @hud.y + y
  end
  #--------------------------------------------------------------------------
  # * �ؽ�Ʈ ��Ʈ�� ����
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
  # * �ʱ�ȭ
  #--------------------------------------------------------------------------   
  def initialize
    super
    @rate = 0.0
  end
  #--------------------------------------------------------------------------
  # * ���� ����
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
  # * �ؽ�Ʈ ��ȭ
  #--------------------------------------------------------------------------   
  def draw_text(str)
    @str = str
    @text = str.call
    self.bitmap.draw_text(self.src_rect,str.call,1)
  end   
  #--------------------------------------------------------------------------
  # * ��ȭ
  #--------------------------------------------------------------------------   
  def update
    super()
    return if @str.call == @text
    @text = @str.call
    self.bitmap.clear
    self.bitmap.draw_text(self.bitmap.rect,@text,1)
  end
end