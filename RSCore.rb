#===============================================================================
# Name : RSCore (RMXP)
# Date : 2018.03.30
# Author : biud436
#===============================================================================

module RSCore
  module CONFIG
    
    # 최대 프레임
    MAX_FRAME = 4
    
    # 스프라이트 설정
    FRAME = [
      "001-Fighter01", # 프레임 1
      "002-Fighter02", # 프레임 2
      "003-Fighter03", # 프레임 3
      "004-Fighter04", # 프레임 4
    ]
    
    # 디버그 콘솔 표시
    # = true이면 디버그 콘솔을 같이 띄웁니다
    ENABLE_DEBUG_CONSOLE = false
    
    # 프레임 소스 위치
    SOURCE_PATH = "Graphics/SplashScreen/"
    
    # 프레임 딜레이 (1000 = 1초)
    FRAME_DELAY = 1500
  
    # 소스 폴더가 없으면 새로 생성
    Dir.mkdir(SOURCE_PATH) unless File.exists?(SOURCE_PATH)
    
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
  RSSetFrame = Win32API.new(DN, 'RSSetFrame', 'ii', 'v')
  
  # 딜레이 설정
  RSSetFrameDelay = Win32API.new(DN, "RSSetFrameDelay", 'i', 'v')
  
  # 디버그 로그 출력
  RSEnableDebugLog = Win32API.new(DN, 'RSEnableDebugLog', 'v', 'v')
  RSDisableDebugLog = Win32API.new(DN, 'RSDisableDebugLog', 'v','v')

  # 초기화 여부
  @@init = false
  
  # 창 열림 여부
  @@opening = false
  
#===============================================================================
# 설정
#===============================================================================
  
  # 딜레이 설정
  RSSetFrameDelay.call(CONFIG::FRAME_DELAY)

  # 최대 프레임 설정
  RSSetMaxFrame.call(CONFIG::MAX_FRAME)
  
  # 디버그 콘솔 표시 여부
  if CONFIG::ENABLE_DEBUG_CONSOLE
    RSEnableDebugLog.call()
  else
    RSDisableDebugLog.call()
  end
  
#===============================================================================
# 메소드 정의
#===============================================================================
  
  class << self
    
    #===========================================================================
    # 시스템 초기화
    #===========================================================================
    def init_with_core_system
      RSInitWithCoreSystem.call
      @@init = true
      self
    end
    #===========================================================================
    # 스플래쉬 윈도우 생성
    #===========================================================================    
    def create_window
      RSCreateWindow.call
      self
    end
    #===========================================================================
    # 스플래쉬 윈도우 오픈
    #===========================================================================    
    def open_window
      RSOpenWindow.call
      @@opening = true
      self
    end
    #===========================================================================
    # 스플래쉬 윈도우 닫기
    #===========================================================================    
    def close_window
      RSCloseWindow.call
      @@opening = false
      self
    end  
    #===========================================================================
    # 코어 시스템 제거 (프로그램 종료 시 자동 호출)
    #===========================================================================    
    def remove_core_system
      RSRemoveCoreSystem.call
      @@init = false
      self
    end  
    #===========================================================================
    # 로그 출력
    #===========================================================================    
    def log(str)
      str = str.to_s if not str.is_a?(String)
      RSDebugLog.call(str + "\n")
    end
    #===========================================================================
    # 로그 출력
    #===========================================================================    
    def print(str)
      self.log(str)
    end
    #===========================================================================
    # 초기화 여부
    #===========================================================================    
    def init?
      @@init
    end
    #===========================================================================
    # 창 열림 여부
    #===========================================================================
    def open?
      @@opening
    end           
  end
  
  # 프레임 설정
  @@frame =[] 
  
  for i in (0...CONFIG::MAX_FRAME)
    @@frame << RPG::Cache.splash_image(CONFIG::FRAME[i], 0)
    RSSetFrame.call(i, @@frame[i].__id__)
  end
  
end

RSCore.create_window.open_window
