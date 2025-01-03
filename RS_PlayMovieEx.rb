#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
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
# 2020.03.28 (v1.0.6) :
# - Added a new feature that can download the ffmpeg during the game.
# - Fixed the bug that place the window position incorrectly when playing the movie using FFPLAY.
# 2022.03.05 (v1.0.7) :
# - Fixed the bug that can't download FFMPEG due to the URL is broken.
# Desc :
# This script allows you to playback a video of specific video format such as mp4
# 
# This script requires an FFMPEG tool.
# On Windows 10, Downloads ffmpeg automatically!
#
# However, it will not download automatically on other Windows.
#
# So before starting this script, you must download the ffmpeg executable files.
# 
# it is available at 
# https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n4.4-latest-win64-lgpl-4.4.zip
#  
# Next, You must place all files in the directory called "ffmpeg-n4.4-latest-win64-lgpl-4.4/bin/"
# 
# The folder tree structure is as follows:
# 
# | Game.exe
# |
# | ffmpeg-n4.4-latest-win64-lgpl-4.4
#   | 
#   | bin
#     | ffmpeg.exe
#     | ffplay.exe
#     | ffprobe.exe
#   | doc
#   | presets
#   | LICENSE.txt
#   | README.txt
#
# This script has a screen recording function. 
# To use the screen replay feature, You place overlay-image at Graphics/Systems/rec.png
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

module Pipe

  FindWindowW = Win32API.new('user32.dll', 'FindWindowW', 'pp', 'l')
  
  GAME_TITLE = INI.read_string("Game", "Title", "Game.ini")
  HWND = FindWindowW.call("RGSS Player".unicode!, GAME_TITLE.unicode!)  

  # BOOL WINAPI CreatePipe(PHANDLE,PHANDLE,LPSECURITY_ATTRIBUTES,DWORD);
  CreatePipe = Win32API.new("Kernel32", "CreatePipe", "PPPL", "L")

  # BOOL WINAPI SetStdHandle(DWORD,HANDLE);
  SetStdHandle = Win32API.new("Kernel32", "SetStdHandle", "LL", "L")

  # HANDLE WINAPI CreateNamedPipeW(LPCWSTR,DWORD,DWORD,DWORD,DWORD,DWORD,DWORD,LPSECURITY_ATTRIBUTES);
  CreateNamedPipeW = Win32API.new("Kernel32", "CreateNamedPipeW", 'PLLLLLLP', 'L')

  # BOOL WINAPI ConnectNamedPipe(HANDLE,LPOVERLAPPED);
  ConnectNamedPipe = Win32API.new("Kernel32", "ConnectNamedPipe", 'LP', 'L')

  # BOOL WINAPI DisconnectNamedPipe(HANDLE);
  DisconnectNamedPipe = Win32API.new("Kernel32", "DisconnectNamedPipe", 'L', 'L')

  # BOOL WINAPI FlushFileBuffers(HANDLE);
  FlushFileBuffers = Win32API.new("Kernel32", "FlushFileBuffers", 'L', 'L')

  # BOOL WINAPI DuplicateHandle(HANDLE,HANDLE,HANDLE,PHANDLE,DWORD,BOOL,DWORD);
  DuplicateHandle = Win32API.new("Kernel32", "DuplicateHandle", "LLLPLLLL", "L")

  # HANDLE WINAPI GetStdHandle(DWORD);
  GetStdHandle = Win32API.new("kernel32", "GetStdHandle", "L", "L")

  # BOOL WINAPI SetStdHandle(DWORD,HANDLE);
  SetStdHandle = Win32API.new("kernel32", "SetStdHandle", "LL", "L")

  # HANDLE GetCurrentProcess();
  GetCurrentProcess = Win32API.new("kernel32", "GetCurrentProcess", "V", "L")

  # BOOL WINAPI SetHandleInformation(HANDLE,DWORD,DWORD);
  SetHandleInformation = Win32API.new("Kernel32", "SetHandleInformation", "LLL", "l")

  # DWORD WINAPI GetLastError(void);
  GetLastError = Win32API.new("Kernel32", "GetLastError", "V", "L")

  # DWORD WINAPI FormatMessageW(DWORD,PCVOID,DWORD,DWORD,LPWSTR,DWORD,va_list*);
  FormatMessageW = Win32API.new("Kernel32", "FormatMessageW", "IPIIPIP", "I")

  # int WINAPI MessageBoxW (HWND, LPCWSTR, LPCWSTR, UINT);
  MessageBoxW = Win32API.new("User32", "MessageBoxW", "LPPL", "L")

  LANG_NEUTRAL = 0x00
  SUBLANG_NEUTRAL = 0x00
  SUBLANG_DEFAULT = 0x01  
  SUBLANG_KOREAN = 0x01
  LANG_ENGLISH = 0x09
  LANG_KOREAN = 0x12
  SUBLANG_ENGLISH_US = 0x01
  MAKELANGID = Proc.new do |primary, sublang| 
    (sublang << 10) | primary
  end

  LCID_ENGLISH = MAKELANGID.call(LANG_ENGLISH, SUBLANG_ENGLISH_US)
  LCID_DEFAULT  = MAKELANGID.call(LANG_NEUTRAL, SUBLANG_DEFAULT)
  LCID_KOREAN = MAKELANGID.call(LANG_KOREAN, SUBLANG_KOREAN)

  FORMAT_MESSAGE_ALLOCATE_BUFFER = 256
  FORMAT_MESSAGE_IGNORE_INSERTS = 512
  FORMAT_MESSAGE_FROM_SYSTEM = 4096

  HANDLE_FLAG_INHERIT = 0x00000001
  HANDLE_FLAG_PROTECT_FROM_CLOSE = 0x00000002  

  STD_INPUT_HANDLE = -10 # 0xfffffff6
  STD_OUTPUT_HANDLE = -11 # 0xfffffff5
  STD_ERROR_HANDLE = -12 # 0xfffffff4    
  
  PIPE_ACCESS_INBOUND = 1 # 읽기
  PIPE_ACCESS_OUTBOUND = 2 # 쓰기  
  PIPE_ACCESS_DUPLEX = 3 # 읽기와 쓰기
  
  PIPE_TYPE_BYTE = 0
  PIPE_UNLIMITED_INSTANCES = 255

  DUPLICATE_CLOSE_SOURCE = 0x00000001
  DUPLICATE_SAME_ACCESS = 0x00000002
  DUPLICATE_SAME_ATTRIBUTES = 0x00000004
  
end

module Process
  include Pipe

  CreateProcessA = Win32API.new("Kernel32", "CreateProcessA", "PPLLLLLLPP", "l")
  CreateProcessW = Win32API.new("Kernel32", "CreateProcessW", "PPLLLLLLPP", "l")
  CloseHandle =  Win32API.new("Kernel32", "CloseHandle", "l", "s")
  WaitForSingleObject = Win32API.new("Kernel32", "WaitForSingleObject", "ll", "l")
    
  # 파일 읽기
  CreateFile = Win32API.new("Kernel32", "CreateFileW", "PLLPLLL", "L")
  ReadFile = Win32API.new("Kernel32", "ReadFile", "LPLPP", "L")
  WriteFile = Win32API.new('Kernel32', 'WriteFile', 'LPLPP', 'L') 
  ReadConsoleOutputCharacterW = Win32API.new("Kernel32", "ReadConsoleOutputCharacterW", "LPLLP", "L")

  GENERIC_READ = 0x80000000
  GENERIC_WRITE = 0x40000000
  GENERIC_EXECUTE = 0x20000000
  CREATE_NEW = 1
  CREATE_ALWAYS = 2
  OPEN_EXISTING = 3
  OPEN_ALWAYS = 4
  TRUNCATE_EXISTING = 5

  # 핸들 상수
  INFINITE = 0xFFFFFFFF
  INVALID_HANDLE_VALUE = 0xFFFFFFFF
  
  # 표준 출력 리다이렉션
  @@std_redirection = false
  # 표준 오류 리다이렉션
  @@err_redirection = false

  STD_REDIR_OUT_FILENAME = "std_redir_out.txt"
  STD_REDIR_ERR_FILENAME = "std_redir_err.txt"
  
  @@wait_mode = true
  
  def self.no_wait
    @@wait_mode = false
  end
  
  def self.set_wait_mode
    @@wait_mode = true
  end
  
  def self.create_startup_info(stdout, stderr)
    x, y, w, h = [0, 0, 0, 0]
    startf_usesize = 0x00000002
    startf_useposition = 0x00000004
    startf_usestdhandles = 0x00000100
    flag = startf_usesize | startf_useposition | startf_usestdhandles
    
    std_output = stdout || Win32API.new("kernel32", "GetStdHandle", "l", "l").call(-11)
    std_error = stderr || 0
    
    cb = [68, 0, 0, 0].pack("LLLL")
    b = [x, y, w, h].pack("LLLL")
    c = [0, 0, 0, flag].pack("LLLL")
    d = [0, 0, 0, 0].pack("SSLL")
    e = [std_output, std_error].pack("LL")
    
    cb + b + c + d + e
    
  end

  def self.create_process_information
    [
      0, # process
      0, # thread
      0, # process_id
      0, # thread_id
    ].pack("LLLL")
  end

  def self.close_handle(process)
    if process.is_a?(String)
      process = process.unpack("LLLL")
    end

    CloseHandle.call(process[0])
    CloseHandle.call(process[1])
  end

  def self.exec(filename)

    si = FFMPEG.create_startup_info(nil, nil)
    pi = FFMPEG.create_process_information
    
    ret = CreateProcessW.call(0, filename.unicode!, 0, 0, 1, 0, 0, 0, si, pi)

    if ret == 0
      FFMPEG.close_handle(pi)
      return false  
    end

    pi = pi.unpack("LLLL")
    ret = WaitForSingleObject.call(pi[0], INFINITE)
  
    FFMPEG.close_handle(pi)

  end
  
  def self.enable_std_redirection
    @@std_redirection = true
  end
  
  def self.disable_std_redirection
    @@std_redirection = false
  end  

  def self.catch_error

    error_code = GetLastError.call
    return if error_code == 0

    buf = ("\x00" * 1024).unicode!
        
    flags = FORMAT_MESSAGE_FROM_SYSTEM

    ret = FormatMessageW.call( flags, 0, error_code, LCID_DEFAULT, buf, 1024, 0 )

    if ret == 0
      ret = FormatMessageW.call( flags, 0, error_code, LCID_ENGLISH, buf, 1024, 0 )
    end
    
    MessageBoxW.call(HWND, buf, GAME_TITLE.unicode!, 16)
    Kernel.exit
  
  end

  def self.redirection(filename)
    handle_temp_in = GetStdHandle.call(STD_INPUT_HANDLE)
    
    stdout = GetStdHandle.call(STD_OUTPUT_HANDLE)
    stderr = GetStdHandle.call(STD_ERROR_HANDLE)      
    si = create_startup_info(stdout, stderr)
    pi = create_process_information      
    ret = CreateProcessW.call(0, filename.unicode!, 0, 0, 1, 0, 0, 0, si, pi)

    if ret == 0
      catch_error
      close_handle(pi)
      return false  
    end    

    pi = pi.unpack("LLLL")
    
    ret = WaitForSingleObject.call(pi[0], INFINITE)

    close_handle(pi)

  end
  
  def self.backtick(filename)
        
    sa = [12, 0, 1].pack("LLL")

    if @@std_redirection
      file_handle = CreateFile.call(STD_REDIR_OUT_FILENAME.unicode!, GENERIC_WRITE, CREATE_NEW|CREATE_ALWAYS, sa, 2, 0x00000080, 0)
    end
    
    if @@err_redirection
      file_error_handle = CreateFile.call(STD_REDIR_ERR_FILENAME.unicode!, GENERIC_WRITE, CREATE_NEW|CREATE_ALWAYS, sa, 2, 0x00000080, 0)    
    end
        
    stdout = GetStdHandle.call(STD_OUTPUT_HANDLE)
    stderr = GetStdHandle.call(STD_ERROR_HANDLE)
    si = create_startup_info(@@std_redirection ? file_handle : stdout, @@err_redirection ? file_error_handle : stderr)
    pi = create_process_information
    
    ret = CreateProcessW.call(0, filename.unicode!, 0, 0, 1, 0, 0, 0, si, pi)

    if ret == 0
      catch_error
      close_handle(pi)
      return false  
    end

    pi = pi.unpack("LLLL")
    
    if @@wait_mode
      ret = WaitForSingleObject.call(pi[0], INFINITE)
    end
    
    close_handle(pi)
    CloseHandle.call(file_handle) if @@std_redirection
    CloseHandle.call(file_error_handle) if @@err_redirection
    
  end
  
end

# backtick 명령어 구현
if RUBY_VERSION == "1.8.1"
  
  def `(cmd)
    raw = ""
    
    Process.backtick(cmd)
    
    if File::exist?(Process::STD_REDIR_OUT_FILENAME)
      f = File.open(Process::STD_REDIR_OUT_FILENAME, "r+")
      raw = f.read
      f.close
    end
    
    raw += "\r\n"
    
    if File::exist?(Process::STD_REDIR_ERR_FILENAME)
      f = File.open(Process::STD_REDIR_ERR_FILENAME, "r+")
      raw << f.read
      f.close
    end

    ret = raw.chomp!.ansi_to_utf8
    ret
  end
end

class File
  class << self
    def exist_safe?(filename)
      unwrap = filename.unicode!
      wrap = unwrap.unicode_s
      File::exist?(wrap)
    end
  end
end

module FFMPEG
  
  FindWindowW = Win32API.new('user32.dll', 'FindWindowW', 'pp', 'l')
  
  GAME_TITLE = INI.read_string("Game", "Title", "Game.ini")
  HWND = FindWindowW.call("RGSS Player".unicode!, GAME_TITLE.unicode!)
  
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
  AUDIO_CAPTURE = Proc.new do |device, time|
    %Q(-f dshow -ar 44100 -ac 2 -t #{time} -i audio="#{device}") 
  end
  
  # Do not try to set this manually!
  # The audio capture option is detected automatically. 
  # and now currently, the audio capturer is unstable, 
  # because ffmpeg's gdigrab doesn't provide the sound capture.
  @@audio_capture_ok = false
  
  # Get the locale
  # My system is used the character sets in CP949.
  @@locale = GetOEMCP.call
    
  # Downloader module can download the ffmpeg during the game.
  module Downloader

    extend self  
    
    HOST = "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n4.4-latest-win64-lgpl-4.4.zip"
    HOST_NAME = "ffmpeg-n4.4-latest-win64-lgpl-4.4/bin"
    TARGET_ZIP_FILE = "ffmpeg-n4.4-latest-win64-lgpl-4.4.zip"
    MSG = "FFMPEG 파일을 다운로드 받으시겠습니까?"
    
    MessageBox = Win32API.new('User32.dll', 'MessageBoxW', 'lppl', 'i')
    IDYES = 6
    IDNO = 7

    URLDownloadToFileW = Win32API.new("Urlmon", "URLDownloadToFileW", "ppplp", "l")
    
    module Zip

      DLL_URL = "https://github.com/biud436/RGSS3/raw/master/unzip/bin/un_zip.dll".unicode!
      DLL_FILE = File.join(Dir.pwd, "un_zip.dll").gsub("/", "\\").unicode!
      URLDownloadToFileW.call(0, DLL_URL, DLL_FILE, 0, 0)
            
      ExtractZip = Win32API.new("un_zip.dll", "extractZip", "p", "l")
      
      def self.extract(filename)
        filename = File.join(Dir.pwd, filename)
        return if not File::exist_safe?(filename)
        ExtractZip.call(filename)    
      end
    
    end    
    
    @@version = `powershell "$PSVersionTable.PSVersion.Major"`.to_i rescue 0

    # 파워쉘 버전 획득
    def version
      @@version
    end
    
    # FFMPEG 다운로드가 필요한가?
    def new_download?
      message = MSG.unicode!
      wnd_name = GAME_TITLE
      ret = MessageBox.call(FFMPEG::HWND, message, wnd_name.unicode!, 4 | 0x00000040)
      ret
    end
    
    # FFMPEG가 설치되어있는 지 여부 확인
    def exist?
      return false if !FileTest.exist?("#{Downloader::HOST_NAME}/ffmpeg.exe")
      return false if !FileTest.exist?("#{Downloader::HOST_NAME}/ffplay.exe")      
      return true
    end    
    
    # 압축 해제
    def decompress
      # Windows 10 이상
      if version >= 5
        `powershell -command "Expand-Archive -Path '#{TARGET_ZIP_FILE}' -DestinationPath '.'"`
      else
        Zip.extract(Zip::TARGET_ZIP_FILE)
      end
    end
      
    # 다운로드 시작
    def pending_download
      
      return if exist?
              
      if new_download? == IDYES
        if version >= 3
          `chcp 65001 | powershell -command "wget '#{HOST}' -OutFile '#{TARGET_ZIP_FILE}'"`
        else
          t = Thread.new do
            ret = Win32API.new("Urlmon", "URLDownloadToFileW", "ppplp", "l").call(0, HOST.unicode!, TARGET_ZIP_FILE.unicode!, 0, 0)
          end
          t.join
        end
        
        if FileTest.exist?(TARGET_ZIP_FILE)
          decompress
          
          File.delete(TARGET_ZIP_FILE)
           
        end
        
      end
      
    end
  
  end
  
  extend self
  
  # 동영상에서 음성 파일(OGG)을 추출합니다
  def extract(_in, _out)
    t = Thread.new do 
      `#{Downloader::HOST_NAME}/ffmpeg -i "#{_in}" -vn -acodec libvorbis -y "#{_out}.ogg"`
    end
  end
  
  # 특정 포맷의 영상을 OGV 파일로 변환합니다
  # FFMPEG.to_ogv("d.mp4", "f.ogv")
  def to_ogv(_in, _out)
    t = Thread.new do
      `#{Downloader::HOST_NAME}/ffmpeg -i "Movies/#{_in}" -s 544x416 -c:v libtheora -q:v 7 -c:a libvorbis -q:a 4 "Movies/#{_out}"`
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
    f = IO.popen(["#{Downloader::HOST_NAME}/ffmpeg", "-list_devices", "true", "-f", "dshow", "-i", "dummy", :err=>[:child, :out]])
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
    `#{Downloader::HOST_NAME}/ffmpeg -i #{name} -af volumedetect -f null -`
  end
  
  # OGV가 아닌 다른 영상을 재생합니다
  def play(filename)
    
    caption = GetSystemMetrics.call(SM_CYCAPTION)
    x_padding = GetSystemMetrics.call(SM_CXEDGE)
    y_padding = GetSystemMetrics.call(SM_CYEDGE)
    
    vw = Graphics.width + x_padding
    vh = Graphics.height + y_padding

    extra = fullscreen? ? "-fs -alwaysontop" : ""
    
    rt = [0,0,0,0].pack('l4')
    GetWindowRect.call(HWND, rt)    
    r = rt.unpack('l4')
    
    x = r[0] + (fullscreen? ? 0 : x_padding)
    y = r[1] + (fullscreen? ? 0 : (caption + y_padding))
    
    rt = [0,0,0,0].pack('l4')
    GetClientRect.call(HWND, rt)
    r = rt.unpack('l4')
    
    vw = (r[2] - r[0]) + x_padding
    vh = r[3] - r[1]
    
    t = Thread.new do
      `#{Downloader::HOST_NAME}/ffplay "Movies/#{filename}" -noborder -autoexit -left #{x} -top #{y} -x #{vw} -y #{vh} #{extra}`
    end
    
    ffplay_hwnd = `powershell (Get-Process -Name "ffplay").MainWindowHandle`.to_i
    
    if !ffplay_hwnd
      raise "Cannot find FFPLAY"
    end
    
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
        `#{Downloader::HOST_NAME}/ffmpeg -y #{audio} -f gdigrab -framerate 30 #{OPTION1} -t #{time} -i title=#{title_name} #{OPTION2} Movies/#{filename}.mkv`
      elsif @@options[:DSHOW]
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
        
        `#{Downloader::HOST_NAME}/ffmpeg -y #{audio} -f gdigrab -framerate 30 #{OPTION1} -t #{time} -i title=#{title_name} #{OPTION2} Movies/#{filename}.mkv`
        `#{Downloader::HOST_NAME}/ffmpeg -i Movies/#{filename}.mkv -i Graphics/System/rec.png -filter_complex "[0:v][1:v] overlay=(W-w)/2:(H-h)/2:enable='between(t,0,20)'" -pix_fmt yuv420p -c:a copy Movies/#{filename}-rec.mkv`
        
        # loudnorm 필터는 사운드 노말라이즈를 위한 것인데 인코딩 속도가 느리다.
        if @@audio_capture_ok
          `#{Downloader::HOST_NAME}/ffmpeg -y -i Movies/#{filename}-rec.mkv -filter:a loudnorm Movies/#{filename}-rec.mp4`
        end
      elsif @@options[:DSHOW]
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
    
  if FFMPEG::Downloader.exist?
  
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
      wnd_name = GAME_TITLE
      ret = Downloader::MessageBox.call(FFMPEG::HWND, "스테레오 믹스로 설정되어있지 않습니다. 스테레오 믹스 설정(소리 - 녹음) 창을 여시겠습니까?".unicode!, wnd_name.unicode!, 4 | 0x00000040)
      if ret == Downloader::IDYES
        # 스테레오 믹스창 열기
        `Rundll32.exe shell32.dll,Control_RunDLL Mmsys.cpl,,1`
      end      
    end
    
  else
    p "FFMPEG does not exist!"
    FFMPEG::Downloader.pending_download
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
