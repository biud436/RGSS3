#==============================================================================
# Name       : 이름 입력의 처리
# Author     : biud436
# Version    : 1.0.3
# Update Log : 
# 2015.07.14 (v1.0.0)
# 2015.07.16 (v1.0.1)
# 2015.07.24 (v1.0.2) : 인자값 수정
# 2019.09.24 (v1.0.3) 
# - 로케일 체크를 하여 정밀한 텍스트 폭 계산
# - 텍스트 커서 이동 기능
#==============================================================================
# 설치
#==============================================================================
# 스크립트를 구동하려면 DLL 파일을 필요합니다.
# 다음 링크에서 내려 받은 후, Game.exe와 같은 폴더에 위치시켜주세요
#
# https://github.com/biud436/RGSS3/raw/master/CommandPrompt/RSEditHost.dll
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
# ** IME
#==============================================================================
module IME
  #--------------------------------------------------------------------------
  # * DLL Setup
  #--------------------------------------------------------------------------
  DLL = 'RSEditHost.dll'
  
  # 에디트 박스를 보이지 않는 상태로 동적으로 생성하고 포커스를 설정한다
  CreateEdit = Win32API.new(DLL,'CreateEdit','ii','i')
  
  # 에디트 박스에 포커스를 설정한다
  SetIME = Win32API.new(DLL,'SetIME','i','i')
  
  # 에디트 박스를 제거하고 화면에 포커스를 설정한다
  ReleaseIME = Win32API.new(DLL,'ReleaseIME','v','i')
  
  # 에디트 박스 내의 전체 문장을 가져온다
  GetCharText = Win32API.new(DLL,'GetCharText','p','i')
  
  # 에디트 박스의 EditProc에서 마지막으로 조합된 한글 문자를 가져온다
  GetLastChar = Win32API.new(DLL, 'GetLastChar', 'v', 'p')
  
  # 에디트 박스의 EditProc에서 현재 조합 중인 한글 문자를 가져온다
  GetCompStr = Win32API.new(DLL, 'GetCompStr', 'v', 'p')
  
  # 특수 문자와 이스케이프를 포함한 문장의 폭을 가져올 수 있다
  # 하지만 폰트 선택이 되어있지 않기 때문에 폰트에 따라 폭이 달라지므로 부정확하다
  GetTextWidth = Win32API.new(DLL, 'GetTextWidth', 'pi', 'l')
  
  # 캐럿의 현재 인덱스를 가져온다
  GetCaretIndex = Win32API.new(DLL, 'GetCaretIndex', 'v', 'i')
  
  #--------------------------------------------------------------------------
  # * IME Setup
  #--------------------------------------------------------------------------
  def self.setup(max_char)
    CreateEdit.call(max_char,0)
  end
  #--------------------------------------------------------------------------
  # * 폭 (폰트 선택이 되어있지 않기 때문에 정확하지 않음)
  #--------------------------------------------------------------------------  
  def self.width(str, c)
    l = GetTextWidth.call(str.unicode!, c)
  end
  #--------------------------------------------------------------------------
  # * 한글 문자 체크
  #--------------------------------------------------------------------------    
  def self.double_byte?(str)
    return false if not str.is_a?(String)
    return true if str =~ /[가-힣]/
    return true if str =~ /[ㄱ-ㅎ]/
    return false
  end
  #--------------------------------------------------------------------------
  # * 특수 문자 체크
  #--------------------------------------------------------------------------    
  def self.specific_char?(str)
    return false if not str.is_a?(String)
    code = str.ord
    return true if code.between?(32, 47)
    return true if code.between?(58, 64)
    return false
  end
  #--------------------------------------------------------------------------
  # * 숫자 문자 체크
  #--------------------------------------------------------------------------    
  def self.number_char?(str)
    return false if not str.is_a?(String)
    code = str.ord
    return true if code.between?(48, 57)
    return false
  end
  
end

# Author : biud436 
# Date : 2019.05.12
# Usage : 
#   Font.default_name = if Locale.check?('ko-KR')
#     ["나눔고딕", "VL Gothic"]
#   elsif Locale.check?('ja-JP')
#     ["Meiryo", "VL Gothic"]
#   else
#     ["VL Gothic"]
#   end
module Locale
  GetUserDefaultLCID = Win32API.new('Kernel32', 'GetSystemDefaultUILanguage', 'v', 'l')
  GetUserDefaultLocaleName = Win32API.new('Kernel32', 'GetUserDefaultLocaleName', 'pl', 'l')
  
  @@locale = ""
  c = "\0" * 255
  GetUserDefaultLocaleName.call(c, 255)
  @@locale = c.delete("\0")
  
  def self.check?(locale)
    @@locale.include?(locale)
  end
  
  def self.get
    @@locale
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
    @buf = "\u0000" * 128
    @key_state = Win32API.new('user32','GetAsyncKeyState','i','i')
    IME::SetIME.call(@max_char)
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
    if Locale.check?('ko-KR')
      text_size("가").width
    elsif Locale.check?('ja-JP')
      text_size("あ").width
    else
      text_size("A").width
    end
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
    @handler.call if @key_state.call(0x0D) & 0x8000 != 0
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
    @index = IME::GetCaretIndex.call
    @max_char.times {|i| draw_underline(i) }
    @name.size.times {|i| draw_char(i) }
    
    width_s = 0
    if @index > 0
      text = @name.dup.slice(0, @index)
      c = text_size(text)
      width_s += c.width 
    elsif @index == 0
      width_s = 0
    end    
    
    mx = (left - left / 3)
    my = 5 + line_height * 2
    
    cursor_rect.set(Rect.new(mx + width_s, my, 1, line_height))
    
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
    IME.setup(@max_char)
  end
  #-------------------------------------------------------------------------
  # * 시작
  #-------------------------------------------------------------------------
  def start
    super
    @actor = $game_actors[@actor_id]
    @edit_window = Window_NameBox.new(@actor, @max_char)
    @edit_window.set_handler = method(:on_input_ok)
  end
  #-------------------------------------------------------------------------
  # * 종료
  #-------------------------------------------------------------------------  
  def terminate
    super
    IME::ReleaseIME.call
  end
  #-------------------------------------------------------------------------
  # * 입력 완료
  #-------------------------------------------------------------------------
  def on_input_ok
    @actor.name = @edit_window.name
    return_scene
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
