#===============================================================================
# Name : RS_Input
# Author : biud436
# Version : 1.0.0 (2018.10.29)
# Description : This script provides the extension keycode and easy to use.
#-------------------------------------------------------------------------------
# How to use
#-------------------------------------------------------------------------------
# To use this code called 'p', You can output the string to the console for debug.
# These functions are checking whether certain key is pressed.
#
# You can use the key name as string type. 
# for example, the virtual keycode of the letter named 'a' returns 65.
# 
# p"]" if Input.press?("]")
# p"[" if Input.press?("[")
# p";" if Input.press?(";")
# p'"' if Input.press?('"')
# p">" if Input.press?(">")
# p"<" if Input.press?("<")
# p"?" if Input.press?("?")
# p"\\" if Input.press?("\\")
# p"-" if Input.press?("-")
# p"+" if Input.press?("+")
# p"~" if Input.press?("~")
#
# You can also use the virtual keycode to parameter 1.
# The keycode value called 221 is the same as the letter called ']'

# p"]" if Input.trigger?(221)
#
# in case of used the symbol, you can use like as at the following code! 
# You can see that, the symbol starts with the colon(:)
#
# p"backspace" if Input.press?(:VK_BACK)
#
#-------------------------------------------------------------------------------
# Funcions : 
#-------------------------------------------------------------------------------
# Please available virtual key codes refer to the line 164 (a.k.a KEY CONSTANT)
#
# Input.trigger?(symbol)
# Input.release?(symbol)
# Input.press?(symbol)
# Input.trigger?(String)
# Input.release?(String)
# Input.press?(String)
# Input.mouse_trigger?(0)
# Input.mouse_trigger?(1)
# Input.mouse_trigger?(2)
# Input.mouse_release?(0)
# Input.mouse_release?(1)
# Input.mouse_release?(2)
# Input.mouse_press?(0)
# Input.mouse_press?(1)
# Input.mouse_press?(2)
# Input.mouse_x
# Input.mouse_y
#
#===============================================================================
$imported = {} if $imported.nil?
$imported["RS_Input"] = true
#===============================================================================
# Unicode module
#===============================================================================
if not defined?(Unicode)
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
  module INI
    WritePrivateProfileStringW = Win32API.new('Kernel32','WritePrivateProfileStringW','pppp','s')
    GetPrivateProfileStringW = Win32API.new('Kernel32','GetPrivateProfileStringW','ppppip','s')
    extend self
    def write_string(app,key,str,file_name)
      path = ".\\" + file_name
      (param = [app,key.to_s,str.to_s,path]).collect! {|i| i.unicode!}
      success = WritePrivateProfileStringW.call(*param)
    end
    def read_string(app_name,key_name,file_name)
      buf = "\0" * 256
      path = ".\\" + file_name
      (param = [app_name,key_name,path]).collect! {|x| x.unicode!}
      GetPrivateProfileStringW.call(param[0], param[1],0,buf,256,param[2])
      buf.unicode_s.unpack('U*').pack('U*')
    end
  end
  class Hash
    def to_ini(file_name="Default.ini",app_name="Default")
      self.each { |k, v| INI.write_string(app_name,k.to_s.dup,v.to_s.dup,file_name) }
    end
  end
end
#===============================================================================
# Buffer classes
#===============================================================================
class InputBuffer
  attr_accessor :old
  attr_accessor :current
  attr_accessor :map
  def initialize(size)
    @old = ""
    @current = "\0" * size
  end
end
class MouseBuffer < InputBuffer
  attr_accessor :point
  def initialize(size)
    super(size)
    @map = Array.new(8, 0)
    @point = Rect.new    
  end
  def left_button=(val)
    @current[0] = val
  end
  def right_button=(val)
    @current[1] = val
  end  
  def middle_button=(val)
    @current[2] = val
  end  
end
#===============================================================================
# Input moudle
#===============================================================================
module Input
  
  FindWindowW = Win32API.new('user32.dll', 'FindWindowW', 'pp', 'l')
  GetKeyboardState = Win32API.new('User32.dll', 'GetKeyboardState', 'p', 's')
  GetCursorPos = Win32API.new('user32.dll', 'GetCursorPos', 'p', 's')
  ScreenToClient = Win32API.new('user32.dll', 'ScreenToClient', 'lp', 's')
  GetAsyncKeyState = Win32API.new('user32.dll', 'GetAsyncKeyState', 'i', 'i')
  GetKeyNameTextW = Win32API.new('user32.dll', 'GetKeyNameText', 'lpi', 'i')
  MapVirtualKey = Win32API.new('user32.dll', 'MapVirtualKey', 'll', 'l')
  
  MAPVK_VSC_TO_VK_EX = 3
  
  # Read the game title from ./Game.ini path and then set the window handle
  WINDOW_NAME = INI.read_string('Game', 'Title', 'Game.ini')
  HANDLE = FindWindowW.call('RGSS Player'.unicode!, WINDOW_NAME.unicode!)
  
  # keyboard input buffer
  @@keyboard = InputBuffer.new(256)
  
  # mouse input buffer;
  @@mouse =  MouseBuffer.new(8)
  
  # Available virtual keys for Windows OS;
  # a-z or A-Z letters are not here.
  KEY = {
      :VK_LBUTTON=>  0x01,
      :VK_RBUTTON=>  0x02,
      :VK_CANCEL=>  0x03,
      :VK_MBUTTON=>  0x04,
      :VK_XBUTTON1=>  0x05,
      :VK_XBUTTON2=>  0x06,
      :VK_BACK=>  0x08, # 백스페이스
      :VK_TAB=>  0x09, # 탭
      :VK_CLEAR=>  0x0C, # NumLock이 해제되었을 때의 5
      :VK_RETURN=>  0x0D, # Enter
      :VK_SHIFT=>  0x10, # Shift
      :VK_CONTROL=>  0x11, # Ctrl
      :VK_MENU=>  0x12, # Alt
      :VK_PAUSE=>  0x13, # Pause
      :VK_CAPITAL=>  0x14, # Caps Lock
      
      :VK_KANA=>  0x15,
      :VK_HANGEUL=>  0x15,
      :VK_HANGUL=>  0x15, # 한/영 변환
      :VK_JUNJA=>  0x17, 
      :VK_FINAL=>  0x18,
      :VK_HANJA=>  0x19, # 한자
      :VK_KANJI=>  0x19,
      
      :VK_ESCAPE=>  0x1B, # Esc
      :VK_CONVERT=>  0x1C, 
      :VK_NONCONVERT=>  0x1D,
      :VK_ACCEPT=>  0x1E,
      :VK_MODECHANGE=>  0x1F,
      :VK_SPACE=>  0x20,
      :VK_PRIOR=>  0x21, # PgUp
      :VK_NEXT=>  0x22, # PgDn
      :VK_END=>  0x23, # End
      :VK_HOME=>  0x24, # Home
      :VK_LEFT=>  0x25, # 
      :VK_UP=>  0x26,
      :VK_RIGHT=>  0x27,
      :VK_DOWN=>  0x28,
      :VK_SELECT=>  0x29,
      :VK_PRINT=>  0x2A,
      :VK_EXECUTE=>  0x2B,
      :VK_SNAPSHOT=>  0x2C, # Print Screen
      :VK_INSERT=>  0x2D, # Insert
      :VK_DELETE=>  0x2E, # Delete
      :VK_HELP=>  0x2F,
      :VK_LWIN=>  0x5B, # 왼쪽 윈도우 키
      :VK_RWIN=>  0x5C, # 오른쪽 윈도우 키
      :VK_APPS=>  0x5D,
      :VK_SLEEP=>  0x5F,
      :VK_NUMPAD0=>  0x60, # 숫자 패드 0 ~ 9
      :VK_NUMPAD1=>  0x61,
      :VK_NUMPAD2=>  0x62,
      :VK_NUMPAD3=>  0x63,
      :VK_NUMPAD4=>  0x64,
      :VK_NUMPAD5=>  0x65,
      :VK_NUMPAD6=>  0x66,
      :VK_NUMPAD7=>  0x67,
      :VK_NUMPAD8=>  0x68,
      :VK_NUMPAD9=>  0x69,
      :VK_MULTIPLY=>  0x6A, # 숫자 패드 *
      :VK_ADD=>  0x6B, # 숫자 패드 +
      :VK_SEPARATOR=>  0x6C,
      :VK_SUBTRACT=>  0x6D, # 숫자 패드 -
      :VK_DECIMAL=>  0x6E, # 숫자 패드 .
      :VK_DIVIDE=>  0x6F, # 숫자 패드 /
      :VK_F1=>  0x70,
      :VK_F2=>  0x71,
      :VK_F3=>  0x72,
      :VK_F4=>  0x73,
      :VK_F5=>  0x74,
      :VK_F6=>  0x75,
      :VK_F7=>  0x76,
      :VK_F8=>  0x77,
      :VK_F9=>  0x78,
      :VK_F10=>  0x79,
      :VK_F11=>  0x7A,
      :VK_F12=>  0x7B,
      :VK_F13=>  0x7C,
      :VK_F14=>  0x7D,
      :VK_F15=>  0x7E,
      :VK_F16=>  0x7F,
      :VK_F17=>  0x80,
      :VK_F18=>  0x81,
      :VK_F19=>  0x82,
      :VK_F20=>  0x83,
      :VK_F21=>  0x84,
      :VK_F22=>  0x85,
      :VK_F23=>  0x86,
      :VK_F24=>  0x87,
      :VK_NUMLOCK=>  0x90, # Num Lock
      :VK_SCROLL=>  0x91, # Scroll Lock
      :VK_OEM_NEC_EQUAL=>  0x92,
      :VK_OEM_FJ_JISHO=>  0x92,
      :VK_OEM_FJ_MASSHOU=>0x93,
      :VK_OEM_FJ_TOUROKU=>0x94,
      :VK_OEM_FJ_LOYA=>  0x95,
      :VK_OEM_FJ_ROYA=>  0x96,
      :VK_LSHIFT=>  0xA0,
      :VK_RSHIFT=>  0xA1,
      :VK_LCONTROL=>  0xA2,
      :VK_RCONTROL=>  0xA3,
      :VK_LMENU=>  0xA4,
      :VK_RMENU=>  0xA5,
      :VK_BROWSER_BACK=> 0xA6,
      :VK_BROWSER_FORWARD=> 0xA7,
      :VK_BROWSER_REFRESH=> 0xA8,
      :VK_BROWSER_STOP=> 0xA9,
      :VK_BROWSER_SEARCH=> 0xAA,
      :VK_BROWSER_FAVORITES=> 0xAB,
      :VK_BROWSER_HOME=> 0xAC,
      :VK_VOLUME_MUTE=> 0xAD,
      :VK_VOLUME_DOWN=> 0xAE,
      :VK_VOLUME_UP=> 0xAF,
      :VK_MEDIA_NEXT_TRACK=> 0xB0,
      :VK_MEDIA_PREV_TRACK=> 0xB1,
      :VK_MEDIA_STOP=> 0xB2,
      :VK_MEDIA_PLAY_PAUSE=> 0xB3,
      :VK_LAUNCH_MAIL=> 0xB4,
      :VK_LAUNCH_MEDIA_SELECT=> 0xB5,
      :VK_LAUNCH_APP1=> 0xB6,
      :VK_LAUNCH_APP2=> 0xB7,
      :VK_OEM_1=>  0xBA,
      :VK_OEM_PLUS=>  0xBB,
      :VK_OEM_COMMA=>  0xBC,
      :VK_OEM_MINUS=>  0xBD,
      :VK_OEM_PERIOD=>  0xBE,
      :VK_OEM_2=>  0xBF,
      :VK_OEM_3=>  0xC0, # `
      :VK_OEM_4=>  0xDB,
      :VK_OEM_5=>  0xDC,
      :VK_OEM_6=>  0xDD,
      :VK_OEM_7=>  0xDE,
      :VK_OEM_8=>  0xDF,
      :VK_OEM_AX=>  0xE1,
      :VK_OEM_102=>  0xE2,
      :VK_ICO_HELP=>  0xE3,
      :VK_ICO_00=>  0xE4,
      :VK_PROCESSKEY=>  0xE5,
      :VK_ICO_CLEAR=>  0xE6,
      :VK_PACKET=>  0xE7,
      :VK_OEM_RESET=>  0xE9,
      :VK_OEM_JUMP=>  0xEA,
      :VK_OEM_PA1=>  0xEB,
      :VK_OEM_PA2=>  0xEC,
      :VK_OEM_PA3=>  0xED,
      :VK_OEM_WSCTRL=>  0xEE,
      :VK_OEM_CUSEL=>  0xEF,
      :VK_OEM_ATTN=>  0xF0,
      :VK_OEM_FINISH=>  0xF1,
      :VK_OEM_COPY=>  0xF2,
      :VK_OEM_AUTO=>  0xF3,
      :VK_OEM_ENLW=>  0xF4,
      :VK_OEM_BACKTAB=>  0xF5,
      :VK_ATTN=>  0xF6,
      :VK_CRSEL=>  0xF7,
      :VK_EXSEL=>  0xF8,
      :VK_EREOF=>  0xF9,
      :VK_PLAY=>  0xFA,
      :VK_ZOOM=>  0xFB,
      :VK_NONAME=>  0xFC,
      :VK_PA1=>  0xFD,
      :VK_OEM_CLEAR=>  0xFE,
      
      # 상단 숫자 키
      :VK_KEY_0 => 0x30,
      :VK_KEY_1 => 0x31,
      :VK_KEY_2 => 0x32,
      :VK_KEY_3 => 0x33,
      :VK_KEY_4 => 0x34,
      :VK_KEY_5 => 0x35,
      :VK_KEY_6 => 0x36,
      :VK_KEY_7 => 0x37,
      :VK_KEY_8 => 0x38,
      :VK_KEY_9 => 0x39,
      
  }  
  
  # 기호 키
  SPECIFIC_KEY = {
    "~" => 192,
    "`" => 192,
    "[" => 219,
    "{" => 219,
    "}" => 221,
    "]" => 221,
    ";" => 186,
    ":" => 186,
    '"' => 222,
    "'" => 222,
    "<" => 188,
    "," => 188,
    ">" => 190,
    "," => 188,
    "?" => 191,
    "/" => 191,
    "-" => 189,
    "_" => 189,
    "+" => 187,
    "=" => 187
  }
  
  # 키 상태
  STATES = {
    :NONE => 0,
    :DOWN => 1,
    :UP => 2,
    :PRESS => 3
  }
  
  MOUSE_BUTTON = {
  :LEFT => 0,
  :RIGHT => 1,
  :MIDDLE => 2
  }
  
  @@test = {}
  
  class << self
    alias rs_input_update update
    def update(*args, &block)
      rs_input_update(*args, &block)
      update_keyboard
      update_mouse
    end
    
    def get_virutal_key(keyname)
      vk_key = SPECIFIC_KEY[keyname]
      vk_key
    end
    
    def get_keycode(keyname)
      keycode = 0
      if keyname.is_a?(String)
        keycode = keyname.ord if keycode == 0
        return keycode if (65..90).include?(keycode) # if it is an upper case
        return keycode if (97..122).include?(keycode) # it it is a lower case
        keycode = get_virutal_key(keyname)
        return keycode if not keycode.nil?
      elsif keyname.is_a?(Integer)
        keycode = keyname
        return keycode
      elsif keyname.is_a?(Symbol)
        keycode = KEY[keyname]
        return (keycode.nil?) ? 0 : keycode
      end
      keycode = 0
      return keycode
    end
    
    alias rs_input_trigger? trigger?
    def trigger?(*args, &block)
      keycode = get_keycode(args[0])
      key_status = @@keyboard.map[keycode]
      if key_status and key_status == STATES[:DOWN]
        return true
      end
      return rs_input_trigger?(*args, &block)
    end
    
    def mouse_trigger?(*args, &block)
      index = args[0].is_a?(Symbol) ? MOUSE_BUTTON[args[0]] : args[0]
      return @@mouse.map[index] == STATES[:DOWN]
    end
    
    def mouse_press?(*args, &block)
      index = args[0].is_a?(Symbol) ? MOUSE_BUTTON[args[0]] : args[0]
      return @@mouse.map[index] == STATES[:PRESS]
    end    
    
    def mouse_release?(*args, &block)
      index = args[0].is_a?(Symbol) ? MOUSE_BUTTON[args[0]] : args[0]
      return @@mouse.map[index] == STATES[:UP]
    end        
    
    alias rs_input_press? press?
    def press?(*args, &block)
      keycode = get_keycode(args[0])
      key_status = @@keyboard.map[keycode]
      if key_status and key_status == STATES[:PRESS]    
        return true
      end
      return rs_input_press?(*args, &block)
    end
    
    def release?(*args, &block)
      keycode = get_keycode(args[0])
      key_status = @@keyboard.map[keycode]
      if key_status and key_status == STATES[:UP]
        return true
      end      
    end
        
    def update_keyboard
      @@keyboard.old = @@keyboard.current.dup
      @@keyboard.current = "\0" * 256
      @@keyboard.map = Array.new(256, 0)
      GetKeyboardState.call(@@keyboard.current)

      @@keyboard.current = @@keyboard.current.unpack('c*')
      
      for i in (0...256)
        @@keyboard.current[i] = ((@@keyboard.current[i] & 0x80) > 0) ? 1 : 0
        old = @@keyboard.old[i]
        cur = @@keyboard.current[i]
        if old == 0 and cur == 1
          @@keyboard.map[i] = STATES[:DOWN]
        elsif old == 1 and cur == 1
          @@keyboard.map[i] = STATES[:PRESS]        
        elsif old == 1 and cur == 0
          @@keyboard.map[i] = STATES[:UP]
        else
          @@keyboard.map[i] = STATES[:NONE]
        end
        
      end
    end
    
    def get_async_key_state(symbol)
      return 0 if not [:VK_LBUTTON, :VK_RBUTTON, :VK_MBUTTON].include?(symbol)
      return ((GetAsyncKeyState.call(KEY[symbol]) & 0x8000) != 0) ? 1 : 0
    end
    
    def update_mouse
      @@mouse.old = @@mouse.current.dup
      @@mouse.current = Array.new(8, 0)
      @@mouse.map = Array.new(8, 0)
      
      @@mouse.left_button = self.get_async_key_state(:VK_LBUTTON)
      @@mouse.right_button = self.get_async_key_state(:VK_RBUTTON)
      @@mouse.middle_button = self.get_async_key_state(:VK_MBUTTON)

      for i in (0...8)
        old = @@mouse.old[i]
        cur = @@mouse.current[i]
        if old == 0 and cur == 1
          @@mouse.map[i] = STATES[:DOWN]
        elsif old == 1 and cur == 1
          @@mouse.map[i] = STATES[:PRESS]
        elsif old == 1 and cur == 0
          @@mouse.map[i] = STATES[:UP]
        end
      end      
      
      update_mouse_point
    
    end
    
    def update_mouse_point
      pt = [0, 0].pack('l2')
      GetCursorPos.call(pt)
      ScreenToClient.call(HANDLE, pt)
      lpt = pt.unpack('l2')
      @@mouse.point.x = lpt[0]
      @@mouse.point.y = lpt[1]      
    end
    
    def mouse_x
      @@mouse.point.x rescue 0
    end
    
    def mouse_y
      @@mouse.point.y rescue 0
    end    
    
  end
  
end

module TouchInput
  
  ShowCursor = Win32API.new("user32", "ShowCursor", "i", "i" )
  ShowCursor.call(0)
  
  MOUSE_ICON = 397
  
  class << self
    def press?(*args, &block)
      Input.mouse_press?(*args, &block)
    end
    
    def trigger?(*args, &block)
      Input.mouse_trigger?(*args, &block)
    end
    
    def release?(*args, &block); Input.mouse_release?(*args, &block); end
    def down?(key); Input.mouse_press?(key); end
    def up?(key); Input.mouse_release?(key); end
    def x
      Input.mouse_x
    end
    def y
      Input.mouse_y
    end
    def get_pos
      [x, y]
    end
  end
end

class Window_Selectable < Window_Base
  def process_cursor_move
    return unless cursor_movable?
    last_index = @index
    cursor_down (Input.trigger?(:DOWN))  if Input.repeat?(:DOWN)
    cursor_up   (Input.trigger?(:UP))    if Input.repeat?(:UP)
    cursor_right(Input.trigger?(:RIGHT)) if Input.repeat?(:RIGHT)
    cursor_left (Input.trigger?(:LEFT))  if Input.repeat?(:LEFT)
    cursor_pagedown   if !handle?(:pagedown) && Input.trigger?(:R)
    cursor_pageup     if !handle?(:pageup)   && Input.trigger?(:L)
    Sound.play_cursor if @index != last_index
    check_mouse_button if defined? TouchInput
  end
  def check_mouse_button
    mx = TouchInput.x
    my = TouchInput.y
    idx = [[((my - self.y) / (col_max * item_height)), 0].max, item_max - 1].min
    idx += [[((mx - self.x) / (row_max * item_width)), 0].max, item_max - 1].min
    self.index = idx
    if TouchInput.press?(0)
      rect = self.item_rect(idx)
      check_area?(rect) { process_ok if ok_enabled? }
    end
    if TouchInput.press?(:RIGHT)
      check_area?(rect) { process_cancel }
    end
  end
  def check_area?(rect)
    mx = TouchInput.x
    my = TouchInput.y
    if (mx - self.x) >= rect.x && (mx - self.x) <= rect.x + rect.width &&
    (my - self.y) >= rect.y && (my - self.y) <= rect.y + rect.height
      yield
    end
  end
end

module TouchInput::Cursor
  def create_cursor(index)
    @cursor = Sprite.new
    @cursor.x, @cursor.y = TouchInput.get_pos
    @cursor.bitmap = Bitmap.new(24,24)
    @contents = @cursor.bitmap
    @draw_icon = lambda {|icon_index,x,y,enabled = true|
    bitmap = Cache.system("Iconset")
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    @contents.blt(x, y, bitmap, rect, enabled ? 255 : 128)}
    @draw_icon.(index,0,0,true)
    @cursor.z = 500
    @update_cursor = lambda {|pos| return false if @cursor.nil?
    @cursor.x, @cursor.y = pos }
    @dispose_cursor = lambda {@contents.dispose; @cursor.dispose}
  end
end

class Scene_Base
  include TouchInput::Cursor
  alias mouse_cursor_start start
  alias mouse_cursor_update update
  alias mouse_cursor_terminate terminate
  def start
    mouse_cursor_start
    create_cursor(TouchInput::MOUSE_ICON)
  end
  def update
    mouse_cursor_update
    @update_cursor.call(TouchInput.get_pos) if @cursor
  end
  def terminate
    mouse_cursor_terminate
    @dispose_cursor.call if @cursor
  end
end