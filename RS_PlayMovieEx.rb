# Name : RS_PlayMovieEx
# Author : biud436
# Date : 2020.03.24
# Version Log :
# 2020.03.24 (v1.0.0) : First Release.
# 2020.03.24 (v1.0.2) :
# - Added a feature that takes a screen record
# - Added an image overlay to the video
# 2020.03.25 (v1.0.3) :
# - Added the audio capture.
# - Added normalize option to replay video.
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
# To use the screen replay feature, 
# You place overlay-image the to Graphics/Systems/rec.png
#
# -----------------------------------------------------------------------------
# Example
# -----------------------------------------------------------------------------
#
# # ** Extract a sound file(*.ogg) from video files
# FFMPEG.extract(_in, _out)
# FFMPEG.extract("Movies/in.mp4", "Movies/out")
# 
# # ** Converts the video file as OGV file format.
# FFMPEG.to_ogv(_in, _out)
# FFMPEG.to_ogv("in.mp4", "out.ogv")
# 
# # ** This can replay the video after recording a screen using ffmpeg.
# FFMPEG.screen_record("myrecord", 5)
# 
# # ** This method allows you to overlay an image to a certain video after recording a game screen.
# FFMPEG.replay("test-record", 5)
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

  OPTION1 = "-show_region 1"
  OPTION2 = "-c:v libx264 -r 30 -preset ultrafast -tune zerolatency -crf 25 -pix_fmt yuv420p"
  AUDIO_CAPTURE = ->(device, time){ %Q(-f dshow -ar 44100 -ac 2 -t #{time} -i audio="#{device}") }
  
  # To start the audio capture automatically, try to set as true
  AUDIO_CAPTURE_OK = true
    
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
  
  # 사용 가능한 오디오 디바이스 출력
  def windows_devices
    devices = {}
    ignore_devices = ["WebCam", "XSplitBroadcaster"]
    f = IO.popen(["ffmpeg", "-list_devices", "true", "-f", "dshow", "-i", "dummy", :err=>[:child, :out]])
    lines = f.readlines    
    flag = false
    lines.each do |line|
      if line =~ /.*\"(.*)\"/
        device = $1
        if device[0] != "@" && ignore_devices.select {|i| device[i] }.size == 0
          flag = device
          next
        end
        if flag
          devices[flag] = device
          flag = false
        end
      end
    end
    
    devices
    
  end
  
  def print_audio_desc(filename)
    name = "Movies/#{filename}"
    return if not FileTest.exist?(name)
    `ffmpeg -i #{name} -af volumedetect -f null -`
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
    
    return t if fullscreen?
    
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
    
    return t

  end
  
  # 화면 녹화
  def screen_record(filename, time=10)
    target_video_name = "Movies/#{filename}.mkv"
    File.delete(target_video_name) if FileTest.exist?(target_video_name)
    Thread.new do 
      title_name = INI.read_string('Game', 'Title', 'Game.ini')
      audio_devices = windows_devices.values
      audio = ""
      if audio_devices.size > 0 && AUDIO_CAPTURE_OK
        audio = AUDIO_CAPTURE.call(audio_devices.first, time)
      end      
      `ffmpeg -y #{audio} -f gdigrab -framerate 30 #{OPTION1} -t #{time} -i title=#{title_name} #{OPTION2} Movies/#{filename}.mkv`
    end
  end  
  
  # 이미지 오버레이
  def screen_record_overlay_image(filename, time=10)
    target_video_name = "Movies/#{filename}.mkv"
    File.delete(target_video_name) if FileTest.exist?(target_video_name)
    Thread.new do 
      title_name = INI.read_string('Game', 'Title', 'Game.ini')
      audio_devices = windows_devices.values
      audio = ""
      if audio_devices.size > 0 && AUDIO_CAPTURE_OK
        audio = AUDIO_CAPTURE.call(audio_devices.first, time)
      end
      
      `ffmpeg -y #{audio} -f gdigrab -framerate 30 #{OPTION1} -t #{time} -i title=#{title_name} #{OPTION2} Movies/#{filename}.mkv`
      `ffmpeg -i Movies/#{filename}.mkv -i Graphics/System/rec.png -filter_complex "[0:v][1:v] overlay=(W-w)/2:(H-h)/2:enable='between(t,0,20)'" -pix_fmt yuv420p -c:a copy Movies/#{filename}-rec.mkv`
      
      # loudnorm 필터는 사운드 노말라이즈를 위한 것인데 인코딩 속도가 느리다.
      `ffmpeg -y -i Movies/#{filename}-rec.mkv -filter:a loudnorm Movies/#{filename}-rec.mp4`
      
    end    
  end
  
  # 리플레이
  def replay(filename, time=10)  
    Thread.new do 
      t = FFMPEG.screen_record_overlay_image(filename, 5)
      t.join
      
      last = RPG::BGM.last
      valid_replay = false
      
      if not last.name.nil?
        Audio.bgm_fade(200) 
        valid_replay = true
      end
    
      play_thread = FFMPEG.play("#{filename}-rec.mp4")
      play_thread.join
      
      target_video_name = "Movies/#{filename}.mkv"
      File.delete(target_video_name) if FileTest.exist?(target_video_name)  
      target_video_name = "Movies/#{filename}-rec.mkv"
      File.rename(target_video_name, "Movies/#{filename}.mkv") if FileTest.exist?(target_video_name)
      
      File.delete(target_video_name) if FileTest.exist?(target_video_name)
      
      last.replay if valid_replay
      
    end                
  end
  
  puts %Q(
=============================
  Audio
=============================
  )
  FFMPEG.windows_devices.each do |k, v|
    p "#{k} -> #{v}"
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
