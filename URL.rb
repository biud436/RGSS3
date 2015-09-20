# 윈도우 API 함수 URLDownloadToFileW 함수를 이용해 인터넷으로 파일을 다운로드 받는 스크립트입니다.

# -  코드를 입력하고 실행한다
# URL >> "https://d289qh4hsbjjw7.cloudfront.net/rpgmaker-20130522223546811/files/carousel-screenshot-rpg-maker-mv.jpg"

# - Graphics/Picture 폴더에 새롭게 추가되어있는 파일을 확인한다
module URL
  API = Win32API.new('urlmon.dll','URLDownloadToFileW', 'ppplp','l')
  def self.download(url)
    path = (Dir.pwd).gsub!("/") {"\\"} + "\\" + url.split("/")[-1]
    Thread.new { API.call(0, url.unicode!, path.unicode!, 0, 0) }
  end
  def self.add_pictures(url)
    m = File.join(Dir.pwd,"Graphics","Pictures")
    file_name = url.split("/")[-1]
    path = m.gsub!("/") {"\\"} + "\\" + file_name
    thread = Thread.new { API.call(0, url.unicode!, path.unicode!, 0, 0) }
    thread.join
    return file_name
  end
  def self.>>(url)
    URL.add_pictures(url)
  end  
end
 
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