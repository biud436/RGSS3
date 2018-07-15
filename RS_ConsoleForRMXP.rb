#==============================================================================
# Name : RMXP Console
# Description : 
# This script allows you to send the debug message to console.
# Author : biud436
# Date : 2018.07.15
# Version : 1.0.1
# Usage :
# p "안녕하세요?", "러닝은빛입니다"
# p 50, 46, 87
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_ConsoleForRMXP"] = true

if not defined? Unicode
module Unicode
  MultiByteToWideChar = Win32API.new('Kernel32','MultiByteToWideChar','llpipi','i')
  WideCharToMultiByte = Win32API.new('Kernel32','WideCharToMultiByte','llpipipp','i')
  UTF_8 = 65001
  def unicode!
    buf = "\0" * (self.size * 2 + 1)
    len = MultiByteToWideChar.call(UTF_8, 0, self, -1, 0, 0)
    MultiByteToWideChar.call(UTF_8, 0, self, -1, buf, len)
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
end

module INI
  WritePrivateProfileStringW = Win32API.new('Kernel32','WritePrivateProfileStringW','pppp','s')
  GetPrivateProfileStringW = Win32API.new('Kernel32','GetPrivateProfileStringW','ppppip','s')
  extend self
  def write_string(app,key,str,file_name)
    path = ".\\" + file_name
    (param = [app,key.to_s,str.to_s,path]).collect! {|i| i.unicode!}
    success = WritePrivateProfileStringW.call(param[0], param[1], param[2], param[3])
  end
  def read_string(app_name,key_name,file_name)
    buf = "\0" * 256
    path = ".\\" + file_name
    (param = [app_name,key_name,path]).collect! {|x| x.unicode!}
    GetPrivateProfileStringW.call(param[0], param[1], 0,buf,256,param[2])
    buf.unicode_s.unpack('U*').pack('U*')
  end
end

module Console
  AllocConsole = Win32API.new('Kernel32', 'AllocConsole', 'v', 's')
  GetStdHandle = Win32API.new('Kernel32', 'GetStdHandle', 'l', 'l')
  WriteConsole = Win32API.new('Kernel32', 'WriteConsole', 'lplpp', 's')
  WriteConsoleW = Win32API.new('Kernel32', 'WriteConsoleW', 'lplpp', 's')
  SetConsoleTitle = Win32API.new('Kernel32', 'SetConsoleTitleW', 'p', 's')
  
  AllocConsole.call
  @@std_handle = GetStdHandle.call(-11)
  @@game_title = INI.read_string("Game", "Title", "Game.ini")
  
  SetConsoleTitle.call(@@game_title.unicode!)
  
  def self.log(args)
    buf = args.join(" ") + "\r\n"
    buf = buf
    len = buf.size
    WriteConsole.call(@@std_handle, buf, len, 0, 0)
  end
  def self.logw(args)
    buf = "\r" + args.join(" ") + "\n"
    len = buf.size
    buf = buf.unicode!
    WriteConsoleW.call(@@std_handle, buf, len, 0, 0)
  end  
end

module Kernel
  extend self
  alias msgbox p
  define_method :p do |*args|
    Console.logw(args)
  end
  define_method :print do |*args|
    Console.logw(args)
  end  
end