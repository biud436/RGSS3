#==============================================================================
# ** Extend MessageBox
# Author : biud436
# Date : 2015.12.19.
# Version : 1.0
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
# ** Example
#------------------------------------------------------------------------------
# msgbox_yesno "선택하시겠습니까?" do |i|
#   if i
#     msgbox "확인 버튼을 눌렀습니다"
#   else
#     msgbox "취소 버튼을 눌렀습니다."
#   end
# end
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_ExtendMessageBox"] = true

module Unicode
  MultiByteToWideChar = Win32API.new('Kernel32','MultiByteToWideChar','llpipi','i')
  WideCharToMultiByte = Win32API.new('Kernel32','WideCharToMultiByte','llpipipp','i')
  UTF_8 = 65001
  #--------------------------------------------------------------------------
  # * MBCS -> WBCS
  #--------------------------------------------------------------------------
  def unicode!
    buf = "\0" * (self.size * 2 + 1)
    MultiByteToWideChar.call(UTF_8, 0, self, -1, buf, buf.size)
    buf
  end
  #--------------------------------------------------------------------------
  # * WBCS -> MBCS
  #--------------------------------------------------------------------------
  def unicode_s
    buf = "\0" * (self.size * 2 + 1)
    WideCharToMultiByte.call(UTF_8, 0, self, -1, buf, buf.size, nil, nil)
    buf.delete("\0")
  end
end

class String
  include Unicode
end

module Utils
  FindWindowW = Win32API.new('User32', 'FindWindowW', 'pp', 'l')
  MessageBoxW = Win32API.new('User32', 'MessageBoxW', 'lppl', 'i')
  GetWindowTextW = Win32API.new('User32', 'GetWindowTextW', 'lpl', 'i')
  HWND = FindWindowW.call("RGSS Player".unicode!, 0)
  MB_YESNO = 4
  IDYES = 6

  def self.window_name
    buffer = (0.chr) * 128
    GetWindowTextW.call(HWND, buffer, buffer.size)
    buffer.delete!(0.chr)
  end
end

module Kernel
  module_function
  def msgbox_yesno(context, &block)
    hwnd = Utils::HWND
    window_name = Utils.window_name.unicode!
    type = Utils::MB_YESNO
    result = Utils::MessageBoxW.call(hwnd, context.unicode!, window_name, type) == Utils::IDYES
    block.call(result)
  end
end
