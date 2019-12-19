#==============================================================================
#   Name      : 화면 중앙 상단 메시지 / Floating Message (GUI)
#   Date      : 2019.12.19
#   Version   : 1.5.4
# -----------------------------------------------------------------------------
#  * Change Log
# -----------------------------------------------------------------------------
#   2019.12.19 (v1.5.4) - 장비 해제 시 아이템 획득으로 나오는 문제 수정
#   2015.06.23 - 게임 로드 버그 수정
#   2015.02.16 - 버그 픽스(경험치 획득 메시지)
#   2015.02.14 - 버그 픽스(경험치 획득 메시지)
#   2015.01.20 - 한국어 조사 처리 추가
#   2014.12.11 - 메시지 표시/감추기 설정, 맵 방문 메시지 수정
#   2014.11.18 - 퀘스트 메시지 추가
#   2014.09.17 - 각종 정보 메시지 추가
#   2014.08.25 - 좌표 오류 수정, 텍스트 중첩 현상 수정
#   2014.08.17 - 스크립트 최초 작성일
# -----------------------------------------------------------------------------
# * 텍스트 출력
# -----------------------------------------------------------------------------
#   $hud.create_text("내용")
# -----------------------------------------------------------------------------
# * 텍스트를 특정 색상으로 출력
# -----------------------------------------------------------------------------
#   $hud.color_message(:red,"내용")
# -----------------------------------------------------------------------------
# * 플레이어 이름을 포함하여 출력
# -----------------------------------------------------------------------------
#   $hud.chat("내용")
# -----------------------------------------------------------------------------
# * 퀘스트 메시지
# -----------------------------------------------------------------------------
#   Quest.set(변수의 번호,최대값)
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_InfoMessageUI"] = true

module UI_MSG
  # 글자의 크기 설정
  FONT_SIZE = 18
  # 글자의 투명도(초당 감산값)
  OPACITY = 1.0
  # HUD 업데이트
  CHAT_UPDATE = true
  # 글자의 색상
  RED = Color.new(255,0,0,255)
  WHITE = Color.new(255,255,255,255)
  BLUE = Color.new(65,102,245,255)
  BKG_COLOR = [Color.new(0,0,0,128),Color.new(0,0,0,0)]
  # 구조체의 선언
  Coord = Struct.new(:x,:y)
  CRect = Struct.new(:w,:h)
  # HUD의 크기 설정
  BackGround = CRect.new(280,85)
  # HUD의 좌표 설정
  BG_Center = Coord.new(Graphics.width/2 - BackGround.w/2, FONT_SIZE * 2)
  # 퀘스트로그 변수의 위치
  QUEST_LOG_INDEX = 100
  # 맵 이름 표시 윈도우의 사용 여부
  MAP_DISPLAY_WNDNAME = false
  # 레벨업 메시지
  LV_UP = true
  # 맵 방문 메시지
  MAP_VISIT = true
  # 파티 추가 메시지
  MB_ADD = true
  # 파티 탈퇴 메시지
  MB_REMOVE = true
  # 금전 메시지
  GOLD = true
  # 경험치 메시지
  EXP = true
  # 아이템 획득 메시지
  ITEM = true
  # 게임 저장 메시지
  SAVE = true
  # 게임 로드 메시지
  LOAD = true
end
#==============================================================================
# ** Temp
#==============================================================================
module Temp
  # 아이템을 획득했을 때
  ITEM1 = ["%s을 획득했습니다","%s를 획득했습니다"]
  # 아이템을 잃었을 때
  ITEM2 = ["%s을 잃었습니다","%s를 잃었습니다"]
  # 파티에 멤버가 추가되었을 때
  ADD_MB = ["%s이 파티에 합류하였습니다","%s가 파티에 합류하였습니다"]
  # 멤버가 파티를 탈퇴했을 때
  REMOVE_MB = ["%s이 파티에서 탈퇴했습니다","%s가 파티에서 탈퇴했습니다"]
  # 경험치를 획득했을 때
  EXP_UP = "경험치 %d EXP를 획득했습니다"
  # 경험치를 상실했을 때
  EXP_DOWN = "경험치 %d EXP를 상실했습니다"
  # 콘솔 명령어의 입력(미지원)
  MESSAGE = "명령어를 입력하세요"
  #--------------------------------------------------------------------------
  # * 효과음 재생
  #--------------------------------------------------------------------------
  def self.se_play(name)
    Audio.se_play('Audio/SE/' + name,50,100)
  end
  #--------------------------------------------------------------------------
  # * 코인 획득
  #--------------------------------------------------------------------------
  def self.play_coin
    se_play('Coin')
  end
end

#==============================================================================
# ** String
#==============================================================================
class String
  def unicode_of
    self.unpack("U*").pop
  end
end

#==============================================================================
# ** M_HUD
#==============================================================================
class M_HUD
  attr_accessor  :text
  attr_accessor  :color
  BKG = Rect.new(0,0,UI_MSG::BackGround.w,UI_MSG::BackGround.h)
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize
    @text = []
    @color = :white
    @contents = []
    @f_size = UI_MSG::FONT_SIZE
    @text_temp = []
    create_background
  end
  #--------------------------------------------------------------------------
  # * 배경 생성
  #--------------------------------------------------------------------------
  def create_background
    @background = Sprite.new
    @background.bitmap = Bitmap.new( BKG.width , BKG.height )
    @background.bitmap.fill_rect(BKG,UI_MSG::BKG_COLOR[1])
    @background.x = UI_MSG::BG_Center.x
    @background.y = UI_MSG::BG_Center.y
  end
  #--------------------------------------------------------------------------
  # * 현재 시간
  #--------------------------------------------------------------------------
  def play_time
    Graphics.frame_count / Graphics.frame_rate unless $game_system.playtime
    $game_system.playtime
  end
  #--------------------------------------------------------------------------
  # * 텍스트 추가
  #--------------------------------------------------------------------------
  def create_text(str)
    txt = H_Text.new
    txt.bitmap = Bitmap.new(BKG.width,BKG.height)
    txt.bitmap.font = Font.new
    txt.bitmap.font.color = set_color
    txt.bitmap.font.size = UI_MSG::FONT_SIZE
    txt.bitmap.draw_text(BKG,str,1)
    txt.x = 2 + UI_MSG::BG_Center.x
    txt.y = @background.y + (UI_MSG::FONT_SIZE * text_size) - UI_MSG::FONT_SIZE
    txt.z = 101
    push_text(txt)
  end
  #--------------------------------------------------------------------------
  # * 컬러 메시지
  #--------------------------------------------------------------------------
  def color_message(color_symbol,str)
    color(color_symbol,:white) { create_text(str) }
  end
  #--------------------------------------------------------------------------
  # * 외치기
  #--------------------------------------------------------------------------
  def chat(str)
    result = sprintf("%s : %s",$data_actors[1].name,str)
    color(:red,:white) { create_text(result) }
  end
  #--------------------------------------------------------------------------
  # * 조사 처리
  #--------------------------------------------------------------------------
  def final_const(str,array)
    if (str - 44032) % 28 == 0
      return array[1]
    else
      return array[0]
    end
  end
  #--------------------------------------------------------------------------
  # * 메시지
  #--------------------------------------------------------------------------
  def message(str1,str2)
    get_text = if str1.is_a?(Array)
      string = str2[-1].unicode_of
      final_const(string,str1)
    else
      str1
    end
    result = sprintf(get_text,str2)
    create_text(result)
  end
  #--------------------------------------------------------------------------
  # * 색
  #--------------------------------------------------------------------------
  def set_color
    case @color
    when :red; return UI_MSG::RED;
    when :white; return UI_MSG::WHITE;
    when :blue; return UI_MSG::BLUE;
    end
  end
  #--------------------------------------------------------------------------
  # * 색
  #--------------------------------------------------------------------------
  def color(color1,color2,&block)
    return unless color1.is_a?(Symbol) and color2.is_a?(Symbol)
    $hud.color = color1
    block.call
    $hud.color = color2
  end
  #--------------------------------------------------------------------------
  # * 텍스트 사이즈
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
      next if i.nil?
      i.y = UI_MSG::BG_Center.y +
      (UI_MSG::FONT_SIZE * index - 1) - UI_MSG::FONT_SIZE
      i.update
    end
  end
  #--------------------------------------------------------------------------
  # * 텍스트 스택
  #--------------------------------------------------------------------------
  def push_text(str)
    if @text.size < 4
      @text.push(str)
    else
      @text[0].opacity = 0
      @text.shift
      @text.push(str)
    end
  end
  #--------------------------------------------------------------------------
  # * 메모리 해방
  #--------------------------------------------------------------------------
  def dispose
    @background.bitmap.dispose
    @background.dispose
  end
  #--------------------------------------------------------------------------
  # * 텍스트 메모리 해방
  #--------------------------------------------------------------------------
  def dispose_text
    @text.each do |i|
      i.bitmap.dispose
      i.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 보임 설정
  #--------------------------------------------------------------------------
  def visible=(v)
    @background.visible = v
    @text.each do |i|
      i.visible = v
    end
  end
end

#==============================================================================
# ** H_Text
#==============================================================================
class H_Text < Sprite
  def update
    super
     self.opacity -= UI_MSG::OPACITY if self.opacity > 0
      $hud.text.shift if self.opacity <= 0
  end
end

#==============================================================================
# ** Scene_Base
#==============================================================================
class Scene_Base
  alias hhh_chat_update update
  #--------------------------------------------------------------------------
  # * 켜기/끄기
  #--------------------------------------------------------------------------
  def update
    hhh_chat_update
    if SceneManager.scene_is?(Scene_Map)
      $hud.visible = true
    else
      $hud.visible = false
    end
  end
end

#==============================================================================
# ** Game_Player
#==============================================================================
class Game_Player
  alias chat_perform_transfer perform_transfer
  #--------------------------------------------------------------------------
  # * 맵 메시지 설정
  #--------------------------------------------------------------------------
  def perform_transfer
    chat_perform_transfer
    return unless UI_MSG::MAP_VISIT
    unless $game_map.display_name.empty?
      $hud.message("%s 에 방문했습니다",$game_map.display_name)
    end
  end
end

#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  alias chat_initialize initialize
  alias chat_update update
  attr_accessor :quest_window_open
  #--------------------------------------------------------------------------
  # * HUD의 생성
  #--------------------------------------------------------------------------
  def initialize
    chat_initialize
    $hud = M_HUD.new
    $hud.visible = false
    @quest_window_open = false
  end
  #--------------------------------------------------------------------------
  # * HUD 업데이트
  #--------------------------------------------------------------------------
  def update(main=false)
    chat_update(main)
    $hud.update if UI_MSG::CHAT_UPDATE && $hud
  end
end

#==============================================================================
# ** Game_Party
#==============================================================================
class Game_Party
  
  alias chat_gain_item gain_item
  alias chat_add_actor add_actor
  alias chat_remove_actor remove_actor
  alias chat_gain_gold gain_gold
  alias chat_lose_gold lose_gold
  #--------------------------------------------------------------------------
  # * 아이템 획득 메시지
  #--------------------------------------------------------------------------
  def gain_item(item, amount, include_equip = false)
    chat_gain_item(item, amount, include_equip = false)
    return if amount < 0
    return unless UI_MSG::ITEM
    $hud.message(Temp::ITEM1,$data_items[item.id].name) if item.is_a?(RPG::Item)
    $hud.message(Temp::ITEM1,$data_armors[item.id].name) if item.is_a?(RPG::Armor)
    $hud.message(Temp::ITEM1,$data_weapons[item.id].name) if item.is_a?(RPG::Weapon)
  end
  #--------------------------------------------------------------------------
  # * 파티 추가 메시지
  #--------------------------------------------------------------------------
  def add_actor(actor_id)
    chat_add_actor(actor_id)
    return unless UI_MSG::MB_ADD
    $hud.message(Temp::ADD_MB,$data_actors[actor_id].name) if @actors.include?(actor_id)
  end
  #--------------------------------------------------------------------------
  # * 파티 탈퇴 메시지
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
    chat_remove_actor(actor_id)
    return unless UI_MSG::MB_REMOVE
    $hud.message(Temp::REMOVE_MB,$data_actors[actor_id].name)
  end
  #--------------------------------------------------------------------------
  # * 금전 획득 메시지
  #--------------------------------------------------------------------------
  def gain_gold(amount)
    chat_gain_gold(amount)
    return unless UI_MSG::GOLD
    $hud.message("+ %d #{Vocab.currency_unit} 를 챙겼습니다" ,amount.abs) if amount > 0
    $hud.message("- %d #{Vocab.currency_unit} 를 지불했습니다 ",amount.abs) if amount < 0
    Temp.play_coin
  end
end
#==============================================================================
# ** Game_Actor
#==============================================================================
class Game_Actor
  alias chat_level_up level_up
  alias chat_change_exp change_exp
  #--------------------------------------------------------------------------
  # * 레벨 업 메시지
  #--------------------------------------------------------------------------
  def level_up
    chat_level_up
    return unless UI_MSG::LV_UP
    $hud.color(:red,:white){ $hud.create_text("레벨이 올랐습니다")
    $hud.create_text(sprintf(Vocab::LevelUp, @name, Vocab::level, @level)) }
  end
  #--------------------------------------------------------------------------
  # * 경험치 획득 메시지
  #--------------------------------------------------------------------------
  def change_exp(exp, show)
    f = self.exp rescue 0
    chat_change_exp(exp, show)
    g = self.exp - f rescue 0
    return unless UI_MSG::EXP
    $hud.message(Temp::EXP_UP,g) if g > 0
    $hud.message(Temp::EXP_DOWN,g) if g < 0
  end
  #--------------------------------------------------------------------------
  # * Trade Item with Party
  #     new_item:  Item to get from party
  #     old_item:  Item to give to party
  #--------------------------------------------------------------------------
  def trade_item_with_party(new_item, old_item)
    return false if new_item && !$game_party.has_item?(new_item)
    temp = UI_MSG::ITEM
    UI_MSG.const_set(:ITEM, false)
    $game_party.gain_item(old_item, 1)
    $game_party.lose_item(new_item, 1)
    UI_MSG.const_set(:ITEM, temp)
    return true
  end  
end
#==============================================================================
# ** DataManager
#==============================================================================
module DataManager

  class << self
    alias xxxx_save_game save_game
    alias xxxx_load_game load_game
  end

  #--------------------------------------------------------------------------
  # * 저장
  #--------------------------------------------------------------------------
  if UI_MSG::SAVE
    def save_game(index)
      if xxxx_save_game(index)
        str = "게임이 #{index+1}번 슬롯에 저장되었습니다"
        $hud.color(:red,:white){ $hud.create_text(str) }
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 로드
  #--------------------------------------------------------------------------
  if UI_MSG::LOAD
    def load_game(index)
      if xxxx_load_game(index)
          str = "#{index+1}번 세이브파일을 로드했습니다"
          $hud.color(:red,:white){ $hud.create_text(str) }
      end
    end
  end

end

#==============================================================================
# ** M_HUD (퀘스트)
#==============================================================================
class M_HUD
  #--------------------------------------------------------------------------
  # * 퀘스트 로그
  #--------------------------------------------------------------------------
  def create_quest(*args)
    txt,txt.bitmap = H_Text.new,Bitmap.new(BKG.width,BKG.height)
    txt.bitmap.font,txt.bitmap.font.size = Font.new,UI_MSG::FONT_SIZE
    last,mid = args[3],"#{args[1]} / #{args[2]}"
    first = args[0][0,6].center(20).concat("".center(4))
    len = [first + mid + last].join("").length
    w = 280 - len * 2
    bitmap_color(w,first,mid,last,len) {|i,v,k|
    txt.bitmap.font.color = Color.new(*v)
    txt.bitmap.draw_text(*k) }
    txt.x,txt.z  = UI_MSG::BG_Center.x,101
    txt.y = @background.y + (UI_MSG::FONT_SIZE * text_size) - UI_MSG::FONT_SIZE
    push_text(txt)
  end
  #--------------------------------------------------------------------------
  # * 컬러
  #--------------------------------------------------------------------------
  def bitmap_color(w,first,mid,last,len)
    yield 1,[255,255,255,255],[0,0,w,24,first,1]
    yield 2,[255,0,0,255],[w/4,0,w,24,mid.center(len),1]
    yield 3,[255,128,0,255],[w/2,0,w,24,last.center(len),1]
  end

end
#==============================================================================
# ** Quest
#==============================================================================
module Quest
  @data = {}
  #--------------------------------------------------------------------------
  # * 퀘스트 설정
  #--------------------------------------------------------------------------
  def self.set(n,max)
    @data[n] = max
  end
  #--------------------------------------------------------------------------
  # * 퀘스트 로그
  #--------------------------------------------------------------------------
  def self.log(n)
    @data[n] || 0
  end
  #--------------------------------------------------------------------------
  # * 데이터
  #--------------------------------------------------------------------------
  def self.data
    @data
  end
  #--------------------------------------------------------------------------
  # * 사이즈
  #--------------------------------------------------------------------------
  def self.size
    @data.size
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def self.update
    @data.each {|k,v| @data.delete(k) if $game_variables[k] >= v and v!=0 }
  end
  #--------------------------------------------------------------------------
  # * 퀘스트 로그 묘화
  #--------------------------------------------------------------------------
  def self.draw_log(i)
    string = $data_system.variables[i].to_s
    gv = $game_variables[i],log(i)
    unless $game_variables[i] > log(i)
      return if $game_variables[i] == 0
      result = $game_variables[i] >= log(i)? "(완료)".center(6) : "".center(6)
      $hud.create_quest(string,gv[0],gv[1],result)
    else
      @data.delete(i) if result == "(완료)".center(6)
    end
  end
end
#==============================================================================
# ** Game_Variables(퀘스트)
#==============================================================================
class Game_Variables
  #--------------------------------------------------------------------------
  # * 변수 설정
  #--------------------------------------------------------------------------
  def []=(variable_id, value)
    @data[variable_id] = value
    on_change
    if Quest.log(variable_id) != 0 and variable_id >= UI_MSG::QUEST_LOG_INDEX
      Quest.draw_log(variable_id)
    end
  end
end
#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Map
  #--------------------------------------------------------------------------
  # * 화면 이동 처리 / 페이드인
  #--------------------------------------------------------------------------
  def post_transfer
    case $game_temp.fade_type
    when 0
      Graphics.wait(fadein_speed / 2)
      fadein(fadein_speed)
    when 1
      Graphics.wait(fadein_speed / 2)
      white_fadein(fadein_speed)
    end
    # 툴에서 제공하는 기본 맵 이름 표시 윈도우의 사용 여부
    @map_name_window.open if UI_MSG::MAP_DISPLAY_WNDNAME
  end
end
