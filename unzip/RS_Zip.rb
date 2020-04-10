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