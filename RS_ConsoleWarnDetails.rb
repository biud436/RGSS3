#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# ** 자세한 오류 출력 및 로그 저장
# Author : biud436
# Version Log : 
# 2019.12.21 (v1.0.0) : First Release
# 2020.02.07 (v1.0.1) :
# - Fixed an issue about the error location.
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_ConsoleWarnDetails"] = true

module RS
  module ConsoleWarnDetails
  
    # 오류를 기록할 디버그 로그 파일의 이름
    # 바탕화면에 저장하고 싶다면 다음과 같습니다.
    #   예:) File.join(ENV["HOME"], "Desktop", "debug.log")
    DEBUG_FILE_NAME = "debug.log"
    
    # 오류 시간 텍스트
    TIME_FMT = "오류 시간 : %s"
    
    # 오류 타입 텍스트
    ERROR_TYPE_FMT = "오류 타입 : %s"
    
    # 오류 스크립트 텍스트
    SCRIPT_NAME_FMT = "오류가 난 스크립트 : %s"
    
    # 오류 라인 텍스트
    SCRIPT_LINE_FMT = "오류가 발생한 라인 : %d"
    
    # 오류가 난 스크립트 토큰
    SCRIPT_TOKEN_FMT = "오류가 발생한 토큰 : %s"
    
    # 자세한 오류
    SCRIPT_DETAIL_ERROR_FMT = "%s --> %d번 라인, %s에서 오류"
    
    # 오류 메시지 텍스트
    ERROR_MESSAGE_FMT = "오류 메시지 : %s"
    ERROR_BACKTRACE_FMT = "오류 스택 : "
    
    # true이면 콘솔에만 오류를 표시하고 게임을 계속 진행합니다.
    # false면 오류를 전달하고 오류와 함께 게임이 종료 됩니다.
    # false면 저장하지 않은 모든 데이터를 잃게 됩니다 (기본값은 false)
    INLINE = false
    
    # true이면 모든 영역에서 자세한 오류 출력
    # false면 Game_Character와 Game_Interpreter에서만 자세한 오류 출력
    # true을 사용하면 모든 곳에서 자세한 오류를 출력합니다.
    ALL = true
    
    def self.extract(lines, backtraces)
      return if backtraces && !backtraces.is_a?(Array)
      backtraces.each do |t|
        if t =~ /^\{(\d+)\}\:(\d+)\:(.*)/    
          script_name = $RGSS_SCRIPTS[$1.to_i][1]
          script_line = $2.to_i
          script_token = $3.gsub!("in ", "")
          lines << sprintf(SCRIPT_DETAIL_ERROR_FMT, script_name, script_line, script_token)
        end
      end
    end
    
    def self.trace(e)
      
      lines = []
      if $@[0].to_s =~ /^\{(\d+)\}\:(\d+)\:(.*)/
        # 오류 타입 표시
        lines << sprintf(ERROR_TYPE_FMT, $!.class.to_s)
        lines << "----------"              
        script_name = $RGSS_SCRIPTS[$1.to_i][1]
        script_line = $2.to_i
        script_token = $3.gsub!("in ", "")
        lines << sprintf(SCRIPT_DETAIL_ERROR_FMT, script_name, script_line, script_token)
      end
      # 오류 시간 표시
      lines << sprintf(TIME_FMT, Time.now.to_s)
      lines << "----------"      
      # 오류 메시지 표시
      lines << sprintf(ERROR_MESSAGE_FMT, e.message)
      lines << "----------"
      lines << ERROR_BACKTRACE_FMT
      self.extract(lines, e.backtrace)
      lines << "----------"
      f = File.open(DEBUG_FILE_NAME, "w+")
      lines.each { |line| f.puts line }
      f.close
      
      f = File.open('scripts.txt', 'w+')
      f.puts $RGSS_SCRIPTS
      f.close      
      
      if INLINE
        puts lines.join("\r\n")
      else
        error = StandardError.new(lines.join("\r\n"))
        error.set_backtrace($@)
        raise error
      end      
      
    end
  end
end

if RS::ConsoleWarnDetails::ALL
       
  def rgss_main
    loop do
      begin
        yield
        break    
      rescue RGSSReset # F12
        Audio.__reset__
        Graphics.__reset__     
      rescue NameError => e
        RS::ConsoleWarnDetails.trace(e)
      rescue => e
        RS::ConsoleWarnDetails.trace(e)
      end
    end
  end  
  
else
  
  class Game_Character < Game_CharacterBase
    alias detail_error_update_routine_move update_routine_move
    def update_routine_move
      begin
        detail_error_update_routine_move
      rescue => e
        RS::ConsoleWarnDetails.trace(e)
      end
    end  
  end
  
  class Game_Interpreter
    def command_355
      script = @list[@index].parameters[0] + "\n"
      while next_event_code == 655
        @index += 1
        script += @list[@index].parameters[0] + "\n"
      end
      begin
        eval(script)
      rescue => e
        RS::ConsoleWarnDetails.trace(e)
      end
    end  
  end
end