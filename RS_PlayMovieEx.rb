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
# 2020.03.26 (v1.0.4) :
# - Fixed logic for detecting the Stereo Mix.
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

module Unicode
  CP_ACP = 0
  
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

module FFMPEG
  
  HWND = `powershell (Get-Process -Name "Game").MainWindowHandle`.to_i
  
  GetWindowRect = Win32API.new('user32.dll', 'GetWindowRect', 'lp', 's')
  GetClientRect = Win32API.new('user32.dll', 'GetClientRect', 'lp', 's')
  MoveWindow = Win32API.new('user32.dll', 'MoveWindow', 'liiiii', 'i')
  GetSystemMetrics = Win32API.new('user32.dll', 'GetSystemMetrics', 'i', 'i')
  
  # Returns the number of waveform-audio input devices present in the system.
  WaveInGetNumDevs = Win32API.new('Winmm.dll', 'waveInGetNumDevs', 'v', 'l')
  
  # 입력 장치의 이름을 획득합니다.
  WaveInGetDevCaps  = Win32API.new('Winmm.dll', 'waveInGetDevCaps', 'lPl', 'l')
  
  # 코드 페이지를 반환합니다.
  GetOEMCP = Win32API.new("Kernel32.dll", "GetOEMCP", "v", "l")
  
  SM_CXEDGE = 45
  SM_CYEDGE = 46
  SM_CXSCREEN = 0
  SM_CYSCREEN = 1
  SM_CYCAPTION = 4
  
  @@options = {
    :VIRTUAL_AUDIO_CAPTURER => false,
    :SCREEN_CAPTURE_RECORDER => false,
    :DSHOW => false,
    :GDIGRAB => true,
  }

  OPTION1 = "-show_region 1"
  OPTION2 = "-c:v libx264 -r 30 -preset ultrafast -tune zerolatency -crf 25 -pix_fmt yuv420p"
  AUDIO_CAPTURE = ->(device, time){ %Q(-f dshow -ar 44100 -ac 2 -t #{time} -i audio="#{device}") }
  
  # Do not try to set this manually!
  # The audio capture option is detected automatically. 
  # and now currently, the audio capturer is unstable, 
  # because ffmpeg's gdigrab doesn't provide the sound capture.
  @@audio_capture_ok = false
  
  # Get the locale
  # My system is used the character sets in CP949.
  @@locale = GetOEMCP.call
    
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
  
  # Checks whether the window is fullscreen.
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
  
  # Retrieves available audio and video devices on your system. 
  # Adds a new device to a list if they are found valid devices.
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
  
  def retrive_streomix
    match = stereo_mix_exist?
    return nil if not match

    windows_devices.each do |k, v|
      return v if k.include?(match)
    end
    
    return nil
  end
    
  # Retrieves available audio devices on your system, without FFMPEG
  # Returns WAVEINCAPS struct like C-Style as Hash.
  def audio_devices

    devices = WaveInGetNumDevs.call
        
    sound_devices = []
    
    for i in (0...devices)
      
      caps = [0,0,0].pack("ssl") + ("\0" * 32) + [0, 0, 0].pack("lss")
      WaveInGetDevCaps.call(i, caps, caps.size)

      v = caps.slice!(0, 8).unpack("ssl") # wMid, wPid, vDriverVersion
      name = caps.slice!(0, 32) # szPname
      s = caps.slice!(0, 8).unpack("lss") # dwFormats, wChannels, wReserved1
      
      sound_devices.push({
        :wMid => v[0],
        :wPid => v[1],
        :vDriverVersion => v[2],
        :szPname => name.ansi_to_utf8.delete!("\0"), # CP949에서 UTF8로 변경
        :dwFormats => s[0],
        :wChannels => s[1],
        :wReserved1 => s[2]
      })
      
    end
        
    sound_devices
    
  end
  
  # Retrieves available Stereo Mix in your sound devices.
  # if not, you must install virtual sound capture card such as XSplit, 
  # CamStudio, OBS Studio.
  def stereo_mix_exist?
    
    str = "Stereo Mix"
    
    str = case @@locale
    when 950 # Chinese (Traditional Chinese)
      "立體聲混音"
    when 949 # 한국어, ks_c_5601-1987
      "스테레오 믹스"
    when 936 # Chinese (Simplified Chinese)
      "立体声混音"      
    when 932 # Japan, shift_jis
      "ステレオ ミキサー"
    when 850 # German 
      "Stereomix"
    when 866 # Russian
      "Стерео микшер"
    when 850 # Brazilian portuguese
      "Mixagem estéreo"      
    when 860 # Portuguese
      "Mistura estéreo"
    when 437 # United States
    else
      "Stereo Mix"
    end    
    
    audio_devices.each do |device|
      return str if device[:szPname].include?(str)
    end
    
    return nil
    
  end
  
  def check_virtual_driver
    
    %Q(
    @@options = {
      :VIRTUAL_AUDIO_CAPTURER => false,
      :SCREEN_CAPTURE_RECORDER => false,
      :DSHOW => false,
      :GDIGRAB => true,
    }
          
    data = windows_devices
        
    if data["screen-capture-recorder"]
      @@options[:SCREEN_CAPTURE_RECORDER] = true
      @@options[:GDIGRAB] = false
      
      if data["virtual-audio-capturer"]
        @@options[:VIRTUAL_AUDIO_CAPTURER] = true
        @@options[:DSHOW] = true
      end      
    end
    
    @@options
    )
    
    @@options[:DSHOW] = false
    @@options[:VIRTUAL_AUDIO_CAPTURER] = false
    @@options[:SCREEN_CAPTURE_RECORDER] = false
    @@options[:GDIGRAB] = true
    
  end
  
  # Print a volume information of the specific audio file.
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
      audio_devices = retrive_streomix
      audio = ""
      
      if @@options[:GDIGRAB]
        if audio_devices && @@audio_capture_ok
          audio = AUDIO_CAPTURE.call(audio_devices, time)
        end      
        `ffmpeg -y #{audio} -f gdigrab -framerate 30 #{OPTION1} -t #{time} -i title=#{title_name} #{OPTION2} Movies/#{filename}.mkv`
      elsif @@options[:DSHOW]
#~         audio = ""
#~         if @@audio_capture_ok
#~           audio = AUDIO_CAPTURE.call("virtual-audio-capturer", time)
#~         end
#~         `ffmpeg -y #{audio} -f gdigrab -framerate 30 #{OPTION1} -t #{time} -i title=#{title_name} #{OPTION2} Movies/#{filename}.mkv`
      end
    end
  end  
  
  # 이미지 오버레이
  def screen_record_overlay_image(filename, time=10)
    target_video_name = "Movies/#{filename}.mkv"
    File.delete(target_video_name) if FileTest.exist?(target_video_name)
    Thread.new do 
      title_name = INI.read_string('Game', 'Title', 'Game.ini')
      audio_devices = retrive_streomix
      audio = ""
      
      if @@options[:GDIGRAB]
        if audio_devices && @@audio_capture_ok
          audio = AUDIO_CAPTURE.call(audio_devices, time)
        end
        
        `ffmpeg -y #{audio} -f gdigrab -framerate 30 #{OPTION1} -t #{time} -i title=#{title_name} #{OPTION2} Movies/#{filename}.mkv`
        `ffmpeg -i Movies/#{filename}.mkv -i Graphics/System/rec.png -filter_complex "[0:v][1:v] overlay=(W-w)/2:(H-h)/2:enable='between(t,0,20)'" -pix_fmt yuv420p -c:a copy Movies/#{filename}-rec.mkv`
        
        # loudnorm 필터는 사운드 노말라이즈를 위한 것인데 인코딩 속도가 느리다.
        if @@audio_capture_ok
          `ffmpeg -y -i Movies/#{filename}-rec.mkv -filter:a loudnorm Movies/#{filename}-rec.mp4`
        end
      elsif @@options[:DSHOW]
#~         audio = ""
#~         if @@audio_capture_ok
#~           audio = AUDIO_CAPTURE.call("virtual-audio-capturer", time)
#~         end
#~         `ffmpeg -y #{audio} -f gdigrab -framerate 30 #{OPTION1} -t #{time} -i title=#{title_name} #{OPTION2} Movies/#{filename}.mkv`
#~         `ffmpeg -i Movies/#{filename}.mkv -i Graphics/System/rec.png -filter_complex "[0:v][1:v] overlay=(W-w)/2:(H-h)/2:enable='between(t,0,20)'" -pix_fmt yuv420p -c:a copy Movies/#{filename}-rec.mkv`
      end
      
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
      
      src = "Movies/#{filename}.mkv"
      File.delete(src) if FileTest.exist?(src)
      src = "Movies/#{filename}-rec.mkv"
      File.delete(src) if FileTest.exist?(src)
      
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
  
  p FFMPEG.check_virtual_driver
  
  if FFMPEG.stereo_mix_exist?
    p "Stereo Mix is detected!"
    @@audio_capture_ok = true
  else
    p "Stereo Mix does not detect!"
    @@audio_capture_ok = false
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