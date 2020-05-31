#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
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
  
  class Game_Event < Game_Character
    def load_text(index, list = [])
      
      # 맵 데이터 로드
      map_data_file_name = sprintf("Data/Map%03d.rxdata", @map_id)
      map = load_data(map_data_file_name)
      id = @id
      
      events = map.events[id]
      
      # 이벤트 목록이 없을 때, 오류 처리
      if not events
        raise "이벤트 목록이 없습니다"
      end
      
      page_index = @event.pages.index(@page)
      
      # 페이지가 없을 때, 오류 처리
      if not page_index
        raise "페이지 인덱스가 없습니다."
      end
      
      # 이벤트 목록이 없을 때, 오류 처리
      if not events.pages[page_index].list
        raise "이벤트 목록이 없습니다"
      end
      
      # 특정 이벤트 목록 삭제
      events.pages[page_index].list.slice!(index, 1)
      
      # 특정 인덱스에 이벤트 목록 추가
      list.each_with_index do |command, i|
        events.pages[page_index].list.insert(index + i, command)
      end
            
      save_data(map, map_data_file_name)
      
    end
  end  

  class Interpreter
    def import(filename)
      return false if $game_temp.message_text != nil
      return false if not File::exist?(filename)
      
      # 파일을 오픈한다.
      f = File.open(filename, 'r')
      
      line_count = 0
      
      # 파일을 읽는다.
      lines = f.readlines
      
      # 파일을 닫는다.
      f.close

      skip = false
      
      # 메시지 대기
      @message_waiting = true
      # 대기를 해제하는 콜백
      $game_temp.message_proc = Proc.new { @message_waiting = false }
      # 메소드 포인터
      m = $game_temp.method(:add_text)
      
      list = []
          
      lines.each_with_index do |e, idx|
        e.gsub!(/[\r\n]+/i, "") # 라인 개행 문자 제거
        e.gsub!("\xEF\xBB\xBF", "") # UTF-8 Byte Order Mark(BOM) 제거
        
        # 첫번째 라인 스캔
        if line_count == 0
          if e =~ /(?:#)(.*)$/i
            e.gsub!("# ", "")
            skip = false
          else
            skip = true
          end
        end
          
        # 비어있는 라인 스킵
        next if skip
        
        current_list = @list[@index]
        
        # 이벤트 깊이 탐색
        current_indent = 0
        if @list[@index]
          current_indent = @list[@index].indent rescue 0
        end
        
        # 라인의 시작이 "#"인지 확인
        if e =~ /(?:#)(.*)$/i && line_count < 4
          m.call("\\f") # 새 페이지 작성      
          e.gsub!("# ", "")
          line_count = 0
          skip = false
        end
        
        case line_count
        when 0..2
          m.call(e)
          list.push( RPG::EventCommand.new(line_count == 0 ? 101 : 401, current_indent, [e + "\\n"]))
          line_count += 1
        when 3
          m.call(e + "\\f")
          list.push( RPG::EventCommand.new(401, current_indent, [e + "\\f"]))
          line_count = 0
        end        
        
      end
      
      # 커먼 이벤트가 아니라면 재작성한다.
      if @event_id != 0
        $game_map.events[@event_id].load_text(@index, list)
      end
      
    end    
  end
      
end