#==============================================================================
# ** GetHTML
# Author : biud436
# Date : 2015.07.09
# Version : 1.0
# Usage : Net::Http.open("raw.githubusercontent.com","/이하주소")
#==============================================================================
# * Usage
#==============================================================================
# - DLL 파일을 Game.exe와 같은 경로에 추가하세요.
#
# buf = Net::Http.open("pastebin.com","/raw.php?i=UV1hpwq7")
# eval(buf)
# p OS_VERSION.new.get_os
# ▲ Pastebin
#
# Net::Http.open("raw.githubusercontent.com","/이하주소")
# ▲ Github
#
# - 다운로드 받을 수 있는 텍스트의 길이를 더 늘릴려면 buf = "\x00" * 65000
# 에서 숫자(바이트 수) 부분을 수정하시기 바랍니다.
#
# 64KB = 1024B * 64 = 65536
#
# 그러나 길이가 길어지면 게임이 장기간 멈출 수도 있습니다.
#
# Thread.new { #코드 }
#
# 그럴땐 쓰레드를 이용해 별도의 흐름에서 코드를 실행해보시기 바랍니다.
#==============================================================================

module Net
  Open = Win32API.new('RSNet.dll','HttpOpen','ppp','v')
end

unless defined? Unicode
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
end

class Net::Http
  def self.open(host,index)
    buf = "\x00" * 65000
    Net::Open.call(host.unicode!,index.unicode!,buf)
    buf.delete!("\x00")
    buf
  end
end
