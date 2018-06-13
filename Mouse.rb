#==============================================================================
# ** Mouse System (Use unicode)
# Author : biud436
# Date : 2016.07.27
# Version : 1.0
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_Mouse"] = true

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

module TouchInput

  FindWindowW = Win32API.new('user32.dll', 'FindWindowW', 'pp', 'l')
  GetCursorPos = Win32API.new('user32.dll', 'GetCursorPos', 'p', 's')
  ScreenToClient = Win32API.new('user32.dll', 'ScreenToClient', 'lp', 's')
  GetAsyncKeyState = Win32API.new('user32.dll', 'GetAsyncKeyState', 'i', 'i')
  ShowCursor = Win32API.new("user32", "ShowCursor", "i", "i" )
  @window_name = INI.read_string('Game', 'Title', 'Game.ini')
  @handle = FindWindowW.call('RGSS Player'.unicode!, @window_name.unicode!)

  ShowCursor.call(0)

  NONE = 0
  PRESSED = 1
  RELEASED = 2
  PRESS = 3

  MOUSE_ICON = 397

  KEY_MAPPER = {
  :LEFT => 0,
  :RIGHT => 1,
  :MIDDLE => 2
  }

  @old_buffer = Array.new(8, false)
  @current_buffer = Array.new(8, false)
  @button_map = []

  @old_point = {:x => 0, :y => 0}
  @current_point = {:x => 0, :y => 0}

  @cr = 0
  @or = 0

  @last_key = nil
  @trigger = Array.new(8, false)

  @time = Time.now.to_i

  module_function

  def update
    @old_buffer = @current_buffer
    @current_buffer.map! {|i| i = false}
    @button_map.map! {|i| i = NONE}
    @trigger.map! {|i| i = false }
    @current_buffer[0] = ((GetAsyncKeyState.call(1) & 0x8000) != 0)
    @current_buffer[1] = ((GetAsyncKeyState.call(2) & 0x8000) != 0)
    @current_buffer[2] = ((GetAsyncKeyState.call(4) & 0x8000) != 0)

    for i in 0...8

      if @old_buffer[i] == false && @current_buffer[i] == true
        @button_map[i] = PRESSED
      elsif @last_key  == PRESS && @current_buffer[i] == false
        @button_map[i] = @last_key = RELEASED
        @trigger[i] = true
      elsif @old_buffer[i] == true && @current_buffer[i] == true
        @button_map[i] = @last_key = PRESS
      end

    end

    point = [0, 0].pack('l2')
    GetCursorPos.call(point)
    ScreenToClient.call(@handle, point)
    @old_point[:x] = @current_point[:x]
    @old_point[:y] = @current_point[:y]
    point = point.unpack('l2')
    @current_point[:x] = point[0]
    @current_point[:y] = point[1]

    if (Time.now.to_i - @time) >= 1

      @time = Time.now.to_i
    end

  end

  def press?(key)
    return false if not key.is_a?(Symbol)
    @button_map[KEY_MAPPER[key]] == PRESS
  end

  def up?(key)
    return false if not key.is_a?(Symbol)
    @button_map[KEY_MAPPER[key]] == RELEASED
  end

  def down?(key)
    return false if not key.is_a?(Symbol)
    @trigger[KEY_MAPPER[key]] && @last_key == RELEASED
  end

  def x
    @current_point[:x]
  end

  def y
    @current_point[:y]
  end

  def get_pos
    [x, y]
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
    if TouchInput.press?(:LEFT)
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

module Input
  class << self
    alias xxxx_update update
  end
  module_function
  def update
    xxxx_update
    TouchInput.update
  end
end

if defined? BattleManager

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

end
