#==============================================================================
# ** Simple Save Loader
# Author : biud436
# Date : 2015.04.08
# Version : 1.0
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_SimpleSaveLoader"] = true

=begin
Code by : 러닝은빛(biud436)
Version : 1.1 (2015.04.08)
=end
 
module View
    Image = {:LOAD => "Book",:SAVE => "Gates",}
  end
   
  module DataManager
    def self.savefile_max
      return 3
    end
    def self.make_save_header
      header = {}
      header[:characters] = $game_party.characters_for_savefile
      header[:playtime_s] = $game_system.playtime_s
      header[:map_name] = $data_mapinfos[$game_map.map_id].name
      header
    end  
  end
   
  class Window_SaveFile < Window_Base
    def initialize(height, index)
      super(0, index * height, Graphics.width-200, height)
      self.y -= 70
      @file_index = index
      window_setting
      refresh
      @selected = false
    end
    def window_setting
      self.x = 100
      self.padding = 12
      self.padding_bottom = 0
      self.opacity = 0
      self.back_opacity = 0
      self.contents_opacity = 255
    end
    def refresh
      contents.clear
      change_color(normal_color)
      name = Vocab::File + " #{@file_index + 1}"
      draw_text(4, 0, 200, line_height, name)
      @name_width = text_size(name).width
      draw_party_characters(52, 58)
      draw_playtime(0, contents.height - line_height, contents.width - 4, 2)
      draw_mapname(0, contents.height - line_height, contents.width - 4, 2)
    end
    def draw_mapname(x,y,width,align)
      header = DataManager.load_header(@file_index)
      return unless header
      draw_text(x, y - 24, width, line_height,header[:map_name],align)
    end
  end
   
  class Scene_File < Scene_MenuBase
    alias sp_create_savefile_viewport create_savefile_viewport
    def create_savefile_viewport
      sp_create_savefile_viewport
      @savefile_viewport.z = 3
      @help_window.opacity = 0
      @help_window.contents_opacity = 0
    end
  end 
  
  module InitSprite
    def sprite_create(type)
      @sprite = Sprite.new
      @sprite.z = 2
      @sprite.bitmap = Cache.title1(View::Image[type])
    end
    def sprite_dispose
      @sprite.bitmap.dispose
      @sprite.dispose
    end  
  end
  
  class Scene_Load < Scene_File
    include InitSprite
    def start; super; sprite_create(:LOAD) end
    def terminate; super; sprite_dispose end
  end
   
  class Scene_Save < Scene_File
    include InitSprite
    def start; super; sprite_create(:SAVE) end
    def terminate; super; sprite_dispose end
  end