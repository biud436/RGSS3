#==============================================================================#
# Name : RS_CustomTitleVX
# Description : This script allows you to change a title command window.
# Author : biud436
# Version : 
# 2009.01.12 (v1.0.0) - First Release.
#================================================================================
class Scene_Title < Scene_Base
    #--------------------------------------------------------------------------
    # ● 메인 처리
    #--------------------------------------------------------------------------
    def main
      if $BTEST                         # 전투 테스트의 경우
        battle_test                     # 전투 테스트의 개시 처리
      else                              # 통상의 플레이의 경우
        super                           # 본래의 메인 처리
      end
    end
    #--------------------------------------------------------------------------
    # ● 개시 처리
    #--------------------------------------------------------------------------
    def start
      super
      load_database                     # 데이타 베이스를 로드
      create_game_objects               # 게임 오브젝트를 작성
      check_continue                    # '이어서 하기' 유효 판정
      create_title_graphic              # 타이틀 그래픽을 작성
      create_command_window
      play_title_music                  # 타이틀 화면의 음악을 연주
    end
    #--------------------------------------------------------------------------
    # ● 트란지션 실행
    #--------------------------------------------------------------------------
    def perform_transition
      Graphics.transition(20)
    end
    #--------------------------------------------------------------------------
    # ● 프레임 갱신
    #--------------------------------------------------------------------------
    def update
      super
     @op1.update
     @op2.update
     @op3.update
    @command_window.update
    if @op1.opacity < 255 and @op2.opacity < 255 and @op3.opacity < 255
      @op1.opacity += 1
      @op2.opacity += 1
      @op3.opacity += 1
    end
      if Input.trigger?(Input::DOWN) and @contardor == 0
       Sound.play_cursor
       @contardor = 1
       @op1.tone = Tone.new(0,0,0,255)
       @op2.tone = Tone.new(0,0,0,0)
       @op3.tone = Tone.new(0,0,0,255)
      elsif Input.trigger?(Input::UP) and @contardor == 0
       Sound.play_cursor
       @contardor = 2
       @op1.tone = Tone.new(0,0,0,255)
       @op2.tone = Tone.new(0,0,0,255)
       @op3.tone = Tone.new(0,0,0,0)
     elsif Input.trigger?(Input::UP) and @contardor == 1
       Sound.play_cursor
       @contardor = 0
       @op1.tone = Tone.new(0,0,0,0)
       @op2.tone = Tone.new(0,0,0,255)
       @op3.tone = Tone.new(0,0,0,255)
       elsif Input.trigger?(Input::DOWN) and @contardor == 1
       Sound.play_cursor
       @contardor = 2
       @op1.tone = Tone.new(0,0,0,255)
       @op2.tone = Tone.new(0,0,0,255)
       @op3.tone = Tone.new(0,0,0,0)
       elsif Input.trigger?(Input::UP) and @contardor == 2
       Sound.play_cursor
       @contardor = 1
       @op1.tone = Tone.new(0,0,0,255)
       @op2.tone = Tone.new(0,0,0,0)
       @op3.tone = Tone.new(0,0,0,255)
       elsif Input.trigger?(Input::DOWN) and @contardor == 2
       Sound.play_cursor
       @contardor = 0
       @op1.tone = Tone.new(0,0,0,0)
       @op2.tone = Tone.new(0,0,0,255)
       @op3.tone = Tone.new(0,0,0,255)
     end
         
  
      if Input.trigger?(Input::C)
        
        case @contardor
        when 0    # 게임 시작
          command_new_game
        when 1    # 게임 로드
          command_continue
        when 2    # 게임 종료
          command_shutdown
        end
      end
      
  
    end
    
    def terminate
      @op1.dispose
      @op2.dispose
      @op3.dispose
    end
    
    #--------------------------------------------------------------------------
    # ● 데이타베이스의 로드
    #--------------------------------------------------------------------------
    def load_database
      $data_actors        = load_data("Data/Actors.rvdata")
      $data_classes       = load_data("Data/Classes.rvdata")
      $data_skills        = load_data("Data/Skills.rvdata")
      $data_items         = load_data("Data/Items.rvdata")
      $data_weapons       = load_data("Data/Weapons.rvdata")
      $data_armors        = load_data("Data/Armors.rvdata")
      $data_enemies       = load_data("Data/Enemies.rvdata")
      $data_troops        = load_data("Data/Troops.rvdata")
      $data_states        = load_data("Data/States.rvdata")
      $data_animations    = load_data("Data/Animations.rvdata")
      $data_common_events = load_data("Data/CommonEvents.rvdata")
      $data_system        = load_data("Data/System.rvdata")
      $data_areas         = load_data("Data/Areas.rvdata")
    end
    #--------------------------------------------------------------------------
    # ● 전투 테스트용 데이타베이스의 로드
    #--------------------------------------------------------------------------
    def load_bt_database
      $data_actors        = load_data("Data/BT_Actors.rvdata")
      $data_classes       = load_data("Data/BT_Classes.rvdata")
      $data_skills        = load_data("Data/BT_Skills.rvdata")
      $data_items         = load_data("Data/BT_Items.rvdata")
      $data_weapons       = load_data("Data/BT_Weapons.rvdata")
      $data_armors        = load_data("Data/BT_Armors.rvdata")
      $data_enemies       = load_data("Data/BT_Enemies.rvdata")
      $data_troops        = load_data("Data/BT_Troops.rvdata")
      $data_states        = load_data("Data/BT_States.rvdata")
      $data_animations    = load_data("Data/BT_Animations.rvdata")
      $data_common_events = load_data("Data/BT_CommonEvents.rvdata")
      $data_system        = load_data("Data/BT_System.rvdata")
    end
    #--------------------------------------------------------------------------
    # ● 각종 게임 오브젝트의 작성
    #--------------------------------------------------------------------------
    def create_game_objects
      $game_temp          = Game_Temp.new
      $game_message       = Game_Message.new
      $game_system        = Game_System.new
      $game_switches      = Game_Switches.new
      $game_variables     = Game_Variables.new
      $game_self_switches = Game_SelfSwitches.new
      $game_actors        = Game_Actors.new
      $game_party         = Game_Party.new
      $game_troop         = Game_Troop.new
      $game_map           = Game_Map.new
      $game_player        = Game_Player.new
    end
    #--------------------------------------------------------------------------
    # ● 이어서 하기 유효 판정
    #--------------------------------------------------------------------------
    def check_continue
      @continue_enabled = (Dir.glob('Save*.rvdata').size > 0)
    end
    #--------------------------------------------------------------------------
    # ● 타이틀 그래픽의 작성
    #--------------------------------------------------------------------------
    def create_title_graphic
      @sprite = Sprite.new
      @sprite.bitmap = Cache.system("Title")
    end
    #--------------------------------------------------------------------------
    # ● 타이틀 그래픽의 해방
    #--------------------------------------------------------------------------
    def dispose_title_graphic
      @sprite.bitmap.dispose
      @sprite.dispose
    end
     #--------------------------------------------------------------------------
    # ● 커멘드 윈도우의 작성
    #--------------------------------------------------------------------------
    def create_command_window
      s1 = Vocab::new_game
      s2 = Vocab::continue
      s3 = Vocab::shutdown
      create_menu_background 
      @op1 = Sprite.new
      @op2 = Sprite.new
      @op3 = Sprite.new
      @op1.bitmap = Cache.picture("game_start")
      @op2.bitmap = Cache.picture("game_load")
      @op3.bitmap = Cache.picture("game_exit")
      @op1.z = 1
      @op2.z = 1
      @op3.z = 1
      @op1.x = (544 - @op1.width) / 2
      @op1.y = (416 - @op1.height) / 2
      @op2.x = (544 - @op2.width) / 2
      @op2.y = @op1.y + @op2.height
      @op2.tone = Tone.new(0,0,0,255)
      @op3.x = (544 - @op3.width) / 2
      @op3.y = @op2.y + @op3.height
      @op3.tone = Tone.new(0,0,0,255)
      @contardor = 0
      @op1.opacity = 0
      @op2.opacity = 0
      @op3.opacity = 0
      #fine==
      
      @command_window = Window_Command.new(@op1.width, [s1,s2,s3])
      @command_window.x =  (544- @op1.x)/3
      @command_window.y =  @op1.y
      @command_window.height = (416-@op1.height/3)
      @command_window.contents_opacity = 0
      @command_window.opacity = 0
        if @continue_enabled                  
        @command_window.index = 1             
      else                               
        @command_window.draw_item(1, false)   
      end
  
      @command_window.open
    end
    #--------------------------------------------------------------------------
    # ● 커멘드 윈도우의 해방
    #--------------------------------------------------------------------------
    def dispose_command_window
      @command_window.dispose
    end
    #--------------------------------------------------------------------------
    # ● 커멘드 윈도우를 연다
    #--------------------------------------------------------------------------
    def open_command_window
      @command_window.open
      begin
        @command_window.update
        Graphics.update
      end until @command_window.openness == 0
    end
    #--------------------------------------------------------------------------
    # ● 커멘드 윈도우를 닫는다
    #--------------------------------------------------------------------------
    def close_command_window
      @command_window.close
      begin
        @command_window.update
        Graphics.update
      end until @command_window.openness == 0
    end
   #--------------------------------------------------------------------------
    # ● 타이틀 화면의 음악 연주
    #--------------------------------------------------------------------------
    def play_title_music
      $data_system.title_bgm.play
      RPG::BGS.stop
      RPG::ME.stop
    end
    #--------------------------------------------------------------------------
    # ● 플레이어의 초기 위치 존재 체크
    #--------------------------------------------------------------------------
    def confirm_player_location
      if $data_system.start_map_id == 0
        print "플레이어의 초기 위치가 설정되어 있지 않습니다."
        exit
      end
    end
    #--------------------------------------------------------------------------
    # ● 커멘드 : 처음부터 하기
    #--------------------------------------------------------------------------
    def command_new_game
      confirm_player_location
      Sound.play_decision
      $game_party.setup_starting_members            # 초기 파티
      $game_map.setup($data_system.start_map_id)    # 초기 위치의 맵
      $game_player.moveto($data_system.start_x, $data_system.start_y)
      $game_player.refresh
       close_command_window
      $scene = Scene_Map.new
      RPG::BGM.fade(1500)
      Graphics.fadeout(60)
      Graphics.wait(40)
      Graphics.frame_count = 0
      RPG::BGM.stop
      $game_map.autoplay
    end
    #--------------------------------------------------------------------------
    # ● 커멘드 : 이어서 하기
    #--------------------------------------------------------------------------
    def command_continue
      if @continue_enabled
        Sound.play_decision
        $scene = Scene_File.new(false, true, false)
      else
        Sound.play_buzzer
      end
    end
    #--------------------------------------------------------------------------
    # ● 커멘드 : 프로그램 종료
    #--------------------------------------------------------------------------
    def command_shutdown
      Sound.play_decision
      RPG::BGM.fade(800)
      RPG::BGS.fade(800)
      RPG::ME.fade(800)
      $scene = nil
    end
    #--------------------------------------------------------------------------
    # ● 전투 테스트
    #--------------------------------------------------------------------------
    def battle_test
      load_bt_database                  # 전투 테스트용 데이타 베이스를 로드
      create_game_objects               # 게임 오브젝트를 작성
      Graphics.frame_count = 0          # 플레이 시간을 초기화
      $game_party.setup_battle_test_members
      $game_troop.setup($data_system.test_troop_id)
      $game_troop.can_escape = true
      $game_system.battle_bgm.play
      snapshot_for_background
      $scene = Scene_Battle.new
    end
  end
  