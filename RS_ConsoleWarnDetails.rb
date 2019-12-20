#==============================================================================
# ** 자세한 오류 출력 및 로그 저장
# Author : biud436
# Date : 2019.12.20 (v1.0.0)
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
        # 바탕화면으로 지정하고 싶다면 다음과 같습니다.
        #   예:) File.join(ENV["HOME"], "Desktop", "debug.log")
        DEBUG_FILE_NAME = "debug.log"

        # 오류 시간 텍스트
        TIME_FMT = "오류 시간 : %s"

        # 오류 메시지 텍스트
        ERROR_MESSAGE_FMT = "메시지 : %s"
        ERROR_BACKTRACE_FMT = "오류 스택 : "
        
        # true이면 콘솔에만 오류를 표시하고 게임을 계속 진행합니다.
        # false면 오류를 전달하고 오류와 함께 게임이 종료 됩니다.
        # false면 저장하지 않은 모든 데이터를 잃게 됩니다 (기본값은 false)
        INLINE = false
        
        def self.trace(e)
        
          lines = []
          lines << "----------"
          lines << sprintf(TIME_FMT, Time.now.to_s)
          lines << sprintf(ERROR_MESSAGE_FMT, e.message)
          lines << "----------"
          lines << ERROR_BACKTRACE_FMT
          lines << e.backtrace
          lines << "----------"
          
          f = File.open(DEBUG_FILE_NAME, "w+")
          lines.each { |line| f.puts line }
          f.close
          
          if INLINE
            puts lines.join("\r\n")
          else
            raise lines.join("\r\n")
          end        
          
        end
    end
end

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