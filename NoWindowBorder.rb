module Unicode
  MultiByteToWideChar = Win32API.new('Kernel32','MultiByteToWideChar','llpipi','i')
  WideCharToMultiByte = Win32API.new('Kernel32','WideCharToMultiByte','llpipipp','i')
  UTF_8 = 65001
  def unicode!
    buf = "\0" * (self.size * 2)
    MultiByteToWideChar.call(UTF_8, 0, self, -1, buf, buf.size)
    buf
  end
  def unicode_s
    buf = "\0" * (self.size * 2)
    WideCharToMultiByte.call(UTF_8, 0, self, -1, buf, buf.size, nil, nil)
    buf.delete("\0")
  end
end
class String
  include Unicode
end
module WindowBorder
  GWL_STYLE = -16
  SetWindowLong = Win32API.new("User32", 'SetWindowLong', ['L','L','L'],'L')
  FindWindow = Win32API.new('User32','FindWindowW',['P','P'],'L')
  HWND = FindWindow.call('RGSS Player'.unicode!, 0)
  WS_POPUP = 0x80000000
  WS_VISIBLE = 0x10000000
  WS_BORDER = 0x00800000
  SetWindowLong.call(HWND, GWL_STYLE, WS_POPUP|WS_VISIBLE|WS_BORDER)
end
