=begin
Name : MiniMap
Author : biud436
Version : 1.54
#==============================================================================
# ** 사용법
#==============================================================================

1. 미니맵을 그릴려면 맵 이름 앞에 [MAP] 라는 옵션을 설정해주세요.
[MAP]Regular Town

2. F6 키로 미니맵 켜기/끄기

3. 이벤트에서 미니맵 끄기
$game_map.minimap_visible = false

4. 이벤트에서 미니맵 켜기
$game_map.minimap_visible = true

5. 스크린의 위치는 SCREEN 상수의 값을 변경해주면 변경할 수 있습니다

6. 이벤트를 이벤트의 그래픽으료 묘화할 땐 주석에 "미니맵 설정"이라고 쓰세요.
미니맵 설정 0

'미니맵 설정 0'으로 설정하면 캐릭터 정면 모습만 그려집니다
'미니맵 설정 1'로 설정하면 캐릭터의 방향과 패턴도 읽어서 묘화됩니다.

7. 이벤트를 특정 아이콘으로 묘화할 땐 아래와 같이 주석을 작성하세요(1번 아이콘을 표시)
아이콘 설정 1

8. 데이터베이스 타일셋에서 특정 지형태그를 설정해두면 미니맵 상에서 색상이 바뀝니다.

9. 미니맵 스케일값 설정 (맵 속성에 있는 주석란에서 스케일값을 설정할 수 있습니다)
<ScaleX=5>
<ScaleY=5>

#==============================================================================
# ** 업데이트 정보
#==============================================================================

## 1.54 (2015.04.10) =========================================================
- 비율 오차값 수정
- 버튼 상수 추가
- 스케일 조정 및 설정 기능 추가
- 테두리 설정 기능 제거
- 카메라 스크롤 기능

## 1.5 (2015.02.21) =========================================================
- 사각형 묘화가 사라지고 캐릭터 묘화로 변경되었습니다
- 주석을 읽어서 처리하는 방식으로 변경되었으며 한글 명령어를 처리합니다

## 1.4(2014.10.17) ============================================================
- 지형 태그가 걸려있는 블록이 다른 색으로 그려집니다
- 벽과 언덕 등의 오토타일을 체크합니다
- 4방향 통행여부를 모두 체크합니다
- 테두리의 묘화 방식이 변경되었습니다
- 미니맵의 기본 사이즈가 확대되었습니다.
- 게임 재시작 오류 수정

## 1.3(2014.10.16) ============================================================
- 테두리 끄고/켜기 기능 추가
- 이벤트가 일시 삭제, 미니맵에 반영

## 1.2(2014.10.14) ============================================================
- 부분적 묘화 기능이 추가되어 큰 맵에서도 미니맵을 사용할 수 있게 되었습니다
- 미니맵에 보이는 영역의 끝에 플레이어가 도달했을 때에만 미니맵이 다시 그려집니다
- 이벤트를 특정 아이콘으로 묘화할 수 있는 기능이 추가되었습니다
- 이벤트의 가시상태가 미니맵에 반영됩니다
- 미니맵이 그려지는 방식을 맵 별로 설정할 수 있습니다

## 1.1(2014.10.13) ============================================================
- 통행이 불가능한 타일을 바탕으로 미니맵을 생성합니다
- 미니맵에 이벤트의 위치가 파란색 또는 노란색으로 표시됩니다
  노란색은 [M], 파란색은 [L] 을 이벤트 명 앞에 붙여주시기 바랍니다
- 배경 화면 설정 기능이 삭제되었습니다

## 1.0(2014.05.27) ============================================================
- 부분적 묘화(큰 사각형, 작은 사각형)
- 배경 화면 설정 기능
=end

#==============================================================================
# ** Class List
#------------------------------------------------------------------------------
# MiniMap         - 미니맵 관련 기본 설정을 할 수 있는 모듈입니다
# Game_Map        - 맵의 폭과 높이를 구해줍니다
# Box             - 미니맵에 사각형을 그려줍니다
# Icon            - 미니맵에 아이콘을 만들어줍니다
# Game_Player     - 플레이어의 가시 상태를 체크해줍니다
# Game_Event      - 이벤트의 이름과 가시 상태를 체크해줍니다
# Game_Map        - 미니맵의 스케일을 설정합니다
# Game_System     - 미니맵의 스케일을 조정합니다
# MiniMap_Manager - 미니맵을 그리기 위한 구성 요소들이 모여있는 클래스입니다
# Mapster         - 미니맵 관리자를 생성하고 관리합니다
# Spriteset_Map   - 맵에 미니맵의 구성 요소들을 그려줍니다
# Spriteset_Map   - 맵에 미니맵의 뷰포트를 선언합니다
# Spriteset_Map   - 타일셋이 그려질 때 미니맵도 같이 그려줍니다
# Game_Map        - 미니맵의 가시상태를 체크하는 변수에 접근을 할 수 있게 합니다
# Game_Player     - 미니맵 시야 확보를 위해 걸음 수를 체크해줍니다
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

#==============================================================================
# ** MiniMap
#------------------------------------------------------------------------------
# 미니맵 관련 기본 설정을 할 수 있는 모듈입니다
#==============================================================================
module MiniMap
  # 스크린의 위치
  SCREEN = :TOP_RIGHT

  # 스크린의 크기
  W,H = 150.0, 150.0

  # 미니맵과 윈도우와의 간격 조절
  PD = 10

  # 스케일 X
  Scale_X = 2

  # 스케일 Y
  Scale_Y = 2

  # 지역 태그 번호
  TAG = 1

  # 미니맵을 켜고 끌 수 있는 버튼입니다
  KEY = :F6

  # 지역 태그 색상
  TAG_COLOR = :red

  # 스크린의 좌표
  OFFSET = case SCREEN
  when :TOP_RIGHT then [Graphics.width - W - PD,PD]
  when :BOTTOM_RIGHT then [Graphics.width - W - PD,Graphics.height - H - PD]
  when :BOTTOM_LEFT then [PD,Graphics.height - H - PD]
  when :TOP_LEFT  then [PD,PD]
  end

  # 시야
  STEP = 25

  # 플래시의 지속시간
  FLASH_DURATION = 120 # 2초(로딩을 하고 있다는 것을 알리기 위한 피드백)

  # 색상 : 빨간색
  RED = Color.new(255,0,0,200)
  # 색상 : 검정색
  BLACK = Color.new(0,0,0,255)
  # 색상 : 파란색
  BLUE = Color.new(10,10,100,200)
  # 색상 : 노란색
  YELLOW = Color.new(255,255,0,200)
  # 색상 : 회색
  GRAY = Color.new(100,100,100,200)
  # 색상 : 하얀색
  WHITE = Color.new(200,200,200,200)

end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
# 맵의 폭과 높이를 구해줍니다
#==============================================================================
class Game_Map
  attr_reader :need_refresh
  #--------------------------------------------------------------------------
  # * 폭
  #--------------------------------------------------------------------------
  def width
    @map.width
  end
  #--------------------------------------------------------------------------
  # * 높이
  #--------------------------------------------------------------------------
  def height
    @map.height
  end
end

#==============================================================================
# ** Box
#------------------------------------------------------------------------------
# 미니맵에 사각형을 그려줍니다
#==============================================================================
class Box < Sprite
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize(viewport,width,height,color)
    super(viewport)
    @color = color
    @width = width
    @height = height
    @x = 0
    @y = 0
    create_bitmap
    update
  end
  #--------------------------------------------------------------------------
  # * 좌표 설정
  #--------------------------------------------------------------------------
  def set_coord(x,y)
    self.x = x
    self.y = y
  end
  #--------------------------------------------------------------------------
  # * 비트맵 생성
  #--------------------------------------------------------------------------
  def create_bitmap
    self.bitmap = Bitmap.new(@width,@height)
    self.x = 0
    self.y = 0
    self.z = 150
    self.bitmap.fill_rect(0,0,@width,@height,set_color)
    self.visible = $game_map.minimap_visible
  end
  #--------------------------------------------------------------------------
  # * 색상 설정
  #--------------------------------------------------------------------------
  def set_color
    case @color
    when :red then MiniMap::RED
    when :black then MiniMap::BLACK
    when :blue then MiniMap::BLUE
    when :yellow then MiniMap::YELLOW
    when :gray then MiniMap::GRAY
    when :white then MiniMap::WHITE
    else
      MiniMap::RED
    end
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    super
    if $game_map.minimap_visible != self.visible
      self.visible = $game_map.minimap_visible
    end
  end
  #--------------------------------------------------------------------------
  # * 다시 그리기
  #--------------------------------------------------------------------------
  def redraw
    self.bitmap.clear
    self.bitmap.fill_rect(0,0,self.bitmap.width,self.bitmap.height,set_color)
    self.visible = $game_map.minimap_visible
  end
  #--------------------------------------------------------------------------
  # * 메모리 해제
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
end

#==============================================================================
# ** Icon
#------------------------------------------------------------------------------
# 미니맵에 아이콘을 만들어줍니다
#==============================================================================
class Icon < Sprite
  attr_accessor :origin
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize(viewport,index,x,y,char_icon = true,origin=0)
    super(viewport)
    @char_icon = char_icon
    @origin = origin
    @index = index
    set_coord(x,y)
    case @char_icon
    when true then draw_char_icon(index,x,y)
    when false then draw_icon(index,x,y)
    else
      draw_char_icon(index,x,y,$game_player)
    end
  end
  #--------------------------------------------------------------------------
  # * 투명도
  #--------------------------------------------------------------------------
  def translucent_alpha
    return 200
  end
  #--------------------------------------------------------------------------
  # * 아이콘 좌표 설정
  #--------------------------------------------------------------------------
  def set_coord(x,y)
    self.x = x
    self.y = y
  end
  #--------------------------------------------------------------------------
  # * 아이콘 메모리 해제
  #--------------------------------------------------------------------------
  def dispose
    super
    self.bitmap.dispose
  end
  #--------------------------------------------------------------------------
  # * 아이콘 묘화
  #--------------------------------------------------------------------------
  def draw_icon(icon_index, x, y)
    self.bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    self.src_rect.set(rect)
    self.bitmap.blt(x,y,self.bitmap,rect,translucent_alpha)
    self.ox = 12
    self.oy = 12
    self.z = 155
  end
  #--------------------------------------------------------------------------
  # * 캐릭터 아이콘 묘화
  #--------------------------------------------------------------------------
  def draw_char_icon(icon_index, x, y,obj = $game_map.events[icon_index])
    str = obj.character_name
    self.bitmap = Bitmap.new(16,16)

    bitmap = Cache.character(str.to_s)
    character = obj
    index = character.character_index
    pattern = @origin > 0? character.pattern : 1
    direction = @origin > 0? character.direction : 2

    sign = obj.character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      @cw = bitmap.width / 12
      @ch = bitmap.height / 8
    end

    sx = (index % 4 * 3 + pattern) * @cw
    sy = (index / 4 * 4 + (direction - 2) / 2) * @ch

    dest_rect = Rect.new(0,0,16,16)
    src_rect = Rect.new(sx,sy,@cw,@ch)

    self.bitmap.stretch_blt(dest_rect, bitmap, src_rect)
    self.ox = 4
    self.oy = 4
    self.z = 155
  end

end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
# 플레이어의 가시 상태를 체크해줍니다
#==============================================================================
class Game_Player
  #--------------------------------------------------------------------------
  # * 가시 상태
  #--------------------------------------------------------------------------
  def visible
     @visible = if @character_name == "" || @transparent
       false
     else
       true
     end
   end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
# 이벤트의 이름과 가시 상태를 체크해줍니다
#==============================================================================
class Game_Event
  attr_accessor :visible
  #--------------------------------------------------------------------------
  # * 이벤트의 이름
  #--------------------------------------------------------------------------
  def name
    @event.name
  end
  #--------------------------------------------------------------------------
  # * 가시 상태
  #--------------------------------------------------------------------------
  def visible
     @visible = if @character_name == "" || @erased || @transparent
       false
     else
       true
     end
   end
  #--------------------------------------------------------------------------
  # * 이벤트의 일시 삭제
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    visible
    refresh
  end
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
# 미니맵의 스케일을 설정합니다
#==============================================================================
class Game_Map
  alias minimap_game_map_setup setup
  def setup(map_id)
    minimap_game_map_setup(map_id)
    @map.note.gsub(/<ScaleX=(\d+)>/i) {
    $game_system.view_scale_x = $1.to_i || MiniMap::Scale_X}
    @map.note.gsub(/<ScaleX=(\d+)>/i) {
    $game_system.view_scale_y = $1.to_i || MiniMap::Scale_Y}
  end
end

#==============================================================================
# ** Game_System
#------------------------------------------------------------------------------
# 미니맵의 스케일을 조정합니다
#==============================================================================
class Game_System
  alias minimap_game_system_initialize initialize
  attr_accessor :view_scale_x
  attr_accessor :view_scale_y
  def initialize
    minimap_game_system_initialize
    @view_scale_x = MiniMap::Scale_X
    @view_scale_y = MiniMap::Scale_Y
  end
end

#==============================================================================
# ** MiniMap_Manager
#------------------------------------------------------------------------------
# 미니맵을 그리기 위한 구성 요소들이 모여있는 클래스입니다
#==============================================================================
class MiniMap_Manager
  #--------------------------------------------------------------------------
  # * 미니맵 관리자 : 초기화
  #--------------------------------------------------------------------------
  def initialize
    @redraw = false
    @size = []
    @event = []
    @large_event = []
    @viewrect = []
    read_map
    create_instance
  end
  #--------------------------------------------------------------------------
  # * 배경 생성
  #--------------------------------------------------------------------------
  def create_background
    read_map
    @background = Box.new($minimap_lower_view,MiniMap::W, MiniMap::H,:gray)
    @background.opacity = 230
    @background.set_coord(MiniMap::OFFSET[0],MiniMap::OFFSET[1])
  end
  #--------------------------------------------------------------------------
  # * 인스턴스 생성
  #--------------------------------------------------------------------------
  def create_instance
    create_background
    create_character
    @char = Icon.new($minimap_high_viewport,0,@ratio_w,@ratio_h,2)
    @char.x = MiniMap::OFFSET[0] + $game_player.real_x * @ratio_w
    @char.y = MiniMap::OFFSET[1] + $game_player.real_y * @ratio_h
    @char.z = 200
  end
  #--------------------------------------------------------------------------
  # * 맵 블록 생성
  #--------------------------------------------------------------------------
  def create_map_object(i,tx,ty,color = :black)
    @viewrect[i] = Box.new($minimap_high_viewport,@ratio_w,@ratio_h,color)
    @viewrect[i].z = 90
    @viewrect[i].set_coord(
    MiniMap::OFFSET[0] + tx * @ratio_w.to_i,
    MiniMap::OFFSET[1] + ty * @ratio_h.to_i)
  end
  #--------------------------------------------------------------------------
  # * 통행 가능 지역 생성
  #--------------------------------------------------------------------------
  def create_viewrect
    read_map
    i, n = 0, MiniMap::STEP
    flags = $game_map.tileset.flags
    mx,dx = $game_player.x-n,$game_player.x+n
    my,dy = $game_player.y-n,$game_player.y+n
    for tx in 0 ... @width
      for ty in 0 ... @height
        # 플레이어 시야 체크
        next unless tx.between?(mx,dx) and ty.between?(my,dy)
        # 오토타일 체크
        next if $game_map.autotile_type(tx,ty,0) != -1 and
        $game_map.tile_id(tx,ty,0).between?(4367,8192)
        # 4방향 통행 가능 체크
        if check_boundary(tx,ty)
          create_map_object(i,tx,ty)
          i+=1
          next
        end
        # 지형 태그 체크
        if $game_map.terrain_tag(tx,ty) == MiniMap::TAG
          create_map_object(i,tx,ty,MiniMap::TAG_COLOR)
          i+=1
          next
        end
        # 통행 가능 체크
        next unless $game_map.check_passage(tx,ty,0x000F)
        create_map_object(i,tx,ty)
        i+=1
      end
    end
    @player_rect = Rect.new(mx,my,dx,dy)
  end
  #--------------------------------------------------------------------------
  # * 통행 여부 체크
  #--------------------------------------------------------------------------
  def flag?(x, y, bit)
    # 통행이 가능한 레이어의 ID값을 반환
    $game_map.layered_tiles(x, y).one? {|tile_id|
    $game_map.tileset.flags[tile_id] & bit != 0 }
  end
  #--------------------------------------------------------------------------
  # * 통행 여부 체크(4방향)
  #--------------------------------------------------------------------------
  def dir4_check(x,y,*args)
    down = flag?(x, y, 1)
    left = flag?(x, y, 2)
    right = flag?(x, y, 4)
    up = flag?(x, y, 8)
    return true if [down,left,right,up] == args
    return false
  end
  #--------------------------------------------------------------------------
  # * 모든 방향을 체크합니다
  #--------------------------------------------------------------------------
  def check_boundary(x,y)
      dir4_check(x,y,false,true,false,false) || #왼쪽만 막힘
      dir4_check(x,y,false,true,false,true)  ||#왼쪽/위가 막힘
      dir4_check(x,y,true,true,false,false)  ||#왼쪽/아래가 막힘
      dir4_check(x,y,false,true,true,false)  ||#왼쪽/오른쪽이 둘다 막힘
      dir4_check(x,y,true,false,false,true)  ||#위/아래가 막힘
      dir4_check(x,y,false,false,true,false) ||#오른쪽만 막힘
      dir4_check(x,y,false,false,true,true)  ||#오른쪽/위가 막힘
      dir4_check(x,y,true,false,true,false)  #오른쪽/아래가 막힘
  end
  #--------------------------------------------------------------------------
  # * 플레이어의 뷰 영역 반환
  #--------------------------------------------------------------------------
  def player_rect
    @player_rect unless @player_rect.nil?
  end
  #--------------------------------------------------------------------------
  # * 통행 가능 지역 메모리 해제
  #--------------------------------------------------------------------------
  def dispose_viewrect
    @viewrect.each do |i|
      i.bitmap.clear  if $game_map.need_refresh
      i.bitmap.dispose  if $game_map.need_refresh
      i.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 캐릭터 생성
  #--------------------------------------------------------------------------
  def create_character
    $game_map.events.values.each_with_index do |event,i|
      list = event.list.select {|i| i.code == 108 or i.code == 408}
      list.each { |m|
      m.parameters[0].gsub(/\u{bbf8}\u{b2c8}\u{b9f5}\u{20}\u{c124}\u{c815}( \d+)/) {
        @event[i] = Icon.new($minimap_high_viewport,event.id,
        MiniMap::OFFSET[0] + event.x * @ratio_w.to_i,
        MiniMap::OFFSET[1] + event.y * @ratio_h.to_i,
        true,($1.to_i rescue 0))
        @event[i].visible = event.visible
      }
      m.parameters[0].gsub(/\u{c544}\u{c774}\u{cf58}\u{20}\u{c124}\u{c815}\u{20}(\d+)/) {
        @large_event[i] = Icon.new($minimap_high_viewport,$1.to_i,
        MiniMap::OFFSET[0] + event.x * @ratio_w.to_i,
        MiniMap::OFFSET[1] + event.y * @ratio_h.to_i,false)
        @large_event[i].visible = event.visible}
      }
    end
  end
  #--------------------------------------------------------------------------
  # * 캐릭터 업데이트
  #--------------------------------------------------------------------------
  def update_character
    $game_map.events.values.each_with_index do |event,i|
      list = event.list.select {|i| i.code == 108 or i.code == 408}
      list.each { |m|
      m.parameters[0].gsub(/\u{bbf8}\u{b2c8}\u{b9f5}\u{20}\u{c124}\u{c815}( \d+)/) {
        @event[i].visible = event.visible
        @event[i].set_coord(
        MiniMap::OFFSET[0] + event.x * @ratio_w.to_i,
        MiniMap::OFFSET[1] + event.y* @ratio_h.to_i)
      }
      m.parameters[0].gsub(/\u{c544}\u{c774}\u{cf58}\u{20}\u{c124}\u{c815}\u{20}(\d+)/) {
        @large_event[i].visible = event.visible
        @large_event[i].set_coord(
        MiniMap::OFFSET[0] + event.x * @ratio_w.to_i,
        MiniMap::OFFSET[1] + event.y* @ratio_h.to_i)}
      }
    end
  end
  #--------------------------------------------------------------------------
  # * 캐릭터 메모리 해제
  #--------------------------------------------------------------------------
  def dispose_character
    if $game_map.need_refresh
      $game_map.events.values.each_with_index do |event,i|
      list = event.list.select {|i| i.code == 108 or i.code == 408}
      list.each { |m|
        m.parameters[0].gsub(/\u{bbf8}\u{b2c8}\u{b9f5}\u{20}\u{c124}\u{c815}( \d+)/) {
          @event[i].bitmap.dispose
          @event[i].dispose
        }
        m.parameters[0].gsub(/\u{c544}\u{c774}\u{cf58}\u{20}\u{c124}\u{c815}\u{20}(\d+)/) {
          @large_event[i].bitmap.dispose
          @large_event[i].dispose}
       }
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    @char.x = MiniMap::OFFSET[0] + $game_player.real_x * @ratio_w
    @char.y = MiniMap::OFFSET[1] + $game_player.real_y * @ratio_h
    update_character
    set_camera
  end

  #--------------------------------------------------------------------------
  # * 미니맵 카메라 설정
  #--------------------------------------------------------------------------
  def set_camera
    cx = $game_player.real_x
    cy = $game_player.real_y

    $minimap_high_viewport.ox = MiniMap::OFFSET[0] + cx * @ratio_w.to_i - MiniMap::W/2
    $minimap_high_viewport.oy = MiniMap::OFFSET[1] + cy * @ratio_h.to_i - MiniMap::H/2

    if $minimap_high_viewport.ox <= MiniMap::OFFSET[0]
      $minimap_high_viewport.ox = MiniMap::OFFSET[0]
    end

    if $minimap_high_viewport.oy <= MiniMap::OFFSET[1]
      $minimap_high_viewport.oy = MiniMap::OFFSET[1]
    end

    if $minimap_high_viewport.ox >= MiniMap::OFFSET[0] + MiniMap::W - @ratio_w * 2
      $minimap_high_viewport.ox = MiniMap::OFFSET[0] + MiniMap::W - @ratio_w * 2
    end

    if $minimap_high_viewport.oy >= MiniMap::OFFSET[1] + MiniMap::H
      $minimap_high_viewport.oy = MiniMap::OFFSET[1] + MiniMap::H
    end

  end
  #--------------------------------------------------------------------------
  # * 메모리 해제
  #--------------------------------------------------------------------------
  def dispose
    @background.bitmap.dispose
    @background.dispose
    @char.bitmap.dispose
    @char.dispose
    dispose_character
  end
  #--------------------------------------------------------------------------
  # * 메모리가 해제된 상태인가?
  #--------------------------------------------------------------------------
  def disposed?
    return true if @background.disposed?
    return false
  end
  #--------------------------------------------------------------------------
  # * 통행 가능 지역 메모리 해제
  #--------------------------------------------------------------------------
  def dispose_rect
    dispose_viewrect if @viewrect[0]
  end
  #--------------------------------------------------------------------------
  # * 맵의 속성 읽기
  #--------------------------------------------------------------------------
  def read_map
    @width = $game_map.width > (MiniMap::W)? (MiniMap::W) : $game_map.width
    @height =$game_map.height > (MiniMap::H)? (MiniMap::H) : $game_map.height
    @ratio_w = (MiniMap::W / @width).to_i * $game_system.view_scale_x
    @ratio_h = (MiniMap::H / @height).to_i * $game_system.view_scale_y
  end
end

#==============================================================================
# ** Mapster
#------------------------------------------------------------------------------
# 미니맵 관리자를 생성하고 관리합니다
#==============================================================================
class Mapster
  #--------------------------------------------------------------------------
  # * 통행 가능 지역 생성
  #--------------------------------------------------------------------------
  def create_viewrect
    @minimap.create_viewrect
  end
  #--------------------------------------------------------------------------
  # * 미니맵 관리자를 생성합니다
  #--------------------------------------------------------------------------
  def create_minimap
    @minimap = MiniMap_Manager.new
  end
  #--------------------------------------------------------------------------
  # * 뷰포트 생성
  #--------------------------------------------------------------------------
  def create_viewports
    $minimap_lower_view = Viewport.new
    $minimap_lower_view.z = 151
    $minimap_lower_view.visible = $game_map.minimap_visible

    $minimap_high_viewport = Viewport.new(MiniMap::OFFSET[0],MiniMap::OFFSET[1],
    MiniMap::W.to_i,MiniMap::H.to_i)
    $minimap_high_viewport.ox = MiniMap::OFFSET[0]
    $minimap_high_viewport.oy = MiniMap::OFFSET[1]
    $minimap_high_viewport.z = 152
    $minimap_high_viewport.visible = $game_map.minimap_visible
  end
  #--------------------------------------------------------------------------
  # * 뷰포트 업데이트
  #--------------------------------------------------------------------------
  def update_viewports
    $minimap_lower_view.update
    $minimap_high_viewport.update
  end
  #--------------------------------------------------------------------------
  # * 뷰포트 해방
  #--------------------------------------------------------------------------
  def dispose_viewports
    $minimap_lower_view.dispose
    $minimap_high_viewport.dispose
  end
  #--------------------------------------------------------------------------
  # * 리프레쉬
  #--------------------------------------------------------------------------
  def refresh
    dispose_minimap
    create_minimap
    create_viewrect
  end
  #--------------------------------------------------------------------------
  # * 영역을 새로 만들어줍니다
  #--------------------------------------------------------------------------
  def refresh_viewrect
    # 영역의 끝에 플레이어가 위치하지 않으면 영역을 새로 그리지 않습니다
    return unless rect_refresh?
    $minimap_high_viewport.flash(MiniMap::GRAY, MiniMap::FLASH_DURATION)
    @minimap.dispose_viewrect
    @minimap.create_viewrect
    $game_player.mstep = 0
  end
  #--------------------------------------------------------------------------
  # * 두 영역의 거리 차이를 계산하여 참/거짓을 반환합니다
  #--------------------------------------------------------------------------
  def rect_refresh?
    x,y = $game_player.x,$game_player.y
    n = MiniMap::STEP
    player = Rect.new(x-n,y-n,x+n,y+n)
    m = distance(player,@minimap.player_rect)
    return true if m[0] >= (n-1) or m[1] >= (n-1)
    return false
  end
  #--------------------------------------------------------------------------
  # * 두 영역의 거리 차이를 계산해줍니다
  #--------------------------------------------------------------------------
  def distance(r1,r2)
    mx = (r1.x - r2.x).abs
    my = (r1.y - r2.y).abs
    return [mx,my]
  end
  #--------------------------------------------------------------------------
  # * 특정 버튼으로 미니맵을 켜고 끕니다
  #--------------------------------------------------------------------------
  def minimap_visible_check
    if Input.trigger?(MiniMap::KEY) && $game_map.map_name?
      $game_map.minimap_visible = !$game_map.minimap_visible
      $minimap_high_viewport.visible = $game_map.minimap_visible
      $minimap_lower_view.visible = $game_map.minimap_visible
      unless @minimap.disposed?
        create_minimap
        create_viewrect
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 미니맵 업데이트
  #--------------------------------------------------------------------------
  def update_minimap
    @minimap.update unless @minimap.nil?
    minimap_visible_check
    refresh_viewrect if $game_player.mstep >= MiniMap::STEP
  end
  #--------------------------------------------------------------------------
  # * 미니맵 해제
  #--------------------------------------------------------------------------
  def dispose_minimap
    @minimap.dispose unless @minimap.nil?
    @minimap.dispose_rect unless @minimap.nil?
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
# 맵에 미니맵의 구성 요소들을 그려줍니다
#==============================================================================
class Spriteset_Map
  alias sunny_minimap_initialize initialize
  alias sunny_minimap_refresh_characters refresh_characters
  alias sunny_minimap_update update
  alias sunny_minimap_dispose dispose
  #--------------------------------------------------------------------------
  # * 미니맵 생성
  #--------------------------------------------------------------------------
  def initialize
    @mapster = Mapster.new
    sunny_minimap_initialize
  end
  #--------------------------------------------------------------------------
  # * 미니맵 업데이트
  #--------------------------------------------------------------------------
  def update
    sunny_minimap_update
    @mapster.update_minimap
  end
  #--------------------------------------------------------------------------
  # * 미니맵 다시 그리기
  #--------------------------------------------------------------------------
  def refresh_characters
    sunny_minimap_refresh_characters
    @mapster.refresh
  end
  #--------------------------------------------------------------------------
  # * 미니맵 해제
  #--------------------------------------------------------------------------
  def dispose
    sunny_minimap_dispose
    @mapster.dispose_minimap
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
# 맵에 미니맵의 뷰포트를 선언합니다
#==============================================================================
class Spriteset_Map
  alias minimap_create_viewports create_viewports
  alias minimap_update_viewports update_viewports
  alias minimap_dispose_viewports dispose_viewports
  #--------------------------------------------------------------------------
  # * 뷰 포트 생성
  #--------------------------------------------------------------------------
  def create_viewports
    minimap_create_viewports
    @mapster.create_viewports
  end
  #--------------------------------------------------------------------------
  # * 뷰 포트 업데이트
  #--------------------------------------------------------------------------
  def update_viewports
    minimap_update_viewports
    @mapster.update_viewports
  end
  #--------------------------------------------------------------------------
  # * 뷰 포트 해제
  #--------------------------------------------------------------------------
  def dispose_viewports
    minimap_dispose_viewports
    @mapster.dispose_viewports
  end
end

#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
# 타일셋이 그려질 때 미니맵도 같이 그려줍니다
#==============================================================================
class Spriteset_Map
  alias minimap_load_tileset load_tileset
  #--------------------------------------------------------------------------
  # * 타일셋 로드
  #--------------------------------------------------------------------------
  def load_tileset
    minimap_load_tileset
    @mapster.create_minimap
    @mapster.create_viewrect
  end
end

#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
# 미니맵의 가시상태를 체크하는 변수에 접근을 할 수 있게 합니다
#==============================================================================
class Game_Map
  alias minimap_setup setup
  attr_accessor :minimap_visible
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def setup(map_id)
    minimap_setup(map_id)
    @minimap_visible = map_name?
  end
  #--------------------------------------------------------------------------
  # * 미니맵 사용 여부를 확인합니다
  #--------------------------------------------------------------------------
  def map_name?
    return true if ($data_mapinfos[@map_id].name =~ /^\[MAP\](.+$)/)
    return false
  end
  #--------------------------------------------------------------------------
  # * 켜고/끄기
  #--------------------------------------------------------------------------
  def minimap_visible=(var=map_name?)
    @minimap_visible = var
    $minimap_high_viewport.visible = @minimap_visible
    $minimap_lower_view.visible = @minimap_visible
  end
end

#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
# 미니맵 시야 확보를 위해 걸음 수를 체크해줍니다
#==============================================================================
class Game_Player
  alias minimap_increase_steps increase_steps
  alias minimap_initialize initialize
  attr_accessor :mstep
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize
    minimap_initialize
    @mstep = 0
  end
  #--------------------------------------------------------------------------
  # * 보행 수 증가
  #--------------------------------------------------------------------------
  def increase_steps
    minimap_increase_steps
    if @mstep.between?(0,MiniMap::STEP - 1)
      @mstep += 1
    end
  end
end
