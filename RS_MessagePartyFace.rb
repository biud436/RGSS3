#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# 날짜 : 2018.08.20
# 사용법 : 
# 파티얼굴[파티원_인덱스] 또는 PF[party_member_index]
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_MessagePartyFace"] = true
if $imported["RS_HangulMessageSystem"]
  RS::CODE["명령어"] = /^[\$\.\|\^!><\{\}\\]|^[A-Z]+|^[가-힣]+[!]*/i
end
class Window_Message < Window_Base
  def obtain_escape_code(text)
    if $imported["RS_HangulMessageSystem"]
      text.slice!(RS::CODE["명령어"])
    else
      text.slice!(/^[\$\.\|\^!><\{\}\\]|^[A-Z]+/i)
    end
  end  
  alias party_member_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    result = party_member_convert_escape_characters(text)
    result.gsub!(/\\/)             { "\e" }
    result.gsub!(/\e\e/)           { "\\" }
    result.gsub!(/(?:\ePF|\e파티얼굴)\[(\d+)\]/i) { set_party_face($1.to_i); "" }
    result
  end  
  def set_party_face(index)
    $game_message.face_name = $game_party.members[index].face_name
    $game_message.face_index = $game_party.members[index].face_index 
  end
  alias party_member_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'PF'
    when '파티얼굴'
      index = obtain_escape_param(text)
      set_party_face(index)
      draw_face($game_message.face_name, $game_message.face_index, 0, 0)        
    else
      party_member_process_escape_character(code, text, pos)
    end
  end
end