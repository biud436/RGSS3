$imported = {} if $imported.nil?
$imported["RS_Display"] = true

module Display
  FindWindowW = Win32API.new('user32.dll', 'FindWindowW', 'pp', 'l')  
  MoveWindow = Win32API.new('user32.dll', 'MoveWindow', 'llllll', 'l')
  GetWindowRect = Win32API.new('user32.dll', 'GetWindowRect', 'lp', 'l')
  GetClientRect = Win32API.new('user32.dll', 'GetClientRect', 'lp', 'l')
  SetWindowPos = Win32API.new('user32.dll', 'SetWindowPos', 'lllllll', 'l')
  GetSystemMetrics = Win32API.new('user32.dll', 'GetSystemMetrics', 'l', 'l')
  SetWindowLong = Win32API.new('user32.dll', 'SetWindowLong', 'lll', 'l')
  AdjustWindowRect = Win32API.new('User32.dll', 'AdjustWindowRect', 'pll', 'l')
    
  # SetWindowLong의 주요 매개변수
  GWL_EXSTYLE = -20
  GWL_STYLE = -16
  
  WINDOW_NAME = INI.read_string('Game', 'Title', 'Game.ini')
  HWND = FindWindowW.call('RGSS Player'.unicode!, WINDOW_NAME.unicode!)
  
  @width = 544
  @height = 416
  
  # true이면 Graphics.width를 바꾸지 않고 창 크기만 조절됨.
  @stretched = false
  
  @fullscreen = false
  
  # GetSystemMetrics의 주요 매개변수
  SM_CXFULLSCREEN = 16
  SM_CYFULLSCREEN = 17  
  SM_CXSCREEN = 0
  SM_CYSCREEN = 1
  
  # Normal Style
  NORMAL_STYLE = 0x00000000|0x10000000|0x04000000|0x00800000|0x00080000|0x00020000|0x04194304
  NORMAL_EX_STYLE = 0x00000100
  
  # Fullscreen Style
  FULLSCREEN_STYLE = 0x00000000|0x80000000|0x20000000|0x10000000|0x04000000|0x00524288
  FULLSCREEN_EX_STYLE = 0x00000008

  # 작업 영역의 크기
  def self.get_rect
    buffer = [0,0,0,0].pack('l4')
    GetClientRect.call(HWND, buffer)
    rect = buffer.unpack('l4')    
  end
  
  # 일반 스타일
  def normal_window_style
    SetWindowLong.call(HWND, GWL_STYLE, NORMAL_STYLE)
    SetWindowLong.call(HWND, GWL_EXSTYLE, NORMAL_EX_STYLE)
  end
  
  # 전체 화면 스타일
  def fullscreen_style
    SetWindowLong.call(HWND, GWL_STYLE, FULLSCREEN_STYLE)
    SetWindowLong.call(HWND, GWL_EXSTYLE, FULLSCREEN_EX_STYLE)
  end  
  
  # 화면 가로 길이
  def self.screen_width
    GetSystemMetrics.call(SM_CXSCREEN)
  end
  
  # 화면 세로 길이
  def self.screen_height
    GetSystemMetrics.call(SM_CYSCREEN)
  end
  
  def self.move(width, height)
    rect = get_rect
    
    dx = screen_width / 2 - width / 2
    dy = screen_height / 2 - height / 2
    
    # 작업 영역의 크기를 지정한다.
    r = [0, 0, width, height].pack('l4')

    AdjustWindowRect.call(r, NORMAL_STYLE, 0)
    
    r = r.unpack('l4')
    swp_nomove = 0x0002
    swp_nosize = 0x0001
    
    # 화면 크기 조정
    SetWindowPos.call(HWND, 0, 0, 0, r[2] - r[0], r[3] - r[1], swp_nomove)
    
    # 주 모니터 중앙에 배치
    SetWindowPos.call(HWND, 0, dx, dy, 0, 0, swp_nosize)
    
  end
    
end

module Graphics
  @@width = 544
  @@height = 416
  
  def self.client_size
    rect = Display.get_rect       
    return rect[2], rect[3]
  end
  
  def self.refresh
    c = client_size
    @@width, @@height = c
  end
  
  def self.width
    @@width
  end
  
  def self.height
    @@height
  end
  
  def self.resize_screen(width, height)
    @@width = width
    @@height = height
    Display.move(width, height)
  end
  
  self.refresh
  
end