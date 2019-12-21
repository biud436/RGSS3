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
    
    # true이면 모든 영역에서 자세한 오류 출력
    # false면 Game_Character와 Game_Interpreter에서만 자세한 오류 출력
    # true을 사용하면 자세한 오류는 출력하지만 
    # 오류가 난 스크립트 에디터 라인을 자동으로 띄워주는 기능은 사용할 수 없게 됩니다.
    ALL = true
    
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

if RS::ConsoleWarnDetails::ALL
  
  # == disasm: <RubyVM::InstructionSequence:rgss_main@>=====================
  # == catch table
  # | catch type: break  st: 0004 ed: 0011 sp: 0000 cont: 0011
  # |------------------------------------------------------------------------
  # 0000 trace            8                                               (   1)
  # 0002 trace            1
  # 0004 putnil           
  # 0005 send             :loop, 0, block in rgss_main, 8, <ic:0>
  # 0011 trace            16
  # 0013 leave            
  # == disasm: <RubyVM::InstructionSequence:block in rgss_main@>============
  # == catch table
  # | catch type: rescue st: 0002 ed: 0013 sp: 0000 cont: 0014
  # == disasm: <RubyVM::InstructionSequence:rescue in block in rgss_main@>==
  # local table (size: 2, argc: 0 [opts: 0, rest: -1, post: 0, block: -1] s0)
  # [ 2] #$!        
  # 0000 getinlinecache   7, <ic:0>                                       (   1)
  # 0003 getconstant      :RGSSReset
  # 0005 setinlinecache   <ic:0>
  # 0007 getdynamic       #$!, 0
  # 0010 send             :===, 1, nil, 0, <ic:1>
  # 0016 branchunless     50
  # 0018 trace            1
  # 0020 getinlinecache   27, <ic:2>
  # 0023 getconstant      :Audio
  # 0025 setinlinecache   <ic:2>
  # 0027 send             :__reset__, 0, nil, 0, <ic:3>
  # 0033 pop              
  # 0034 trace            1
  # 0036 getinlinecache   43, <ic:4>
  # 0039 getconstant      :Graphics
  # 0041 setinlinecache   <ic:4>
  # 0043 send             :__reset__, 0, nil, 0, <ic:5>
  # 0049 leave            
  # 0050 getdynamic       #$!, 0
  # 0053 throw            0
  # | catch type: retry  st: 0013 ed: 0014 sp: 0000 cont: 0002
  # | catch type: redo   st: 0000 ed: 0014 sp: 0000 cont: 0000
  # | catch type: next   st: 0000 ed: 0014 sp: 0000 cont: 0014
  # |------------------------------------------------------------------------
  # 0000 trace            1                                               (   1)
  # 0002 trace            1
  # 0004 invokeblock      0, 0
  # 0007 pop              
  # 0008 trace            1
  # 0010 putnil           
  # 0011 throw            2
  # 0013 nop              
  # 0014 leave            
       
  def rgss_main
    loop do
      begin
        yield
        break    
      rescue RGSSReset # F12
        Audio.__reset__
        Graphics.__reset__     
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
