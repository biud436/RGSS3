#==============================================================================
# ** GIF_Controller
# Author : biud436
# Date : 2015.10.12
# Version : 1.0b
#==============================================================================
module GIF
  
  # GIF ������ ����� ��ġ
  BASE_FOLDER = "Graphics/Pictures/"  

  # GIF ����ü
  GIFC = Struct.new(:path, :event, :visible)
  
end

class Spriteset_Map
  alias bmex_initialize initialize
  alias bmex_update update
  alias bmex_dispose dispose
  #--------------------------------------------------------------------------
  # * �ʱ�ȭ
  #--------------------------------------------------------------------------    
  def initialize
    bmex_initialize
    @gif = GIF_Controller.new
  end
  #--------------------------------------------------------------------------
  # * ������Ʈ
  #--------------------------------------------------------------------------    
  def update
    bmex_update
    @gif.update if @gif
  end
  #--------------------------------------------------------------------------
  # * �ع�
  #--------------------------------------------------------------------------    
  def dispose
    bmex_dispose
    @gif.dispose if @gif
  end
end

class GifSprite
  attr_accessor :position_update
  #--------------------------------------------------------------------------
  # * ��ġ ������Ʈ
  #--------------------------------------------------------------------------   
  alias alias_position_update update
  def update
    alias_position_update
    @position_update.call
  end
end

class GIF_Controller
  include GIF
  #--------------------------------------------------------------------------
  # * ��Ʈ�ѷ� �ʱ�ȭ
  #--------------------------------------------------------------------------  
  def initialize
    @list = []
    create_list
  end
  #--------------------------------------------------------------------------
  # * GIF ���� ��� ���
  #--------------------------------------------------------------------------    
  def gif_path(file_name)
    Dir.glob(File.join(BASE_FOLDER, file_name + ".gif")).join
  end
  #--------------------------------------------------------------------------
  # * GIF ����Ʈ ���
  #--------------------------------------------------------------------------    
  def gif_list
    temp = []
    $game_map.events.values.each do |event|
      event.list.each do |l| 
        next unless l.code == 108 || l.code == 408
        gif = GIFC.new
        gif.path = l.parameters[0].gsub!(/GIF\W*->\W*(.+)/i){ gif_path($1) }
        gif.event = event
        gif.visible = true
        temp << gif
      end 
    end
    return temp
  end
  #--------------------------------------------------------------------------
  # * ����Ʈ ���� �� ��ǥ ����
  #--------------------------------------------------------------------------    
  def create_list(wait_time = 2)
    gif_list.each do |gif|
      pic = GifSprite.new(gif.path, wait_time)
      file_name = File.basename(gif.path,".gif")
      pic.visible = gif.visible
      pic.position_update = ->() do
        pic.x = gif.event.screen_x - (pic.width / 2)
        pic.y = gif.event.screen_y - (pic.height / 2)
      end
      @list << pic
    end
  end
  #--------------------------------------------------------------------------
  # * ������Ʈ
  #--------------------------------------------------------------------------    
  def update
    @list.each { |pic| pic.update if pic } if @list
  end
  #--------------------------------------------------------------------------
  # * �ع�
  #--------------------------------------------------------------------------    
  def dispose
    @list.each {|pic| pic.dispose if pic} if @list
  end
end