#==============================================================================
# ** GIF_Controller
# Author : biud436
#==============================================================================
module GIF
  
  # GIF 파일이 저장된 위치
  BASE_FOLDER = "Graphics/Pictures/"  

  # GIF 구조체
  GIFC = Struct.new(:path, :x, :y, :visible)
  
end

class Spriteset_Map
  alias bmex_initialize initialize
  alias bmex_update update
  alias bmex_dispose dispose
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------    
  def initialize
    bmex_initialize
    @gif = GIF_Controller.new
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------    
  def update
    bmex_update
    @gif.update if @gif
  end
  #--------------------------------------------------------------------------
  # * 해방
  #--------------------------------------------------------------------------    
  def dispose
    bmex_dispose
    @gif.dispose if @gif
  end
end

class GIF_Controller
  include GIF
  #--------------------------------------------------------------------------
  # * 컨트롤러 초기화
  #--------------------------------------------------------------------------  
  def initialize
    @list = []
    create_list
  end
  #--------------------------------------------------------------------------
  # * GIF 파일 경로 취득
  #--------------------------------------------------------------------------    
  def gif_path(file_name)
    Dir.glob(File.join(BASE_FOLDER, file_name + ".gif")).join
  end
  #--------------------------------------------------------------------------
  # * GIF 리스트 취득
  #--------------------------------------------------------------------------    
  def gif_list
    temp = []
    $game_map.events.values.each do |event|
      event.list.each do |l| 
        next unless l.code == 108 || l.code == 408
        gif = GIFC.new
        gif.path = l.parameters[0].gsub!(/GIF\W*->\W*(.+)/i){ gif_path($1) }
        gif.x = event.screen_x
        gif.y = event.screen_y
        gif.visible = true
        temp << gif
      end 
    end
    return temp
  end
  #--------------------------------------------------------------------------
  # * 리스트 생성 및 좌표 설정
  #--------------------------------------------------------------------------    
  def create_list(wait_time = 2)
    gif_list.each do |gif|
      pic = GifSprite.new(gif.path, wait_time)
      file_name = File.basename(gif.path,".gif")
      pic.x = gif.x - (pic.width / 2)
      pic.y = gif.y - (pic.height / 2)
      pic.visible = gif.visible
      @list << pic
    end
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------    
  def update
    @list.each { |pic| pic.update if pic } if @list
  end
  #--------------------------------------------------------------------------
  # * 해방
  #--------------------------------------------------------------------------    
  def dispose
    @list.each {|pic| pic.dispose if pic} if @list
  end
end
