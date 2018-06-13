#==============================================================================
#   Name      : 이름 입력의 처리(IME)
#   Date      : 2015.07.14
#   Author    : 러닝은빛(biud436)
#   Version   : 1.0.2
#   Update    : 2015.07.16
#             : 2015.07.24 (인자값 수정)
#==============================================================================
# ** 유니코드
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_HangulNameInputProcessing"] = true

unless defined? Unicode
  #--------------------------------------------------------------------------
  # * 유니코드 처리 모듈
  #--------------------------------------------------------------------------
  module Unicode
    MultiByteToWideChar = Win32API.new('Kernel32','MultiByteToWideChar','llpipi','i')
    WideCharToMultiByte = Win32API.new('Kernel32','WideCharToMultiByte','llpipipp','i')
    UTF_8 = 65001
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
  end
  class String
    include Unicode
  end
end

#==============================================================================
# ** IME SETUP
#==============================================================================
module IME
  #--------------------------------------------------------------------------
  # * DLL Setup
  #--------------------------------------------------------------------------
  DLL = 'RSModule.dll'
  CreateEdit = Win32API.new(DLL,'CreateEdit','ii','i')
  SetIME = Win32API.new(DLL,'SetIME','v','i')
  ReleaseIME = Win32API.new(DLL,'ReleaseIME','v','i')
  GetCharText = Win32API.new(DLL,'GetCharText','p','i')
  #--------------------------------------------------------------------------
  # * IME Setup
  #--------------------------------------------------------------------------
  def self.setup(max_char)
    CreateEdit.call(max_char, 0)
  end
end

#==============================================================================
# ** Window_NameBox (Window_NameEdit + EditBox)
#==============================================================================
class Window_NameBox < Window_Base
  attr_reader   :name
  attr_reader   :index
  attr_reader   :max_char
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize(actor, max_char)
    return false unless max_char.is_a?(Integer)
    super(get_x, get_y, 360, fitting_height(4))
    create_item(actor, max_char)
    refresh
  end
  #--------------------------------------------------------------------------
  # * X 좌표
  #--------------------------------------------------------------------------
  def get_x
    (Graphics.width - 360) / 2
  end
  #--------------------------------------------------------------------------
  # * Y 좌표
  #--------------------------------------------------------------------------
  def get_y
    (Graphics.height - (fitting_height(4) + fitting_height(9) + 8)) / 2
  end
  #--------------------------------------------------------------------------
  # * IME 초기화
  #--------------------------------------------------------------------------
  def create_item(actor, max_char)
    @actor = actor
    @max_char = max_char
    IME.setup(@max_char)
    @buf = "\u0000" * 128
    @key_state = Win32API.new('user32','GetAsyncKeyState','i','i')
    IME::SetIME.call
  end
  #--------------------------------------------------------------------------
  # * 페이스칩 폭
  #--------------------------------------------------------------------------
  def face_width
    return 96
  end
  #--------------------------------------------------------------------------
  # * 왼쪽 여백
  #--------------------------------------------------------------------------
  def left
    name_center = (contents_width + face_width) / 2
    name_width = (@max_char + 1) * char_width
    return [name_center - name_width / 2, contents_width - name_width].min
  end
  #--------------------------------------------------------------------------
  # * 글자의 폭
  #--------------------------------------------------------------------------
  def char_width
    text_size($game_system.japanese? ? "あ" : "A").width
  end
  #--------------------------------------------------------------------------
  # * 텍스트 영역
  #--------------------------------------------------------------------------
  def item_rect(index)
    Rect.new((left - left / 3) + index * char_width , 5 + line_height * 2, char_width, line_height)
  end
  #--------------------------------------------------------------------------
  # * 밑줄 영역
  #--------------------------------------------------------------------------
  def underline_rect(index)
    rect = item_rect(index)
    rect.x += 1
    rect.y += rect.height - 4
    rect.width -= 2
    rect.height = 2
    rect
  end
  #--------------------------------------------------------------------------
  # * 밑줄의 색상
  #--------------------------------------------------------------------------
  def underline_color
    color = normal_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # * 핸들러
  #--------------------------------------------------------------------------
  def set_handler=(handler)
    @handler = handler
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    super
    refresh
    keyboard_check
  end
  #--------------------------------------------------------------------------
  # * 키보드 체크(엔터키)
  #--------------------------------------------------------------------------
  def keyboard_check
    @handler.call if @key_state.call(13) == 0x8000
  end
  #--------------------------------------------------------------------------
  # * 밑줄 그리기
  #--------------------------------------------------------------------------
  def draw_underline(index)
    contents.fill_rect(underline_rect(index), underline_color)
  end
  #--------------------------------------------------------------------------
  # * 텍스트 그리기
  #--------------------------------------------------------------------------
  def draw_char(index)
    rect = item_rect(index)
    rect.x -= 1
    rect.width += 4
    change_color(normal_color)
    draw_text(rect, @name[index] || "")
  end
  #--------------------------------------------------------------------------
  # * 묘화
  #-------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_text(left - left / 3, line_height , 140, line_height, "이름을 입력하세요" )
    @buf = "\u0000" * 128
    IME::GetCharText.call(@buf)
    draw_actor_face(@actor, 0, 0)
    @name = @buf.unicode_s.strip
    @index = @name.size
    @max_char.times {|i| draw_underline(i) }
    @name.size.times {|i| draw_char(i) }
    cursor_rect.set(item_rect(@index))
  end
end

#==============================================================================
# ** Scene_NameBox
#==============================================================================
class Scene_NameBox < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * 준비
  #-------------------------------------------------------------------------
  def prepare(actor_id, max_char)
    @actor_id = actor_id
    @max_char = max_char
  end
  #--------------------------------------------------------------------------
  # * 시작
  #-------------------------------------------------------------------------
  def start
    super
    @actor = $game_actors[@actor_id]
    @edit_window = Window_NameBox.new(@actor, @max_char)
    @edit_window.set_handler = method(:on_input_ok)
  end
  #--------------------------------------------------------------------------
  # * 종료
  #-------------------------------------------------------------------------
  def on_input_ok
    @actor.name = @edit_window.name
    return_scene
    IME::ReleaseIME.call
  end
end

#==============================================================================
# ** Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * 이름 입력의 처리
  #-------------------------------------------------------------------------
  def command_303
    return if $game_party.in_battle
    if $data_actors[@params[0]]
      SceneManager.call(Scene_NameBox)
      SceneManager.scene.prepare(@params[0], @params[1])
      Fiber.yield
    end
  end
end
