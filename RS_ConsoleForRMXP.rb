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
    buf = "\0" * (self.size * 2)
    len = MultiByteToWideChar.call(UTF_8, 0, self, -1, 0, 0)
    MultiByteToWideChar.call(UTF_8, 0, self, -1, buf, len)
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
end

module Console
  AllocConsole = Win32API.new('Kernel32', 'AllocConsole', 'v', 's')
  GetStdHandle = Win32API.new('Kernel32', 'GetStdHandle', 'l', 'l')
  WriteConsole = Win32API.new('Kernel32', 'WriteConsole', 'lplpp', 's')
  WriteConsoleW = Win32API.new('Kernel32', 'WriteConsoleW', 'lplpp', 's')
  
  AllocConsole.call
  @@std_handle = GetStdHandle.call(-11)
  
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