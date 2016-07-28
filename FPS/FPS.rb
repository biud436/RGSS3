module FPS
  DLL_NAME = "FPS_DLL.dll"
  InitFrameTime = Win32API.new(DLL_NAME, 'InitFrameTime', 'V', 'i')
  UpdateFrameTime = Win32API.new('FPS_DLL.dll', 'UpdateFrameTime', 'V', 'i')
  GetFPS = Win32API.new(DLL_NAME, 'GetFPS', 'V', 'p')
  GetFrameTime = Win32API.new(DLL_NAME, 'GetFrameTime', 'V', 'p')
  
  module_function
  def init
    InitFrameTime.call
  end
  def update
    UpdateFrameTime.call
  end
  def frame_time
    GetFrameTime.call.unpack('f')[0] rescue 0
  end
  def fps
    GetFPS.call.unpack('f')[0].round rescue 0
  end
  
  FPS.init
  
end

module Graphics
  class << self
    alias x1xx_update update
    def update(*args, &block)
      x1xx_update(*args, &block)
      FPS.update
    end
  end
  
end