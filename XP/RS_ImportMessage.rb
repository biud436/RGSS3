#==============================================================================
# Name : Import Message
# Author : biud436
# Date : 2020.04.21 (v1.0.0)
# Desc : This script allows you to load the message from the text file
# Usage :
#
# # \색[빨강]소녀\색[기본색]
# 안녕하세요?
#
# # \색[빨강]소녀\색[기본색]
# 네, 반갑습니다.
#
# # \색[빨강]소녀\색[기본색]
# 안녕하세요
# 반갑습니다.
# 저는 아무것도 모릅니다.
#
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
imported = {} if imported.nil?
imported["RS_ImportMessage"] = true

if $imported["RS_HangulMessageSystem"]
  class Interpreter
    def extract(filename)
      return false if $game_temp.message_text != nil    
      f = File.open(filename, "r")
      line_count = 0
      lines = f.readlines
      skip = false
      @message_waiting = true
      $game_temp.message_proc = Proc.new { @message_waiting = false }
      
      m = $game_temp.method(:add_text)
          
      for i in lines 
        if line_count == 0
          if i.slice(0, 2) == "# "
            i.gsub!("# ", "")
            skip = false
          else
            skip = true
          end
        end
        if skip
          next
        else
          if i.slice(0, 2) == "# " && line_count < 4
            m.call("\\f")          
            i.gsub!("# ", "")
            line_count = 0
            skip = false
          end
          i.gsub!(/[\r\n]+/i, "")
          case line_count
          when 0..2
            m.call(i)
            line_count += 1
          when 3
            m.call(i + "\\f")
            line_count = 0
          end
        end
      end
      
    end
  end;end