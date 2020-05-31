#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# ** TitleManagerEx (RPG Maker VX)
#==============================================================================
# Name    : TitleManagerEx
# Desc    : This script allows you to set up various title image to title screen
# Author  : biud436
# Usage   :
# In a script calls, you can be used as below codes.
# The parameters are the name of an ending within a game and its name can set
# in Tool module.
#
# EndingManager.ending_setup("ENDING2")
#
#==============================================================================
# ** Tool
#------------------------------------------------------------------------------
# This module sets up graphics resources to import within a title screen.
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_TitleManagerEx"] = true

module Tool

  # Import the game data from Data/System.rxdata file
  SYS = load_data("Data/System.rvdata")

  # Sets the name of the menu commands for a title screen.
  MENU = [
  "새로운 게임",  # New Game
  "계속 하기",    # Continue
  "게임 종료"     # Shutdown
  ]

  # Sets the image and BGM for title screen and notice that you must set the
  # actual name of the resouce file.
  RESOURCE = {
  "DEFAULT" => ["Title",SYS.title_bgm], # Default Title Resource
  "ENDING1" => ["Title","Scene1"],
  "ENDING2" => ["Title","Scene2"],
  "ENDING3" => ["Title","Scene3"]
  }

end

#==============================================================================
# **  EndingManager
#------------------------------------------------------------------------------
# All values save as a file called 'temp.dat'
#==============================================================================
module EndingManager
  def self.ending_setup(string)
    begin
			save_data(publish_key(string), "temp.dat") 
    rescue
      return false
    end
  end
  def self.load_background
    begin
			f = load_data("temp.dat")
			f
    rescue
      ending_null
    end
  end
  def self.ending_null
    ending = {}
    ending[:version] = 0
    ending[:username] = "NULL"
    ending[:n] = Tool::RESOURCE["DEFAULT"]
    ending
  end
  def self.publish_key(string)
    begin
      ending = {}
      ending[:version] = 1000
      ending[:username] = ENV["USERNAME"]
      ending[:n] = Tool::RESOURCE[string]
      ending
    rescue
      ending_null
    end
  end
end

#==============================================================================
# ** Header
#------------------------------------------------------------------------------
# 엔딩값을 외부파일에서 불러옵니다
#==============================================================================
module Header
  @@background = nil
  def self.load
    f = EndingManager.load_background
    return [f[:version],f[:username],f[:n]]
  end
  def self.choose_background?
    if [load[0],load[1]] == [1000,ENV["USERNAME"]]
      load_background(load[2])
      return true
    else
      @@background = Tool::RESOURCE["DEFAULT"]
      return false
    end
  end
  def self.load_background(set)
    @@background = set
  end
  def self.export_background
    return @@background
  end
end

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
# This scripts creates all objects for the title screen
#==============================================================================
class Scene_Title
  def create_command_window
    @command_window = Window_Command.new(172, Tool::MENU)
    @command_window.x = (544 - @command_window.width) / 2
    @command_window.y = 288
    if @continue_enabled                    # If continue is enabled
      @command_window.index = 1             # Move cursor over command
    else                                    # If disabled
      @command_window.draw_item(1, false)   # Make command semi-transparent
    end
    @command_window.openness = 0
    @command_window.open		
				
  end
  def create_title_graphic
    @sprite = Sprite.new
    if Header.choose_background?
      @sprite.bitmap = Cache.system(Header.export_background[0])
    else
      @sprite.bitmap = Cache.system(Header.export_background[0])
    end
  end
  def play_title_music
    if Header.choose_background?
      $data_system.title_bgm.name = Header.export_background[1]
    end
    $data_system.title_bgm.play
    RPG::BGS.stop
    RPG::ME.stop
  end
end
