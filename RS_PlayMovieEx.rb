# Name : RS_PlayMovieEx
# Author : biud436
# Date : 2020.03.24 (v1.0.1)
# Desc :
# This script allows you to playback a video of specific video format such as mp4
# 
# Before starting this script, you must download the ffmpeg executable files,
# it is available at https://ffmpeg.zeranoe.com/builds/
# You grab the latest build from 'Windows 64-bit' - 'Static'-'Download Build'
#  
# Next, place all files in the root directory where it is the same as Game.exe
# 
# | Game.exe
# |
# | - ffmpeg.exe
# | - ffplay.exe
#
$imported = {} if $imported.nil?
$imported["RS_PlayMovieEx"] = true

if not defined?(Unicode)
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
      GetPrivateProfileStringW.call(param[0], param[1],0,buf,256,param[2])
      buf.unicode_s.unpack('U*').pack('U*')
    end
  end
  class Hash
    def to_ini(file_name="Default.ini",app_name="Default")
      self.each { |k, v| INI.write_string(app_name,k.to_s.dup,v.to_s.dup,file_name) }
    end
  end
end

module FFMPEG
  
  HWND = `powershell (Get-Process -Name "Game").MainWindowHandle`.to_i
  
  GetWindowRect = Win32API.new('user32.dll', 'GetWindowRect', 'lp', 's')
  GetClientRect = Win32API.new('user32.dll', 'GetClientRect', 'lp', 's')
  MoveWindow = Win32API.new('user32.dll', 'MoveWindow', 'liiiii', 'i')
  GetSystemMetrics = Win32API.new('user32.dll', 'GetSystemMetrics', 'i', 'i')
  
  SM_CXEDGE = 45
  SM_CYEDGE = 46
  SM_CXSCREEN = 0
  SM_CYSCREEN = 1
  SM_CYCAPTION = 4
  
  # 명령행 인자 사용, 다른 프로세스로 구현, 작동된다면 소스코드 공개의 의무는 없습니다.
  # https://olis.or.kr/consulting/projectHistoryDetail.do?bbsId=2&bbsNum=17521
  
  extend self
  
  # 동영상에서 음성 파일(OGG)을 추출합니다
  def extract(_in, _out)
    t = Thread.new do 
      `ffmpeg -i "#{_in}" -vn -acodec libvorbis -y "#{_out}.ogg"`
    end
  end
  
  # 특정 포맷의 영상을 OGV 파일로 변환합니다
  # FFMPEG.to_ogv("d.mp4", "f.ogv")
  def to_ogv(_in, _out)
    t = Thread.new do
      `ffmpeg -i "Movies/#{_in}" -s 544x416 -c:v libtheora -q:v 7 -c:a libvorbis -q:a 4 "Movies/#{_out}"`
    end
  end
  
  def fullscreen?
    ct = client_size
    return true if ct.width == screen_width && ct.height == screen_height
    return false
  end
  
  def screen_width
    GetSystemMetrics.call(SM_CXSCREEN)
  end
  
  def screen_height
    GetSystemMetrics.call(SM_CYSCREEN)
  end  
  
  def client_size
    rt = [0,0,0,0].pack('l4')
    GetClientRect.call(HWND, rt)
    r = rt.unpack('l4')
    
    return Rect.new(r[0], r[1], r[2] - r[0], r[3] - r[1])
  end
  
  # OGV가 아닌 다른 영상을 재생합니다
  def play(filename)
    
    caption = GetSystemMetrics.call(SM_CYCAPTION)
    x_padding = GetSystemMetrics.call(SM_CXEDGE)
    y_padding = GetSystemMetrics.call(SM_CYEDGE)
    
    vw = Graphics.width + x_padding
    vh = Graphics.height + y_padding
    
    extra = fullscreen? ? "-fs -alwaysontop" : ""
    
    t = Thread.new do
      `ffplay "Movies/#{filename}" -noborder -autoexit -x #{vw} -y #{vh} #{extra}`
    end
    
    ffplay_hwnd = `powershell (Get-Process -Name "ffplay").MainWindowHandle`.to_i
    
    if !ffplay_hwnd
      raise "ffplay가 없습니다"
    end
    
    return if fullscreen?
    
    rt = [0,0,0,0].pack('l4')
    GetWindowRect.call(ffplay_hwnd, rt)
    r = rt.unpack('l4')
        
    x = r[0]
    y = r[1]
    w = r[2] - x
    h = r[3] - y
    
    GetWindowRect.call(HWND, rt)
    r = rt.unpack('l4')
        
    x = r[0] + x_padding
    y = r[1] + caption + y_padding
    w = w
    h = h
    
    MoveWindow.call(ffplay_hwnd, x, y, w, h, 0)

  end
  
  # 화면 녹화
  def screen_record(filename, time=10)
    target_video_name = "Movies/#{filename}"
    File.delete(target_video_name) if FileTest.exist?(target_video_name)
    Thread.new do 
      title_name = INI.read_string('Game', 'Title', 'Game.ini')
      `ffmpeg -f gdigrab -framerate 30 -t #{time} -i title=#{title_name} Movies/#{filename}.mkv`
    end
  end  
end

module Graphics
  class << self
    alias xnrp_play_movie play_movie
    def play_movie(filename)
      items = Dir.glob("Movies/*.*").select {|v| v =~ /(.*).*/ && v.include?(filename)}
      filename_0 = items.first
      if FileTest.exist?("Movies/#{filename}.ogv")
        xnrp_play_movie(filename)
      else
        FFMPEG.play(File.basename(filename_0))
      end
    end
  end
end