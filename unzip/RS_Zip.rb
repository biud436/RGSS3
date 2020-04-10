# Author : biud436
# Desc :
# Zip.extract("example.zip")
#
module Unicode
  [:MultiByteToWideChar, :WideCharToMultiByte, :UTF_8, :CP_ACP].each do 
    |i| remove_const(i) if const_defined?(i)
  end
  MultiByteToWideChar = Win32API.new('Kernel32','MultiByteToWideChar','llpipi','i')
  WideCharToMultiByte = Win32API.new('Kernel32','WideCharToMultiByte','llpipipp','i')
  UTF_8 = 65001
  CP_ACP = 0
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
  def ansi_to_utf8
    buf = "\0" * (self.size * 2 + 1)
    ubuf = "\0" * (self.size * 2 + 1)
    
    MultiByteToWideChar.call(CP_ACP, 0, self, -1, buf, buf.size)
    WideCharToMultiByte.call(UTF_8, 0, buf, -1, ubuf, ubuf.size, 0, 0)
    
    ubuf
  end
  def utf8_to_ansi
    ubuf = "\0" * (self.size * 2 + 1)    
    buf = "\0" * (self.size * 2 + 1)    
    
    MultiByteToWideChar.call(UTF_8, 0, self, -1, ubuf, ubuf.size)
    WideCharToMultiByte.call(CP_ACP, 0, ubuf, -1, buf, buf.size, 0, 0)
    
    buf
  end    
end

class String
  include Unicode
end

module INI
  [:WritePrivateProfileStringW, :GetPrivateProfileStringW].each do 
    |i| remove_const(i) if const_defined?(i)
  end
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

module Zip
    
  URLDownloadToFileW = Win32API.new("Urlmon", "URLDownloadToFileW", "ppplp", "l")

  DLL_URL = "https://github.com/biud436/RGSS3/raw/master/unzip/bin/un_zip.dll".unicode!
  DLL_FILE = File.join(Dir.pwd, "un_zip.dll").gsub("/", "\\").unicode!
  URLDownloadToFileW.call(0, DLL_URL, DLL_FILE, 0, 0) if !File::exist?(DLL_FILE)
          
  ExtractZip = Win32API.new("un_zip.dll", "extractZip", "p", "l")

  def self.extract(filename)
      filename = File.join(Dir.pwd, filename)
      return if not File::exist?(filename)
      ExtractZip.call(filename)    
  end

end