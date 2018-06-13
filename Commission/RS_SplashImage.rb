# ==============================================================================
# Name : 스플래시 애니메이션 띄우기
# Date : 2018.03.30
# Update :
# 2018.04.06 - (v1.0.0)
# 2018.04.07 - (v1.0.1) 이미지 확대 축소
# 2018.04.08 - (v1.0.2) 이미지 위치 조절 함수 제거
# 2018.04.08 - (v1.0.3) 키보드 후킹을 제거하고 Input 모듈로 대체
# Author : biud436@gmail.com
# API 목록 :
# ------------------------------------------------------------------------------
# * 애니메이션 재생
# ------------------------------------------------------------------------------
#
# RSCore.play(시작 프레임 번호, 종료 프레임 번호)
#
# - 시작 프레임 번호 : 1부터 시작합니다.
# ------------------------------------------------------------------------------
# * 비트맵 메모리 해제
# ------------------------------------------------------------------------------
# 스크립트 커맨드에서 다음 스크립트를 호출하십시오.
#
# if not RSCore.disposed?
#   RSCore.dispose
# end
#
# ------------------------------------------------------------------------------
# * 비트맵 메모리 재생성
# ------------------------------------------------------------------------------
# 스크립트 커맨드에서 다음 스크립트를 호출하십시오.
#
# if RSCore.disposed?
#   RSCore.init_with_bitmap
# end
#
# ==============================================================================

$imported = {} if $imported.nil?
$imported["RS_SplashImage"] = true

module RSCore
  module CONFIG

    # ------------------------------------------------------------------------
    # * 최대 프레임
    # 이미지의 갯수를 적어주세요.
    # ------------------------------------------------------------------------
    MAX_FRAME = 12

    # 기본 프레임 딜레이 (1000 = 1초)
    DEFALT_FRAME_DELAY = 150

    # ------------------------------------------------------------------------
    # 특정 프레임 딜레이
    # ------------------------------------------------------------------------
    CERTAIN_FRAME_DELAY = {
      12 => 2000,
    }

    # 디버그 콘솔 표시(true이면 디버그 콘솔을 같이 띄웁니다)
    ENABLE_DEBUG_CONSOLE = false

    # 프레임 소스 위치
    SOURCE_PATH = "Graphics/SplashScreen/"

  end
end

module RPG::Cache
  def self.splash_image(filename, hue)
    self.load_bitmap(RSCore::CONFIG::SOURCE_PATH, filename, hue)
  end
end

module RSCore

  # DLL 이름
  DN = "RS-XPCore"

  # 코어 시스템 초기화
  RSInitWithCoreSystem = Win32API.new(DN, "RSInitWithCoreSystem", "v", "v")

  # 비트맵 초기화
  RSInitWithBitmap = Win32API.new(DN, "RSInitWithBitmap", "v", "v")

  # 코어 시스템 제거
  RSRemoveCoreSystem = Win32API.new(DN, "RSRemoveCoreSystem", "v", "v")

  # 스플래쉬 윈도우 생성
  RSCreateWindow = Win32API.new(DN, "RSCreateWindow", "v", "v")

  # 스플래쉬 윈도우 오픈
  RSOpenWindow = Win32API.new(DN, "RSOpenWindow", "v", "v")

  # 스플래쉬 윈도우 닫기
  RSCloseWindow = Win32API.new(DN, "RSCloseWindow", "v", "v")

  # 최대 프레임 설정
  RSSetMaxFrame = Win32API.new(DN, "RSSetMaxFrame", "i", "v")

  # 디버그 로그
  RSDebugLog = Win32API.new(DN, "RSDebugLog", "p", "v")

  # 프레임 설정
  # int frame_id, int delay
  RSSetFrame = Win32API.new(DN, 'RSSetFrame', 'ii', 'v')

  # 딜레이 설정
  RSSetFrameDelay = Win32API.new(DN, "RSSetFrameDelay", 'ii', 'v')

  # 디버그 로그 출력
  RSEnableDebugLog = Win32API.new(DN, 'RSEnableDebugLog', 'v', 'v')
  RSDisableDebugLog = Win32API.new(DN, 'RSDisableDebugLog', 'v','v')

  # 재생 구간 설정
  RSSetStartEndFrame = Win32API.new(DN, 'RSSetStartEndFrame', 'ii','v')

  # 비트맵 핸들 해제
  RSRemoveBitmap = Win32API.new(DN, 'RSRemoveBitmap', 'v','v')

  # 초기화 여부 (창 생성 여부)
  @@init = false

  # 메모리 해제 여부
  @@disposed = true

  # 창 열림 여부
  @@opening = false

  # 프레임 설정
  @@frame =[]

  class << self

    #--------------------------------------------------------------------------
    # * 시스템 초기화
    #--------------------------------------------------------------------------
    def init_with_core_system
      RSInitWithCoreSystem.call
      self
    end
    #--------------------------------------------------------------------------
    # * 스플래쉬 윈도우 생성
    #--------------------------------------------------------------------------
    def create_window
      RSCreateWindow.call
      @@init = true
      self
    end
    #--------------------------------------------------------------------------
    # * 스플래쉬 윈도우 오픈
    #--------------------------------------------------------------------------
    def open_window
      RSOpenWindow.call
      @@opening = true
      self
    end
    #--------------------------------------------------------------------------
    # * 스플래쉬 윈도우 닫기
    #--------------------------------------------------------------------------
    def close_window
      RSCloseWindow.call
      @@opening = false
      self
    end
    #--------------------------------------------------------------------------
    # * 코어 시스템 제거 (프로그램 종료 시 자동 호출)
    #--------------------------------------------------------------------------
    def remove_core_system
      RSRemoveCoreSystem.call
      @@init = false
      self
    end
    #--------------------------------------------------------------------------
    # * 로그 출력
    #--------------------------------------------------------------------------
    def log(str)
      str = str.to_s if not str.is_a?(String)
      str = (str + "\n")
      RSDebugLog.call(str)
    end
    #--------------------------------------------------------------------------
    # * 로그 출력
    #--------------------------------------------------------------------------
    def print(str)
      self.log(str)
    end
    #--------------------------------------------------------------------------
    # * 초기화 여부
    #--------------------------------------------------------------------------
    def init?
      @@init
    end
    #--------------------------------------------------------------------------
    # * 창 열림 여부
    #--------------------------------------------------------------------------
    def open?
      @@opening
    end
    #--------------------------------------------------------------------------
    # * 비트맵 메모리 해제되었나?
    #--------------------------------------------------------------------------
    def disposed?
      @@disposed
    end

    #--------------------------------------------------------------------------
    # * 프레임 별 딜레이 설정
    #--------------------------------------------------------------------------
    def set_delay
      for id in (0...CONFIG::MAX_FRAME)
        delay = CONFIG::CERTAIN_FRAME_DELAY[id + 1]
        delay = CONFIG::DEFALT_FRAME_DELAY if not delay
        RSSetFrameDelay.call(id, delay)
      end
    end

    #--------------------------------------------------------------------------
    # * 프레임 별 딜레이 설정
    #--------------------------------------------------------------------------
    def set_image_pos(n)
      RSSetImagePos.call(n)
    end

    #--------------------------------------------------------------------------
    # * 재생 구간 설정
    # * s : 시작 프레임
    # * e : 종료 프레임
    #--------------------------------------------------------------------------
    def set_frames(sf, ef)
      RSSetStartEndFrame.call(sf, ef)
    end

    #--------------------------------------------------------------------------
    # * 재생
    # * s : 시작 프레임
    # * e : 종료 프레임
    #--------------------------------------------------------------------------
    def play(start_frame, end_frame)
      set_frames(start_frame, end_frame)
      open_window
    end

    #--------------------------------------------------------------------------
    # * 설정
    #--------------------------------------------------------------------------
    def set_config

      # 최대 프레임 설정
      # 사용하는 이미지의 갯수만큼 지정하십시오
      RSSetMaxFrame.call(CONFIG::MAX_FRAME)

      # 딜레이 설정
      set_delay

      # 디버그 콘솔 표시 여부
      if CONFIG::ENABLE_DEBUG_CONSOLE
        RSEnableDebugLog.call()
      else
        RSDisableDebugLog.call()
      end
    end

    #--------------------------------------------------------------------------
    # * 비트맵 설정
    #--------------------------------------------------------------------------
    def init_with_bitmap

      # 비트맵 메모리 할당
      RSInitWithBitmap.call

      for i in (0...CONFIG::MAX_FRAME)
        bitmap = RPG::Cache.splash_image((i + 1).to_s, 0) rescue Bitmap.new(1, 1)
        @@frame << bitmap
        RSSetFrame.call(i, @@frame[i].__id__)
      end

      @@disposed = false

    end

    #--------------------------------------------------------------------------
    # * 윈도우용 비트맵 메모리 해제
    #--------------------------------------------------------------------------
    def remove_windows_bitmap
      RSRemoveBitmap.call
    end

    #--------------------------------------------------------------------------
    # * 비트맵 해제 (DLL에서도 호출됩니다)
    #--------------------------------------------------------------------------
    def dispose

      # 이미 해제되었다면 그냥 반환
      return if @@disposed

      remove_windows_bitmap

      @@frame.each do |bitmap|
        bitmap.dispose
      end

      @@frame = []

      @@disposed = true

    end

  end

  set_config
  if RSCore.disposed?
    init_with_bitmap
  end

end

# ==============================================================================
# Name : 입력 모듈
# Author : biud436
# 키보드 입력을 감지하여 전체 화면과 F12 버튼 누를 시 메모리 해제를 담당합니다.
# ==============================================================================
module Input

  # 키입력 감지
  GetKeyState = Win32API.new('user32','GetAsyncKeyState','i','i')
  KEYDB_EVENT = Win32API.new('user32','keybd_event','llll','v')

  KEYS = {
  :VK_BACK => 0x08,
  :VK_TAB => 0x09,
  :VK_RETURN => 0x0D, # Enter
  :VK_MENU => 0x12, #ALT
  :VK_F1 => 0x70,
  :VK_F2 => 0x71,
  :VK_F3 => 0x72,
  :VK_F4 => 0x73,
  :VK_F5 => 0x74,
  :VK_F6 => 0x75,
  :VK_F7 => 0x76,
  :VK_F8 => 0x77,
  :VK_F9 => 0x78,
  :VK_F10 => 0x79,
  :VK_F11 => 0x7A,
  :VK_F12 => 0x7B,
  :VK_NUMPAD0 => 0x60,
  :VK_NUMPAD1 => 0x61,
  :VK_NUMPAD2 => 0x62,
  :VK_NUMPAD3 => 0x63,
  :VK_NUMPAD4 => 0x64,
  :VK_NUMPAD5 => 0x65,
  :VK_NUMPAD6 => 0x66,
  :VK_NUMPAD7 => 0x67,
  :VK_NUMPAD8 => 0x68,
  :VK_NUMPAD9 => 0x69,
  :VK_ESCAPE => 0x1B, # ESC
  :VK_SPACE =>   0x20,
  :VK_PRIOR =>   0x21,
  :VK_NEXT =>    0x22,
  :VK_END =>     0x23,
  :VK_HOME =>    0x24,
  :VK_LEFT =>    0x25,
  :VK_UP =>      0x26,
  :VK_RIGHT =>   0x27,
  :VK_DOWN =>    0x28,
  :VK_SELECT =>  0x29,
  :VK_PRINT =>   0x2A,
  :VK_EXECUTE => 0x2B,
  :VK_SNAPSHOT => 0x2C,
  :VK_INSERT =>  0x2D,
  :VK_DELETE =>  0x2E,
  :VK_HELP =>    0x2F,
  :VK_LSHIFT =>    0xA0,
  :VK_RSHIFT =>    0xA1,
  :VK_LCONTROL =>  0xA2,
  :VK_RCONTROL =>  0xA3,
  :VK_A => 0x41,
  :VK_B => 0x42,
  :VK_C => 0x43,
  :D => 0x44,
  :E => 0x45,
  :F => 0x46,
  :G => 0x47,
  :H => 0x48,
  :I => 0x49,
  :J => 0x4A,
  :K => 0x4B,
  :VK_L => 0x4C,
  :M => 0x4D,
  :N => 0x4E,
  :O => 0x4F,
  :P => 0x50,
  :Q => 0x51,
  :VK_R => 0x52,
  :S => 0x53,
  :T => 0x54,
  :U => 0x55,
  :V => 0x56,
  :W => 0x57,
  :VK_X => 0x58,
  :VK_Y => 0x59,
  :VK_Z => 0x5A,
  :VK_OEM_1 =>     0xBA   , # ;:
  :VK_OEM_PLUS =>  0xBB   , # +
  :VK_OEM_COMMA => 0xBC   , # ,
  :VK_OEM_MINUS => 0xBD   , # -
  :VK_OEM_PERIOD => 0xBE   , # .
  :VK_OEM_2 =>     0xBF   , # /?
  :VK_OEM_3 =>     0xC0   , # `~
  :VK_OEM_4 =>     0xDB  , #  [{
  :VK_OEM_5 =>     0xDC  , #  \|
  :VK_OEM_6 =>     0xDD  , #  ]}
  :VK_OEM_7 =>     0xDE  , #  '"
  }

  @key_down = Array.new(255,false)
  @key_pressed = Array.new(255,false)

  KEY_ARRAYS = 256

  class << self

    #--------------------------------------------------------------------------
    # * 버튼 눌림 체크
    #--------------------------------------------------------------------------
    def vk_press?(vk_key)
      return false unless KEYS[vk_key] < KEY_ARRAYS
      if GetKeyState.call(KEYS[vk_key]) & 0x8000 != 0
        @key_down[KEYS[vk_key]] = true
        return true
      else
        @key_down[KEYS[vk_key]] = false
        return false
      end
    end

    #--------------------------------------------------------------------------
    # * 업데이트
    #--------------------------------------------------------------------------
    unless method_defined?(:rs_key_update)
      alias rs_key_update update
    end

    def update
      rs_key_update

      255.times {|i| @key_down[i] = false }

      # Alt + Enter 감지
      if Input.vk_press?(:VK_MENU) && GetKeyState.call(KEYS[:VK_RETURN])
        # ALT를 떼버린다.
        KEYDB_EVENT.call(KEYS[:VK_MENU],0,0x0002,0)
      end

      # F12 감지
      if Input.vk_press?(:VK_F12)
        # 비트맵의 메모리를 해제합니다.
        if not RSCore.disposed?
          RSCore.dispose
        end
      end
    end

  end
end
