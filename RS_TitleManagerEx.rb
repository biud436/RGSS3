#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# ** TitleManagerEx (RPG Maker VX Ace)
#==============================================================================
# Name       : TitleManagerEx
# Author     : biud436
# Date       : 2015.09.07
# Version    : 1.0
# Usage      :
# In a script calls, you can be used as below codes. The parameters are the name
# of an ending within a game and its name can set in Tool module.
#
# DataManager.ending_setup("엔딩1")
# Version Log :
# 1.0.0 (2015.09.07) : First Release
# 1.0.1 (2021-11-04) : BGM 버그 수정
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
# ** Tool
#------------------------------------------------------------------------------
# This module sets up graphics resources to import within a title screen.
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_TitleManagerEx"] = true

module Tool

  # Import the game data from Data/System.rvdata2 file
  SYS = load_data("Data/System.rvdata2")
  RESOURCE = {

  # Sets the image and BGM for title screen and notice that you must set the
  # actual name of the resouce file.
  "기본타이틀" => [SYS.title1_name,SYS.title2_name,SYS.title_bgm], # Default Title Resource
  "엔딩1" => ["Book","","Theme1"],
  "엔딩2" => ["Castle","","Theme2"],
  "엔딩3" => ["CrossedSwords","","Theme3"],
  "엔딩4" => ["Dragon","Forest","Theme4"],
  #--------------------------------------------------------------------------
  }
end

#==============================================================================
# ** Position (Add-On)
#==============================================================================
module Position

  # 스페셜 맵의 ID
  MAP_ID = 2

  # 플레이어의 시작 X
  X = 6

  # 플레이어의 시작 Y
  Y = 11

  # 이동 좌표
  RESULT = [MAP_ID,X,Y]
end

#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
# 엔딩값을 temp.dat 파일로 저장합니다
#==============================================================================
module DataManager
  #--------------------------------------------------------------------------
  # * 엔딩을 설정합니다
  #--------------------------------------------------------------------------
  def self.ending_setup(string)
    begin
      File.open("temp.dat","wb") do |file|
        Marshal.dump(publish_key(string),file)
      end
    rescue
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * 파일을 로드합니다
  #--------------------------------------------------------------------------
  def self.load_background
    begin
      File.open("temp.dat","rb") do |file|
        Marshal.load(file)
      end
    rescue
      ending_null
    end
  end
  #--------------------------------------------------------------------------
  # * 엔딩키를 찾을 수 없을 때
  #--------------------------------------------------------------------------
  def self.ending_null
    ending = {}
    ending[:version] = 0
    ending[:username] = "NULL"
    ending[:n] = Tool::RESOURCE["기본타이틀"]
    ending
  end
  #--------------------------------------------------------------------------
  # * 엔딩키 발급(게임의 버전/사용자의 이름/리소스의 이름)
  #--------------------------------------------------------------------------
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
  #--------------------------------------------------------------------------
  # * 엔딩키값을 로드합니다
  #--------------------------------------------------------------------------
  def self.load
    f = DataManager.load_background
    return f[:version],f[:username],f[:n]
  end
  #--------------------------------------------------------------------------
  # * 배경화면 정보를 설정합니다
  #--------------------------------------------------------------------------
  def self.choose_background?
    if [load[0],load[1]] == [1000,ENV["USERNAME"]]
      load_background(load[2])
      return true
    else
      @@background = Tool::RESOURCE["기본타이틀"]
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * 배경화면을 불러옵니다
  #--------------------------------------------------------------------------
  def self.load_background(set)
    @@background = set
  end
  #--------------------------------------------------------------------------
  # * 배경화면을 배포합니다
  #--------------------------------------------------------------------------
  def self.export_background
    return @@background
  end
end

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
# create_background 메소드를 오버라이딩 합니다
#==============================================================================
class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # * 배경화면을 생성합니다
  #--------------------------------------------------------------------------
  def create_background
    @sprite1 = Sprite.new
    @sprite2 = Sprite.new
    choose_background
    center_sprite(@sprite1)
    center_sprite(@sprite2)
  end
  #--------------------------------------------------------------------------
  # * 배경화면을 선택합니다
  #--------------------------------------------------------------------------
  def choose_background
    if Header.choose_background?
      @sprite1.bitmap = Cache.title1(Header.export_background[0])
      @sprite2.bitmap = Cache.title2(Header.export_background[1])
    else
      # 엔딩키를 찾을 수 없으면 기본 배경화면을 생성합니다
      @sprite1.bitmap = Cache.title1(Header.export_background[0])
      @sprite2.bitmap = Cache.title2(Header.export_background[1])
    end
  end
  #--------------------------------------------------------------------------
  # * 배경음악을 변경합니다
  #--------------------------------------------------------------------------
  def play_title_music
    if Header.choose_background?
      $data_system.title_bgm.name = Header.export_background[2]
    end
    $data_system.title_bgm.play rescue nil
    RPG::BGS.stop
    RPG::ME.stop
  end
end

#==============================================================================
# ** Header (Add-On)
#==============================================================================
module Header
  def self.special_menu?
    [load[0],load[1]] == [1000,ENV["USERNAME"]]
  end
end

#==============================================================================
# ** DataManager (Add-On)
#==============================================================================
module DataManager
  def self.setup_special_game(*args)
    create_game_objects
    $game_party.setup_starting_members
    $game_map.setup(args[0])
    $game_player.moveto(args[1], args[2])
    $game_player.refresh
    Graphics.frame_count = 0
  end
end

#==============================================================================
# ** Window_TitleCommand (Add-On)
#==============================================================================
class Window_TitleCommand
  def alignment
    return 1
  end
  def make_command_list
    add_command(Vocab::new_game, :new_game)
    add_command(Vocab::continue, :continue, continue_enabled)
    add_command("스페셜 메뉴",:special_menu) if Header.special_menu?
    add_command(Vocab::shutdown, :shutdown)
  end
end

#==============================================================================
# ** Scene_Title (Add-On)
#==============================================================================
class Scene_Title
  alias thou_create_command_window create_command_window
  def create_command_window
    thou_create_command_window
    set_menu if Header.special_menu?
  end
  def set_menu
    @command_window.set_handler(:special_menu, method(:special_menu))
  end
  def special_menu
    DataManager.setup_special_game(*Position::RESULT)
    close_command_window
    fadeout_all
    $game_map.autoplay
    SceneManager.goto(Scene_Map)
  end
end