#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================

$imported = {} if $imported.nil?
$imported["RS_TestEditBox"] = true

module EditBox
  FindWindow = Win32API.new('User32','FindWindowW',['P','P'],'L')
  HWND = FindWindow.call('RGSS Player'.unicode!, 0)
  WS_POPUP = 0x80000000
  WS_VISIBLE = 0x10000000
  WS_BORDER = 0x00800000
  WS_CHILD = 0x40000000

  EDIT_WIDTH = 200
  EDIT_HEIGHT = 28

  GetWindowRect = Win32API.new('User32','GetWindowRect',['L','P'],'L')
  GetWindowText = Win32API.new('User32','GetWindowTextW',['L','P', 'L'],'L')
  SetWindowPos = Win32API.new('User32','SetWindowPos','LLLLLLL' ,'L')
  CreateWindow = Win32API.new("User32", "CreateWindowEx", ["L","P","P","L","L","L","L","L","L","L","L","P"], 'L')
  SetFocus = Win32API.new('User32', 'SetFocus', 'L', 'L')

  @rect = [0, 0, 0, 0].pack('l4')
  GetWindowRect.call(HWND, @rect)
  @rect = @rect.unpack('l4') if @rect != nil

  EDIT_WINDOW = CreateWindow.call(0, 'edit', 0, WS_VISIBLE|WS_BORDER|WS_CHILD, 0, 0, 200, 16, HWND, 0, 0, 0)

  EditBox::SetWindowPos.call(EditBox::EDIT_WINDOW, -1, 0, 0, 0, 0, 0x0002|0x0001)

end

class Scene_Map < Scene_Base
  alias xxxx_update update
  def update
    xxxx_update
    str = "\0" * 255
    EditBox::GetWindowText.call(EditBox::EDIT_WINDOW, str, 256)
    EditBox::SetFocus.call(EditBox::HWND) if Input.trigger?(:C)
    p str.unpack('A*')[0].unicode_s
  end
end
