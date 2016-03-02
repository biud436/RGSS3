#==============================================================================
# ** Stealing System
#------------------------------------------------------------------------------
# Name      : 도둑질 시스템
# Author    : 러닝은빛(biud436)
# Date      : 2014-08-19
# Version   : 1.0
#==============================================================================
 
module Tile
  # 탐색이 가능한 타일셋의 이름 (타일셋이 등록되지 않은 곳에선 물건을 훔칠 수 없습니다)
  NAME = ["Interior"]
  
  # 탐색이 가능한 조형물의 범위
  RANGE = [(48..112),(48..112)]
  
  # 찾아낼 수 있는 화폐의 최대값
  GOLD = 1000
  
  # 아이템을 찾을 수 있는 최소 확률
  P_MIN = 0
  
  # 아이템을 찾을 수 있는 확률 (램덤입니다만 이 값이 높을 수록 찾기가 어려워질 수 있습니다)
  P_MAX = 20
  
end
 
#==============================================================================
# ** Message(HUD)
#------------------------------------------------------------------------------
# Author    : 러닝은빛(biud436)
# Date      : 2014-08-17
# Version   : 1.0
#==============================================================================
module HUD_TEMP
  #--------------------------------------------------------------------------
  # * Font Size
  #--------------------------------------------------------------------------  
  FONT_SIZE = 18
  #--------------------------------------------------------------------------
  # * Decrease Opacity 
  #--------------------------------------------------------------------------    
  OPACITY = 0.5
  #--------------------------------------------------------------------------
  # * Chat Update
  #--------------------------------------------------------------------------    
  CHAT_UPDATE = true
  #--------------------------------------------------------------------------
  # * Color
  #--------------------------------------------------------------------------
  RED = Color.new(255,0,0,255)
  WHITE = Color.new(255,255,255,255)
  BLUE = Color.new(65,102,245,255)
  BKG_COLOR = [Color.new(0,0,0,64),Color.new(0,0,0,0)]
  #--------------------------------------------------------------------------
  # * Class::Struct
  #--------------------------------------------------------------------------  
  Coord = Struct.new(:x,:y)
  CRect = Struct.new(:w,:h)
  #--------------------------------------------------------------------------
  # * Coordinate Struct
  #--------------------------------------------------------------------------    
  BackGround = CRect.new(220,85)
  BG_Center = Coord.new(Graphics.width/2 - BackGround.w/2, FONT_SIZE * 2)
end
 
#==============================================================================
# ** HUD
#------------------------------------------------------------------------------
# 
#==============================================================================
class HUD
  attr_accessor  :text
  attr_accessor  :color
  BKG = Rect.new(0,0,HUD_TEMP::BackGround.w,HUD_TEMP::BackGround.h)
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------  
  def initialize
    @text = []
    @color = :white
    @f_size = HUD_TEMP::FONT_SIZE 
    @text_temp = []
    create_background
  end
  #--------------------------------------------------------------------------
  # * 배경
  #--------------------------------------------------------------------------    
  def create_background
    @background = Sprite.new
    @background.bitmap = Bitmap.new( BKG.width , BKG.height )
    @background.bitmap.fill_rect(BKG,HUD_TEMP::BKG_COLOR[1])
    @background.x = HUD_TEMP::BG_Center.x
    @background.y = HUD_TEMP::BG_Center.y
  end
  #--------------------------------------------------------------------------
  # * 텍스트
  #--------------------------------------------------------------------------    
  def create_text(str)
    txt = Text.new
    txt.bitmap = Bitmap.new(BKG.width,BKG.height)
    txt.bitmap.font = Font.new
    txt.bitmap.font.color = set_color
    txt.bitmap.font.size = HUD_TEMP::FONT_SIZE 
    txt.bitmap.draw_text(BKG,str,1)
    txt.x = HUD_TEMP::BG_Center.x
    txt.y = @background.y + (HUD_TEMP::FONT_SIZE * text_size) - HUD_TEMP::FONT_SIZE 
    push_text(txt)
  end
  #--------------------------------------------------------------------------
  # * 색상
  #--------------------------------------------------------------------------   
  def set_color
    case @color
    when :red; return HUD_TEMP::RED;
    when :white; return HUD_TEMP::WHITE;
    when :blue; return HUD_TEMP::BLUE;
    end
  end
  #--------------------------------------------------------------------------
  # * 배열 사이즈
  #--------------------------------------------------------------------------     
  def text_size
    size = @text.size - 1
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------    
  def update
    @background.update
    @text.each_with_index do |i,index| 
      return false if i.nil?
      i.y = @background.y + (i.bitmap.font.size * index - 1) - HUD_TEMP::FONT_SIZE 
      i.update
    end
  end
  #--------------------------------------------------------------------------
  # * 배열에 텍스트 추가
  #--------------------------------------------------------------------------    
  def push_text(str)
    if @text.size >= 4
      @text.shift
    end
    @text.push(str)
  end
  #--------------------------------------------------------------------------
  # * 해방
  #--------------------------------------------------------------------------    
  def dispose
    @background.bitmap.dispose
    @background.dispose
  end
  #--------------------------------------------------------------------------
  # * 텍스트 해방
  #--------------------------------------------------------------------------    
  def dispose_text
    @text.each do |i| 
      i.bitmap.dispose 
      i.dispose 
    end    
  end
end
#==============================================================================
# ** Text
#------------------------------------------------------------------------------
# 텍스트의 투명도를 낮춰줍니다
#==============================================================================
class Text < Sprite
  #--------------------------------------------------------------------------
  # * 투명도
  #--------------------------------------------------------------------------     
  def update
    super
      self.opacity -= HUD_TEMP::OPACITY if self.opacity > 0
      $hud.text.shift if self.opacity <= 0
  end
end
 
#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
# HUD 생성을 담당합니다
#==============================================================================
class Game_Map
  alias chat_initialize initialize
  alias chat_update update  
  #--------------------------------------------------------------------------
  # * 전역 변수 선언
  #--------------------------------------------------------------------------    
  def initialize
    chat_initialize
    $hud = HUD.new
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------    
  def update(main=false)
    chat_update(main)
    $hud.update if HUD_TEMP::CHAT_UPDATE
  end
end
 
#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
# 도둑질 시스템이 정의되어있는 클래스입니다
# Date      : 2014-08-19
#==============================================================================
class Game_Map
  alias cup_initialize initialize
  alias cup_update update
  attr_accessor :probability
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------     
  def initialize
    cup_initialize
    @hash = Hash.new
    @steal = []    
    @size = {:item => item_size, :weapons => weapons_size, :armors => armors_size}
    @probability = [4+Tile::P_MIN,rand(Tile::P_MAX)].max
  end
  #--------------------------------------------------------------------------
  # * 결정키를 누르면 훔칠 아이템이 있는 지 확인합니다 
  #--------------------------------------------------------------------------     
  def update(main=false)
    cup_update(main)
    count_main if Input.trigger?(:C)
  end
  #--------------------------------------------------------------------------
  # * 통행이 불가능한 장애물이 있는지 확인합니다
  #--------------------------------------------------------------------------     
  def count_main
    d = $game_player.direction
    f = passable?(x_with_direction($game_player.x,d),
    y_with_direction($game_player.y,d),d)
    if f == false
      id = layered_tiles(x_with_direction($game_player.x,d),y_with_direction($game_player.y,d))
        steal_item(id,x_with_direction($game_player.x,d),y_with_direction($game_player.y,d))
    end
  end
  #--------------------------------------------------------------------------
  # * 특정 조형물만 탐색합니다
  #--------------------------------------------------------------------------     
  def steal_item(id,x,y)
    # 이미 탐색이 완료된 조형물인가?
    if @hash[@map_id].is_a?(Array) && @hash[@map_id].include?([id[0],x*y])
      $hud.create_text("더 이상 훔칠 물건이 없습니다")
      return false
    end
    # 탐색이 가능한 지역인가?
    if Tile::NAME.include?(tileset.name) == false
      $hud.create_text("탐색이 불가능한 지역입니다")
      return false
    end
    # 탐색이 가능한 오브젝트인가?
    case id[0]
    when range
      @hash[@map_id] = @steal.push([id[0],x*y])
      random_item;
    end
  end
  #--------------------------------------------------------------------------
  # * 타일의 범위를 검색합니다
  #--------------------------------------------------------------------------     
  def range
    begin
      i = Tile::NAME.index(tileset.name)
      return Tile::RANGE[i]
    rescue
      return Tile::RANGE[0]
    end
  end
  #--------------------------------------------------------------------------
  # * 물건을 램덤으로 획득합니다
  #--------------------------------------------------------------------------    
  def random_item
    case srand(Graphics.frame_count) % @probability.to_i
    when 0 # 아이템 획득
      $game_party.gain_item($data_items[[1,rand(@size[:item])].max], 1)
      $hud.create_text(sprintf("%s 을/를 훔쳤습니다",
      $data_items[[1,rand(@size[:item])].max].name))
    when 1 # 무기구 획득
      $game_party.gain_item($data_weapons[[1,rand(@size[:weapons])].max], 1)
      $hud.create_text(sprintf("%s 을/를 훔쳤습니다",
      $data_weapons[[1,rand(@size[:weapons])].max].name))      
    when 2 # 방어구 획득
      $game_party.gain_item($data_armors[[1,rand(@size[:armors])].max], 1)
      $hud.create_text(sprintf("%s 을/를 훔쳤습니다",
      $data_armors[[1,rand(@size[:armors])].max].name))      
    when 3 # 골드 획득
      $hud.create_text(sprintf("+%d %s 획득",
      $game_party.gain_gold([1,rand(Tile::GOLD)].max),
      $data_system.currency_unit))
    else # 아무것도 찾지 못했을 때
      $hud.color = :red
      $hud.create_text("아무것도 찾지 못했습니다")
      $hud.color = :white
    end
  end
  #--------------------------------------------------------------------------
  # * 아이템의 갯수
  #--------------------------------------------------------------------------  
  def item_size
    j = []
    $data_items.each_with_index do |i,index|
        next if i.is_a?(RPG::Item) == false
        next if i.nil?
        next if i.name.size <= 0
        j.push(index)
      end
      return j.size
  end
  #--------------------------------------------------------------------------
  # * 무기구의 갯수
  #--------------------------------------------------------------------------    
  def weapons_size
    j = []
    $data_weapons.each_with_index do |i,index|
        next if i.is_a?(RPG::Weapon) == false
        next if i.nil?
        next if i.name.size <= 0
        j.push(index)
      end    
      return j.size
  end
  #--------------------------------------------------------------------------
  # * 방어구의 갯수
  #--------------------------------------------------------------------------    
  def armors_size
    j = []
    $data_armors.each_with_index do |i,index|
        next if i.is_a?(RPG::Armor) == false
        next if i.nil?
        next if i.name.size <= 0
        j.push(index)
      end    
      return j.size
  end  
end
