#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
# Name : RS_InputXP
# Author : 러닝은빛(biud436)
# Change Log : 
# - 2020.02.14 (초안1)
# - 2020.02.19 (초안2)
# - 2020.02.22

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
  ClearText = Win32API.new(DLL, "clear_text", "i", "v")
    
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
  
  def clear_text(level=0)
    ClearText.call(level)
  end
  #--------------------------------------------------------------------------
  # * 조합된 텍스트를 반환합니다 (한글 포함)
  #--------------------------------------------------------------------------  
  def char
    str = $input_char || ""
    return $1.to_s
  end
  
end

module RS
  class Scene_Base
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
    end
    def update
    end
    def terminate
    end
  end
end

class Scene_HangulName < RS::Scene_Base
  def initialize(id)
    @actor_id = id
  end
  def start
    @children = []
    
    @actor = $game_actors[@actor_id || 1]
    
    @name = ""
    create_background
    create_name
  end
  def create_name
    @name_sprite = Sprite.new
    @name_sprite.bitmap = Bitmap.new(240, (48 * 2) + 4)    
    @children << @name_sprite
  end
  def client_rect
    hwnd = Win32API.new("User32.dll", "FindWindow", "pp", "l").call("RGSS Player", 0)
    f = Win32API.new("User32.dll", "GetClientRect", "lP", "i")
    rect = [0,0,0,0].pack('l4')
    f.call(hwnd , rect)
    rect = rect.unpack("l4")
    h = rect[3] - rect[1]
    w = rect[2] - rect[0]    
    
    return w, h
    
  end
  def create_background
    @background = Sprite.new
    bitmap = Bitmap.new(240, 48)
    @background.bitmap = bitmap
        
    w, h = client_rect
    
    @background.x = (w / 2) - bitmap.width / 2
    @background.y = (h / 2) - bitmap.height / 2
    c = Color.new(100, 100, 100, 200)
    @background.bitmap.fill_rect(0, 0, bitmap.width, bitmap.height, c)
    
    @children << @background
    
  end
  def refresh_name_window
    return if !@name
    @name_sprite.bitmap.clear
    
    text = $input_char || ""
    @name = text.gsub(/[^ㄱ-ㅎ가-힣A-Za-z\!\@\#\$\%\^\&\*\(\)\=\+\-\_\?]+/) { "" }
    
    @name_sprite.bitmap.draw_text(0, 0, 240, 48, @name, 0)
    w, h = client_rect
    @name_sprite.x = w / 2 - 240 / 2
    @name_sprite.y = h / 2 - 48 / 2  
  end
  def update
    
    refresh_name_window
    
    @children.each {|i| i.update }
    
    if Input.key_down?(0x08)
        Input.clear
        Input.clear_text(0)
    end
    
    if Input.key_down?(13)
      @actor.name = @name
      $scene = Scene_Map.new 
    end
  
  end
  def terminate
    return if !@name
    @actor = nil
    @children.each do |child|
      child.bitmap.dispose
      child.dispose
    end
  end
end