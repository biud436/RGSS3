#==============================================================================
# ** Create Shortcut to your desktop (RPG Maker VX Ace)
#==============================================================================
# Name       : Create Shortcut to your desktop
# Author     : biud436
# Version    : 1.0
#==============================================================================
# ** Unicode
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_ShortCut"] = true

if not defined? Unicode
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
end
#==============================================================================
# ** Utils
#==============================================================================
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
#==============================================================================
# ** INI
#==============================================================================
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
    GetPrivateProfileStringW.call(*param[0..1],0,buf,256,param[2])
    buf.unicode_s.unpack('U*').pack('U*')
  end
end
#==============================================================================
# ** Hash
#==============================================================================
class Hash
  def to_ini(file_name="Default.ini",app_name="Default")
    self.each { |k, v| INI.write_string(app_name,k.to_s.dup,v.to_s.dup,file_name) }
  end
end
#==============================================================================
# ** Kernel
#==============================================================================
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
#==============================================================================
# ** ShortCut
#==============================================================================
module ShortCut
  Settings = {"ShortCut" => "true"}
  CreateShortcut = Win32API.new("ShortCut.dll", 'CreateShortcut', 'ppp', 's')
  module_function
  def local_path(d = "")
    Dir.pwd.gsub("/","\\") + "\\" + d
  end
  def convert_path(*args)
    args[0].gsub("/","\\")
  end
  def create_shortcut(lpath, tpath, desc)
    a = lpath.unicode!
    b = tpath.unicode!
    c = desc.unicode!
    CreateShortcut.call(a, b, c)
  end
  def desktop_path(name)
    convert_path File.join(ENV["HOMEPATH"],"Desktop",name)
  end
  def create_desktop_icon(name, description)
    lnk_path = desktop_path(name + ".LNK")
    target_path = local_path("Game.exe")
    create_shortcut(lnk_path,target_path,description)
  end
end
#==============================================================================
# ** Main
#==============================================================================
if INI.read_string("ShortCut Settings","ShortCut","ShortCut.ini") != "true"
  msgbox_yesno "Do you want to create a shortcut icon to your desktop?" do |i|
    if i
      w = Utils.window_name
      ShortCut.create_desktop_icon(w,"Start the game")
      ShortCut::Settings.to_ini("ShortCut.ini", "ShortCut Settings")
    end
  end
end
