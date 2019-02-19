#==============================================================================
# ** Hangul Message System 1.5.13 (RPG Maker VX Ace)
#==============================================================================
# Name       : Hangul Message System
# Author     : biud436
# Version    : 1.5.13
# Link       : http://biud436.blog.me/220251747366
#==============================================================================
# ** 업데이트 로그
#==============================================================================
# 2019.02.19 (v1.5.13) :
# - 폰트 크기 변경 시 말풍선의 폭과 높이가 제대로 계산되지 않는 현상 수정
# - 폰트 변경 부분 호환성 패치
# 2019.02.16 (v1.5.12) :
# - 말풍선 사용 후 일반 메시지 사용 시 글자가 잘리는 현상 수정
# 2019.01.27 (v1.5.11) :
# - 크기 및 오프셋 설정 추가
# - 노트 태그 읽는 중 생기는 오류 현상 수정
# 2018.11.09 (v1.5.9) :
# - 말풍선 모드 Background 타입에 Dim 지원
# - 노트 태그 기능 추가
# - 윈도우 스킨 변경 기능을 추가하였습니다.
# 2018.07.12 (v1.5.7) :
# - 페이스칩 Z좌표 설정 기능 추가
# - 자동 개행을 옵션에서 미리 설정할 수 있습니다.
# - 설명 보강
# 2018.06.26 (v1.5.6) :
# - draw_text_ex 추가
# - text_width_ex 추가
# 2017.06.20 :
# - 말풍선 모드에서도 얼굴 이미지 사용 가능
# - 멈춤 표시 이미지 표시
# - 말풍선 위치 화면 내로 자동 조절
# 2016.05.07 - 정규표현식 및 텍스트 매칭 코드 수정, 자동 개행 기능 추가
# 2015.10.12 - 이름 윈도우 텍스트 크기 설정
# 2015.09.06 - 화면 영역 내 메시지 표시 기능
# 2015.08.22 - 버그 수정(명령어 처리 순서 변경)
# 2015.08.11 - RGB 모듈 코드 정리
# 2015.08.08 - 이름 윈도우 폭을 텍스트 길이에 맞춤
# 2015.08.06 - 말풍선 크기 계산 방법 수정 (폭과 높이를 동적으로 계산)
# 2015.08.02 - 이름 윈도우 좌표 버그 수정, 페이스칩 클래스 추가
# 2015.07.29 - 말풍선 그래픽이 없을 때 말풍선 모드에서 이름 윈도우 위치 수정
# 2015.06.19 - 그림 삽입 기능 추가
# 2015.06.18 - 변수, 주인공, 파티원, 골드 등 새로운 명령어 추가
# 2015.06.15 - 정규표현식을 UTF_8(16진수)에서 한글로 변경, 상수를 해시로 정리
# 2015.06.11 - 페이스칩 좌표 및 정렬 기능 수정, 페이스칩 투명 처리 변경
# 2015.06.10 - 색상 불러오기 기능 추가
# 2015.06.08 - 최대 라인 수 변경 기능 업데이트
# 2015.06.03 - 사용자 정의 그래픽, 최대 라인 수 변경 기능 추가
# 2015.06.02 - 선택지 Z좌표 수정
# 2015.05.13 - 기울임꼴 문제 수정
# 2015.05.11 - 기본 폰트 사이즈를 변경할 때 생기는 말풍선 좌표 오차 수정
# 2015.04.15 - 페이스칩 반전 기능 사용 여부 스크립트 사용자 선택에 맡김
# 2015.03.21 - 코드 정리
# 2015.03.20 - 말풍선 스프라이트 추가, 말풍선으로 시작 시 창열림효과 제거, 투명도 조절
# 2015.02.20 - 저장 버그 수정
# 2015.02.16 - 말풍선 모드 추가, 효과음 재생 기능 추가, 이름 윈도우 거리 조절 기능
# 2015.02.14 - 굵게, 기울임꼴, 테두리색 추가, 버그 픽스
# 2015.02.13 - 한글 명령어 추가, 큰 페이스칩 이름 수정, 이름 윈도우 정렬 위치 수정
# 2015.02.12 - 이름 윈도우 정렬 오류 수정
# 2015.02.11 - 이름 윈도우 좌표 수정
# 2015.02.05 - 메시지 시스템 + 색상 변환 스크립트 통합
# 2015.01.26 - 버그 픽스
# 2015.01.25 - 스크립트 통합
#==============================================================================
# ** 사용법
#==============================================================================
# \이름<이벤트명>
# \말풍선[이벤트의 ID]
# \말풍선[0]
# \말풍선[-1]
# \변수[인덱스]
# \골드
# \주인공[인덱스]
# \파티원[인덱스]
# \색[색상명]
# \효과음![효과음명]
# \테두리색![색상명]
# \#색상코드!
# \굵게!
# \이탤릭!
# \속도![텍스트의 속도]
# \그림![그림파일명]
# \자동개행!
#==============================================================================
# ** 노트 태그
#==============================================================================
# 대화가 시작되기 전에 다음 노트 태그를 설정하면 메시지 설정을 바꿀 수 있습니다.
#
# <대화창 윈도우스킨:Window>
# <이름 윈도우스킨:Window>
# <대화창 투명도:255>
#
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
# ** RS
#------------------------------------------------------------------------------
# 기본 설정값입니다.
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_HangulMessageSystem"] = true

module RS

  LIST = CODE = {}

  # 폰트 리스트 예:) ["나눔고딕, "굴림"]
  # Fonts 폴더에 해당 폰트 파일에 있어야 합니다.
  # 폰트 파일과 글꼴명은 다를 수 있습니다.
  # 여기에 적는 것은 해당 폰트의 실제 글꼴명입니다.
  LIST["폰트명"] = Font.default_name
  
  # 폰트 크기를 변경합니다. 예:) Font.default_size는 기본 폰트 사이즈입니다.
  LIST["폰트크기"] = Font.default_size
  
  # 얼굴 이미지의 X좌표 설정 
  # 기준 좌표값 RS::LIST["왼쪽"] 또는 RS::LIST["오른쪽"]로부터 상대적입니다.
  # 문장의 표시 커맨드가 시작되기 전에, 다음과 같은 스크립트를 설정하면 
  #
  #   RS::LIST["X"] = -186
  #
  # 얼굴 이미지의 X좌표를 언제든지 바꿀 수가 있습니다.
  LIST["X"] = -186
  
  # 얼굴 이미지의 Y좌표 설정
  # 화면 세로 크기 - RS::LIST["Y"] - 얼굴 이미지의 세로 크기
  LIST["Y"] = 0

  # 자동 개행 설정
  # true이면 창의 폭을 넘겼을 때 자동으로 개행합니다.
  # 사용 시 정렬 기능이 제대로 동작하지 않을 수 있으니 주의 바랍니다.
  LIST["자동개행"] = true
  
  # 얼굴 이미지의 Z좌표 설정
  # 1이면 대화창 위, 
  # -1이면 대화창 뒤
  # 나중에 변경하려면 스크립트 커맨드로 변경이 가능합니다.
  # 예를 들어, RS::LIST["Z"] = -1 라고 입력하면 대화창 뒤로 얼굴 이미지가 가려집니다.
  LIST["Z"] = -1
  
  LIST["높이"] = Graphics.height - LIST["Y"]
  
  # 기본 라인 갯수
  LIST["라인"] = 4
  
  LIST["효과음"] = "Attack3"
  
  # 얼굴 이미지가 오른쪽에 위치할 경우, 이미지를 좌우 반전하여 표시합니다.
  # 페이스칩 인덱스는 왼쪽 위부터 0번이며, 그 다음이 1번인데 1번 이상일 경우,
  # 오른쪽에 표시됩니다.
  LIST["반전"] = true
  
  # 윈도우 스킨
  LIST["윈도우스킨"] = "Window"
  LIST["이름윈도우스킨"] = "Window"
  
  # 대화창의 배경 이미지를 pictures 폴더에 찾아 설정합니다. 예:) "msgback"
  LIST["바탕화면"] = nil
  
  # 얼굴 이미지를 어디에 위치시킬 지 기준 좌표를 정합니다.
  LIST["왼쪽"] = 190
  LIST["오른쪽"] = 534
  
  # 대화창의 전체 투명도를 설정합니다.
  # 투명도의 경우, 배경 창의 투명도, 텍스트의 투명도가 따로 나뉘지만
  # 여기에서는 그 둘을 포함한 전체 투명도를 조절합니다.
  LIST["투명도"] = 250
  
  # 이름 윈도우의 X좌표는 얼굴 이미지가 왼쪽에 표시되면 왼쪽에 표시되고,
  # 오른쪽에 표시되면 오른쪽에 표시합니다.
  # 스크립트 커맨드에서 RS::LIST["이름윈도우X1"] = 10 등으로 수정이 가능합니다.
  LIST["이름윈도우X1"] = 10
  LIST["이름윈도우X2"] = 210
  
  # 이름 윈도우 Y. 
  # 메시지 윈도우 Y좌표 값을 기준으로 위(+) 또는 아래(-)로 내릴 수 있습니다.
  # 위는 메시지 박스의 위쪽을 말하며, 아래는 메시지 박스와 겹쳐지는 방향을 말합니다.
  LIST["이름윈도우Y"] = 0
  
  # 얼굴 이미지가 설정되어있을 때 텍스트 시작 좌표입니다.
  LIST["텍스트시작X"] = 202
  
  # 텍스트 속도 조절 텍스트 코드를 사용하실 때의 최소, 최대 속도입니다.
  # 텍스트 속도가 1이라면 일반 글자 묘화 처리 후, 1프레임을 대기합니다.
  # 대기는 메시지 처리를 중단하고 나머지 업데이트 함수를 실행합니다.
  LIST["텍스트속도-최소"] = 0
  LIST["텍스트속도-최대"] = 8
  
  # 말풍선을 화면 영역 안으로 자동 조절하여 표시합니다.
  # 이 옵션을 설정하면 캐릭터가 가장 자리에 있을 경우, 
  # 말풍선의 중앙 지점(anchor)이 옮겨질 수 있습니다.
  LIST["화면영역내표시"] = true
  
  # 크기 및 오프셋 설정
  LIST["가로"] = (Graphics.width / 2 + Graphics.width / 3).floor
  LIST["오프셋X"] = 0
  LIST["오프셋Y"] = 0

  # 정규 표현식 (잘 아시는 분들만 건드리십시오)
  CODE["16진수"] = /#([a-zA-Z^\d]*)/i
  CODE["색상추출"] = /^\p{hangul}+|c_[a-zA-z]+$/
  CODE["명령어"] = /^[\$\.\|\^!><\{\}\\]|^[A-Z가-힣]+[!]*/i
  CODE["이름색상코드"] = /\[(\p{hangul}+[\d]*|c_[\p{Latin}]+)\]/
  CODE["웹색상"] = /([\p{Latin}\d]+)!/
  CODE["추출"] = /^(\p{hangul}+)/
  CODE["큰페이스칩"] = /^큰\_+/
  CODE["효과음"] = /^\[(.+?)\]/i
  CODE["처리!"] = /^(\p{hangul}+)!/
  CODE["이름"] = /\e이름\<(.+?)\>/
  CODE["말풍선"] = /\e말풍선\[(\d+|-\d+)\]/i
  CODE["이름추출"] = /\[(.*)\]/
  CODE["이름색상변경1"] = /\eC\[(.+)\]/
  CODE["이름색상변경2"] = /\e색\[(.+)\]/

  extend self
  #--------------------------------------------------------------------------
  # 색상을 불러옵니다(토큰 추출)
  #--------------------------------------------------------------------------
  def import_color(string)
    begin
      data = INI.read_string("색상목록",string,'색상테이블.ini')
      parser = RubyVM::InstructionSequence.compile(data)
      token = parser.to_a[13][2][0]
      case token
      when :duparray then return Color.new(*parser.eval())
      else
        return Color.new(255,255,255,255)
      end
    rescue
      Color.new(255,255,255,255)
    end
  end

end

#==============================================================================
# ** RS::EventComment
#==============================================================================
module RS::EventComment
  def self.get(event_id, index)
    return nil if index <= 0
    
    data = {}
    data[:note] = []
    data[:meta] = {}
    meta = nil
    
    list = $game_map.events[event_id].list
    param = list[index]
    
    while param and param.code == 408
      value = param.parameters[0] || ""
      data[:note] << value
      index -= 1
      param = list[index]  
    end
    if param and param.code == 108
      value = param.parameters[0] || ""
      data[:note] << value
      index -= 1
      param = list[index]
      while param.code == 408
        value = param.parameters[0] || ""
        data[:note] << value
        index -= 1
        param = list[index]  
      end      
      if param.code == 108
        value = param.parameters[0] || ""
        data[:note] << value
      end
    end
    
    re = /<([^<>:]+)(:?)([^>]*)>/m
    
    data[:note].each do |i|
      m = re.match(i)
      meta = data[:meta]
      if not m.nil?
        if m[2] == ":"
          name = m[1] || ""
          meta[name.strip] = m[3]
        else
          name = m[1] || ""
          meta[name.strip] = true
        end
      else
        break
      end
    end
    
    meta
    
  end
  
end

#==============================================================================
# ** RS::BALLOON
#------------------------------------------------------------------------------
# 말풍선 대화창을 위한 상수들이 정의되어있습니다
#==============================================================================
module RS::BALLOON

  # 폰트 사이즈(폰트 사이즈를 바꾸는 상수가 아니라 기본 폭과 높이에 영향을 주는 상수입니다)
  FONT_SIZE = 24

  # 간격
  STD_PADDING = 24

  # 최소 폭
  WIDTH = (FONT_SIZE * 6) + STD_PADDING

  # 최소 높이
  HEIGHT = FONT_SIZE + (STD_PADDING / 2)

  #--------------------------------------------------------------------------
  # * 말풍선 스프라이트가 있는가?
  #--------------------------------------------------------------------------
  def balloon_sprite?
    return false
  end
end

#==============================================================================
# ** RS::BNSprite
#------------------------------------------------------------------------------
# 말풍선 스프라이트 생성을 위한 메소드들이 정의되어있습니다
#==============================================================================
module RS::BNSprite
  #--------------------------------------------------------------------------
  # * 말풍선 스프라이트 생성
  #--------------------------------------------------------------------------
  def create_balloon_sprite
    @b_cursor = Sprite.new
    @b_cursor.visible = false
    @b_cursor.bitmap = Cache.system("Window")
    @b_cursor.src_rect.set(96, 80, 16, 16)
    @b_cursor.z = 290
  end
  #--------------------------------------------------------------------------
  # * 말풍선 스프라이트 해방
  #--------------------------------------------------------------------------
  def update_balloon_sprite
    if @b_cursor and @b_cursor.bitmap
      dx = 16 * ((Time.now.to_i % 2) + 1)
      @b_cursor.src_rect.set(96 + dx, 80,16, 16)
    end
  end
  #--------------------------------------------------------------------------
  # * 말풍선 스프라이트 해방
  #--------------------------------------------------------------------------
  def dispose_balloon_sprite
    if @b_cursor
      @b_cursor.bitmap.dispose
      @b_cursor.dispose
    end
  end
end

#==============================================================================
# ** RS::LoadFace
#------------------------------------------------------------------------------
# 큰 페이스칩 설정을 위한 메소드들이 정의되어있습니다
#==============================================================================
module RS::LoadFace
  #--------------------------------------------------------------------------
  # * 비트맵 생성
  #--------------------------------------------------------------------------
  def create_face_bitmap
    @face_sprite = Sprite.new
    @face_bitmap = Bitmap.new(544, 416)
  end
  #--------------------------------------------------------------------------
  # * 스프라이트 생성
  #--------------------------------------------------------------------------
  def create_face_sprite(align=false)
    @face_sprite.visible = true
    @face_sprite.bitmap = @face_bitmap
    @face_sprite.opacity = 255
    @face_sprite.x = RS::LIST["X"] + RS::LIST[align ? "오른쪽" : "왼쪽"]
    @face_sprite.mirror = RS::LIST["반전"] ? align : false
    @face_sprite.y = RS::LIST["높이"] - @face_bitmap.height
  end
  #--------------------------------------------------------------------------
  # * 스프라이트 설정
  #--------------------------------------------------------------------------
  def set_sprite(align)
    @face_sprite.visible = true
    @face_sprite.bitmap = @face_bitmap
    @face_sprite.x = RS::LIST["X"] + RS::LIST[align ? "오른쪽" : "왼쪽"]
    @face_sprite.mirror = RS::LIST["반전"] ? align : false
    @face_sprite.y = RS::LIST["높이"] - @face_bitmap.height
    
  end
  #--------------------------------------------------------------------------
  # * 페이스칩 인덱스 체크
  #--------------------------------------------------------------------------
  def bigface_right_alignment?
    $game_message.face_index != 0
  end
  #--------------------------------------------------------------------------
  # * 큰 페이스칩 체크
  #--------------------------------------------------------------------------
  def bigface_valid?
    return false if $game_message.face_name == ""
    return true if $game_message.face_name[RS::CODE["큰페이스칩"]] == "큰_"
    return false
  end
  #--------------------------------------------------------------------------
  # * 일반 페이스칩 체크
  #--------------------------------------------------------------------------
  def normal_face?
    return true if bigface_valid? == false && $game_message.face_name.size > 0
    return false
  end
  #--------------------------------------------------------------------------
  # * 비트맵 제거
  #--------------------------------------------------------------------------
  def iface_clear
    @face_bitmap = nil
  end
  #--------------------------------------------------------------------------
  # * 비트맵 업데이트
  #--------------------------------------------------------------------------
  def face_update
    @face_sprite.visible = if $game_message.visible
    @face_sprite.update; true else; false end
  end
end

#==============================================================================
# ** RS::Face
#------------------------------------------------------------------------------
# 큰 페이스칩과 관련된 클래스입니다.
#==============================================================================
class RS::Face
  include RS::LoadFace
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize(message_window)
    create_face_bitmap
    create_face_sprite
    init_params
    @message_window = message_window
    @face_sprite.z = message_window.z + RS::LIST["Z"]
  end
  #--------------------------------------------------------------------------
  # * 인스턴스 초기화
  #--------------------------------------------------------------------------
  def init_params
    @face_set_x = 0
    @face_index = 0
    @face_name = ""
  end
  #--------------------------------------------------------------------------
  # * 이름 초기화
  #--------------------------------------------------------------------------
  def reset_face_name
    @face_name = ""
  end
  #--------------------------------------------------------------------------
  # * 투명도 초기화
  #--------------------------------------------------------------------------
  def reset_opacity
    @face_sprite.opacity = 0
  end
  #--------------------------------------------------------------------------
  # * 인덱스가 유효한가?
  #--------------------------------------------------------------------------
  def face_index_invalid?
    @face_index != $game_message.face_index
  end
  #--------------------------------------------------------------------------
  # * 이름이 유효한가?
  #--------------------------------------------------------------------------
  def face_name_invalid?
    @face_name != $game_message.face_name
  end
  #--------------------------------------------------------------------------
  # * 다시 그려야 하는가?
  #--------------------------------------------------------------------------
  def check_redraw?
    face_index_invalid? || face_name_invalid?
  end
  #--------------------------------------------------------------------------
  # * 해방
  #--------------------------------------------------------------------------
  def dispose
    @face_bitmap.dispose
    @face_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * 큰 페이스칩 그리기
  #--------------------------------------------------------------------------
  def draw_bigface(align)
    set_sprite(align)
    @face_sprite.z = @message_window.z + RS::LIST["Z"]
  end
  #--------------------------------------------------------------------------
  # * 투명도 조절
  #--------------------------------------------------------------------------
  def opacity=(n)
    @face_sprite.opacity = n
  end
  #--------------------------------------------------------------------------
  # * 큰 페이스칩 다시 그리기
  #--------------------------------------------------------------------------
  def redraw_bigface
    @face_bitmap = Cache.face($game_message.face_name)
    @face_index = $game_message.face_index
    @face_name = $game_message.face_name
    draw_bigface(align)
  end
  #--------------------------------------------------------------------------
  # * 정렬 위치
  #--------------------------------------------------------------------------
  def align
    bigface_right_alignment?
  end
  #--------------------------------------------------------------------------
  # * Set Visible
  #--------------------------------------------------------------------------
  def visible=(toggle)
    @face_sprite.visible = toggle
  end
  #--------------------------------------------------------------------------
  # * 오른쪽 정렬인가?
  #--------------------------------------------------------------------------
  def right_alignment_check?
    @face_sprite.visible && align == false && $game_message.balloon == -2
  end
  #--------------------------------------------------------------------------
  # * 큰 페이스칩이 설정된 상태인가?
  #--------------------------------------------------------------------------
  def visible?
    @face_Sprite.visible == true
  end
end

#==============================================================================
# ** RS::Color
#------------------------------------------------------------------------------
# 색상테이블 파일을 만듭니다
#==============================================================================
module RS::Color
  #--------------------------------------------------------------------------
  # * 색상을 초기화합니다
  #--------------------------------------------------------------------------
  def init_color_table
    # 기본 색상을 추가합니다
    color_table = {}
    color_range = (0..31)
    color_range.each_with_index do |color,index|
      color_table["기본색#{index}"] = text_color(color).to_a
    end
    # 추가로 정의된 색상을 추가합니다
    extend_color {|k,v| color_table[k] = v }
    # INI 파일을 생성합니다
    color_table.to_ini("색상테이블.ini","색상목록")
  end
  #--------------------------------------------------------------------------
  # * 색상을 추가합니다
  #--------------------------------------------------------------------------
  def extend_color
    yield "하늘색",[153, 217, 234, 255]
    yield "연보라색",[200,191,231,255]
  end
end

#==============================================================================
# ** Unicode
#==============================================================================
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

#==============================================================================
# ** String 확장
#==============================================================================
class String
  include Unicode
end

#==============================================================================
# ** INI
#------------------------------------------------------------------------------
# INI 파일을 만들거나 읽을 수 있는 모듈입니다
#==============================================================================
module INI
  WritePrivateProfileStringW = Win32API.new('Kernel32','WritePrivateProfileStringW','pppp','s')
  GetPrivateProfileStringW = Win32API.new('Kernel32','GetPrivateProfileStringW','ppppip','s')
  extend self
  #--------------------------------------------------------------------------
  # * INI 파일의 내용을 작성합니다
  #--------------------------------------------------------------------------
  def write_string(app,key,str,file_name)
    path = ".\\" + file_name
    (param = [app,key.to_s,str.to_s,path]).collect! {|i| i.unicode!}
    success = WritePrivateProfileStringW.call(*param)
  end
  #--------------------------------------------------------------------------
  # * INI 파일의 내용을 읽어옵니다
  #--------------------------------------------------------------------------
  def read_string(app_name,key_name,file_name)
    buf = "\0" * 256
    path = ".\\" + file_name
    (param = [app_name,key_name,path]).collect! {|x| x.unicode!}
    GetPrivateProfileStringW.call(*param[0..1],0,buf,256,param[2])
    buf.unicode_s.unpack('U*').pack('U*')
  end
end

#==============================================================================
# ** Hash
#------------------------------------------------------------------------------
# Hash의 원소(Key, Value)를 바탕으로 INI 파일을 만듭니다
#==============================================================================
class Hash
  def to_ini(file_name="Default.ini",app_name="Default")
    self.each { |k, v| INI.write_string(app_name,k.to_s.dup,v.to_s.dup,file_name) }
  end
end

#==============================================================================
# ** RGB
#==============================================================================
module RGB
  extend self
  #--------------------------------------------------------------------------
  # * 색상 코드 처리(정수형)
  #--------------------------------------------------------------------------
  def int_to_rgb(rgb)
    [rgb, rgb>>8, rgb>>16].map {|i| i & 0xFF }
  end
  #--------------------------------------------------------------------------
  # * 색상 코드 처리(16진수)
  #--------------------------------------------------------------------------
  def hex_to_rgb(hex)
    return unless hex.is_a?(String)
    hex = hex.delete('#').to_i(16)
    return int_to_rgb(hex).reverse
  end
end

#==============================================================================
# ** Colour
#==============================================================================
module Colour
  include RGB
  # 색상을 추출합니다
  GET_COLOR = ->(cint){color = Color.new(*int_to_rgb(cint),get_alpha); color}
  extend self

  @@c_alpha = 255
  @@c_base = Color.new(255,255,255,255)
  #--------------------------------------------------------------------------
  # * 색상 코드 처리
  #--------------------------------------------------------------------------
  def gm_color(string)
    case string
    when "청록",'청록색','c_aqua' then GET_COLOR.(16776960)
    when "검은색","검정",'c_black' then GET_COLOR.(0)
    when "파란색","파랑",'c_blue' then GET_COLOR.(16711680)
    when "짙은회색",'c_dkgray' then GET_COLOR.(4210752)
    when "자홍색","자홍",'c_fuchsia' then GET_COLOR.(16711935)
    when "회색",'c_gray' then GET_COLOR.(8421504)
    when "녹색",'c_green' then GET_COLOR.(32768)
    when "밝은녹색","라임",'c_lime' then GET_COLOR.(65280)
    when "밝은회색",'c_ltgray' then GET_COLOR.(12632256)
    when "밤색","마룬",'c_maroon' then GET_COLOR.(128)
    when "감청색","네이비",'c_navy'  then GET_COLOR.(8388608)
    when "황록색","올리브",'c_olive' then GET_COLOR.(32896)
    when "주황색","주황","오렌지",'c_orange' then GET_COLOR.(4235519)
    when "보라색","보라",'c_purple' then GET_COLOR.(8388736)
    when "빨간색","빨강",'c_red' then GET_COLOR.(255)
    when "은색","은",'c_silver' then GET_COLOR.(12632256)
    when "민트색",'c_teal'   then GET_COLOR.(8421376)
    when "흰색","흰",'c_white'  then GET_COLOR.(16777215)
    when "노란색","노랑",'c_yellow' then GET_COLOR.(65535)
    when "기본","기본색",'c_normal' then get_base_color
    else
      RS.import_color(string)
    end
  end
  #--------------------------------------------------------------------------
  # * 투명도 조절
  #--------------------------------------------------------------------------
  def draw_set_alpha(value)
    @@c_alpha = if value.between?(0,255)
      value
    else
      255
    end
  end
  #--------------------------------------------------------------------------
  # * 기본색 획득
  #--------------------------------------------------------------------------
  def get_base_color
    @@c_base
  end
  #--------------------------------------------------------------------------
  # * 기본색 설정
  #--------------------------------------------------------------------------
  def set_base_color=(color)
    @@c_base = color
  end
  #--------------------------------------------------------------------------
  # * 투명색 획득
  #--------------------------------------------------------------------------
  def get_alpha
    @@c_alpha
  end
end

#==============================================================================
# ** Color
#==============================================================================
class Color
  extend Colour
  #--------------------------------------------------------------------------
  # * 정수로 변환
  #--------------------------------------------------------------------------
  def to_int(r=red.round,g=green.round,b=blue.round)
    (r) | (g << 8) | (b << 16)
  end
  #--------------------------------------------------------------------------
  # * 16진수로 웹 색상 코드로 변환
  #--------------------------------------------------------------------------
  def to_hex(r=red.round,g=green.round,b=blue.round)
    "#" + ([r,g,b].collect {|i| sprintf("%#02x", i)}.join)[2..-1].upcase
  end
  #--------------------------------------------------------------------------
  # * 배열로 변환
  #--------------------------------------------------------------------------
  def to_a
    [red.round,green.round,blue.round,alpha.round]
  end
end

#==============================================================================
# ** String
#==============================================================================
class String
  #--------------------------------------------------------------------------
  # * 색상 코드 처리
  #--------------------------------------------------------------------------
  def c
    Color.gm_color(self) if (self =~ RS::CODE["색상추출"])
  end
  #--------------------------------------------------------------------------
  # * 웹 색상 코드 처리
  #--------------------------------------------------------------------------
  def hex_to_color
    Color.new *Color.hex_to_rgb(self),255
  end
end

#==============================================================================
# ** Window_Base
#==============================================================================
class Window_Base
  #--------------------------------------------------------------------------
  # * 기본색 처리
  #--------------------------------------------------------------------------
  alias get_base_text_color_initialize initialize
  def initialize(x, y, width, height)
    get_base_text_color_initialize(x, y, width, height)
    Color.set_base_color = text_color(0)
  end
  #--------------------------------------------------------------------------
  # * 문자 처리
  #--------------------------------------------------------------------------
  def obtain_escape_code(text)
    text.slice!(RS::CODE["명령어"])
  end
  #--------------------------------------------------------------------------
  # * 색상 코드 처리
  #--------------------------------------------------------------------------
  def obtain_name_color(text)
    text.slice!(RS::CODE["이름색상코드"])[$1]
  end
  #--------------------------------------------------------------------------
  # * 색상 변환 (MV Feature to v0.1.32)
  #--------------------------------------------------------------------------  
  alias rs_message_system_change_color change_color
  def change_color(color, enabled = true)
    if color.is_a?(String)
      c = color.to_i
      if c.between?(0, 32)
        color = text_color(c)
      end
    end
    rs_message_system_change_color(color, enabled)
  end
  #--------------------------------------------------------------------------
  # * 웹 색상 코드 처리
  #--------------------------------------------------------------------------
  def to_hex(text)
    text.slice!(RS::CODE["웹색상"])[$1] rescue "#FFFFFF"
  end
  #--------------------------------------------------------------------------
  # * 명령 문자 처리
  #--------------------------------------------------------------------------
  alias color_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    case code.upcase
    when '색'
      color = Color.gm_color(obtain_name_color(text))
      change_color(color)
    when '#'
      color = "##{to_hex(text)}".hex_to_color
      change_color(color)
    else
      color_process_escape_character(code, text, pos)
    end
  end
  #--------------------------------------------------------------------------
  # * 기본 폰트 설정
  #--------------------------------------------------------------------------
  def reset_font_settings
    change_color(normal_color)
    contents.font.name = RS::LIST["폰트명"]
    contents.font.size = RS::LIST["폰트크기"]
    contents.font.bold = Font.default_bold
    contents.font.italic = Font.default_italic
    contents.font.outline = Font.default_outline
    contents.font.out_color = Font.default_out_color
  end
  #--------------------------------------------------------------------------
  # * 저장
  #--------------------------------------------------------------------------
  def save
    @message_desc = {}
    @message_desc[:font_name] = contents.font.name
    @message_desc[:font_size] = contents.font.size
    @message_desc[:font_bold] = contents.font.bold
    @message_desc[:font_italic] = contents.font.italic
    @message_desc[:font_outline] = contents.font.outline
    @message_desc[:font_out_color] = contents.font.out_color
    @message_desc[:font_color] = contents.font.color
  end
  #--------------------------------------------------------------------------
  # * 복구
  #--------------------------------------------------------------------------
  def restore
    return if @message_desc.nil?
    contents.font.name = @message_desc[:font_name]
    contents.font.size = @message_desc[:font_size]
    contents.font.bold = @message_desc[:font_bold]
    contents.font.italic = @message_desc[:font_italic]
    contents.font.outline = @message_desc[:font_outline]
    contents.font.out_color = @message_desc[:font_out_color]
    contents.font.color = @message_desc[:font_color]
    @message_desc = nil
  end
  #--------------------------------------------------------------------------
  # * 테두리 색상 처리
  #--------------------------------------------------------------------------
  def change_out_color(color, enabled = true)
    contents.font.out_color.set(color)
    contents.font.out_color.alpha = translucent_alpha unless enabled
  end
  #--------------------------------------------------------------------------
  # * 아이템 이름
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, enabled = true, width = 172)
    return unless item
    draw_icon(item.icon_index, x, y, enabled)
    change_color(normal_color, enabled)
    draw_text_ex(x + 24, y, item.name)
  end
  #--------------------------------------------------------------------------
  # * draw_text_ex
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    reset_font_settings
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    process_character(text.slice!(0, 1), text, pos) until text.empty?
    return pos[:x] - x
  end
  #--------------------------------------------------------------------------
  # * text_width_ex
  #--------------------------------------------------------------------------
  def text_width_ex(text)
    save
    temp_width = draw_text_ex(0, contents_height + 6, text)
    restore
    return temp_width
  end
end

#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
# 메시지 시스템이 구현되어있는 클래스입니다
#==============================================================================
class Window_Message
  include RS::BNSprite
  include RS::Color
  include RS::BALLOON
  #--------------------------------------------------------------------------
  # * 재정의
  #--------------------------------------------------------------------------
  alias load_face_initialize initialize
  alias load_face_update update
  alias load_face_dispose dispose
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize
    load_face_initialize
    init_color_table
    @util = RS::Face.new(self)
    create_balloon_sprite
    set_font(RS::LIST["폰트명"],RS::LIST["폰트크기"])
    @windowskin_id = RS::LIST["윈도우스킨"].object_id
  end
  #--------------------------------------------------------------------------
  # * 윈도우의 폭 (가로 길이)
  #--------------------------------------------------------------------------
  def window_width
    RS::LIST["가로"]
  end  
  #--------------------------------------------------------------------------
  # * 폰트 설정
  #--------------------------------------------------------------------------
  def set_font(name, size = Font.default_size )
    self.contents.font.name = name
    self.contents.font.size = size
  end
  #--------------------------------------------------------------------------
  # * 윈도우스킨 적용
  #--------------------------------------------------------------------------  
  def update_windowskin
    # 문자열의 오브젝트 ID 값이 변경할 때 마다 바뀝니다.
    # 이 점을 이용하여 정확히 한 번만 업데이트 합니다.
    return if @windowskin_id == RS::LIST["윈도우스킨"].object_id
    bitmap = Cache.system(RS::LIST["윈도우스킨"])
    self.windowskin = bitmap
    @windowskin_id = RS::LIST["윈도우스킨"].object_id
  end
  #--------------------------------------------------------------------------
  # * 인스턴스 초기화
  #--------------------------------------------------------------------------
  alias load_face_clear_instance_variables clear_instance_variables
  def clear_instance_variables
    load_face_clear_instance_variables
    @util.reset_face_name if @util
  end
  #--------------------------------------------------------------------------
  # * 피버 메인
  #--------------------------------------------------------------------------
  def fiber_main
    
    # Fiber는 Thread와는 비슷하지만,
    # 쓰레드와는 달리 Ruby VM이 쓰레드 간의 전환을 수행하지 않는다.
    # Fiber는 프로그래머가 직접 명시적으로 실행과 쓰레드 간의 전환을 지시할 수 있다.

    # 따라서 프로그래머가 원하는 타이밍에 재진입, 인자 전달이 가능하다.
    # Fiber.yield를 만나면 메인 쓰레드(또는 부모)의 업데이트(프레임 업데이트, 게임 업데이트 등) 등이 수행된다.
    # Fiber.resume을 만나면 이전에 정지한 위치로 재진입하여 처리를 재개한다.

    # 배경 업데이트
    update_background
    # 말풍선 위치 업데이트
    update_balloon_position
    # 큰 얼굴 이미지 업데이트
    @util.face_update
    # 메시지를 보여지는 상태로 설정
    $game_message.visible = true   
    
    loop do
      process_all_text if $game_message.has_text?
      process_input
      $game_message.clear
      @name_window.close
      @gold_window.close

      # 루프를 빠져나가고, 메인 쓰레드의 게임 업데이트를 처리한다 (이후 다음 라인부터 재진입)
      # (fiber_main -> Main Frame Work의 업데이트 코드 -> 다시 fiber_main 진입)
      Fiber.yield

      break unless text_continue?
    end

    # 모든 창이 닫힐 때 까지 메인 프레임워크의 게임 업데이트를 수행한다 (반복 루프)
    close_and_wait

    $game_message.visible = false
    # 큰 얼굴 이미지 투명도 재설정
    @util.reset_opacity
    @util.face_update
    # 메시지창 크기 재설정
    resize_message_system
    # 큰 얼굴 이미지 이름 재설정
    @util.reset_face_name
    # Fiber를 끝낸다.
    @fiber = nil
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    load_face_update
    update_balloon_sprite
    update_windowskin
    @util.face_update if @fiber
  end
  #--------------------------------------------------------------------------
  # * 해방
  #--------------------------------------------------------------------------
  def dispose
    load_face_dispose
    @util.dispose
    dispose_balloon_sprite
  end
  #--------------------------------------------------------------------------
  # * 새로운 페이지
  #--------------------------------------------------------------------------
  def new_page(text, pos)
    contents.clear
    @util.bigface_valid? ? draw_bigface_entity(text,pos) : draw_normalface_entity(text,pos)
  end
  #--------------------------------------------------------------------------
  # * 큰 페이스칩 그리기
  #--------------------------------------------------------------------------
  def draw_bigface_entity(text,pos)
    @util.create_face_sprite( @util.align )
    if @util.check_redraw?
      @util.redraw_bigface
    else
      @util.visible = true
    end
    normal_set_page(pos,@util.align ? 0 : RS::LIST["텍스트시작X"],text)
  end
  #--------------------------------------------------------------------------
  # * 일반 페이스칩 그리기
  #--------------------------------------------------------------------------
  def draw_normalface_entity(text,pos)
    @util.opacity = 0 if @util.check_redraw?
    draw_face($game_message.face_name,$game_message.face_index, 0, 0)
    normal_set_page(pos,new_line_x,text)
  end
  #--------------------------------------------------------------------------
  # * 새로운 페이지
  #--------------------------------------------------------------------------
  def normal_set_page(pos,*args)
    reset_font_settings
    pos[:x] = args[0]
    pos[:y] = 0
    pos[:new_x] = args[0]
    pos[:height] = calc_line_height(args[1])
    clear_flags
  end
  #--------------------------------------------------------------------------
  # * 효과음 추출
  #--------------------------------------------------------------------------
  def obtain_escape_sound(text)
    text.slice!(RS::CODE["효과음"])[$1] rescue RS::LIST["효과음"]
  end
  #--------------------------------------------------------------------------
  # * Preconvert Control Characters
  #    As a rule, replace only what will be changed into text strings before
  #    starting actual drawing. The character "\" is replaced with the escape
  #    character (\e).
  #--------------------------------------------------------------------------
  def convert_escape_characters(text)
    result = text.to_s.clone
    result.gsub!(/\\/)            { "\e" }
    result.gsub!(/\e\e/)          { "\\" }
    result.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }
    result.gsub!(/(?:\eN|\e주인공)\[(\d+)\]/i) { actor_name($1.to_i) }
    result.gsub!(/(?:\eP|\e파티원)\[(\d+)\]/i) { party_member_name($1.to_i) }
    result.gsub!(/(?:\eG|\e골드)/i)          { Vocab::currency_unit }
    result
  end
  #--------------------------------------------------------------------------
  # * 명령어 처리 (대화가 시작된 후에 처리됩니다)
  #--------------------------------------------------------------------------
  alias msg_speed_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
      case code
      when '속도!'
        set_text_speed(obtain_escape_param(text).to_i)
      when '크기!'
        t = obtain_escape_param(text).to_i
        contents.font.size = t
        pos[:height] = [t,pos[:height]].max
      when '굵게!'
        contents.font.bold = !contents.font.bold
      when '이탤릭!'
        contents.font.italic = !contents.font.italic
      when '테두리!'
        contents.font.outline = !contents.font.outline
      when '테두리색!'
        color = Color.gm_color(obtain_name_color(text))
        change_out_color(color)
      when '그림!'
        process_draw_picture(obtain_escape_sound(text).to_s,pos)
      when '효과음!'
        $game_map.se_play = obtain_escape_sound(text).to_s
      when '자동개행!'
        $game_message.word_wrap_enabled = true
      else
        msg_speed_process_escape_character(code, text, pos)
      end
  end
  #--------------------------------------------------------------------------
  # * 그림의 처리
  #--------------------------------------------------------------------------
  def process_draw_picture(picture_name, pos)
    draw_picture(pos ,picture_name)
    wait_for_one_character
  end
  #--------------------------------------------------------------------------
  # * 그림 그리기
  #--------------------------------------------------------------------------
  def draw_picture(pos, picture_name, enabled = true)
    bitmap = Cache.picture(picture_name)
    rect = Rect.new(0, 0, bitmap.width, bitmap.height)

    pic_opacity = enabled ? 255 : translucent_alpha

    # 원본 복제
    contents_temp = Bitmap.new(contents_width,contents_height + bitmap.height)
    temp_rect = Rect.new(0,0,self.width,self.height + bitmap.height)
    contents_temp.blt(0,0,contents,temp_rect,pic_opacity)

    # 콘텐츠 높이 계산
    if rect.height <= (self.height - STD_PADDING)
      self.height += rect.height
    else
      value = rect.height - (self.height - STD_PADDING)
      self.height += value + line_height if value > 0
    end

    # 새로운 비트맵
    self.contents = contents_temp

    # 위치 업데이트
    update_placement

    # 묘화
    contents.blt(pos[:x],pos[:y] , bitmap, rect,pic_opacity)
    pos[:x] += bitmap.width
    pos[:y] += bitmap.height
  end
  #--------------------------------------------------------------------------
  # * 새로운 페이지가 필요한 지 여부를 결정합니다
  #--------------------------------------------------------------------------
  def need_new_page?(text, pos)
    pos[:y] + pos[:height] > (self.height - STD_PADDING) && !text.empty?
  end
  #--------------------------------------------------------------------------
  # * 텍스트 속도 조절
  #--------------------------------------------------------------------------
  def set_text_speed(text_speed)
    $game_message.message_speed = case text_speed
    when (RS::LIST["텍스트속도-최소"]..RS::LIST["텍스트속도-최대"])
      text_speed
    else
      RS::LIST["텍스트속도-최소"]
    end
  end
  #--------------------------------------------------------------------------
  # * 명렁어 처리(대화가 시작되기 전에 처리됩니다)
  #--------------------------------------------------------------------------
  alias rs_extend_msg_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    f = rs_extend_msg_convert_escape_characters(text)

    # 이름 윈도우 띄우기 텍스트 코드를 정규 표현식으로 찾아내 텍스트 코드를 없애고
    # 괄호 안에 있는 특정 문자열만 추출합니다.
    f.gsub!(RS::CODE["이름"]) {
      name_text = $1.to_s
      # 콜론과 정렬 위치 문자가 포함되어있으면 해당 위치에 이름 윈도우를 띄웁니다.
      if (name_text =~ /(.*)(:)(.*)/i)
        # strip은 공백 제거를 뜻함
        name = $1.strip
        position = $3.strip
        name_window_open(name, position)
      else
        # 왼쪽에 이름 윈도우를 띄웁니다.
        name_window_open(name_text, 'left')  
      end
      ""
    }
    f.gsub!(RS::CODE["말풍선"]) { $game_message.balloon = $1.to_i; "" }
    f
  end
  #--------------------------------------------------------------------------
  # * 문자 출력 속도
  #--------------------------------------------------------------------------
  def wait_for_one_character
    update_show_fast
    wait($game_message.message_speed) unless @show_fast || @line_show_fast
  end
  #--------------------------------------------------------------------------
  # * 이름 뽑아내기
  #--------------------------------------------------------------------------
  def obtain_name_text(text)
    text.slice!(RS::CODE["이름추출"])[$1]
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 띄우기
  #--------------------------------------------------------------------------
  def name_window_open(text, position)
    @name_window.draw_name(text)
    @name_window.align = position
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 생성
  #--------------------------------------------------------------------------
  alias namewindow_create_all_windows create_all_windows
  def create_all_windows
    namewindow_create_all_windows
    @name_window = RS::Window_Name.new
    @name_window.x = self.x + RS::LIST["이름윈도우X1"]
    @name_window.y = self.y - RS::LIST["이름윈도우Y"]
    @name_window.openness = 0
  end
  #--------------------------------------------------------------------------
  # * 윈도우 업데이트
  #--------------------------------------------------------------------------
  alias namewindow_update_all_windows update_all_windows
  def update_all_windows
    update_name_windows
    namewindow_update_all_windows
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우의 X좌표
  #--------------------------------------------------------------------------
  def namewindow_get_x
    if @name_window.align == 'right'
      return self.x + self.width - @name_window.width
    elsif @name_window.align == 'center'
      return self.x + self.width / 2 - @name_window.width / 2
    else
      if @util.normal_face?
        return self.x + 112 + RS::LIST["이름윈도우X1"]
      else
        if @util.bigface_valid?
          if @util.bigface_right_alignment?
            return self.x + RS::LIST["이름윈도우X1"]
          else
            return self.x + RS::LIST["이름윈도우X2"]
          end
        end
      end
      return self.x + RS::LIST["이름윈도우X1"]
    end
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 업데이트
  #--------------------------------------------------------------------------
  def update_name_windows
    
    @name_window.x = namewindow_get_x
    
    position = $game_message.position

    if position == 0 and $game_message.balloon == -2
      @name_window.y = 0
      self.y = @name_window.open? ? (@name_window.height) : 0
    else
      @name_window.y = self.y - @name_window.height - RS::LIST["이름윈도우Y"]
    end

    @name_window.update
    
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 제거
  #--------------------------------------------------------------------------
  alias namewindow_dispose_all_windows dispose_all_windows
  def dispose_all_windows
    @name_window.dispose
    namewindow_dispose_all_windows
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우의 Y값 조절
  #--------------------------------------------------------------------------
  alias namewindow_update_placement update_placement
  def update_placement
    position = $game_message.position 
    if $game_message.balloon == -2
      self.x = (Graphics.width / 2) - self.width / 2 + RS::LIST["오프셋X"]
      self.y = position * (Graphics.height - self.height) + RS::LIST["오프셋Y"]
    end
    @gold_window.y = y > 0 ? 0 : Graphics.height - @gold_window.height
    if not @name_window.open?
      self.ox = $game_message.ox
      namewindow_update_placement
    end
    update_name_windows if @name_window.open? || settings_changed?    
  end
end

#==============================================================================
# ** RS::Window_Name
#------------------------------------------------------------------------------
# 이름 윈도우가 구현되어있는 클래스입니다
#==============================================================================
class RS::Window_Name < Window_Base
  attr_accessor :align
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize
    @in_pos = 0
    @text = ""
    super(0, 0, window_width, fitting_height(1))
    create_back_bitmap
    create_back_sprite
    self.z = 206
    refresh
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우의 크기
  #--------------------------------------------------------------------------
  def window_width
    return 140
  end
  #--------------------------------------------------------------------------
  # * 배경 비트맵 생성
  #--------------------------------------------------------------------------
  def create_back_bitmap
    @back_bitmap = Bitmap.new(width, height)
    back_color2 =  Color.new(12, 24, 13, 0)
    back_color1 =  Color.new(0, 13, 24, 160)
    rect1 = Rect.new(standard_padding, 0, width, 12)
    rect2 = Rect.new(standard_padding, 12, width, height - 24)
    rect3 = Rect.new(standard_padding, height - 12, width, 12)
    @back_bitmap.gradient_fill_rect(rect1, back_color2, back_color1, true)
    @back_bitmap.fill_rect(rect2, back_color1)
    @back_bitmap.gradient_fill_rect(rect3, back_color1, back_color2, true)
  end
  #--------------------------------------------------------------------------
  # * 배경 스프라이트 생성
  #--------------------------------------------------------------------------
  def create_back_sprite
    @back_sprite = Sprite.new
    @back_sprite.bitmap = @back_bitmap
    @back_sprite.visible = false
    @back_sprite.z = z + 2
  end
  #--------------------------------------------------------------------------
  # * 배경 스프라이트의 업데이트
  #--------------------------------------------------------------------------
  def update_back_sprite
    @back_sprite.visible = (@background == 1)
    @back_sprite.x = x
    @back_sprite.y = y
    @back_sprite.opacity = openness
    @back_sprite.update
  end
  #--------------------------------------------------------------------------
  # * 배경 스프라이트의 해방
  #--------------------------------------------------------------------------
  def dispose
    super
    @back_bitmap.dispose
    @back_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------
  def update
    super
    update_back_sprite
  end
  #--------------------------------------------------------------------------
  # * 말풍선 영역 계산
  #--------------------------------------------------------------------------
  def get_balloon_text_rect(text)
    begin
      tmp_text = text_processing(text)
      tmp_text = tmp_text.split("\n")
      tmp_text.sort! {|a,b| b.size - a.size }
      _rect = contents.text_size(tmp_text[0])
      @_width = (_rect.width) + RS::BALLOON::STD_PADDING
    rescue
      @_width = window_width
    end
  end
  #--------------------------------------------------------------------------
  # * 텍스트 매칭 (모든 명령어 제거)
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
    f.gsub!(/(?:\eC)\[(\d+)\]/i) { "" }
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
    f
  end
  #--------------------------------------------------------------------------
  # * 명령어 처리 (대화가 시작되기 전에 처리됩니다)
  #--------------------------------------------------------------------------
  alias rs_extend_name_convert_escape_characters convert_escape_characters
  def convert_escape_characters(text)
    f = rs_extend_name_convert_escape_characters(text)
    f.gsub!(RS::CODE["이름색상변경1"]) { change_color(text_color($1.to_i)) }
    f.gsub!(RS::CODE["이름색상변경2"]) do
      color = Color.gm_color($1)
      change_color(color)
    end
    f
  end
  #--------------------------------------------------------------------------
  # * 리프레쉬
  #--------------------------------------------------------------------------
  def refresh
    self.windowskin = Cache.system(RS::LIST["이름윈도우스킨"])
    contents.clear
    @background = $game_message.background
    self.opacity = @background == 0 ? RS::LIST["투명도"] : 0
    update_back_sprite
    rect = text_size(@text)
    self.arrows_visible = false
    self.width = @_width || window_width
    text = convert_escape_characters(@text)
    self.contents.font.size = RS::LIST["폰트크기"]
    draw_text(0,0,contents_width,calc_line_height(text),text.to_s,1)
  end
  #--------------------------------------------------------------------------
  # * 이름 출력
  #--------------------------------------------------------------------------
  def draw_name(text)
    @text = text
    @_width = window_width
    get_balloon_text_rect(text.dup) if $game_message.background != 1
    open
  end
  #--------------------------------------------------------------------------
  # * 기본색 처리
  #--------------------------------------------------------------------------
  def set_base_color
    change_color("기본색".c)
  end
  #--------------------------------------------------------------------------
  # * 창을 닫고 비활성화합니다
  #--------------------------------------------------------------------------
  def close
    set_base_color
    super
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우를 활성화합니다
  #--------------------------------------------------------------------------
  def open
    @back_sprite.ox = 0
    refresh
    super
  end
end

#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
# 메시지 시스템에 사용되는 인스턴스 변수들이 선언되어있는 클래스입니다
#==============================================================================
class Game_Message
  attr_accessor :message_speed
  attr_accessor :line
  attr_accessor :balloon
  attr_accessor :texts
  attr_accessor :ox
  attr_accessor :word_wrap_enabled
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  alias multi_line_initialize initialize
  def initialize
    multi_line_initialize
    @line = RS::LIST["라인"]
  end
  #--------------------------------------------------------------------------
  # * 클리어
  #--------------------------------------------------------------------------
  alias msg_speed_clear clear
  def clear
    msg_speed_clear
    @message_speed = 1
    @balloon = -2
    @ox = 0
    @word_wrap_enabled = RS::LIST["자동개행"]
  end
end

#==============================================================================
# ** Game_Map
#==============================================================================
class Game_Map
  attr_accessor :msg_owner
  attr_accessor :msg_event
  alias game_map_balloon_initialize initialize
  #--------------------------------------------------------------------------
  # * 말풍선 대화창의 소유자를 설정합니다
  #--------------------------------------------------------------------------
  def initialize
    game_map_balloon_initialize
    @msg_owner = $game_player
    @msg_event = 0
  end
  #--------------------------------------------------------------------------
  # * 효과음을 재생합니다
  #--------------------------------------------------------------------------
  def se_play=(name)
    msg_se = RPG::SE.new
    msg_se.name = name
    msg_se.play
  end
end

#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
# 말풍선 시스템과 관련되어있습니다.
#==============================================================================
class Window_Message < Window_Base
  include RS::BALLOON
  #--------------------------------------------------------------------------
  # * 새로운 페이지 설정
  #--------------------------------------------------------------------------
  alias balloon_new_page new_page
  def new_page(text, pos)
    open_balloon
    balloon_new_page(text,pos)
    wait(1)
  end
  #--------------------------------------------------------------------------
  # * 말풍선 설정
  #--------------------------------------------------------------------------
  def open_balloon(sign=$game_message.balloon)
    # 말풍선 모드가 아니라면 메시지 재설정 후 반환된다.
    if sign == -2
      resize_message_system
      return nil
    end
    setup_owner(sign.to_i)
    update_balloon_position
    $game_message.word_wrap_enabled = false
  end
  #--------------------------------------------------------------------------
  # * 텍스트 처리
  #--------------------------------------------------------------------------
  def process_all_text
    open_and_wait
    set_font(RS::LIST["폰트명"],RS::LIST["폰트크기"])
    get_balloon_text_rect($game_message.all_text.dup)
    text = convert_escape_characters($game_message.all_text)
    pos = {}

    # 이 라인으로 인하여 fiber_main에 재진입 시 텍스트 컨텐츠 영역이 백지화된다.
    # self.contents는 contents_width와 contents_height만큼 설정된다.
    # 다만 메시지 영역을 재설정 해줄 필요성이 있다.
    resize_message_system
    create_contents    
    set_font(RS::LIST["폰트명"],RS::LIST["폰트크기"])
    new_page(text, pos)
    process_character(text.slice!(0, 1), text, pos) until text.empty?
  end
  #--------------------------------------------------------------------------
  # * 말풍선 높이
  #--------------------------------------------------------------------------  
  def calc_balloon_rect_height(text)
    temp_font_size = contents.font.size
    text2 = convert_escape_characters(text)
    height = calc_line_height(text2)
    self.contents.font.size = temp_font_size
    return height
  end
  #--------------------------------------------------------------------------
  # * 말풍선 영역 계산
  #--------------------------------------------------------------------------
  def get_balloon_text_rect(text)    
    
    # 라인 갯수를 구하기 위해 텍스트를 줄바꿈 문자를 기준으로 나눈다.
    tmp_text = text_processing(text)
    tmp_text = tmp_text.split("\n")
    tmp_text.sort! {|a,b| b.size - a.size }
    num_of_lines = tmp_text.size
    
    height = 0
    pad = standard_padding * 2
    
    # 높이를 구한다.
    tmp_text.each do |i|
      height += calc_balloon_rect_height(i)
    end
    
    if height <= 0
      # 높이를 구할 수 없었다면,
      height = fitting_height(num_of_lines)
    else
      # 높이를 구했다면
      height = height + pad
    end
    
    @_width = text_width_ex(text.dup) + pad + 6
    @_height = height

    if $game_message.face_name.size > 0
      @_width += new_line_x
      @_height = [@_height, fitting_height(4)].max
    end
    
  end
  #--------------------------------------------------------------------------
  # * 텍스트 매칭 (모든 명령어 제거)
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
    f.gsub!(/(?:\eC)\[(\d+)\]/i) { "" }
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
    f
  end
  #--------------------------------------------------------------------------
  # * 메시지 윈도우의 X좌표를 구합니다
  #--------------------------------------------------------------------------
  def get_x(n)
    return n unless RS::LIST["화면영역내표시"]
    case
    when n < 0 then return 0
    when n > Graphics.width - @_width
      Graphics.width - @_width
    else
      return n
    end
  end
  #--------------------------------------------------------------------------
  # * 메시지 윈도우의 Y좌표를 구합니다
  #--------------------------------------------------------------------------
  def get_y(n)
    return n unless RS::LIST["화면영역내표시"]
    case
    when n < 0 then return 0 + @name_window.height - @name_window.x
    when n > Graphics.height - @_height + @_height
      Graphics.height - @_height
    else
      return n
    end
  end
  #--------------------------------------------------------------------------
  # * 말풍선 위치 업데이트
  #--------------------------------------------------------------------------
  def update_balloon_position
    return update_placement if $game_message.balloon == -2

    # 말풍선 소유자의 화면 좌표
    mx = $game_map.msg_owner.screen_x rescue 0
    my = $game_map.msg_owner.screen_y rescue 0
    tx = @_width / 2
    ty = @_height
    scale_y = 1
    tile_height = 32
    dx = mx - @_width / 2
    dy = my - @_height - tile_height
    ny = self.y - @name_window.height - RS::LIST["이름윈도우Y"]

    # 화면 좌측
    if (mx - @_width / 2) < 0
      dx = 0
      tx = mx
    end

    # 화면 우측
    if (mx - @_width / 2) > (Graphics.width - @_width)
      dx = Graphics.width - @_width
      tx = mx - dx
    end

    # 화면 상단
    if (my - @_height - tile_height / 2) < 0
      dy = my + tile_height / 2
      scale_y = -1
      ty = (@_height * scale_y) + @_height
      ny = (self.y + @_height) + RS::LIST["이름윈도우Y"]
    end

    # 화면 하단
    if (my - @_height) > Graphics.height - @_height
      dy = Graphics.width - @_height
      ty = dy - @_height
    end

    # 말풍선 위치 및 크기 설정
    self.x = dx
    self.y = dy
    self.width = @_width
    self.height = @_height

    # Dim
    create_balloon_back_bitmap(@_width, @_height)
    @back_sprite.x = dx
    @back_sprite.y = dy
    @back_sprite.src_rect.width = @_width
    @back_sprite.src_rect.height = @_height
    @back_sprite.opacity = openness
    @back_sprite.update    

    # pause 커서의 좌표
    @b_cursor.x = dx + tx
    @b_cursor.y = dy + ty
    @b_cursor.mirror = (scale_y == -1) ? true : false

    # 이름 윈도우 좌표 수정
    @name_window.y = ny

    # 투명도 설정
    self.opacity = balloon_sprite? ? 0 : RS::LIST["투명도"]

    @balloon_pause = false
    self.arrows_visible = false
    @b_cursor.visible = true
    show

    update_background

  end
  #--------------------------------------------------------------------------
  # * 말풍선 Dim 비트맵 갱신
  #--------------------------------------------------------------------------  
  def create_balloon_back_bitmap(width, height)
    @back_bitmap = Bitmap.new(width, height)
    rect1 = Rect.new(0, 0, width, 12)
    rect2 = Rect.new(0, 12, width, height - 24)
    rect3 = Rect.new(0, height - 12, width, 12)
    @back_bitmap.gradient_fill_rect(rect1, back_color2, back_color1, true)
    @back_bitmap.fill_rect(rect2, back_color1)
    @back_bitmap.gradient_fill_rect(rect3, back_color1, back_color2, true)
    @back_sprite.bitmap = @back_bitmap if @back_sprite
  end  
  #--------------------------------------------------------------------------
  # * 소유자를 설정합니다
  #--------------------------------------------------------------------------
  def setup_owner(sign)
    $game_map.msg_owner = case sign
    when -1
      $game_player
    when 0
      $game_map.msg_event
    else
      $game_map.events[sign]
    end
  end
  #--------------------------------------------------------------------------
  # * 크기 재설정
  #--------------------------------------------------------------------------
  def resize_message_system

    # 대화창의 소유자 설정
    $game_map.msg_owner = $game_player

    @balloon_pause = true
    self.arrows_visible = true
    @b_cursor.visible = false

    # 대화창의 위치
    @position = $game_message.position

    # 대화창의 X좌표
    x = (Graphics.width / 2) - (window_width / 2) + RS::LIST["오프셋X"]
    
    # 대화창의 Y좌표
    y = @position * (Graphics.height - window_height) / 2 + RS::LIST["오프셋Y"]

    # 위치 및 크기 설정
    self.move(x, y, window_width, fitting_height($game_message.line || RS::LIST["라인"]) )

    # Dim
    create_back_bitmap
    @back_sprite.bitmap = @back_bitmap
    @back_sprite.x = 0
    @back_sprite.y = y
    @back_sprite.src_rect.width = window_width
    @back_sprite.src_rect.height = fitting_height($game_message.line || RS::LIST["라인"])
    @back_sprite.opacity = openness
    @back_sprite.update        

  end
  #--------------------------------------------------------------------------
  # * Input Pause Processing (말풍선 모드)
  #--------------------------------------------------------------------------
  def input_pause
    self.pause = @balloon_pause
    wait(10)
    Fiber.yield until Input.trigger?(:B) || Input.trigger?(:C)
    Input.update
    self.pause = false
  end
  #--------------------------------------------------------------------------
  # * 말풍선 체크
  #--------------------------------------------------------------------------
  def open_and_wait
    hide if $game_message.all_text.include?("\\말풍선")
    open
    Fiber.yield until open?
  end
  #--------------------------------------------------------------------------
  # * 배경 업데이트
  #--------------------------------------------------------------------------
  def update_background
    update_balloon_sprite
    @background = $game_message.background
    self.opacity = @background == 0 ? RS::LIST["투명도"] : 0
  end
end

#==============================================================================
# ** 게임 인터프리터
#==============================================================================
class Game_Interpreter
  
  def process_message_params
    event_id = @event_id
    index = @index
    meta = RS::EventComment.get(event_id, index - 1)
    return if meta.nil?
    if meta["대화창 투명도"]
      RS::LIST["투명도"] = meta["대화창 투명도"].to_i
    end
    if meta["대화창 윈도우스킨"]
      RS::LIST["윈도우스킨"] = meta["대화창 윈도우스킨"].strip
    end
    if meta["이름 윈도우스킨"]
      RS::LIST["이름윈도우스킨"] = meta["이름 윈도우스킨"].strip
    end    
  end
  #--------------------------------------------------------------------------
  # * 문장의 표시(오버라이딩)
  #--------------------------------------------------------------------------
  def command_101
    wait_for_message
    $game_map.msg_event = get_character(@event_id > 0? 0 : -1)
    $game_message.face_name = @params[0]
    $game_message.face_index = @params[1]
    $game_message.background = @params[2]
    $game_message.position = @params[3]
    process_message_params

    # 라인 확장 여부 체크
    multi_line_flag? ? multi_line_add_message : default_add_message

    case next_event_code
    when 102  # Show Choices
      @index += 1
      setup_choices(@list[@index].parameters)
    when 103  # Input Number
      @index += 1
      setup_num_input(@list[@index].parameters)
    when 104  # Select Item
      @index += 1
      setup_item_choice(@list[@index].parameters)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * 기본형 메시지 추가
  #--------------------------------------------------------------------------
  def default_add_message
    while next_event_code == 401       # Text data
      @index += 1
      $game_message.add(@list[@index].parameters[0])
    end
  end
  #--------------------------------------------------------------------------
  # * 확장형 대화창 추가
  #--------------------------------------------------------------------------
  def multi_line_add_message
    init_line_height # 라인 초기화
    until @line_height >= $game_message.line # 라인 읽기
      while next_event_code == 401       # 텍스트 데이터
        @index += 1
        $game_message.add(@list[@index].parameters[0])
        add_line_height # 라인 추가
      end
        # 다음 이벤트가 대화창이 아니면 루프 탈출
        break if next_event_code != 101
    end
  end
  #--------------------------------------------------------------------------
  # * 라인 초기화
  #--------------------------------------------------------------------------
  def init_line_height
    @line_height = 0
  end
  #--------------------------------------------------------------------------
  # * 라인 확장 설정 확인
  #--------------------------------------------------------------------------
  def multi_line_flag?
    $game_message.line > 4
  end
  #--------------------------------------------------------------------------
  # * 라인 추가
  #--------------------------------------------------------------------------
  def add_line_height
    @line_height += 1
    @index += 1 if next_event_code == 101
  end
end

class Window_Message < Window_Base
  attr_accessor :name_window
end

#==============================================================================
# ** Window_ChoiceList (선택지 Z좌표)
#==============================================================================
class Window_ChoiceList < Window_Command
  alias choicelist_initialize initialize
  #--------------------------------------------------------------------------
  # * 선택지 윈도우의 Z좌표를 설정합니다
  #--------------------------------------------------------------------------
  def initialize(message_window)
    choicelist_initialize(message_window)
    self.z = @message_window.z + 5
  end
  alias rs_message_update_placement update_placement
  def update_placement
    rs_message_update_placement
    update_normal_placement
  end
  def update_normal_placement

    message_x = @message_window.x    
    message_y = @message_window.y
    message_width = @message_window.width
    message_height = @message_window.height
    position_type = $game_message.position

    # 메시지 윈도우가 화면 하단에 위치한다면
    if message_y >= Graphics.height / 2

      name_window = @message_window.name_window
      name_window_align = name_window.align 

      # 이름 윈도우가 가운데 또는 오른쪽에 있으면 패딩 값이 추가된다.
      if name_window.open? and ['center', 'right'].include?(name_window_align)
        self.y = message_y - name_window.height - self.height
      else 
        self.y = message_y - self.height
      end
        
    else
      # 메시지 윈도우가 상단에 있으면 선택지 윈도우는 메시지 윈도우 하단으로 오게 된다.
      self.y = message_y + message_height
    end

    self.x = message_x + message_width - self.width
    

  end
end

#==============================================================================
# ** Game_Temp(Call Refer)
#==============================================================================
class Game_Temp
  attr_accessor :set_max_line
  #--------------------------------------------------------------------------
  # * 최대 라인 수를 결정합니다
  #--------------------------------------------------------------------------
  def max_line=(n)
    return if @set_max_line.nil?
    @set_max_line.call(n)
  end
end

#==============================================================================
# ** Window_Message
#==============================================================================
class Window_Message
  alias xxxheight_initialize initialize
  #--------------------------------------------------------------------------
  # * 라인 수를 설정합니다
  #--------------------------------------------------------------------------
  def initialize
    xxxheight_initialize
    $game_temp.set_max_line = method(:set_height)
    set_height(RS::LIST["라인"])
  end
  #--------------------------------------------------------------------------
  # * 메시지 윈도우의 높이를 변경합니다
  #--------------------------------------------------------------------------
  def set_height(n)
    contents.clear
    $game_message.line = n
    self.height = fitting_height(n)
    create_contents
    set_font(RS::LIST["폰트명"],RS::LIST["폰트크기"])
    update_placement
  end
  #--------------------------------------------------------------------------
  # * 윈도우의 배경 화면을 사용자 정의 그래픽으로 설정합니다
  #--------------------------------------------------------------------------
  if RS::LIST["바탕화면"]
    def create_back_bitmap
      @back_bitmap = Cache.picture(RS::LIST["바탕화면"])
    end
  end
  #--------------------------------------------------------------------------
  # * 보여질 라인의 갯수
  #--------------------------------------------------------------------------
  def visible_line_number
    $game_message.line || RS::LIST["라인"]
  end
  #--------------------------------------------------------------------------
  # * Character Processing
  #     c    : Characters
  #     text : A character string buffer in drawing processing (destructive)
  #     pos  : Draw position {:x, :y, :new_x, :height}
  #--------------------------------------------------------------------------
  def process_character(c, text, pos)
    case c
    when "\n"   # New line
      process_new_line(text, pos)
    when "\f"   # New page
      process_new_page(text, pos)
    when "\e"   # Control character
      process_escape_character(obtain_escape_code(text), text, pos)
    else        # Normal character
      process_normal_character(c, pos, text)
    end
  end
  #--------------------------------------------------------------------------
  # * 텍스트 자동 개행
  #--------------------------------------------------------------------------
  alias process_word_wrap_character process_normal_character
  def process_normal_character(c, pos, text)

    # 자동 개행 여부 판단
    if $game_message.word_wrap_enabled
      tw = text_size(c).width
      if pos[:x] + (tw * 2) > contents_width
        process_new_line(text, pos)
      end
    end
    process_word_wrap_character(c, pos)
  end
end