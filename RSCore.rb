#-----------------------------------------------------
# Name : 스플래시 애니메이션 띄우기
# Date : 2018.03.30
# Update : 2018.04.06
# Author : biud436@gmail.com
#-----------------------------------------------------
module Unicode
  MultiByteToWideChar = Win32API.new('Kernel32','MultiByteToWideChar','llpipi','i')
  WideCharToMultiByte = Win32API.new('Kernel32','WideCharToMultiByte','llpipipp','i')
  UTF_8 = 65001
  def unicode!
    buf = "\0" * (self.size * 2 + 1)
    MultiByteToWideChar.call(UTF_8, 0, self, -1, buf, buf.size)
    buf
  end
  def unicode_s
    buf = "\0" * (self.size * 2 + 1)
    WideCharToMultiByte.call(UTF_8, 0, self, -1, buf, buf.size, nil, nil)
    buf.delete("\0")
  end
end

class String
  include Unicode
end

module RSCore
  module CONFIG
        
    # ------------------------------------------------------------------------
    # * 최대 프레임
    # 이미지의 갯수에 비례합니다.
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
    
    # 이미지 위치 (기본값은 2)
    IMAGE_POS = {
      # 중앙 위
      :TOP_MIDDLE => 0,
      
      # 오른쪽 위
      :TOP_RIGHT => 1, 
      
      # 완전 가운데
      :MIDDLE => 2 
    }
    
    # 디버그 콘솔 표시(true이면 디버그 콘솔을 같이 띄웁니다)
    ENABLE_DEBUG_CONSOLE = true
    
    # 프레임 소스 위치
    SOURCE_PATH = "Graphics/SplashScreen/"
    
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
  
  # 이미지 위치 설정
  RSSetImagePos = Win32API.new(DN, 'RSSetImagePos', 'i','v')
  
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
      @@init = true
      self
    end
    #--------------------------------------------------------------------------
    # * 스플래쉬 윈도우 생성
    #--------------------------------------------------------------------------   
    def create_window
      RSCreateWindow.call
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
    # * pos : 이미지 위치 (0 = 중앙 위, 1 = 오른쪽 위, 2 = 가운데)
    #--------------------------------------------------------------------------   
    def play(start_frame, end_frame, image_pos=CONFIG::IMAGE_POS[:MIDDLE])
      image_pos = image_pos || CONFIG::IMAGE_POS[:MIDDLE]
      set_frames(start_frame, end_frame)
      set_image_pos(image_pos)
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
  init_with_bitmap 
  create_window 

end
