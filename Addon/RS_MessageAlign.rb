#==============================================================================
# ** 메시지 정렬 1.0.1 (RPG Maker VX Ace)
#==============================================================================
# Name        : 메시지 정렬
# Author      : 러닝은빛(biud436)
# Version     : 1.0.1
# Description : 한글 메시지 시스템 스크립트가 필요합니다.
# Version Log : 
# 2019.02.25 (v1.0.1) : 
# text_width_ex 메서드의 이름을 text_width_ex2로 변경하였습니다.
#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
#
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_MessageAlign"] = true

class Game_Message
  attr_accessor :align
  #--------------------------------------------------------------------------
  # * clear
  #--------------------------------------------------------------------------
  alias hms_gm_clear clear
  def clear
    hms_gm_clear
    @align = 0
  end
end
#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#
#==============================================================================
class Window_Message < Window_Base
  #--------------------------------------------------------------------------
  # * convert_escape_characters
  #--------------------------------------------------------------------------
  alias hms_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    result = hms_convert_escape_characters(text)
    result.gsub!(/(?:\e정렬자)\[(\d+)\]/i) do
      $game_message.align = $1.to_i
      ""
    end
    result
  end
  #--------------------------------------------------------------------------
  # * process_align
  #--------------------------------------------------------------------------
  def process_align(text, pos)
    case $game_message.align
    when 1
      set_align_center(text, pos)
    when 2
      set_align_right(text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # * process_new_line
  #--------------------------------------------------------------------------
  alias hms_process_new_line process_new_line
  def process_new_line(text, pos)
    hms_process_new_line(text, pos)
    process_align(text, pos)
  end
  #--------------------------------------------------------------------------
  # * set_align_center
  #--------------------------------------------------------------------------
  def set_align_center(text, pos)
    tx = text_width_ex2(text)
    pos[:x] = (new_line_x + contents_width + self.padding) / 2 - (tx / 2)
  end
  #--------------------------------------------------------------------------
  # * set_align_right
  #--------------------------------------------------------------------------
  def set_align_right(text, pos)
    tx = text_width_ex2(text)
    pos[:x] = (contents_width - self.padding) - tx
  end
  #--------------------------------------------------------------------------
  # * text_processing
  #--------------------------------------------------------------------------
  def text_processing(text)
    f = text.dup
    f.gsub!("\\") { "\e" }
    f.gsub!("\e\e") { "\\" }
    f.gsub!(/\e[\$\.\|\!\>\<\^]/) { "" }
    f.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }
    f.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }
    f.gsub!(/(?:\eN|\e주인공)\[(\d+)\]/i) { actor_name($1.to_i) }
    f.gsub!(/(?:\eP|\e파티원)\[(\d+)\]/i) { party_member_name($1.to_i) }
    f.gsub!(/(?:\eG|\e골드)/i)          { Vocab::currency_unit }
    f.gsub!(/\e색\[(.+?)\]/) { "" }
    f.gsub!(/\e테두리색!\[(.+)\]/) { "" }
    f.gsub!(/\e#([\p{Latin}\d]+)!/) { "" }
    f.gsub!(RS::CODE["이름"]) { "" }
    f.gsub!(RS::CODE["말풍선"]) { "" }
    f.gsub!(/\e효과음!\[(.+?)\]/i) { "" }
    f.gsub!(/\e속도!\[\d+\]/) { "" }
    f.gsub!(/\e크기!\[\d+\]/) { "" }
    f.gsub!(/\e굵게!/) { "" }
    f.gsub!(/\e이탤릭!/) { "" }
    f.gsub!(/\e테두리!/) { "" }
    f.gsub!(/\e그림!\[(.+?)\]/) { "" }
    f.gsub!(/\e정렬자\[(\d+)\]/i) { "" }
    f
  end
  #--------------------------------------------------------------------------
  # * text_width_ex
  #--------------------------------------------------------------------------
  def text_width_ex2(text)
    temp_text = text_processing(text)
    text_size(temp_text.split(/[\n]+/)[0]).width
  end
  #--------------------------------------------------------------------------
  # * new_page
  #--------------------------------------------------------------------------
  alias hms_new_page new_page
  def new_page(text, pos)
    hms_new_page(text, pos)
    process_align(text, pos)
  end
end
