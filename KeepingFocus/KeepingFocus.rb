#==============================================================================
# Author : biud436
# Version : 0.0.0.19
# DLL : https://www.dropbox.com/s/kehgd0gg9a9912h/RSModule.dll?dl=0
# Link : http://biud436.blog.me/220425931217
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_KeepingFocus"] = true

module RS
  Init = Win32API.new('RSModule','Initialize','v','s')
  GetFPS = Win32API.new('RSModule','GetFPS','v','i')
  #--------------------------------------------------------------------------
  # * 모듈 초기화
  #--------------------------------------------------------------------------
  Init.call
  RS.focus_on
end

class Integer
  #--------------------------------------------------------------------------
  # * true?
  #--------------------------------------------------------------------------
  def true?
    case self
    when 0, false, nil
      return false
    else
      return true
    end
  end
end

#==============================================================================
# ** RS::Input
#==============================================================================
module RS::Input
  GetMouseX = Win32API.new('RSModule','GetMousePosX','v','i')
  GetMouseY = Win32API.new('RSModule','GetMousePosY','v','i')
  MouseButtonDown = Win32API.new('RSModule','MouseButtonDown','i','i')
  GetKeyDown = Win32API.new('RSModule','GetKeyDown','i','i')
  ResetInput = Win32API.new('RSModule','ResetInput','i','v')

  KEYS = {
  :VK_BACK => 0x08,
  :VK_TAB => 0x09,

  # Enter
  :VK_RETURN => 0x0D,

  #ALT
  :VK_MENU => 0x12,

  :VK_F1 => 0x70, :VK_F2 => 0x71, :VK_F3 => 0x72, :VK_F4 => 0x73,
  :VK_F5 => 0x74, :VK_F6 => 0x75, :VK_F7 => 0x76, :VK_F8 => 0x77,
  :VK_F9 => 0x78, :VK_F10 => 0x79, :VK_F11 => 0x7A, :VK_F12 => 0x7B,

  :VK_NUMPAD0 => 0x60, :VK_NUMPAD1 => 0x61, :VK_NUMPAD2 => 0x62,
  :VK_NUMPAD3 => 0x63, :VK_NUMPAD4 => 0x64, :VK_NUMPAD5 => 0x65,
  :VK_NUMPAD6 => 0x66, :VK_NUMPAD7 => 0x67, :VK_NUMPAD8 => 0x68,
  :VK_NUMPAD9 => 0x69,

  # ESC
  :VK_ESCAPE => 0x1B,

  :VK_SPACE =>   0x20,  :VK_PRIOR =>   0x21,  :VK_NEXT =>    0x22,
  :VK_END =>     0x23,  :VK_HOME =>    0x24,  :VK_LEFT =>    0x25,
  :VK_UP =>      0x26,  :VK_RIGHT =>   0x27,  :VK_DOWN =>    0x28,
  :VK_SELECT =>  0x29,  :VK_PRINT =>   0x2A,  :VK_EXECUTE => 0x2B,
  :VK_SNAPSHOT => 0x2C, :VK_INSERT =>  0x2D,  :VK_DELETE =>  0x2E,
  :VK_HELP =>    0x2F,  :VK_LSHIFT =>    0xA0,  :VK_RSHIFT =>    0xA1,
  :VK_LCONTROL =>  0xA2,  :VK_RCONTROL =>  0xA3,

  :A => 0x41, :B => 0x42, :C => 0x43,
  :D => 0x44, :E => 0x45, :F => 0x46,
  :G => 0x47, :H => 0x48, :I => 0x49,
  :J => 0x4A, :K => 0x4B, :L => 0x4C,
  :M => 0x4D, :N => 0x4E, :O => 0x4F,
  :P => 0x50, :Q => 0x51, :R => 0x52,
  :S => 0x53, :T => 0x54, :U => 0x55,
  :V => 0x56, :W => 0x57, :X => 0x58,
  :Y => 0x59, :Z => 0x5A,

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
  #--------------------------------------------------------------------------
  # * press?
  #--------------------------------------------------------------------------
  def self.press?(keycode)
    return GetKeyDown.call(KEYS[keycode]).true? if keycode.is_a?(Symbol)
    return GetKeyDown.call(keycode.ord).true?  if keycode.is_a?(String)
  end
  #--------------------------------------------------------------------------
  # * 마우스 X좌표 반환
  #--------------------------------------------------------------------------
  def self.mouse_x
    return RS::Input::GetMouseX.call
  end
  #--------------------------------------------------------------------------
  # * 마우스 Y좌표 반환
  #--------------------------------------------------------------------------
  def self.mouse_y
    return RS::Input::GetMouseY.call
  end
  #--------------------------------------------------------------------------
  # * 마우스 버튼
  #--------------------------------------------------------------------------
  def self.mouse_check_button(sym)
    case sym
    when :mb_left
      RS::Input::MouseButtonDown.call(0).true?
    when :mb_right
      RS::Input::MouseButtonDown.call(1).true?
    when :mb_middle
      RS::Input::MouseButtonDown.call(2).true?
    end
  end
end

if $WindowRunning
  module Input
    class << self
      alias rs_input_update update
    end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
    # def self.update(*args, &block)
      # return if not $WindowRunning
      # rs_input_update(*args, &block)
    # end
  end
end
