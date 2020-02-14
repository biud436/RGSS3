# Name : RS_InputXP 초안
# Author : 러닝은빛(biud436)
# Date : 2020.02.14 (초안)

$imported = {} if $imported.nil?
$imported["RS_InputXP"] = true
module Input
  
  DLL = 'RS-InputCore.dll'
  RSGetWheelDelta = Win32API.new(DLL, 'RSGetWheelDelta', 'v', 'l')
  RSResetWheelDelta = Win32API.new(DLL, 'RSResetWheelDelta', 'v', 'v')
  
  GetMouseX = Win32API.new(DLL, 'get_mouse_x', 'v', 'l')
  GetMouseY = Win32API.new(DLL, 'get_mouse_y', 'v', 'l')
  
  IsKeyDown = Win32API.new(DLL, 'is_key_down', 'i', 'i')
  KeyPressed = Win32API.new(DLL, 'was_key_pressed', 'i', 'i')

  Button = {
    :LEFT => Win32API.new(DLL, 'get_mouse_lbutton', 'v', 'i'),
    :MIDDLE => Win32API.new(DLL, 'get_mouse_mbutton', 'v', 'i'),
    :RIGHT => Win32API.new(DLL, 'get_mouse_rbutton', 'v', 'i'),
  }
  
  Clear = Win32API.new(DLL, "clear", "v", "v")
    
  extend self
  def mouse_x
    GetMouseX.call
  end
  
  def mouse_y
    GetMouseY.call
  end  
  
  def mouse_trigger?(type)
    if Button.has_key?(type)
      ret = Button[type].call
      return ret > 0
    else
      return false
    end
  end
  
  def key_down?(vkey)
    IsKeyDown.call(vkey) > 0
  end
  
  def key_pressed?(vkey)
    KeyPressed.call(vkey) == 1
  end
  
  def up?(vkey)
    IsKeyUp.call(vkey) > 0
  end
  
  def clear
    Clear.call
  end
  
  def char
    str = $input_char || ""
    /([a-zA-Z가-힣ㄱ-ㅎ\.\?\!\@\#\$\%\^\&\*\(\)\-\=\_\+\/\*0-9\~\`\{\}])/i =~ str
    return $1.to_s
  end
  
end