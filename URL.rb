#==============================================================================
# ** URL
# Name : URL
# Desc : This script allows you to download certain picture to your project
# from certain site.
# Author : biud436
# Version : 1.0
#==============================================================================
# ** How to Use
#==============================================================================
# This code executes the code that can download an image from certain site :
# URL >> "https://d289qh4hsbjjw7.cloudfront.net/rpgmaker-20130522223546811/files/carousel-screenshot-rpg-maker-mv.jpg"
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_AsyncDownloader"] = true

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
