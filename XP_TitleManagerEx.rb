#==============================================================================
# ** TitleManagerEx (RPG Maker XP)
#==============================================================================
# Name       : TitleManagerEx
# Author     : biud436
# Usage      :
# 다음 스크립트를 호출하세요.
# EndingManager.ending_setup("엔딩1")
# EndingManager.ending_setup("엔딩2")
# EndingManager.ending_setup("엔딩3")
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
# ** Tool
#------------------------------------------------------------------------------
# 타이틀에서 불러올 그래픽 파일들을 설정합니다
#==============================================================================
module Tool

  # 기본 데이터 로드
  SYS = load_data("Data/System.rxdata")

  # 타이틀 커맨드 텍스트 설정
  MENU = {
  :NEW => "새로운 게임",
  :LOAD => "계속 하기",
  :EXIT => "게임 종료"
  }

  # 타이틀 이미지 및 BGM 설정
  RESOURCE = {
  "기본타이틀" => [SYS.title_name,SYS.title_bgm],
  "엔딩1" => ["001-Title01","064-Slow07"],
  "엔딩2" => ["002-Title02","063-Slow06"],
  "엔딩3" => ["003-Title03","062-Slow05"]
  }

end

#==============================================================================
# **  EndingManager
#------------------------------------------------------------------------------
# 엔딩값을 temp.dat 파일로 저장합니다
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
    ending[:n] = Tool::RESOURCE["기본타이틀"]
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
    return f[:version],f[:username],f[:n]
  end
  def self.choose_background?
    if [load[0],load[1]] == [1000,ENV["USERNAME"]]
      load_background(load[2])
      return true
    else
      @@background = Tool::RESOURCE["기본타이틀"]
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
#  이 클래스는 타이틀 화면 처리를 수행합니다.
#==============================================================================
class Scene_Title
  def main
    pre_title
    update_title
    dispose_title
  end
  def battle_test
    if $BTEST
      battle_test
      return
    end
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
    @command_window = Window_Command.new(192, Tool::MENU.values)
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
    battle_test
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
