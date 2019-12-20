=begin
Name : 눈보라 효과가 적용된 타이틀 메뉴 / RS_CustomTitleScene.rb
Author : biud436
First Release Date : 2014. 06. 27
Version Log : 
  2019.12.20 (v1.1.0) : 
    - 리팩토링 및 이미지 수정
=end

$imported = {} if $imported.nil?
$imported["RS_CustomTitleScene.rb"] = true

module RS
  module CustomTitle
    
    # Graphics/Pictures
    IMAGE = {
      :BASE => "base_1",
      :START => "base_2",
      :CONTINUE => "base_3", 
      :SHUTDOWN => "base_4",
    }
  
    Z = {
      :VIEWPORT => 1000,
      :ICON => 156,
      :MENU_BACKGROUND => 154,
      :MENU_COMMAND_SPRITE => 155,
    }

    # 타이틀 커맨드의 위치
    # :LEFT, :CENTER, :RIGHT 중 하나
    DEFAULT_ALIGN = :LEFT

    # 아이콘
    ICON_INDEX = 272

  end
end

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  타이틀을 만드는 스크립트입니다
#==============================================================================
class Scene_Title < Scene_Base

  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------  
  alias rs_custom_title_scene_start start    
  def start
    rs_custom_title_scene_start
    init_members      
    create_icon_sprite
    create_weather_viewport
    create_weather
  end
  #--------------------------------------------------------------------------
  # * 아이콘 흔들기를 위한 변수를 선언해줍니다
  #--------------------------------------------------------------------------    
  def init_members
    @time = 0
  end
  #--------------------------------------------------------------------------
  # * 날씨 효과를 그려줄 뷰포트를 선언합니다
  #--------------------------------------------------------------------------
  def create_weather_viewport
    @weather_viewport = Viewport.new
    @weather_viewport.z = RS::CustomTitle::Z[:VIEWPORT]
  end
  #--------------------------------------------------------------------------    
  # * 날씨 효과를 만들어줍니다    
  #--------------------------------------------------------------------------    
  def create_weather
    @weather = Spriteset_Weather.new(@weather_viewport)      
  end

  def dispose_icon
    # 스프라이트 아이콘를 해제합니다
    @icon.bitmap.dispose
    @icon.dispose      
  end

  def dispose_menu_command_sprite
    # 스프라이트 메뉴를 해제합니다
    @menu_command_sprite.bitmap.dispose
    @menu_command_sprite.dispose      
  end

  def dispose_menu_background
    # 메뉴 뒷부분을 장식한 검정색 스프라이트를 해제합니다
    @menu_background.bitmap.dispose
    @menu_background.dispose      
  end

  def dispose_weather
    # 날씨 효과을 해제합니다
    @weather.dispose      
  end

  def dispose_viewport
    # 뷰포트를 해제합니다
    @weather_viewport.dispose      
  end

  #--------------------------------------------------------------------------
  # * 파괴
  #--------------------------------------------------------------------------  
  alias rs_custom_title_scene_terminate terminate    
  def terminate
    rs_custom_title_scene_terminate
    dispose_icon
    dispose_menu_command_sprite
    dispose_menu_background
    dispose_weather
    dispose_viewport
  end

  #--------------------------------------------------------------------------
  # * 아이콘 만들기
  #--------------------------------------------------------------------------    
  def create_icon_sprite
    
    @icon = Sprite.new
    @icon.z = RS::CustomTitle::Z[:ICON]
    @icon.visible = false
    @icon.bitmap = Bitmap.new(24, 24)
    
    bitmap = Cache.system("Iconset")
    
    idx = RS::CustomTitle::ICON_INDEX
    rect = Rect.new(idx % 16 * 24, idx / 16 * 24, 24, 24)
    
    @icon.bitmap.blt(0, 0, bitmap, rect)
  end
  #--------------------------------------------------------------------------
  # * 스프라이트 메뉴 만들기
  #--------------------------------------------------------------------------    
  def create_sprite_menu
    
    menu_command_bitmap = Cache.picture(RS::CustomTitle::IMAGE[:BASE])
    menu_command_bitmap_width = menu_command_bitmap.width
    menu_command_bitmap_height = menu_command_bitmap.height
    black2 = Color.new(0, 0, 25, 64)
    black1 = Color.new(0, 0, 0, 0)    
    base_tone = Tone.new(-10, 100, 20)
    rect = Rect.new(0, 0, menu_command_bitmap_width, menu_command_bitmap_height)
    
    # 검은색 바탕 부분을 그려줍니다
    @menu_background = Sprite.new
    @menu_background.bitmap = Bitmap.new(menu_command_bitmap_width, menu_command_bitmap_height)
    @menu_background.bitmap.gradient_fill_rect(rect, black2, black1)
    @menu_background.bitmap.blur
    @menu_background.x = @command_window.x
    @menu_background.y = @command_window.y
    @menu_background.z = RS::CustomTitle::Z[:MENU_BACKGROUND]
    
    # 타이틀 메뉴를 그려줍니다
    @menu_command_sprite = Sprite.new
    @menu_command_sprite.bitmap = menu_command_bitmap
    @menu_command_sprite.x = @command_window.x
    @menu_command_sprite.y = @command_window.y
    @menu_command_sprite.z = RS::CustomTitle::Z[:MENU_COMMAND_SPRITE]
    
    # 타이틀 메뉴의 톤을 바꿔줄 수 있습니다
    @menu_command_sprite.tone = base_tone
    
  end
  #--------------------------------------------------------------------------
  # * 아이콘 위치 지정
  #--------------------------------------------------------------------------  
  def set_icon(x,y)
    return if !@icon
    bitmap = @icon.bitmap
    @icon.x = (bitmap.width / 2) + x - 15
    @icon.y = (bitmap.height / 2) + y
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------    
  def update
    super
    
    # 커서의 움직임이 감지되면 그림을 변경합니다
    change_sprite if !@command_window.nil? and @command_window.cursor_movable?
    
    weather_update
    
    # 플레이타임을 2로 나눈 나머지 값으로 0과 1로 분기됩니다
    @time = (Graphics.frame_count / Graphics.frame_rate) % 2
  end
  #--------------------------------------------------------------------------
  # * 눈보라 생성
  #--------------------------------------------------------------------------     
  def weather_update
    @weather.type = :snow
    @weather.power = 3
    @weather.ox = $game_map.display_x * 32
    @weather.oy = $game_map.display_y * 32
    @weather.update
  end
  #--------------------------------------------------------------------------
  # * 그림 변경 하기
  #--------------------------------------------------------------------------    
  def change_sprite
    
    @icon.visible = true
    
    @menu_command_sprite.bitmap = case @command_window.index
    when 0
      Cache.picture(RS::CustomTitle::IMAGE[:START])
    when 1
      Cache.picture(RS::CustomTitle::IMAGE[:CONTINUE])
    when 2
      Cache.picture(RS::CustomTitle::IMAGE[:SHUTDOWN])
    end
    
    # 매 프레임마다 0과 4로 분기되는 값입니다
    @temp_x = @time * 4
    
    set_icon(
      @command_window.x + @temp_x,
      @command_window.y + @command_window.index * @command_window.line_height
    )
    
  end
  #--------------------------------------------------------------------------
  # * 윈도우 기본 생성
  #--------------------------------------------------------------------------    
  def create_command_window
    
    menu_command_bitmap = Cache.picture(RS::CustomTitle::IMAGE[:BASE])
    line_height = (menu_command_bitmap.height / 3).floor
    
    @command_window = RS::Window_TitleCommand.new(line_height)
    @command_window.set_handler(:new_game, method(:command_new_game))
    @command_window.set_handler(:continue, method(:command_continue))
    @command_window.set_handler(:shutdown, method(:command_shutdown))
    
    create_sprite_menu
    
  end
end

class RS::Window_TitleCommand < Window_TitleCommand
  alias old_initialize initialize
  def initialize(value)  
    old_initialize
    @remain_line_height = value
    @remain_window_width = 160     
    self.opacity = 0
    self.padding = 0
    self.contents_opacity = 0
    self.arrows_visible = false
  end    
  def set_line_height(value)
    @remain_line_height = value
  end
  def update_placement
    case RS::CustomTitle::DEFAULT_ALIGN
    when :RIGHT
      self.x = (Graphics.width - width) - 20
    when :LEFT
      self.x = 20
    else
      self.x = (Graphics.width - width) / 2 
    end
    self.y = (Graphics.height * 1.3 - height) / 2
  end    
  def window_width
    return @remain_window_width || 160
  end
  def line_height
    return @remain_line_height || 45
  end 
end