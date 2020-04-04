#==============================================================================
# Name : RMXP Console
# Description : 
# This script allows you to send the debug message to console.
# Author : biud436
# Date : 2018.07.15
# Version : 
# 2020.04.01 (v1.0.4) :
# - 이제 게임 윈도우가 콘솔 윈도우보다 더 위에 표시됩니다.
# 2020.04.04 (v1.0.5) :
# - Console.activate 함수 추가
# - 메인 윈도우에 포커스 설정
# - SetForegroundWindow 추가 (메인 창 활성화 API)
# Usage :
# p "안녕하세요?", "러닝은빛입니다"
# p 50, 46, 87
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_ConsoleForRMXP"] = true

if not defined? $NEKO_RUBY
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
  
  class Array
    def to_s
      ret = '['
      max = self.size
      self.each_with_index do |e, i| 
        if i != max - 1
          ret += "#{e}, "
        else
          ret += "#{e}"
        end
      end
      ret += "]"
      ret
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
    GetConsoleWindow = Win32API.new("Kernel32", "GetConsoleWindow", "v", "l")
    ShowWindow = Win32API.new("User32", "ShowWindow", "li", "s")
    SetWindowPos = Win32API.new("User32", "SetWindowPos", "lliiiil", "s")
    GetWindowRect = Win32API.new('User32', 'GetWindowRect', 'lp', 's')
    FindWindowW = Win32API.new('user32', 'FindWindowW', 'pp', 'l')
    SetForegroundWindow   = Win32API.new("user32", "SetForegroundWindow", "l", "s")
      
    AllocConsole.call if $DEBUG or $BTEST
    @@std_handle = GetStdHandle.call(-11)
    @@game_title = INI.read_string("Game", "Title", "Game.ini")
    
    # Consts
    HWND_BOTTOM = 1
    HWND_NOTOPMOST = -2    
      
    def self.activate
      
      SetConsoleTitle.call((@@game_title + " - Console").unicode!)
      
      @console_hwnd = GetConsoleWindow.call
      rt = [0,0,0,0].pack("l4")
      GetWindowRect.call(@console_hwnd, rt)
      rt.unpack("l4")
      
      @@player_hwnd = FindWindowW.call("RGSS Player".unicode!, @@game_title.unicode!)
            
      SetWindowPos.call(@console_hwnd, HWND_NOTOPMOST, 
        rt[0], rt[1], 0, 0, 
        0x0001 | 0x0002| 0x0040)
        
      SetWindowPos.call(@@player_hwnd, 0, 0, 0, 0, 0, 0x0001 | 0x0002| 0x0040)      
      
      SetForegroundWindow.call(@@player_hwnd)
      
    end
    
    def self.log(args)
      buf = args.to_s.join(" ") + "\r\n"
      buf = buf
      len = buf.size
      WriteConsole.call(@@std_handle, buf, len, 0, 0)
    end
    def self.logw(args)
      buf = []
      
      args.each do |i|
        buf.push(i.to_s + "\r\n") 
      end
      
      buf = buf.join(", ") + "\r\n"
      len = buf.size
      buf = buf.unicode!
      WriteConsoleW.call(@@std_handle, buf, len, 0, 0)
    end  
    
    Console.activate
    
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
end