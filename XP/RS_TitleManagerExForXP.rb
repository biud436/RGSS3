#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# ** TitleManagerEx (RPG Maker XP)
#==============================================================================
# Name    : TitleManagerEx
# Desc    : This script allows you to set up various title image to title screen
# Author  : biud436
# Usage   :
# In a script calls, you can be used as below codes.
# The parameters are the name of an ending within a game and its name can set
# in Tool module.
#
# EndingManager.ending_setup("ENDING1")
# EndingManager.ending_setup("ENDING2")
# EndingManager.ending_setup("ENDING3")
#
# Version Log :
# 2016.07.27 (v1.0.0) - First Release.
# 2019.03.23 (v1.0.1) - Fixed the issue that can not start the game in the battle test mode.
#
#==============================================================================
# ** Tool
#------------------------------------------------------------------------------
# This module sets up graphics resources to import within a title screen.
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_TitleManagerExForXP"] = true

module Tool

  # Import the game data from Data/System.rxdata file
  SYS = load_data("Data/System.rxdata")

  # Sets the name of the menu commands for a title screen.
  MENU = [
  "새로운 게임",  # New Game
  "계속 하기",    # Continue
  "게임 종료"     # Shutdown
  ]

  # Sets the image and BGM for title screen and notice that you must set the
  # actual name of the resouce file.
  RESOURCE = {
  "DEFAULT" => [SYS.title_name,SYS.title_bgm], # Default Title Resource
  "ENDING1" => ["001-Title01","061-Slow04"],
  "ENDING2" => ["002-Title02","063-Slow06"],
  "ENDING3" => ["003-Title03","062-Slow05"]
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
      File.open("temp.dat","wb") do |file|
        Marshal.dump(publish_key(string),file)
      end
    rescue
      return false
    end
  end
  def self.load_background
    begin
      File.open("temp.dat","rb") do |file|
        Marshal.load(file)
      end
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
# Load the ending settings from 'temp.dat' file.
#==============================================================================
module Header
  @@background = nil
  def self.load
    f = EndingManager.load_background
    return f[:version],f[:username],f[:n]
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
  def main
    if $BTEST
      battle_test
      return
    end    
    pre_title
    update_title
    dispose_title
  end
  def load_database
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    $data_weapons       = load_data("Data/Weapons.rxdata")
    $data_armors        = load_data("Data/Armors.rxdata")
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
  end
  def create_command_window
    @command_window = Window_Command.new(192, Tool::MENU)
    @command_window.back_opacity = 160
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
  end
  def continue_enabled?
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
  end
  def create_background
    @sprite = Sprite.new
    if Header.choose_background?
      @sprite.bitmap = RPG::Cache.title(Header.export_background[0])
    else
      @sprite.bitmap = RPG::Cache.title(Header.export_background[0])
    end
  end
  def play_title_bgm
    if Header.choose_background?
      $data_system.title_bgm.name = Header.export_background[1]
    end
    $game_system.bgm_play($data_system.title_bgm)
  end
  def pre_title
    load_database
    $game_system = Game_System.new
    create_background
    create_command_window
    continue_enabled?
    play_title_bgm
    Audio.me_stop
    Audio.bgs_stop
    Graphics.transition
  end
  def update_title
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
  end
  def dispose_title
    Graphics.freeze
    @command_window.dispose
    @sprite.bitmap.dispose
    @sprite.dispose
  end
end
