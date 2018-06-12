# ==============================================================
# 작성자 : 러닝은빛
# 작성일 : 2018.06.13
# ==============================================================
module VARIABLE
  ID = 5
end

$Imported = {} if not defined? $Imported
$Imported["RS_VariableWindow"] = true

class Window_Variable < Window_Base
  def initialize
    super(0, 0, window_width, fitting_height(1))
    refresh
  end    
  def window_width
    return 160
  end
  def draw_text_ex(x, y, text)
    reset_font_settings
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
    return pos[:x]
  end  
  def text
    "\\v[#{VARIABLE::ID}]"
  end
  def size
    text_size(text).width
  end
  def padding
    window_width + 10
  end
  def refresh
    contents.clear
    pos = draw_text_ex(padding, 0, text) - padding
    width = contents_width
    width -= pos
    width -= 8
    draw_text_ex(width, 0, text)
  end
end

class Scene_Menu < Scene_MenuBase
  alias xxxx_start start
  def start
    xxxx_start
    create_variable_window
  end    
  def create_variable_window
    @variable_window = Window_Variable.new
    @variable_window.x = 0
    @variable_window.y = @gold_window.y - @variable_window.height
  end
end


