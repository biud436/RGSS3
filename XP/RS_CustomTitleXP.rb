#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# Name : RS_CustomTitleXP
# Author : biud436
# Version : 
# 2009.01.20 (v1.0.0) - First Release.
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # ● 메인 처리
  #--------------------------------------------------------------------------
  def main
    # 전투 테스트의 경우
    if $BTEST
      battle_test
      return
    end
    # 데이타베이스를 로드
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
    # 시스템 오브젝트를 작성
    $game_system = Game_System.new
    # 타이틀 그래픽을 작성
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.picture("back1")
    @op1 = Sprite.new
    @op2 = Sprite.new
    @op3 = Sprite.new
    @bak1 = Plane.new
    @bak2 = Plane.new #구름 흐르기
    @bak3 = Plane.new # 화면
    @bak1.bitmap = RPG::Cache.picture("Antares")
    @bak2.bitmap = RPG::Cache.picture("back1")
    @bak3.bitmap = RPG::Cache.picture("back2")
    @bak1.z = 2
    @bak2.z = 0
    @bak3.z = 1
    @bak1.opacity = 0
    @bak2.opacity = 20
    @bak1.tone=Tone.new(0,0,0,255)
    @bak1.ox=130
    @bak1.oy=0
    @bak2.ox= 0
    @bak2.oy= 0
    @bak3.ox= 0
    @bak3.oy= 0
    @bak1.zoom_x = 1
    @bak1.zoom_y = 1
    @op1.bitmap = RPG::Cache.picture("game_start")
    @op2.bitmap = RPG::Cache.picture("game_load")
    @op3.bitmap = RPG::Cache.picture("game_exit")
    @op1.x = (640-200)/2
    @op1.y = 250
    @op2.x = (640-200)/2
    @op2.y = @op1.y + 60
    @op2.tone = Tone.new(0,0,0,255)
    @op3.x = (640-200)/2
    @op3.y = @op2.y + 50
    @op3.tone = Tone.new(0,0,0,255)
    @op1.opacity = 0
    @op2.opacity = 0
    @op3.opacity = 0
    @op1.z=3
    @op2.z=3
    @op3.z=3
    @contardor = 0
    # 커멘드 윈도우를 작성
    s1 = "새로운 시작"
    s2 = "세이브 파일 불러오기"
    s3 = "게임 끝내기"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.back_opacity = 0
    @command_window.opacity = 0
    @command_window.contents_opacity = 0
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
   # 콘티 뉴 유효 판정
    # 세이브 파일이 하나에서도 존재할지를 조사한다
    # 유효하면 @continue_enabled 를 true, 무효라면 false 로 한다
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    # 콘티 뉴가 유효한 경우, 커서를 콘티 뉴에 맞춘다
    # 무효인 경우, 콘티 뉴의 문자를 그레이 표시로 한다
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
    # 타이틀 BGM 를 연주
    $game_system.bgm_play($data_system.title_bgm)
    # ME, BGS 의 연주를 정지
    Audio.me_stop
    Audio.bgs_stop
    # 트란지션 실행
    Graphics.transition
    # 메인 루프
    loop do
      # 게임 화면을 갱신
      Graphics.update
      # 입력 정보를 갱신
      Input.update
      # 프레임 갱신
      update
      # 화면이 바뀌면 루프를 중단
      if $scene != self
        break
      end
    end
    # 트란지션 준비
    Graphics.freeze
    # 커멘드 윈도우를 해방
    @command_window.dispose
    # 타이틀 그래픽을 해방
    @sprite.bitmap.dispose
    @sprite.dispose
    @op1.dispose
    @op2.dispose
    @op3.dispose
    @bak1.dispose
    @bak2.dispose
    @bak3.dispose
  end
  #--------------------------------------------------------------------------
  # ● 프레임 갱신
  #--------------------------------------------------------------------------
  def update
    @op1.update
    @op2.update
    @op3.update
    if @op1.opacity < 255 and @op2.opacity < 255 and @op3.opacity < 255 and @bak1.opacity
      @op1.opacity += 4
      @op2.opacity += 4
      @op3.opacity += 4
      @bak1.opacity += 30
      @bak2.opacity += 30
    end
    @bak1.tone = Tone.new(0,0,0,0)
    i = 0
    @bak2.ox += 1
    if @bak1.ox >= 5
    @bak1.ox -= 4
    @bak1.visible = true
  else
    Audio.se_stop 
    @bak1.ox = 0
  end
    @bak1.tone = Tone.new(0,0,0,0)
    if Input.trigger? (Input::DOWN) and @contardor == 0
      $game_system.se_play($data_system.cursor_se)
      @contardor = 1
      @op1.tone = Tone.new(0,0,0,255)
      @op2.tone = Tone.new(0,0,0,0)
      @op3.tone = Tone.new(0,0,0,255)
    elsif Input.trigger? (Input::UP) and @contardor == 0
      $game_system.se_play($data_system.cursor_se)
      @contardor = 2
      @op1.tone = Tone.new(0,0,0,255)
      @op2.tone = Tone.new(0,0,0,255)
      @op3.tone = Tone.new(0,0,0,0)
    elsif Input.trigger? (Input::UP) and @contardor == 1
      $game_system.se_play($data_system.cursor_se)
      @contardor = 0
      @op1.tone = Tone.new(0,0,0,0)
      @op2.tone = Tone.new(0,0,0,255)
      @op3.tone = Tone.new(0,0,0,255)
    elsif Input.trigger? (Input::DOWN) and @contardor == 1
      $game_system.se_play($data_system.cursor_se)
      @contardor = 2
      @op1.tone = Tone.new(0,0,0,255)
      @op2.tone = Tone.new(0,0,0,255)
      @op3.tone = Tone.new(0,0,0,0)
    elsif Input.trigger? (Input::UP) and @contardor == 2
      $game_system.se_play($data_system.cursor_se)
      @contardor = 1
      @op1.tone = Tone.new(0,0,0,255)
      @op2.tone = Tone.new(0,0,0,0)
      @op3.tone = Tone.new(0,0,0,255)
    elsif Input.trigger? (Input::DOWN) and @contardor == 2
      $game_system.se_play($data_system.cursor_se)
      @contardor = 0
      @op1.tone = Tone.new(0,0,0,0)
      @op2.tone = Tone.new(0,0,0,255)
      @op3.tone = Tone.new(0,0,0,255)
    end
    # 커멘드 윈도우를 갱신
    @command_window.update
    # C 버튼이 밀렸을 경우
    if Input.trigger?(Input::C)
      # 커멘드 윈도우의 커서 위치에서 분기
      case @contardor
      when 0  # 뉴 게임
        command_new_game
      when 1  # 콘티 뉴
        command_continue
      when 2  # 슛다운
        command_shutdown
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 커멘드 : 뉴 게임
  #--------------------------------------------------------------------------
  def command_new_game
    # 결정 SE 를 연주
    $game_system.se_play($data_system.decision_se)
    # BGM 를 정지
    Audio.bgm_stop
    # 플레이 시간 계측용의 프레임 카운트를 리셋트
    Graphics.frame_count = 0
    # 각종 게임 오브젝트를 작성
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 초기 파티를 셋업
    $game_party.setup_starting_members
    # 초기 위치의 맵을 셋업
    $game_map.setup($data_system.start_map_id)
    # 플레이어를 초기 위치에 이동
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    # 플레이어를 리프레쉬
    $game_player.refresh
    # 맵으로 설정되어 있는 BGM 와 BGS 의 자동 변환을 실행
    $game_map.autoplay
    # 맵을 갱신 (병렬 이벤트 실행)
    $game_map.update
    # 맵 화면으로 전환해
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● 커멘드 : 콘티 뉴
  #--------------------------------------------------------------------------
  def command_continue
    # 콘티 뉴가 무효의 경우
    unless @continue_enabled
      # 버저 SE 를 연주
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # 결정 SE 를 연주
    $game_system.se_play($data_system.decision_se)
    # 로드 화면으로 전환해
    $scene = Scene_Load.new
  end
  #--------------------------------------------------------------------------
  # ● 커멘드 : 슛다운
  #--------------------------------------------------------------------------
  def command_shutdown
    # 결정 SE 를 연주
    $game_system.se_play($data_system.decision_se)
    # BGM, BGS, ME 를 페이드아웃
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # 슛다운
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● 전투 테스트
  #--------------------------------------------------------------------------
  def battle_test
    # 데이타베이스 (전투 테스트용)를 로드
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    $data_weapons       = load_data("Data/BT_Weapons.rxdata")
    $data_armors        = load_data("Data/BT_Armors.rxdata")
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
    # 플레이 시간 계측용의 프레임 카운트를 리셋트
    Graphics.frame_count = 0
    # 각종 게임 오브젝트를 작성
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 전투 테스트용의 파티를 셋업
    $game_party.setup_battle_test_members
    # 무리 ID, 도주 가능 플래그, 배틀 가방을 설정
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    # 배틀 개시 SE 를 연주
    $game_system.se_play($data_system.battle_start_se)
    # 배틀 BGM 를 연주
    $game_system.bgm_play($game_system.battle_bgm)
    # 배틀 화면으로 전환해
    $scene = Scene_Battle.new
  end
end