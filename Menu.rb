=begin
Script Name : 메뉴 스크립트
Author : 러닝은빛
Date : 2014-08-13
Version : 1.1 (2015-02-18)

■ 스크립트 소개
인게임 메뉴를 그래픽으로 표시하는 스크립트입니다.

■ 스크린샷
 http://postfiles9.naver.net/20140813_264/biud436_1407933418618ig1Rw_PNG/8.PNG?type=w1
▲ 예제 스샷에 사용된 UI 그래픽 : http://cafe.naver.com/sonnysoft2004/47269 (By 제스킨)
 
■ 설치
- 스크립트를 추가한다.
- 하나의 통 이미지가 필요한데 그 이미지의 이름은'inter'로 정하고 Graphics/pictures 폴더로 불러온다.
 
■ 사용법

- 통 이미지 제작 방법
W는 버튼(그림)의 가로 크기를 말한다. 
H는 버튼(그림)의 세로 크기를 말한다.
가로로 5열, 세로로 2행이다, 
첫번째 행은 선택이 되지 않은 상태이다.
나머지는 선택이 된 그래픽으로 제작한다.
 
- Scene 수정 방법
RECT_SRC 의 MENU 부분을 수정해주면 된다.
 
- 시작 위치 조절 방법
START_X 와 START_Y 상수값을 변경해주면 된다.

■ 버전
1.1 (2015-02-18) - 코드가 정리되고 재정의 관련 버그가 수정됨.

=end
 
module RECT_SRC
  W = 78
  H = 78
  START_X = Graphics.width / 2 - ((W*5) / 2)
  START_Y = Graphics.height / 2 - H/2
  RECT = []
  RECT[0] = {:x => 0, :y => [0,W], :w => W, :h => H}
  RECT[1] = {:x => W, :y => [0,W], :w => W, :h => H}
  RECT[2] = {:x => W * 2, :y => [0,W], :w => W, :h => H}
  RECT[3] = {:x => W * 3, :y => [0,W], :w => W, :h => H}
  RECT[4] = {:x => W * 4, :y => [0,W], :w => W, :h => H}
  MENU = [Scene_Status,Scene_Item,Scene_Skill,Scene_Map,Scene_Map]
end
 
class Game_Map
  attr_accessor :linear_menu
  #--------------------------------------------------------------------------
  # * 메뉴 상태 변수 설정
  #--------------------------------------------------------------------------     
  alias linear_menu_initialize initialize
  def initialize
    linear_menu_initialize
    @linear_menu = false
  end
end
 
 
class Scene_Linear_Menu < Scene_MenuBase
  include RECT_SRC
  attr_accessor :visible
  @@index = 0   
  #--------------------------------------------------------------------------
  # * 시작
  #--------------------------------------------------------------------------    
  def start
    super
    create_rect
  end
  #--------------------------------------------------------------------------
  # * create_help_window (오버라이딩)
  #--------------------------------------------------------------------------   
  def create_help_window
  end
  #--------------------------------------------------------------------------
  # * 파괴
  #--------------------------------------------------------------------------    
  def terminate
    super
    dispose_bitmap
  end 
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------    
  def update
    super
    update_index
    process_exit
  end
  #--------------------------------------------------------------------------
  # * 인덱스의 증가
  #--------------------------------------------------------------------------  
  def up
    @@index = (@@index + 1) % 5
    Sound.play_cursor
  end
  #--------------------------------------------------------------------------
  # * 인덱스의 감소
  #--------------------------------------------------------------------------    
  def down
    @@index = (@@index - 1) % 5
    Sound.play_cursor
  end
  #--------------------------------------------------------------------------
  # * 메뉴 처리
  #--------------------------------------------------------------------------    
  def update_index
    up if Input.trigger?(:RIGHT)
    down if Input.trigger?(:LEFT)
    select_scene if Input.trigger?(:C)
    set_rect(@rect[@@index],@@index)
  end
  #--------------------------------------------------------------------------
  # * 씬 호출
  #--------------------------------------------------------------------------   
  def select_scene
    SceneManager.call(MENU[@@index])
  end
  #--------------------------------------------------------------------------
  # * 메뉴 나가기
  #--------------------------------------------------------------------------   
  def process_exit
    SceneManager.call(Scene_Map) if Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # * 메뉴 생성
  #--------------------------------------------------------------------------    
  def create_cache(*args)
    sprite = Sprite.new
    sprite.bitmap = Cache.picture("inter")
    sprite.src_rect.set(*args)
    return sprite
  end
  #------------------- -------------------------------------------------------
  # * 영역 생성
  #--------------------------------------------------------------------------   
  def create_rect
    @rect = []
    for i in (0..4)
      @rect[i] = create_cache(RECT[i][:x],RECT[i][:y][0],RECT[i][:w],RECT[i][:h])
      @rect[i].x = START_X + RECT[i][:x]
      @rect[i].y = START_Y + RECT[i][:y][0]
    end
    set_rect(@rect[@@index],@@index)
  end
  #--------------------------------------------------------------------------
  # * 영역 설정
  #--------------------------------------------------------------------------  
  def set_rect(rect,i)
    rect.src_rect.set(RECT[i][:x],RECT[i][:y][1],RECT[i][:w],RECT[i][:h])
    for j in (0..4)
      next if j == @@index
      @rect[j].src_rect.set(RECT[j][:x],RECT[j][:y][0],RECT[j][:w],RECT[j][:h])
    end
  end
  #--------------------------------------------------------------------------
  # * 비트맵 메모리 해제
  #--------------------------------------------------------------------------   
  def dispose_bitmap
    @rect.each {|i| i.bitmap.dispose; i.dispose }
  end
end
 
 
class Scene_Map < Scene_Base
  def call_menu
    Sound.play_ok
    SceneManager.call(Scene_Linear_Menu)
  end
end
