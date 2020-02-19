# Name : RS_InputXP
# Author : 러닝은빛(biud436)
# Change Log : 
# - 2020.02.14 (초안1)
# - 2020.02.19 (초안2)

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
  #--------------------------------------------------------------------------
  # * Get the mouse x
  #--------------------------------------------------------------------------  
  def mouse_x
    GetMouseX.call
  end
  #--------------------------------------------------------------------------
  # * Get the mouse y
  #--------------------------------------------------------------------------    
  def mouse_y
    GetMouseY.call
  end  
  #--------------------------------------------------------------------------
  # * Check whether specific mouse button is triggered
  #--------------------------------------------------------------------------    
  def mouse_trigger?(type)
    if Button.has_key?(type)
      ret = Button[type].call
      return ret > 0
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * Check whether specific keyboard button is triggered
  #--------------------------------------------------------------------------   
  def key_down?(vkey)
    IsKeyDown.call(vkey) > 0
  end
  #--------------------------------------------------------------------------
  # * Check whether specific keyboard button is pressed
  #--------------------------------------------------------------------------     
  def key_pressed?(vkey)
    KeyPressed.call(vkey) == 1
  end
  #--------------------------------------------------------------------------
  # * Check whether specific keyboard button is released
  #--------------------------------------------------------------------------     
  def up?(vkey)
    IsKeyUp.call(vkey) > 0
  end
  #--------------------------------------------------------------------------
  # * Clear all pressed keys.
  #--------------------------------------------------------------------------       
  def clear
    Clear.call
  end
  #--------------------------------------------------------------------------
  # * 조합된 텍스트를 반환합니다 (한글 포함)
  #--------------------------------------------------------------------------  
  def char
    str = $input_char || ""
    return $1.to_s
  end
  
end

class Scene_Name2
  def main
    start
    # Transition run
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze    
    terminate
  end
  def start
    @name = Sprite.new
    @name.bitmap = Bitmap.new(240, (48 * 2) + 4)
  end
  def update
    return if !@name
    @name.bitmap.clear
    x = "#{Input.mouse_x}, #{Input.mouse_y}, #{Input.mouse_x / 32}, #{Input.mouse_y / 32}"
    @name.bitmap.draw_text(0, 0, 240, 48, x, 0)
    x = $input_char
    @name.bitmap.draw_text(0, 50, 240, 48, x, 0)
    @name.x = Input.mouse_x
    @name.y = Input.mouse_y
    @name.update    
    
    if Input.key_down?(13)
      $scene = Scene_Map.new
    end
  end
  
  def terminate
    return if !@name
    @name.bitmap.dispose
    @name.dispose
  end
end