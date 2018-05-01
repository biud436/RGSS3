#===============================================================================
# 이름 : 환경 변수 획득
# 날짜 : 2018.05.01
# 사용법 :
# 다음과 같이 호출하십시오.
#
#   RS.get_env("USERNAME")
#===============================================================================

if not defined? Unicode
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

module RS
  GetEnvironmentVariableW = Win32API.new('Kernel32', 'GetEnvironmentVariableW', 'ppl', 'l')
  def self.get_env(name)
    buf = "\0" * 256
    GetEnvironmentVariableW.call(name.unicode!, buf, 256)
    buf.unicode_s
  end
end