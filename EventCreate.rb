#==============================================================================
# Author       : biud436
# Change Log   :
#   2018.08.30 - 이벤트 삭제 방법 변경
#   2015.07.10 - 그래픽 설정 수정
#   2015.07.07 - 일괄 삭제 메소드(열거자 형식) 추가
#   2015.06.22 - 새로운 메소드 추가
#   2015.06.16 - 모든 페이지를 설정합니다.
#   2015.02.02 - 다른 맵에 있는 이벤트도 불러올 수 있습니다
#   2015.01.18 - 최초 버전입니다
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_InstanceEvent"] = true

class Game_Event
  attr_reader :move_type
  def get_pages
    @event.pages
  end
end

module OPT
  EVData = Struct.new(:sprite_name,:sprite_index,:pages)
  #--------------------------------------------------------------------------
  # * Init Struct
  #--------------------------------------------------------------------------
  def set_character_data
    ev_data = EVData.new
    page = RPG::Event::Page.new
    page.graphic.character_name = ev_data.sprite_name = "Actor#{1 + rand(5)}"
    page.graphic.character_index = ev_data.sprite_index = rand(8)
    page.trigger = 0
    page.priority_type = 1
    page.move_speed = 4
    page.move_frequency = 3
    page.move_type = 3
    page.through = false
    page.list = get_test_event_list
    page.move_route = get_test_move_route
    ev_data.pages = [page]
    ev_data
  end
  #--------------------------------------------------------------------------
  # * 이벤트 커맨드 리스트를 스크립트로 작성한 것입니다
  #--------------------------------------------------------------------------
  def get_test_event_list
    list = []
    # 페이스칩 명 , 페이스칩의 인덱스, 메시지의 배경, 메시지의 위치 설정
    list.push RPG::EventCommand.new(101,0,["",0,0,2])
    # 대화창 표시
    list.push RPG::EventCommand.new(401,0,["테스트 대화입니다"])
    # 인스턴스 캐릭터를 파괴합니다
    list.push RPG::EventCommand.new(355,0,["instance_destroy(@event_id)"])
    # 빈 커맨드를 만나야 이벤트가 끝납니다. 따라서 빈 이벤트를 반드시 추가해야 합니다.
    list.push RPG::EventCommand.new
    list
  end
  #--------------------------------------------------------------------------
  # * 실제 이벤트에 설정해놓은 커맨드 리스트를 가져옵니다
  #--------------------------------------------------------------------------
  def get_event_list(event_index)
    list = $game_map.events[event_index].list
    list
  end
  #--------------------------------------------------------------------------
  # * 이동 루트의 설정을 스크립트로 작성한 것입니다
  #--------------------------------------------------------------------------
  def get_test_move_route
    # 이동 루트의 설정입니다
    move_route = RPG::MoveRoute.new
    move_route.repeat = true
    # 램덤 이동
    move_route.list = [RPG::MoveCommand.new(9),RPG::MoveCommand.new]
    move_route
  end
  #--------------------------------------------------------------------------
  # * 실제 이벤트에 설정해놓은 이동 루트를 가져옵니다
  #--------------------------------------------------------------------------
  def get_move_route(event_index)
    list = $game_map.events[event_index].move_route
    list
  end
  #--------------------------------------------------------------------------
  # * 다른 맵에 있는 이벤트를 가져옵니다.
  #--------------------------------------------------------------------------
  def set_event_data(index,map_id=$game_map.map_id)
    events = {}
    map = load_data(sprintf("Data/Map%03d.rvdata2", map_id))
    map.events.each {|i, event| events[i] = Game_Event.new(map_id, event) }
    ev_data = EVData.new
    page = events[index].find_proper_page
    ev_data.sprite_name = page.graphic.character_name
    ev_data.sprite_index = page.graphic.character_index
    ev_data.pages = events[index].get_pages
    ev_data
  end
end

class Object
  include OPT
  #--------------------------------------------------------------------------
  # * 이벤트를 즉시 생성합니다
  #--------------------------------------------------------------------------
  def instance_create(x,y,data=set_character_data)

    # 기초 이벤트를 구성합니다
    m_event = RPG::Event.new(x,y)

    # 이벤트의 ID 를 설정합니다
    m_event.id = if $game_map.events.empty?
      1
    else
      $game_map.events.keys.max + 1
    end

    # 이벤트의 이름입니다
    m_event.name = "EV#{m_event.id.to_s}"

    # 페이지 설정
    data.pages.each_with_index { |page,i| m_event.pages[i] = page }

    # 이벤트를 추가합니다
    event = Game_Event.new($game_map.map_id,m_event)
    $game_map.events[m_event.id] = event

    # Spriteset_Map 의 캐릭터 배열에 방금 만든 캐릭터를 추가합니다
    get_scene = SceneManager.scene
    if get_scene.is_a?(Scene_Map)
      get_scene = get_scene.spriteset
      get_sprite = Sprite_Character.new(get_scene.viewport1,event)
      get_scene.character_sprites.push(get_sprite)
      return $game_map.events[m_event.id]
    end
  end
  #--------------------------------------------------------------------------
  # * 이벤트를 구성하고 있는 모든 오브젝트를 없앱니다
  #--------------------------------------------------------------------------
  def instance_destroy(index)
    $game_map.events.delete(index)
    get_scene = SceneManager.scene.spriteset
    get_scene.character_sprites.delete_if do |ev| 
      ev.character.id == index
    end
  end
  #--------------------------------------------------------------------------
  # * 병렬 처리 이벤트에서 이벤트를 생성합니다
  #--------------------------------------------------------------------------
  def instance_create_ex(event_id,x,y,map_id=$game_map.map_id)
    Thread.new do
      ev_data = set_event_data(event_id,map_id)
      instance_create(x,y,ev_data)
    end
  end
end

class Scene_Map
  attr_accessor :spriteset
end

class Spriteset_Map
  attr_accessor :character_sprites
  attr_accessor :custom_events
  attr_reader :viewport1
end

class Game_Character
  attr_reader   :move_route
end

class Object
  def instance_destroy_each(args)
    return unless args.is_a?(Range) || args.is_a?(Array)
    args.each do |i|
      $game_map.events.delete(i)
      get_scene = SceneManager.scene.spriteset
      get_scene.character_sprites.delete(i - 1)
    end
    SceneManager.scene.spriteset.refresh_characters
  end
end

class Game_Event < Game_Character
  attr_reader   :id
end