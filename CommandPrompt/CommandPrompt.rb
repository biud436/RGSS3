#==============================================================================
#   Name      : Ruby Command Prompt (RPG Maker VX Ace)
#   Date      : 2015.07.14
#   Author    : 러닝은빛(biud436)
#   Version   : 1.0.4 (2015.08.03)
#   Link      : http://biud436.blog.me/220419412203
#==============================================================================
# ** 설정
#==============================================================================
module RS
  #--------------------------------------------------------------------------
  # * 기본 설정
  #--------------------------------------------------------------------------
  VERSION = "1.0.4"
  TEXT_LENGTH = 40
  CHAT_TOGGLE = 0xC0
  DEFAULT_MESSAGE = "> 명령어를 입력하세요."
end

#==============================================================================
# ** 유니코드
#==============================================================================
unless defined? Unicode
  #--------------------------------------------------------------------------
  # * 유니코드 처리 모듈
  #--------------------------------------------------------------------------
  module Unicode
    MultiByteToWideChar = Win32API.new('Kernel32','MultiByteToWideChar','llpipi','i')
    WideCharToMultiByte = Win32API.new('Kernel32','WideCharToMultiByte','llpipipp','i')
    # 코드 페이지
    UTF_8 = 65001
    #--------------------------------------------------------------------------
    # * MBCS(멀티바이트) -> WBCS(유니코드)
    #--------------------------------------------------------------------------
    def unicode!
      buf = "\0" * (self.size * 2 + 1)
      MultiByteToWideChar.call(UTF_8, 0, self, -1, buf, buf.size)
      buf
    end
    #--------------------------------------------------------------------------
    # * WBCS(유니코드) -> MBCS(멀티바이트)
    #--------------------------------------------------------------------------
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
# ** IME
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
    CreateEdit.call(max_char,0)
  end
end

#==============================================================================
# ** Color
#==============================================================================
class Color
  #--------------------------------------------------------------------------
  # * 흰색
  #--------------------------------------------------------------------------
  def self.White
    new(255,255,255,255)
  end
end

#==============================================================================
# ** Carat (커서)
#==============================================================================
class Carat
  VK_HOME = 0x24
  VK_END = 0x23
  VK_RIGHT = 0x27
  VK_LEFT = 0x25
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize(text_box)
    @body = Sprite.new
    @body.visible = false
    @state = false
    @text = ""
    @body.x = text_box.x
    @body.y = text_box.y
    @body.z = text_box.z + 1
    @body.bitmap = Bitmap.new(1,Font.default_size)
    @rect = Rect.new(0,0,2,Font.default_size)
    @body.bitmap.fill_rect(@rect, Color.White)
    @pos = -1
  end
  #--------------------------------------------------------------------------
  # * Visible (State)
  #--------------------------------------------------------------------------
  def visible(t)
    @body.visible = t
    @state = t
  end
  #--------------------------------------------------------------------------
  # * 키 체크 (확장)
  #--------------------------------------------------------------------------
  def pressed?(vkey)
    Win32API.new('user32','GetAsyncKeyState','i','i').call(vkey) & 1 != 0
  end
  #--------------------------------------------------------------------------
  # * 캐럿의 위치 설정
  #--------------------------------------------------------------------------
  def set_pos(n, text)
    return @pos unless n.between?( -1 + (-text.size) , -1 )
    @pos = n
  end
  #--------------------------------------------------------------------------
  # * 캐럿의 위치
  #--------------------------------------------------------------------------
  def pos(text_box, text = "")
    if @text == text
      set_pos( @pos - 1, @text )         if pressed?(VK_LEFT)
      set_pos( @pos + 1, @text )         if pressed?(VK_RIGHT)
      @pos = text.size                  if pressed?(VK_END)
      @pos = (-text.size) - 1           if pressed?(VK_HOME)
    else
      @pos = -1
    end

    @text = text

    rect = @body.bitmap.text_size(text[0..@pos])
    @body.x = text_box.x + rect.width
    @body.y = text_box.height / 2 - Font.default_size / 2
  end
  #--------------------------------------------------------------------------
  # * 캐럿의 깜빡임
  #--------------------------------------------------------------------------
  def update
    if @state
      @body.visible = !@body.visible if (Graphics.frame_count % 15) == 0
    end
  end
  #--------------------------------------------------------------------------
  # * Carat Dispose
  #--------------------------------------------------------------------------
  def dispose
    @body.dispose
  end
end

#==============================================================================
# ** EditBox
#==============================================================================
class EditBox
  KEY_STATE = Win32API.new('user32','GetAsyncKeyState','i','i')
  attr_accessor :x, :y, :visible, :flag
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize(x,y,width,height)
    @rect = Rect.new(x,y,width,height)
    @x, @y, @width, @height = x, y, width, height
    create_background
    @state = false                      # EditBox 상태 토글
    @visible = true
    create_text
  end
  #--------------------------------------------------------------------------
  # * 배경 생성
  #--------------------------------------------------------------------------
  def create_background
    @back = Sprite.new
    @back.bitmap = Bitmap.new(@width, @height)
    @back.bitmap.fill_rect( @rect , Color.new(0,0,0,128) )
    @back.z = 499
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    if @fiber
      @fiber.resume
    elsif input_update && !$game_message.busy?
      @fiber = Fiber.new { run }
    end
  end
  #--------------------------------------------------------------------------
  # * 핸들러
  #--------------------------------------------------------------------------
  def set_handler=(_method)
    @p_method = _method
  end
  #--------------------------------------------------------------------------
  # * 스프라이트 생성
  #--------------------------------------------------------------------------
  def create_text
    @text_sprite = Sprite.new
    @text_sprite.z = 500
    @text_sprite.bitmap = Bitmap.new(@width,@height)
    @text_sprite.bitmap.font.color = Color.White
    @text_sprite.bitmap.draw_text(@rect,RS::DEFAULT_MESSAGE)
    @carat = Carat.new(@text_sprite)
  end
  #--------------------------------------------------------------------------
  # * 텍스트 업데이트
  #--------------------------------------------------------------------------
  def text_update
    return unless @text_sprite
    @text_sprite.update
    @text_sprite.x = @x
    @text_sprite.y = @y
  end
  #--------------------------------------------------------------------------
  # * 텍스트 지우기
  #--------------------------------------------------------------------------
  def text_bitmap_clear
    @text_sprite.bitmap.clear
  end
  #--------------------------------------------------------------------------
  # * Input 업데이트
  #--------------------------------------------------------------------------
  def input_update
    return false unless KEY_STATE.call(RS::CHAT_TOGGLE) & 1 != 0
    return true
  end
  #--------------------------------------------------------------------------
  # * 시작 여부 판단
  #--------------------------------------------------------------------------
  def state_ok?
    @state == true
  end
  #--------------------------------------------------------------------------
  # * 텍스트 편집 끝내기
  #--------------------------------------------------------------------------
  def end_edit
    @p_method.call( (@flag || "") + @text )
    text_bitmap_clear
    @text_sprite.bitmap.draw_text(@rect,RS::DEFAULT_MESSAGE)
    @buf = "\u0000" * 128
    @text = ""
    @state = false
    @carat.visible(false)
    @carat.update
    IME::ReleaseIME.call
  end
  #--------------------------------------------------------------------------
  # * Execute
  #--------------------------------------------------------------------------
  def run
    start_edit
    loop do
      @carat.update
      text_update
      Graphics.update
      get_input
      Input.update
      break if KEY_STATE.call(0x0D) == 0x8000
    end
    end_edit
    @fiber = nil
  end
  #--------------------------------------------------------------------------
  # * 텍스트 편집 시작
  #--------------------------------------------------------------------------
  def start_edit
    @buf = "\u0000" * 128
    @text = ""
    IME::SetIME.call
    @state = true
    @carat.visible(true)
    @carat.pos(@text_sprite)
  end
  #--------------------------------------------------------------------------
  # * 텍스트 비트맵 해방
  #--------------------------------------------------------------------------
  def dispose
    return unless @text_sprite
    @text_sprite.bitmap.dispose
    @text_sprite.dispose
    @back.dispose
    @carat.dispose
  end
  #--------------------------------------------------------------------------
  # * 텍스트 처리
  #--------------------------------------------------------------------------
  def get_input
    return unless @state
    text_bitmap_clear if @text != @buf
    IME::GetCharText.call(@buf)
    @text = @buf.unicode_s
    @text_sprite.bitmap.draw_text(0, 0, @width, @height,@text) if @text != 0
    @carat.pos(@text_sprite, @text )
  end
end

#==============================================================================
# ** Scene_Map
#==============================================================================
class Scene_Map < Scene_Base
  alias editbox_addon_start start
  alias editbox_addon_update update
  alias editbox_addon_terminate terminate
  def start
    editbox_addon_start
    IME.setup(RS::TEXT_LENGTH)
    @edit_box = EditBox.new( 0, 0, 544, 48 )
    @edit_box.x = 0
    @edit_box.y = 0
    @edit_box.set_handler = method(:compile)
  end
  def compile(str)
    begin
      result = RubyVM::InstructionSequence.compile(str)
      puts result.disasm
    rescue Exception => msg
      msgbox("코드가 잘못되었습니다(#{msg})")
    end
    result.eval if result
  end
  def update
    editbox_addon_update
    @edit_box.update
  end
  def terminate
    editbox_addon_terminate
    @edit_box.dispose
  end
end
