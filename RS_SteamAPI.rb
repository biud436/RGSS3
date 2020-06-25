module Steam
  
  DLL = "steam_api.dll"
  SteamAPI_RestartAppIfNecessary = Win32API.new(DLL , "SteamAPI_RestartAppIfNecessary", "l", "l")
  SteamAPI_Init = Win32API.new(DLL , "SteamAPI_Init", "v", "l")
  SteamAPI_Shutdown = Win32API.new(DLL , "SteamAPI_Shutdown", "v", "v")
  
  SteamAPI_SteamUtils_v009 = Win32API.new(DLL , "SteamAPI_SteamUtils_v009", "v", "p")
  SteamAPI_ISteamUtils_GetAppID = Win32API.new(DLL , "SteamAPI_ISteamUtils_GetAppID", "p", "l")
  SteamAPI_ISteamUtils_IsOverlayEnabled = Win32API.new(DLL , "SteamAPI_ISteamUtils_IsOverlayEnabled", "p", "l")
  
  SteamAPI_GetSteamInstallPath = Win32API.new(DLL , "SteamAPI_GetSteamInstallPath", "v", "p")

  class SteamScreenshot
    
    SteamAPI_SteamScreenshots_v003 = Win32API.new(DLL , "SteamAPI_SteamScreenshots_v003", "v", "p")
    SteamAPI_ISteamScreenshots_TriggerScreenshot = Win32API.new(DLL , "SteamAPI_ISteamScreenshots_TriggerScreenshot", "p", "v")
    SteamAPI_ISteamScreenshots_HookScreenshots = Win32API.new(DLL , "SteamAPI_ISteamScreenshots_HookScreenshots", "pl", "v")
    SteamAPI_ISteamScreenshots_IsScreenshotsHooked = Win32API.new(DLL , "SteamAPI_ISteamScreenshots_IsScreenshotsHooked", "p", "s")
    SteamAPI_ISteamScreenshots_AddScreenshotToLibrary = Win32API.new(DLL , "SteamAPI_ISteamScreenshots_AddScreenshotToLibrary", "pppll", "l")
    SteamAPI_ISteamScreenshots_WriteScreenshot = Win32API.new(DLL , "SteamAPI_ISteamScreenshots_WriteScreenshot", "pplll", "l")
    SteamAPI_ISteamScreenshots_SetLocation = Win32API.new(DLL , "SteamAPI_ISteamScreenshots_WriteScreenshot", "plp", "l")    
        
    # 초기화
    def initialize
      @base = SteamAPI_SteamScreenshots_v003.call
    end
    
    # 훅
    def hook
      SteamAPI_ISteamScreenshots_HookScreenshots.call(@base, 1)
    end
    
    # 언훅
    def unhook
      SteamAPI_ISteamScreenshots_HookScreenshots.call(@base, 0)
    end
    
    # 스크린샷 추가
    def add_screenshot(filename)
      ret = SteamAPI_ISteamScreenshots_AddScreenshotToLibrary.call(@base, filename, filename, 544, 416)
    end
    
    # 스크린샷을 찍습니다
    # 스팀 오버레이가 활성화된 상태여야 동작합니다
    def take_screenshot
      
      if SteamAPI_ISteamScreenshots_IsScreenshotsHooked.call(@base) == 0
        hook
      end    
      
      screenshot_handle = SteamAPI_ISteamScreenshots_TriggerScreenshot.call(@base)
    end    
      
  end
  
  class SteamUser
    SteamAPI_ISteamUser_BLoggedOn = Win32API.new(DLL , "SteamAPI_ISteamUser_BLoggedOn", "p", "l")
    SteamAPI_ISteamUser_GetUserDataFolder = Win32API.new(DLL , "SteamAPI_ISteamUser_GetUserDataFolder", "ppl", "l")
    
    def initialize
      @user = Win32API.new(DLL , "SteamAPI_SteamUser_v021", "v", "p").call
    end
    
    def login
      SteamAPI_ISteamUser_BLoggedOn.call(@user)
    end
    
    def get_data_folder
      data = "\0" * 255
      SteamAPI_ISteamUser_GetUserDataFolder.call(@user, data, 255)
      data.delete!("\0")
      data
    end
  end
  
  class SteamFriends
    SteamAPI_SteamFriends_v017 = Win32API.new(DLL, "SteamAPI_SteamFriends_v017", "v", "p")
    SteamAPI_ISteamFriends_ActivateGameOverlay = Win32API.new(DLL, "SteamAPI_ISteamFriends_ActivateGameOverlay", "pp", "v")
    def initialize
      @base = SteamAPI_SteamFriends_v017.call
    end
    
    def activate_game_overlay
      SteamAPI_ISteamFriends_ActivateGameOverlay.call(@base, "friends")
    end
  end
  
  extend self
  
  @@steam_util = nil
  @@shot = nil
  @@steam_ready = false
  @@screenshot = nil
  
  @@steam_user = nil
  
  def start
    
    # 테스트 ID 480이 아니면 스팀 초기화 실패함
    temp_app_id = 480
    
    # 스팀을 통해서 게임이 실행되었는가?
    # 게임 프로젝트 경로에 steam_appid.txt가 있으면 false를 반환합니다
    if valid Proc.new { SteamAPI_RestartAppIfNecessary.call(temp_app_id) }
      raise "실패"
    end
    
    # 스팀 API HOOK 방식으로 동작하는데,
    # 프로그램 내부의 메인 함수에서 초기화 되어야 
    # 스팀 오버레이가 정상 동작할 것으로 보여짐.
    if !valid Proc.new { SteamAPI_Init.call }
      raise "스팀 API 초기화에 실패했습니다"
    end
    
    @@steam_user = SteamUser.new
    
    # 로그인
    @@steam_user.login
  
    @@screenshot = SteamScreenshot.new
    @@screenshot.hook
    
    # 스팀 유틸 초기화
    @@steam_util = SteamAPI_SteamUtils_v009.call
    
#~     system "explorer #{@@steam_user.get_data_folder}"
    
    # 스팀 오버레이 활성화 여부 출력
    if !overlay_enabled?
      p "스팀 오버레이가 비활성화 되어있습니다."
end

    # 스팀 오버레이 강제 활성화
    @@friends = SteamFriends.new
    @@friends.activate_game_overlay
    
    @@steam_ready = true
  
  end
    
  def get_app_id
    SteamAPI_ISteamUtils_GetAppID.call(@@steam_util)
  end
  
  def get_steam_install_path
    SteamAPI_GetSteamInstallPath.call
  end
  
  def overlay_enabled?
    ret = SteamAPI_ISteamUtils_IsOverlayEnabled.call(@@steam_util)
    return ret == 1
  end
  
  def take_screenshot(filename)
    @@screenshot.take_screenshot
    @@screenshot.add_screenshot(filename)
  end
  
  def valid(proc)
    ret = proc.call
    return ret == 1
  end
  
  def shutdown
    SteamAPI_Shutdown.call
  end
end

# 게임 재시작 시 중복 실행이 되지 않게 rgss_main을 재정의합니다
alias xxxx_rgss_main rgss_main 
def rgss_main(&block)
  Steam.start
  xxxx_rgss_main(&block)
  Steam.shutdown
end