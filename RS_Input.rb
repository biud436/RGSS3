#===============================================================================
# Name : RS_Input
# Author : biud436
# Version : 1.0.2 (2018.10.29)
# Link : https://biud436.blog.me/220289463681
# Description : This script provides the extension keycode and easy to use.
# Version Log : 
# v1.0.0 (2018.10.29) - First Release.
# v1.0.1 (2018.10.29) : 
# - Fixed the bug that causes an error when clicking the right button of the mouse.
# - Added the TouchInput feature that is the same as RPG Maker MV.
# - Fixed the issue that did not play the cursor sound when selecting the button using mouse
# v1.0.2 (2018.11.11)
# - Added the feature such as a path finding in RPG Maker MV
# - Added the destination sprite such as RPG Maker MV
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
# TouchInput.x
# TouchInput.y
# TouchInput.trigger?(:LEFT)
# TouchInput.trigger?(:RIGHT)
# TouchInput.trigger?(:MIDDLE)
# TouchInput.press?(:LEFT)
# TouchInput.press?(:RIGHT)
# TouchInput.press?(:MIDDLE)
# TouchInput.release?(:LEFT)
# TouchInput.release?(:RIGHT)
# TouchInput.release?(:MIDDLE)
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
  
  @@pressed_time = 0
  @@triggered = false
  @@mouse_pressed = false
  
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
      return @@triggered > 0|| @@mouse.map[index] == STATES[:DOWN]
    end
    
    def mouse_press?(*args, &block)
      index = args[0].is_a?(Symbol) ? MOUSE_BUTTON[args[0]] : args[0]
      return @@mouse_pressed || @@mouse.map[index] == STATES[:PRESS]
    end    
    
    def mouse_long_press?(*args, &block)
      @@pressed_time >= 24 && mouse_press?(*args, &block)
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
      
      @@triggered = @@mouse.map[MOUSE_BUTTON[:LEFT]] if @@mouse.map

      for i in (0...8)
        old = @@mouse.old[i]
        cur = @@mouse.current[i]
        if old == 0 and cur == 1
          @@mouse.map[i] = STATES[:DOWN]
          @@mouse_pressed = true
          @@pressed_time = 0
        elsif old == 1 and cur == 1
          @@mouse.map[i] = STATES[:PRESS]
        elsif old == 1 and cur == 0
          @@mouse.map[i] = STATES[:UP]
          @@mouse_pressed = false
        end
      end      
      
      update_mouse_point
      
      if mouse_trigger?(:LEFT)
        @@pressed_time += 1
      end
      
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

#===============================================================================
# TouchInput moudle
#===============================================================================
module TouchInput
  
  ShowCursor = Win32API.new("user32", "ShowCursor", "i", "i" )
  ShowCursor.call(0)
  
  MOUSE_ICON = 397
  
  class << self
    def press?(*args, &block)
      Input.mouse_press?(*args, &block)
    end
    
    def long_press?(*args, &block)
      Input.mouse_long_press?(*args, &block)
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

#===============================================================================
# Window_Selectable
#===============================================================================
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
    _self = self
    idx = [[((my - self.y) / (col_max * item_height)), 0].max, item_max - 1].min
    idx += [[((mx - self.x) / (row_max * item_width)), 0].max, item_max - 1].min
    item_max.times do |i| 
      temp_rect = self.item_rect(i)
      check_area?(temp_rect) do
        last_index = self.index
        self.index = idx
        Sound.play_cursor if self.index != last_index      
      end
    end
    if TouchInput.trigger?(:LEFT)
      rect = self.item_rect(idx)
      check_area?(rect) { process_ok if ok_enabled? }
    end
    if TouchInput.trigger?(:RIGHT)
      rect = self.item_rect(idx)
      process_cancel if cancel_enabled?
    end
  end
  def check_area?(rect)
    mx = TouchInput.x
    my = TouchInput.y
    tx = self.x
    ty = self.y
    if (mx - tx) >= rect.x && (mx - tx) <= rect.x + rect.width &&
    (my - ty) >= rect.y && (my - ty) <= rect.y + rect.height
      yield
    end
  end
end

#===============================================================================
# Window_Message
#===============================================================================
class Window_Message < Window_Base
  def cancelled?
    Input.trigger?(:B) || TouchInput.trigger?(:RIGHT)
  end
  def triggered?
    Input.trigger?(:C) || TouchInput.trigger?(:LEFT)
  end
  def update_show_fast
    @show_fast = true if cancelled?
  end
  def input_pause
    self.pause = true
    wait(10)
    Fiber.yield until triggered?
    Input.update
    self.pause = false
  end
end

#===============================================================================
# TouchInput::Cursor
#===============================================================================
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
    @cursor.ox = 0
    @cursor.oy = 0
    @update_cursor = lambda {|pos| return false if @cursor.nil?
    @cursor.x, @cursor.y = pos }
    @dispose_cursor = lambda {@contents.dispose; @cursor.dispose}
  end
end

#===============================================================================
# Scene_Base
#===============================================================================
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

#===============================================================================
# Scene_MenuBase
#===============================================================================
class Scene_MenuBase
  alias rs_open_menu_update update
  def update
    rs_open_menu_update
    update_when_starting_with_menu_scene
  end
  def update_when_starting_with_menu_scene
    is_trigger = false
    instance_variables.each do |varname|
      ivar = instance_variable_get(varname)
      if not ivar.is_a?(Window_Selectable)
        is_trigger = true
      end
    end    
    if is_trigger and TouchInput.trigger?(:RIGHT)
      Sound.play_cancel
      return_scene 
    end
  end
end

#===============================================================================
# Numeric
#===============================================================================
class Numeric
  def clamp min, max
    [[self, max].min, min].max
  end
end

#===============================================================================
# Game_Map
#===============================================================================
class Game_Map
  def delta_x(x1, x2)
    result = x1 - x2
    if $game_map.loop_horizontal? && result.abs > $game_map.width / 2
      if result < 0
        result += $game_map.width
      else
        result -= $game_map.width
      end
    end
    result        
  end
  def delta_y(y1, y2)
    result = y1 - y2
    if $game_map.loop_vertical? && result.abs > ($game_map.height / 2)
      if result < 0
        result += $game_map.height
      else
        result -= $game_map.height
      end
    end
    result        
  end
  def distance(x1, y1, x2, y2)
    delta_x(x1, x2).abs + delta_y(y1, y2).abs
  end

  def canvas_to_map_x(x)
    origin_x = @display_x * 32
    map_x = ((origin_x + x) / 32).floor
    return round_x(map_x)
  end
  
  def canvas_to_map_y(y)
    origin_y = @display_y * 32
    map_y = ((origin_y + y) / 32).floor
    return round_y(map_y)
  end  
  
end

#===============================================================================
# Game_Character
#===============================================================================
class Game_Character < Game_CharacterBase
  
  #--------------------------------------------------------------------------
  # * find_direction_to
  # RPG Maker MV의 findDirectionTo(goalX, goalY)를 그대로 루비로 옮김
  # @param {Integer} goal_x
  # @param {Integer} goal_y
  # @return {Integer} direction
  #--------------------------------------------------------------------------
  def find_direction_to(goal_x, goal_y)
    search_limit = 12
    map_width = $game_map.width
    node_list = []
    open_list = []
    closed_list = []
    start = {}
    best = start
    
    return 0 if @x == goal_x and @y == goal_y
    
    start[:parent] = nil
    start[:x] = @x
    start[:y] = @y
    
    # F = G + H
    # G = 시작점으로부터 목표 타일까지의 이동 비용; 생성된 경로 (장애물 피하는 경로)
    # 대각선 방향은 0, 수평은 수직은 1
    # H = 시작점으로부터 목표 타일까지의 이동 비용 (장애물 무시)
    # 대각선 방향을 무시하고 수평, 수직 이동 비용만 계산 1
    start[:g] = 0
    
    start[:f] = $game_map.distance(start[:x], start[:y], goal_x, goal_y)
    
    # 시작점을 열린 목록에 추가한다.    
    node_list.push(start)
    open_list.push(start[:y] * map_width + start[:x])
    
    
    while node_list.size > 0
      
      base_index = 0
      for i in (0...node_list.size)
        # F 비용 값이 가장 작은 노드를 찾는다.
        if node_list[i][:f] < node_list[base_index][:f]
          base_index = i
        end
      end
      
      # 현재 기준 노드를 설정한다.
      current = node_list[base_index]
      x1 = current[:x]
      y1 = current[:y]
      pos1 = y1 * map_width + x1
      g1 = current[:g]
      
      # F 비용이 가장 작은 노드를 열린 목록에서 빼고 닫힌 목록에 추가한다.
      node_list.delete_at(base_index)
      open_list.delete_at(open_list.index(pos1))
      closed_list.push(pos1)
      
      # 현재 노드가 목적지라면 베스트이므로 빠져나간다.
      if current[:x] == goal_x and current[:y] == goal_y
        best = current
        break
      end
      
      # g 비용이 12보다 커지면 최적화 문제로 탐색하지 않는다
      next if g1 >= search_limit
      
      # 인접한 4개의 타일을 열린 목록에 추가한다.
      for j in (0...4)
        direction = 2 + j * 2
        x2 = $game_map.round_x_with_direction(x1, direction)
        y2 = $game_map.round_y_with_direction(y1, direction)
        pos2 = y2 * map_width + x2
        
        # 닫힌 목록에 이미 있으면 무시한다.
        next if closed_list.include?(pos2)
        # 지나갈 수 없는 경우 무시한다.
        next if !passable?(x1, y1, direction)
        
        # g 비용을 1 늘린다 (이동 했다고 가정)
        g2 = g1 + 1
        # 열린 목록에서 해당 노드의 인덱스 값을 찾는다 (int or nil)
        index2 = open_list.index(pos2) || -1
        
        # 노드를 찾을 수 없었거나, 새로운 찾은 노드의 이동 비용이 작을 경우
        if (index2 < 0) or (g2 < node_list[index2][:g])
          neighbor = {}
          if index2 >= 0
            # 이미 열린 목록에 있는 노드를 선택한다.
            neighbor = node_list[index2]
          else
            # 열린 목록에 방금 찾은 인접 타일을 추가한다.
            neighbor = {}
            node_list.push(neighbor)
            open_list.push(pos2)
          end
          
          # 새로 찾은 인접 노드의 부모가 이전 타일로 설정된다.
          neighbor[:parent] = current
          
          # 인접 타일의 F 비용이 계산된다.
          neighbor[:x] = x2
          neighbor[:y] = y2
          neighbor[:g] = g2
          # F값 = 이동 비용 + 장애물을 무시한 실제 거리
          neighbor[:f] = g2 + $game_map.distance(x2, y2, goal_x, goal_y)
          
          # best가 nil이거나, 인접 타일의 실제 거리 값이 더 짧으면
          if best.nil? or (neighbor[:f] - neighbor[:g]) < (best[:f] - best[:g])
            # 인접 타일을 베스트 노드로 설정
            best = neighbor
          end
        end
      end
    end
    
    # 최단 거리 노드 값을 가져온다
    node = best
    
    # 노드의 부모 노드로 거슬러 올라간다 (딱 한 칸만 거슬러 올라간다)
    while node[:parent] and node[:parent] != start
      node = node[:parent] 
    end
    
    # 거리 차 계산
    delta_x1 = $game_map.delta_x(node[:x], start[:x])
    delta_y1 = $game_map.delta_y(node[:y], start[:y])
    
    # 최단 거리 노드가 아래 쪽에 있다.
    if delta_y1 > 0
      return 2     
    # 최단 거리 노드가 왼쪽에 있다
    elsif delta_x1 < 0
      return 4
    # 최단 거리 노드가 오른쪽 쪽에 있다.
    elsif delta_x1 > 0
      return 6
    # 최단 거리 노드가 위 쪽에 있다.
    elsif delta_y1 < 0
      return 8
    end
    
    # 그래도 찾지 못했다면, 장애물을 고려하지 않는 거리가 가장 가까운 곳으로 이동한다.
    delta_x2 = distance_x_from(goal_x)
    delta_y2 = distance_y_from(goal_y)
    if delta_x2.abs > delta_y2.abs
      return delta_x2 > 0 ? 4 : 6
    elsif delta_y2 != 0
      return delta_y2 > 0 ? 8 : 2
    end
    
    # 이동 불가능
    return 0      
      
  end
end

#===============================================================================
# Game_Temp
#===============================================================================
class Game_Temp
  attr_reader :destination_x
  attr_reader :destination_y
  attr_accessor :destination_time
  alias rs_map_touch_initialize initialize
  def initialize
    rs_map_touch_initialize
    @destination_x = nil
    @destination_y = nil  
    @destination_time = 0
  end
  def set_destination(x, y)
    @destination_x = x
    @destination_y = y
    @destination_time = 60
  end
  def clear_destination
    @destination_x = nil
    @destination_y = nil  
    @destination_time = 0
  end
  def destination_valid?
    return @destination_x != nil
  end
end

#===============================================================================
# Game_Player
#===============================================================================
class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * can_move?
  #--------------------------------------------------------------------------  
  def can_move?
    return false if $game_map.interpreter.running? || $game_message.busy?
    return false if @move_route_forcing || @followers.gathering?
    return false if @vehicle_getting_on || @vehicle_getting_off
    return false if vehicle && !vehicle.movable?
    return true    
  end
  #--------------------------------------------------------------------------
  # * check_touch_event
  #--------------------------------------------------------------------------   
  def check_touch_event
    if can_move?
      return false if in_airship?
      check_event_trigger_here([1,2])
      $game_map.setup_starting_event
    end
  end  
  #--------------------------------------------------------------------------
  # * update_nonmoving
  #--------------------------------------------------------------------------   
  def update_nonmoving(last_moving)
    return if $game_map.interpreter.running?
    if last_moving
      $game_party.on_player_walk
      return if check_touch_event
    end
    return if trigger_action
    if last_moving
      update_encounter 
    else
      $game_temp.clear_destination
    end
  end  
  #--------------------------------------------------------------------------
  # * trigger_action
  #--------------------------------------------------------------------------    
  def trigger_action
    if can_move?
      return true if trigger_button_action
      return true if trigger_touch_action
    end    
    return false
  end
  #--------------------------------------------------------------------------
  # * trigger_button_action
  #--------------------------------------------------------------------------     
  def trigger_button_action
    if Input.trigger?(:C)
      return true if get_on_off_vehicle
      check_event_trigger_here([0])
      return true  if $game_map.setup_starting_event
      check_event_trigger_there([0,1,2])
      return true  if $game_map.setup_starting_event
    end    
    return false
  end  
  #--------------------------------------------------------------------------
  # * trigger_touch_action
  #--------------------------------------------------------------------------   
  def trigger_touch_action
    if $game_temp.destination_valid?
      dir = @direction
      x1 = @x
      y1 = @y
      # 한 칸 앞의 좌표
      x2 = $game_map.round_x_with_direction(x1, dir)
      y2 = $game_map.round_y_with_direction(y1, dir)
      # 두 칸 앞의 좌표
      x3 = $game_map.round_x_with_direction(x2, dir)
      y3 = $game_map.round_y_with_direction(y2, dir)
      # 목적지 좌표
      dest_x = $game_temp.destination_x
      dest_y = $game_temp.destination_y
    
      if dest_x == x1 and dest_y == y1
        return trigger_touch_action_d1(x1, y1)
      # 한 칸 앞에 이벤트가 있다.
      elsif dest_x == x2 and dest_y == y2
        return trigger_touch_action_d2(x2, y2)
      # 두 칸 앞에 이벤트가 있다 (책상 : 카운터 속성)
      elsif dest_x == x3 and dest_y == y3
        return trigger_touch_action_d3(x2, y2)
      end
    end
    
    return false
    
  end
  #--------------------------------------------------------------------------
  # * trigger_touch_action_d1
  #--------------------------------------------------------------------------   
  def trigger_touch_action_d1(x1, y1)
    # 현재 좌표에 바로 위에 비행선이 놓여 있으면
    if $game_map.airship.pos?(x1, y1)
      # 마우스 왼쪽 버튼을 클릭하고 비행선 탑승 또는 하차 처리
      if TouchInput.trigger?(:LEFT) && get_on_off_vehicle
          return true
      end
    end
    # 현재 좌표 위에 이벤트가 있으면 실행한다.
    check_event_trigger_here([0])
    return $game_map.setup_starting_event
  end
  #--------------------------------------------------------------------------
  # * trigger_touch_action_d2
  #--------------------------------------------------------------------------   
  def trigger_touch_action_d2(x2, y2)
    # 보트나 배가 있으면
    if $game_map.boat.pos?(x2, y2) || $game_map.ship.pos?(x2, y2)
      # 마우스 왼쪽 버튼 눌렀을 때 탑승 처리
      if TouchInput.trigger?(:LEFT) and get_on_vehicle
        return true
      end
    end
    # 이미 보트나 배에 탑승 중이면
    if in_boat? or in_ship?
      # 마우스 왼쪽 버튼 눌렀을 때 하차 처리
      if TouchInput.trigger?(:LEFT) and get_off_vehicle
        return true
      end
    end
    # 현재 방향 바로 앞에 이벤트가 있으면 실행한다.
    check_event_trigger_there([0,1,2])
    return $game_map.setup_starting_event   
  end
  #--------------------------------------------------------------------------
  # * trigger_touch_action_d3
  #--------------------------------------------------------------------------   
  def trigger_touch_action_d3(x2, y2)
    # 앞에 책상이 있는가?
    if $game_map.counter?(x2, y2)   
      # 두 칸 앞에 있는 이벤트를 실행한다.
      check_event_trigger_there([0,1,2])
    end
    return $game_map.setup_starting_event
  end
  #--------------------------------------------------------------------------
  # * move_by_input
  #--------------------------------------------------------------------------  
  def move_by_input
    if (!moving?) && (can_move?)
      direction = Input.dir4
      if direction > 0
        $game_temp.clear_destination
      elsif $game_temp.destination_valid?
        x = $game_temp.destination_x
        y = $game_temp.destination_y
        direction = find_direction_to(x, y)
      end
      if direction > 0
        move_straight(direction)
      end
    end
  end  
  #--------------------------------------------------------------------------
  # * dash?
  #--------------------------------------------------------------------------    
  def dash?
    return false if @move_route_forcing
    return false if $game_map.disable_dash?
    return false if vehicle
    return Input.press?(:A) || $game_temp.destination_valid?
  end
end

class Spriteset_Map
  alias rs_input_initialize initialize
  def initialize
    rs_input_initialize
    create_destination
  end
  alias rs_input_update update
  def update
    rs_input_update
    update_destination
  end
  alias rs_input_dispose dispose
  def dispose
    rs_input_dispose
    dispose_destination
  end  
  def create_destination
    @destination = Sprite.new(@viewport1)
    @destination.bitmap = Bitmap.new(32, 32)
    @des_normal_color = Color.new(255, 255, 255, 255)
    @des_red_color = Color.new(255, 0, 0, 255)
    @destination.bitmap.fill_rect(0, 0, 32, 32, @des_normal_color)
    @destination.opacity = 128
    @destination.z = 500
    @destination.visible = false
    @destination_zoom_effect = 1
    @destination.ox = 16
    @destination.oy = 16
  end
  def update_destination
    return if not @destination
    @destination.visible = true
    if $game_temp.destination_valid? and $game_temp.destination_time > 0
      @destination.x = ($game_map.adjust_x($game_temp.destination_x) * 32) + 16
      @destination.y = ($game_map.adjust_y($game_temp.destination_y) * 32) + 16
      @destination_zoom_effect = (@destination_zoom_effect + 1) % 10
      @destination.zoom_x = @destination_zoom_effect / 10.0
      @destination.zoom_y = @destination_zoom_effect / 10.0
      $game_temp.destination_time -= 1
      $game_temp.destination_time = 0 if $game_temp.destination_time <= 0
    else
      @destination.x = ((TouchInput.x / 32).floor * 32) + 16
      @destination.y = ((TouchInput.y / 32).floor * 32) + 16
      @destination.zoom_x = 1
      @destination.zoom_y = 1
    end
    if $game_player.moving? and $game_temp.destination_valid?
      @destination.color = @des_red_color 
    else
      x = $game_map.canvas_to_map_x(TouchInput.x)
      y = $game_map.canvas_to_map_y(TouchInput.y)
      if $game_map.airship_land_ok?(x, y)
        @destination.color = @des_normal_color 
      else
        @destination.color = @des_red_color
      end
    end
    @destination.update

  end
  def dispose_destination
    return if not @destination
    @destination.bitmap.dispose
    @destination.dispose
  end
end

#===============================================================================
# Scene_Map
#===============================================================================
class Scene_Map
  
  alias rs_map_touch_start start
  def start
    rs_map_touch_start
    @touch_count = 0
  end
  
  alias rs_open_menu_update update
  def update
    rs_open_menu_update
    update_when_starting_with_menu_scene
    update_destination
  end
  
  def update_when_starting_with_menu_scene
    call_menu if TouchInput.trigger?(:RIGHT) and !$game_message.busy?
  end
  
  def update_destination
    if map_touch_ok?
      process_map_touch
    else
      $game_temp.clear_destination
      @touch_count = 0
    end
  end
  
  def map_touch_ok?
    $game_player.can_move?
  end
  
  def process_map_touch
    if TouchInput.trigger?(:LEFT) || @touch_count > 0
      if TouchInput.press?(:LEFT)
        if @touch_count == 0 or (@touch_count >= 15)
          x = $game_map.canvas_to_map_x(TouchInput.x)
          y = $game_map.canvas_to_map_y(TouchInput.y)
          if $game_map.airship_land_ok?(x, y)
            $game_temp.set_destination(x, y) 
          end
        end
        @touch_count += 1
      else
        @touch_count = 0
      end
    end
  end
end