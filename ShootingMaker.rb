=begin
Script Name : ShootingMaker
Code by : biud436
Version : 1.1
=end
#==============================================================================
# ** Shooting_Maker 모듈
#------------------------------------------------------------------------------
#
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_ShootingMaker"] = true

module Shooting_Maker

 # Game_Character 전방에 선언되어있는 상수값에 대한 해쉬 블록입니다
 MOVE = {
  :DOWN => 1,
  :UP => 4,
  :LEFT => 2,
  :RIGHT => 3,
  :RANDOM => 9,
  :PLAYER => 10
 }
 # 스테이지 목록입니다
 STAGE = [1,2,3,4,5]
 # 스테이지 별로 할당된 시간에 대한 배열입니다
 TIME = 65,55,50,45,40
 # 스테이지 별로 할당된 시간에 대한 해쉬 블록입니다
 TIME = {
  STAGE[0] => 65,
  STAGE[1] => 60,
  STAGE[2] => 55,
  STAGE[3] => 45,
  STAGE[4] => 40
 }
end
#==============================================================================
# ** MM
#------------------------------------------------------------------------------
# RX라는 상수를 가지고 있는 모듈입니다
#==============================================================================
module MM
 # RX상수는 캐릭터의 움직임에 관여합니다
 RX = 1
end


$imported = {} if $imported.nil?
$imported["Sunny_Move"] = true

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#
#==============================================================================
class Game_Map
 include MM
 alias :sun004rs_initialize :initialize
 alias :sun004rs_update_events :update_events
 #--------------------------------------------------------------------------
 # * Public Instance Variables
 #--------------------------------------------------------------------------
 attr_accessor :move
 attr_accessor :events
 attr_reader   :time
 #--------------------------------------------------------------------------
 # * 초기화
 #--------------------------------------------------------------------------
 def initialize
  sun004rs_initialize
  @move = Sunny_Move.new
  @time = 0
 end
 #--------------------------------------------------------------------------
 # *
 #--------------------------------------------------------------------------
 def update_events
  sun004rs_update_events
  @move.update
  # $game_system.playtime
  @time = (Graphics.frame_count/Graphics.frame_rate).round
 end
 #--------------------------------------------------------------------------
 # * 화면에 맞게 X값을 조율합니다
 #--------------------------------------------------------------------------
 def round_x(x)
  # 삼항 연산자로 가로 루프에 따라 분기됩니다
  loop_horizontal? ? (x + width) % width : x
 end
 #--------------------------------------------------------------------------
 # * 화면에 맞게 Y값을 조율합니다
 #--------------------------------------------------------------------------
 def round_y(y)
  # 삼항 연산자로 세로 루프에 따라 분기됩니다
  loop_vertical? ? (y + height) % height : y
 end
 #--------------------------------------------------------------------------
 # * 왼쪽, 오른쪽을 체크하여 X값을 정합니다
 #--------------------------------------------------------------------------
 def x_with_direction(x, d)
  x + (d == 6 ? RX : d == 4 ? -RX : 0)
 end
 #--------------------------------------------------------------------------
 # * 위쪽, 아래쪽을 체크하여 Y값을 정합니다
 #--------------------------------------------------------------------------
 def y_with_direction(y, d)
  y + (d == 2 ? RX : d == 8 ? -RX : 0)
 end
 #--------------------------------------------------------------------------
 # * 화면 상태에 맞춰 X값을 정합니다
 #--------------------------------------------------------------------------
 def round_x_with_direction(x, d)
  round_x(x + (d == 6 ? RX : d == 4 ? -RX : 0))
 end
 #--------------------------------------------------------------------------
 # * 화면 상태에 맞춰 Y값을 정합니다
 #--------------------------------------------------------------------------
 def round_y_with_direction(y, d)
  round_y(y + (d == 2 ? RX : d == 8 ? -RX : 0))
 end

end

#==============================================================================
# ** Sunny_Move
#------------------------------------------------------------------------------
# 슈팅에 관련된 일을 처리하는 클래스입니다
#==============================================================================
class Sunny_Move
 include Shooting_Maker
 #--------------------------------------------------------------------------
 # * Public Instance Variables
 #--------------------------------------------------------------------------
 attr_reader   :instance_create
 attr_reader   :player
 attr_reader   :size
 attr_reader   :event_create
 attr_reader   :set_move
 attr_reader   :score
 attr_reader   :change_stage
 #--------------------------------------------------------------------------
 # * 초기화
 #--------------------------------------------------------------------------
 def initialize
  @size,@bullet_index,@c_id,@_start_id,@timer = 0,0,1,nil,Game_Timer.new
  @score = 0
  @_id, @gar, @bullet_stack = [], [], []
  @char_stack, @bullet = Queue.new(7), Queue.new(4)
  create_fiber
 end
 #--------------------------------------------------------------------------
 # * 현재 맵의 가로 길이를 반환합니다
 #--------------------------------------------------------------------------
 def Get_X(var)
  w = $game_map.instance_variable_get(:@map).width
  if var >= 0 && var < w
   return var
  else
   return 0
  end
 end
 #--------------------------------------------------------------------------
 # * 현재 맵의 세로 길이를 반환합니다
 #--------------------------------------------------------------------------
 def Get_Y(var)
  h = $game_map.instance_variable_get(:@map).height
  if var >= 0 && var < h
   return var
  else
   return 0
  end
 end
 #--------------------------------------------------------------------------
 # * 피버 객체를 생성합니다(추가적인 캐릭터 생성을 제한합니다)
 #--------------------------------------------------------------------------
 def create_fiber
  @fiber = Fiber.new {run}
 end
 #--------------------------------------------------------------------------
 # * 사이즈값을 증가시킵니다
 #--------------------------------------------------------------------------
 def run
  @size = 1
  loop do
   Fiber.yield
   @size += 1
  end
 end
 #--------------------------------------------------------------------------
 # * $game_player 를 반환합니다
 #--------------------------------------------------------------------------
 def player
  return $game_player
 end
 #--------------------------------------------------------------------------
 # * $game_map.events 를 반환합니다
 #--------------------------------------------------------------------------
 def _ev
  return $game_map.events
 end
 #--------------------------------------------------------------------------
 # * 주석 명령을 감지하여 처리합니다
 #--------------------------------------------------------------------------
 def comment_move
  $game_map.events.values.each do |event|
   next if event.list.nil?
   for i in 0...event.list.size
    list = event.list[i]

    #gsub! 그룹 별로 한 번 치환  (내용1) => $1, (내용2)=> $2
    #gsub 반복적인 치환

    if list.code == 108
     # DOWN x
     list.parameters[0].gsub!(/(DOWN)\s(\d{1,})/){
      set_move(event.id,$2.to_i,MOVE[:DOWN])
     }
     # RIGHT x
     list.parameters[0].gsub!(/(RIGHT)\s(\d{1,})/){
      set_move(event.id,$2.to_i,MOVE[:RIGHT])
     }
     # LEFT x
     list.parameters[0].gsub!(/(LEFT)\s(\d{1,})/){
      set_move(event.id,$2.to_i,MOVE[:LEFT])
     }
     # UP x
     list.parameters[0].gsub!(/(UP)\s(\d{1,})/){
      set_move(event.id,$2.to_i,MOVE[:UP])
     }
     # START ID
     list.parameters[0].gsub!(/(START)/){
      @c_id = event.id
      @_start_id = @c_id
     }
     # ENEMY Created?
     list.parameters[0].gsub!(/(ENEMY)/){
     }
     # BULLET
     list.parameters[0].gsub!(/(BULLET)/){
      @_id.push(event.id)
     }
    end
   end
  end
 end
 #--------------------------------------------------------------------------
 # * 인스턴스 이벤트를 생성합니다
 #--------------------------------------------------------------------------
 def instance_create(x,y,type=["ENEMY"])

  # 베이스 이벤트 클래스 생성
  m_event = RPG::Event.new(Get_X(x),Get_Y(y))
  m_event.id = 1 if $game_map.events.empty?
  m_event.id = $game_map.events.keys.max + 1 if !$game_map.events.empty?
  m_event.name = "[M]사람" + m_event.id.to_s
  m_event.type = type

  # 이벤트 커맨드 리스트 추가
  list = [RPG::EventCommand.new(108,0,type),RPG::EventCommand.new]
  # 주석(커맨드 108) 추가
  m_event.pages[0].list.push(list[0])
  # 스크립트 추가
  m_event.pages[0].list.push(RPG::EventCommand.new(355,0,string)) if type == ["ENEMY"]
  # 이벤트 커맨드 리스트의 끝을 상징하는 리스트(반드시 필요)
  m_event.pages[0].list.push(list[1])
  m_event.pages[0].move_speed = 4
  m_event.pages[0].trigger = 4 # 4 : 병렬처리
  m_event.pages[0].priority_type = 1 # 1 : 주인공과 겹치지 않음
  m_event.pages[0].through = false

  # 게임 이벤트 추가
  event = Game_Event.new($game_map.map_id,m_event)
  $game_map.events[m_event.id] = event
  event.set_graphic(str,rand)

  # 새 이벤트 즉시 묘화
  new_char = Sprite_Character.new(SceneManager.scene.spriteset.viewport1, event)
  @gar[event.id] = new_char
  SceneManager.scene.spriteset.character_sprites.push(@gar[event.id])

  # 현재 화면 업데이트
  SceneManager.scene.spriteset.refresh_characters
  $game_map.refresh_tile_events
  $game_map.refresh
  return event
 end
 #--------------------------------------------------------------------------
 # * 난수 범위값을 문자 형식으로 반환합니다
 #--------------------------------------------------------------------------
 def str
  return "People#{Random.rand(6)+1}"
 end
 #--------------------------------------------------------------------------
 # * 난수 범위값을 반환합니다
 #--------------------------------------------------------------------------
 def rand
  return Random.rand(6)+1
 end
 #--------------------------------------------------------------------------
 # * 업데이트
 #--------------------------------------------------------------------------
 def update
  comment_move
  if _ev[@c_id] != nil
   time_control
   destroy_event
   collision
   change_stage
   # lengthdir(_ev[2],(@timer.count % 10) * 0.01,45) if _ev[2] != nil
   bullet_stack(-1) if Input.trigger? (:C)
   dash
   $game_map.events[@c_id].erased = false if $game_map.events[@c_id].erased == true
  end
 end
 #--------------------------------------------------------------------------
 # * 대쉬
 #--------------------------------------------------------------------------
 def dash
  #    $game_party.members[0].mp-=0.01 if $game_player.dash?
  #    $draw_gauge.update
 end
 #--------------------------------------------------------------------------
 # * 현재 스테이지 반환
 #--------------------------------------------------------------------------
 def change_stage
  return 0 if $game_map.time < 15
  return 1 if $game_map.time < 30
  return 2 if $game_map.time < 45
  return 3 if $game_map.time < 60
  return 4 if $game_map.time >= 60
 end
 #--------------------------------------------------------------------------
 # * 충돌 처리
 #--------------------------------------------------------------------------
 def collision
  for i in 0...@char_stack.size
   next if @char_stack[i] == nil
   if  _ev[@char_stack[i].id].moving? == false
    *c = @char_stack[i].x,@char_stack[i].y+1
    if @char_stack[i].collide_with_events?(c[0],c[1])
     erase(@char_stack[i])
     id = $game_map.event_id_xy(c[0],c[1])
     @score += 100
     $draw_score.update
     erase(_ev[id])
    elsif collision_ok?(@char_stack[i],*c)
     erase(@char_stack[i])
     $game_player.animation_id = 57
     $game_player.actor.hp -= 50
     $draw_gauge.update
    end
   end
  end
 end
 #--------------------------------------------------------------------------
 # * 플레이어와의 충돌 여부 반환
 #--------------------------------------------------------------------------
 def collision_ok?(event,*c)
  return true if event.collide_with_player_characters?(c[0],c[1])
  return true if event.collide_with_player_characters?(c[0] - 1,c[1])
  return true if event.collide_with_player_characters?(c[0] + 1,c[1])
  return false
 end
 #--------------------------------------------------------------------------
 # * 탄환 생성
 #--------------------------------------------------------------------------
 def bullet_stack(id)
  begin
   if @bullet.size >= @bullet.max
    # 탄환 배열에 저장된 이벤트를 꺼냅니다
    event = @bullet.queue
    # 비동기화된 탄환을 동기화시킵니다
    _ev[event.id].moveto(player.x,player.y)
    set_move(event.id,Random.rand(2)+1,MOVE[:UP])
    _ev[event.id].set_graphic(str,rand)
    _ev[event.id].transparent = false
    _ev[event.id].move_speed = 5
   else
    # 새로운 이벤트를 생성하고 배열에 저장합니다
    @bullet.push(event_create(-1,MOVE[:UP],["BULLET"]))
   end
  rescue
  end
 end
 #--------------------------------------------------------------------------
 # * 이벤트가 화면 바깥으로 나갔을 때
 #--------------------------------------------------------------------------
 def destroy_event
  $game_map.events.values.each do |event|
   # 이 이벤트의 지역 ID가 '2'와 같은가?
   if event.region_id == 2
    # 이동 불가 처리
    set_move(event.id,1,0)
    # 이벤트 투명화 처리
    event.transparent = true
   end
  end
 end
 #--------------------------------------------------------------------------
 # * 이벤트 비동기화
 #--------------------------------------------------------------------------
 def erase(event)
  _ev[event.id].moveto(0,0) if event.id != @c_id
  set_move(event.id,1,0)
  event.transparent = true
 end
 #--------------------------------------------------------------------------
 # * 스테이지 레벨 관리
 #--------------------------------------------------------------------------
 def time_control
  @timer.update
  if @timer.working == false && @c_id != nil
   stack_manager(@c_id) if $game_map.region_id(_ev[@c_id].x, _ev[@c_id].y) == 1
   @timer.start(TIME[STAGE[change_stage]])
  elsif @timer.working && @c_id != nil && @timer.count <= 0
   @timer.stop
   @timer.count = 0
  end
 end
 #--------------------------------------------------------------------------
 # * 적 에너미 생성
 #--------------------------------------------------------------------------
 def stack_manager(id)
  begin
   if @char_stack.size >= @char_stack.max
    # 적 이벤트를 꺼냅니다
    event = @char_stack.queue
    # 적 이벤트의 생성 위치
    _ev[event.id].moveto(_ev[@c_id].x,_ev[@c_id].y)
    # 적 이벤트의 이동 방향
    set_move(event.id,Random.rand(2)+1,random_move)
    _ev[event.id].move_speed = 5 if change_stage == 1
    # 적 이벤트의 그래픽 설정
    _ev[event.id].set_graphic(str,rand)
    # 비동기화된 적 에너미를 동기화시킵니다
    _ev[event.id].transparent = false
   else
    # 적 이벤트를 생성한 후에 배열에 저장합니다
    @char_stack.push(event_create(id))
   end
  rescue
  end
 end
 #--------------------------------------------------------------------------
 # * 이동 방향을 반환합니다
 #--------------------------------------------------------------------------
 def random_move
  i = Random.rand(1)
  case i
  when 0; return MOVE[:DOWN] # 플레이어 쪽으로 이동
  when 1; return MOVE[:DOWN] # 화면 하단으로 이동
  else; return MOVE[:DOWN]; end;
 end
 #--------------------------------------------------------------------------
 # * 이벤트 생성
 #--------------------------------------------------------------------------
 def event_create(id,move=MOVE[:DOWN],type=["ENEMY"])
  ev = instance_create(_ev[id].x,_ev[id].y,type) if id != -1
  ev = instance_create(player.x,player.y,type) if id == -1
  set_move(ev.id,Random.rand(2)+1,move)
  $game_map.refresh
  @fiber.resume
  return ev
 end
 #--------------------------------------------------------------------------
 # * 모든 이벤트를 이동시킵니다
 #--------------------------------------------------------------------------
 def all_move(move_mode)
  $game_map.events.values.each do |event|
   set_move(event.id,10,MOVE[move_mode])
  end
 end
 #--------------------------------------------------------------------------
 # * 모든 이벤트가 플레이어 중심으로 뭉칩니다
 #--------------------------------------------------------------------------
 def set_zero
  $game_map.events.values.each do |event|
   event.moveto(player.x,player.y)
  end
 end
 #--------------------------------------------------------------------------
 # * 이벤트를 특정 위치로 이동시킵니다(많은 비용이 소비됨)
 #--------------------------------------------------------------------------
 def set_move(id,repeat,*wh)
  move_route = RPG::MoveRoute.new
  move_route.repeat = true
  move_route.skippable = true
  m = RPG::MoveCommand.new(*wh)
  #for j in 0..repeat
  move_route.list.insert(0,m.clone)
  #end
  $game_map.events[id].force_move_route(move_route)
 end
end

#==============================================================================
# ** Queue
#------------------------------------------------------------------------------
# 클래스를 배열처럼 사용합니다(자료를 꺼내고 넣을 수 있습니다)
#==============================================================================
class Queue
 #--------------------------------------------------------------------------
 # * 클래스 외부에서 읽을 수 있는 변수 목록
 #--------------------------------------------------------------------------
 attr_reader   :index
 attr_reader   :max
 #--------------------------------------------------------------------------
 # * 초기화
 #--------------------------------------------------------------------------
 def initialize(max)
  @data = []
  @min = 0
  @size
  @max = max
  @index = 0
 end
 #--------------------------------------------------------------------------
 # * 클래스를 배열처럼 사용할 수 있습니다(연산자 오버로딩, 읽기)
 #--------------------------------------------------------------------------
 def [](id)
  @data[id] || 0
 end
 #--------------------------------------------------------------------------
 # * 현재 사이즈 반환
 #--------------------------------------------------------------------------
 def size
  return @data.size
 end
 #--------------------------------------------------------------------------
 # * 최대 사이즈 반환
 #--------------------------------------------------------------------------
 def max
  return @max
 end
 #--------------------------------------------------------------------------
 # * 현재 인덱스의 배열값 반환
 #--------------------------------------------------------------------------
 def queue
  index_temp = @index
  index_add
  return @data[index_temp]
 end
 #--------------------------------------------------------------------------
 # * 인덱스값 관리
 #--------------------------------------------------------------------------
 def index_add
  if @index.between?(@min, @max-1)
   return @index = @index + 1
  elsif @index >= @min and @index >= @max
   return @index = 0
  end
 end
 #--------------------------------------------------------------------------
 # * 배열의 제일 끝에 새로운 값을 추가한다
 #--------------------------------------------------------------------------
 def push(data)
  @data.push(data) if @data.size <= @max
 end
 #--------------------------------------------------------------------------
 # * 클래스를 배열처럼 사용할 수 있습니다(연산자 오버로딩, 대입)
 #--------------------------------------------------------------------------
 def []=(id, value)
  @data[id] = value if @data.size <= @max
 end

end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
# 외부에서 Spriteset_Map에 선언된 변수에 접근, 변경을 가능하게 해줍니다
#==============================================================================
class Spriteset_Map
 attr_accessor :character_sprites
 attr_reader   :refresh_characters
 attr_reader   :viewport1
 attr_accessor :gauge
end

#==============================================================================
# ** Game_Plyaer
#------------------------------------------------------------------------------
# 플레이어가 왼쪽 또는 오른쪽으로만 이동할 수 있습니다
#==============================================================================
class Game_Player
 def move_by_input(*args)
  return if !movable? || $game_map.interpreter.running?
  move_straight(4) if Input.press?(:LEFT)
  move_straight(6) if Input.press?(:RIGHT)
 end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
# 외부에서 Scene_Map에 선언된 변수에 접근, 변경을 가능하게 해줍니다
#==============================================================================
class Scene_Map < Scene_Base
 attr_accessor :spriteset
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
# 외부에서 Game_Event에 선언된 변수에 접근, 변경을 가능하게 해줍니다
#==============================================================================
class Game_Event < Game_Character
 attr_accessor :list
 attr_accessor :page
 attr_accessor :condition
 attr_accessor :self_switch_valid
 attr_accessor :erased
 attr_accessor :angle
 attr_accessor :dist
 alias ii_initialize initialize
 alias ii_update update

 def initialize(map_id, event)
  ii_initialize(map_id, event)
  @angle = 0
  @dist = 0
 end

 def update
  ii_update
  @dist = 0 if @dist >= 4
 end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
# 게임시작 후 플레이어의 초기 상태가 정의됩니다
#==============================================================================
class Game_Player < Game_Character
 alias :rrs_initialize :initialize
 def initialize
  rrs_initialize
  set_direction(8)
  @direction_fix = true
  @through = true
 end
 def collide?(x, y)
  @through && (pos?(x, y) || followers.collide?(x, y))
 end
end

#==============================================================================
# ** RPG::Event
#------------------------------------------------------------------------------
# 외부에서 RPG::Event에 선언된 변수에 접근, 변경을 가능하게 해줍니다
#==============================================================================
class RPG::Event
 attr_accessor :type
end

#==============================================================================
# ** Game_Timer
#------------------------------------------------------------------------------
# 외부에서 Game_Timer에 선언된 변수에 접근, 변경을 가능하게 해줍니다
#==============================================================================
class Game_Timer
 attr_accessor :working
 attr_accessor :count
 attr_accessor :sec
end

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
# 외부에서 Game_CharacterBase에 선언된 변수에 접근, 변경을 가능하게 해줍니다
#==============================================================================
class Game_CharacterBase
 attr_accessor   :move_speed
 #--------------------------------------------------------------------------
 # * 이동 속도
 #--------------------------------------------------------------------------
 def real_move_speed
  @move_speed + (dash? ? 2 : 0)
 end
end

#==============================================================================
# ** Window_Score
#------------------------------------------------------------------------------
# 화면에 점수를 표시하기 위한 윈도우 클래스입니다
#==============================================================================

class Window_Score < Window_Base
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize
  super(0, 0, window_width, fitting_height(3))
  self.opacity = 0
  self.contents_opacity = 0
  @show_count = 250
  update
 end
 #--------------------------------------------------------------------------
 # * Get Window Width
 #--------------------------------------------------------------------------
 def window_width
  return 240
 end
 #--------------------------------------------------------------------------
 # * Open Window
 #--------------------------------------------------------------------------
 def open
  @show_count = 150
  self.contents_opacity = 200
  self
 end
 #--------------------------------------------------------------------------
 # * Close Window
 #--------------------------------------------------------------------------
 def close
  @show_count = 0
  self
 end
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def update
  contents.clear
  unless $game_map.move.score.to_s.empty?
   draw_background(contents.rect)
   str1 = "점수"
   draw_text_ex(contents_width/2 - (str1.size),0,str1)
   str2 = $game_map.move.score.to_s
   draw_text_ex(contents_width/2 - (str2.size),24,str2)
   #~       x,t = Mouse.true_grid
   #~       draw_text_ex(0,32,sprintf("%d, %d",x,t))
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Background
 #--------------------------------------------------------------------------
 def draw_background(rect)
  temp_rect = rect.clone
  temp_rect.width /= 2
  contents.gradient_fill_rect(temp_rect, back_color2, back_color1)
  temp_rect.x = temp_rect.width
  contents.gradient_fill_rect(temp_rect, back_color1, back_color2)
 end
 #--------------------------------------------------------------------------
 # * Get Background Color 1
 #--------------------------------------------------------------------------
 def back_color1
  Color.new(0, 0, 0, 192)
 end
 #--------------------------------------------------------------------------
 # * Get Background Color 2
 #--------------------------------------------------------------------------
 def back_color2
  Color.new(0, 0, 0, 0)
 end
end

#==============================================================================
# ** Window_Gauge
#------------------------------------------------------------------------------
# 화면에 게이지를 표시하기 위한 클래스입니다
#==============================================================================

class Window_Gauge < Window_Base
 #--------------------------------------------------------------------------
 # * Object Initialization
 #--------------------------------------------------------------------------
 def initialize
  super(0, 0, window_width, fitting_height(3))
  self.opacity = 0
  self.contents_opacity = 255
  @show_count = 250
  update
 end
 #--------------------------------------------------------------------------
 # * Get Window Width
 #--------------------------------------------------------------------------
 def window_width
  return 240
 end
 #--------------------------------------------------------------------------
 # * Refresh
 #--------------------------------------------------------------------------
 def update
  contents.clear
  unless $game_map.move.score.to_s.empty?
   draw_background(contents.rect)
   draw_actor_hp($game_party.members[0], 0, 0, width = 124)
   #     draw_actor_mp($game_party.members[0], 0, 24, width = 124)
   #draw_text_ex(0,24,sprintf("%.0f",$game_map.time))
   draw_text_ex(0,48,"WAVE" + Shooting_Maker::STAGE[$game_map.move.change_stage].to_s)
  end
 end
 #--------------------------------------------------------------------------
 # * Draw Background
 #--------------------------------------------------------------------------
 def draw_background(rect)
  temp_rect = rect.clone
  temp_rect.width /= 2
  contents.gradient_fill_rect(temp_rect, back_color2, back_color1)
  temp_rect.x = temp_rect.width
  contents.gradient_fill_rect(temp_rect, back_color1, back_color2)
 end
 #--------------------------------------------------------------------------
 # * Get Background Color 1
 #--------------------------------------------------------------------------
 def back_color1
  Color.new(0, 0, 0, 192)
 end
 #--------------------------------------------------------------------------
 # * Get Background Color 2
 #--------------------------------------------------------------------------
 def back_color2
  Color.new(0, 0, 0, 0)
 end
end

#==============================================================================
# ** Scene_Map
#------------------------------------------------------------------------------
# 현재 화면에 윈도우(UI용 윈도우)를 그려줍니다
#==============================================================================

class Scene_Map < Scene_Base
 alias :rsr_create_all_windows :create_all_windows
 alias :rsr_pre_transfer :pre_transfer
 alias :rsr_post_transfer :post_transfer
 alias :rsr_update :update
 #--------------------------------------------------------------------------
 # *
 #--------------------------------------------------------------------------
 def create_all_windows
  rsr_create_all_windows
  # 점수가 표시되는 윈도우를 생성합니다
  $draw_score = Window_Score.new
  # 게이지가 표시되는 윈도우를 생성합니다
  $draw_gauge = Window_Gauge.new
  $draw_score.x = 320
  $draw_gauge.x = 0
  $draw_score.open
  # 게임 시작과 동시에 애니메이션을 재생합니다
  $game_player.animation_id = 112
 end
 #--------------------------------------------------------------------------
 # * update
 #--------------------------------------------------------------------------
 def update
  rsr_update
 end
 #--------------------------------------------------------------------------
 # * close_score
 #--------------------------------------------------------------------------
 def close_score
  $draw_score.close
 end
end

#==============================================================================
# ** Scene_Gameover
#------------------------------------------------------------------------------
# 게임오버 후에 (타이틀을 스킵하며) 게임이 재시작됩니다
#==============================================================================
class Scene_Gameover < Scene_Base
 def goto_title
  fadeout_all
  SceneManager.new_game
 end
end

#==============================================================================
# ** 타이틀 스킵
#------------------------------------------------------------------------------
# 타이틀을 생략합니다
#==============================================================================
module SceneManager
 def self.run
  DataManager.init
  Audio.setup_midi if use_midi?
  SceneManager.new_game
  #@scene = first_scene_class.new
  @scene.main while @scene
 end
 #--------------------------------------------------------------------------
 # * New Game
 #--------------------------------------------------------------------------
 def self.new_game
  SceneManager.clear
  DataManager.setup_new_game
  $game_map.autoplay
  SceneManager.goto(Scene_Map)
  #SceneManager.goto(Scene_Title)
 end
end

#==============================================================================
# ** Sunny_Move[추가 정의]
#------------------------------------------------------------------------------
# Sunny_Move 클래스의 메소드 중 하나를 재정의하거나 메소드를 추가로 정의합니다
#==============================================================================
class Sunny_Move
 alias length_initialize initialize
 alias length_update update
 def initialize
  length_initialize
  @length_path = []
 end
 #--------------------------------------------------------------------------
 # * 원점과의 거리와 각도로 위치를 재설정합니다
 #--------------------------------------------------------------------------
 def lengthdir(event,length,angle)
  rad = angle * (Math::PI/180)
  x = _ev[event.id].x + length * Math.cos(rad)
  y = _ev[event.id].y + length * Math.sin(rad)
  _ev[event.id].moveto(x,y)
 end
 #--------------------------------------------------------------------------
 # * 이벤트 커맨드 리스트에 스크립트를 추가합니다
 #--------------------------------------------------------------------------
 def string
  script_param = "
    if $game_map.move.change_stage >= 7
      rad = Math.get_rad(get_character(0).x,get_character(0).y,$game_player.x,$game_player.y)
      get_character(0).angle = rad if get_character(0).dist == 0
      _x = get_character(1).x + get_character(0).dist * Math.cos(get_character(0).angle)
      _y = get_character(1).y + get_character(0).dist * Math.sin(get_character(0).angle)
      get_character(0).moveto(_x,_y)
      get_character(0).dist += 0.1
    end
    "
  pa = []
  pa.push(script_param)
  return pa
 end
end

#==============================================================================
# ** Math 모듈
#------------------------------------------------------------------------------
#
#==============================================================================
module Math
 #--------------------------------------------------------------------------
 # * 거듭제곱
 #--------------------------------------------------------------------------
 def self.pow(x,d)
  r = x**d
  r
 end
 #--------------------------------------------------------------------------
 # * 두 점 사이의 라디안
 #--------------------------------------------------------------------------
 def self.get_rad(x1,y1,x2,y2)
  return rad = Math.atan2(y2 - y1, x2 - x1)
 end
 #--------------------------------------------------------------------------
 # * 두 점 사이의 각도
 #--------------------------------------------------------------------------
 def self.get_angle(x1,y1,x2,y2)
  return Math.get_rad(x1,y1,x2,y2) * (180/Math::PI)
 end
end
