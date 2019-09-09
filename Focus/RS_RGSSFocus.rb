#==============================================================================
# Name : 게임 포커스 유지(RGSSFocus)
# Author : 러닝은빛(biud436)
#------------------------------------------------------------------------------
# 스크립트 커맨드(Script Commands) : 
#------------------------------------------------------------------------------
#
# RS.focus?
# => 창이 포커스를 가진 상태인지 확인하는 함수입니다. 
# 포커스 여부에 따라 true 또는 false를 반환합니다.
# true이면 현재 화면이 포커스를 가지고 있다는 것을 뜻합니다.
# false면 현재 화면에 포커스가 없다는 것을 말합니다.
#
# RS.switch_fullscreen
# => 창을 전체 화면으로 전환합니다.
# ALT + ENTER와 동일한 기능입니다.
#
# RS.toggle_fps
# => 창에 FPS를 표시하거나 표시하지 않는 기능입니다.
# F2와 동일한 기능입니다.
#
# RS.open_option_window
# => 키 설정 및 옵션 창을 수동으로 열 수 있습니다.
# F1과 동일한 기능입니다.
#   
#------------------------------------------------------------------------------
# Change Log : 
#------------------------------------------------------------------------------
# 2015.07.29 (v0.0.16) : BGM, BGS 재생, 종료 관련
# 2015.07.30 (v0.0.19) : 
# 2019.09.09 (v1.0.0) :
# - 버그로 동작하지 않는 문제로 인해 DLL 파일을 처음부터 다시 만들었습니다.
# - 전체 화면, 옵션, FPS 표시 등 모든 기능들이 이제 제대로 동작합니다.
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_RGSSFocus"] = true

module RS
  
  # DLL 파일 로드 함수
  LoadLibrary = Win32API.new('kernel32.dll', 'LoadLibrary', 'p', 'l')
  
  # RGSS301.DLL의 핸들
  @system_handle = LoadLibrary.call("System/RGSS301.dll")

  # 초기화 함수
  Init = Win32API.new('RGSSFocus.dll', 'Init', 'l', 'v')
  
  # 설정창 열기
  OpenOptionWindow = Win32API.new('RGSSFocus.dll', 'OpenOptionWindow', 'v', 'v')
  
  # FPS 표시 토글
  ToggleFPS = Win32API.new('RGSSFocus.dll', 'ToggleFPS', 'v', 'v')
  
  # 전체 화면 전환
  SwitchFullScreen = Win32API.new('RGSSFocus.dll', 'SwitchFullScreen', 'v', 'v')
  
  # 윈도우 프로시저 함수 재정의
  RSCallProc = Win32API.new('RGSSFocus.dll', 'RSCallProc', '_L', 'v')
  
  class << self
    #--------------------------------------------------------------------------
    # * 초기화
    #--------------------------------------------------------------------------    
    def init
      Init.call(@system_handle)
      static_address = focus_on
      RSCallProc.call(static_address)
    end
    #--------------------------------------------------------------------------
    # * 포커스를 가지고 있는가?
    #--------------------------------------------------------------------------      
    def focus?
      $window_focus      
    end
    #--------------------------------------------------------------------------
    # * 옵션/키 설정 창 열기
    #--------------------------------------------------------------------------     
    def open_option_window
      OpenOptionWindow.call
    end
    #--------------------------------------------------------------------------
    # * FPS 표시 토글
    #--------------------------------------------------------------------------     
    def toggle_fps
      ToggleFPS.call
    end
    #--------------------------------------------------------------------------
    # * 전체 화면 전환 토글
    #--------------------------------------------------------------------------     
    def switch_fullscreen
      SwitchFullScreen.call
    end
  end
  
end
  
#==============================================================================
# ** Input
#==============================================================================
if $window_focus
  module Input
    class << self
      alias rs_input_update update
    end
    def self.update(*args, &block)
      return if not $window_focus
      rs_input_update(*args, &block)
    end
  end
end

RS.init