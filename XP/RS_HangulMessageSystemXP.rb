#==============================================================================
#  ** 한글 메시지 시스템 v1.0.16 (2019.11.14)
#==============================================================================
#  ** 사용법
#==============================================================================
# 색상 변경 명령을 수행하려면 다음과 같은 텍스트 코드를 사용하세요.
# 한글 색상명은 색상테이블.ini 파일에서 나와있으며 새로 추가할 수도 있습니다.
#
#  \색[빨강]    : "청록","검은색","파란색","짙은회색","자홍색","회색","녹색","밝은녹색",
#              "밝은회색", "밤색","감청색","황록색","주황색","주황색","보라색","빨간색",
#              "민트색","노란색", "기본색"
# \색[c_red]  : c_aqua, c_black, c_blue, c_dkgray, c_fuchsia, c_gray, c_green,
#              c_lime, c_ltgray, c_maroon, c_navy, c_olive, c_orange, c_purple,
#              c_red, c_silver, c_teal, c_white, c_yellow, c_normal
# \색[기본색]  : 텍스트 색상을 기본색으로 바꿉니다.
#  \C[0-7]
#  \#FFFFFF!    : 웹 색상 변환입니다. (예제는 흰색이며 16진수 기준으로 RRGGBB 형식입니다)
#   
#  \변수[변수 인덱스]
#  \주인공[주인공 번호]
#  \파티원[파티원 번호]
#
#  \G      : 골드를 표시합니다.
#  \$      : 골드 윈도우를 띄웁니다.
#  \!      : 결정키 입력을 받는 퍼지 모드로 전환합니다.
#  \.      : 10 프레임을 대기합니다 (60프레임에선 15 프레임 대기)
#  \|      : 40 프레임을 대기합니다 (60프레임에선 60 프레임 대기)
#  \^       : 결정키 입력을 받지 않고 다음 텍스트로 넘깁니다.
#  \<      :  텍스트를 스킵 모드로 전환하여 대기 없이 빠르게 표시합니다.
#  \>      :  텍스트 스킵 모드를 끄고 원래 속도로 표시합니다.
#
# 스킬, 아이템, 무기구, 방어구의 아이콘과 이름을 표시하려면 다음과 같은 명령을 사용하세요.
#
#  \SI[스킬 인덱스]
#  \스킬아이콘[스킬 인덱스]
#
#  \II[아이템 인덱스]
#  \아이템아이콘[아이템 인덱스]
#
#  \WI[아이템 인덱스]
#  \무기구아이콘[아이템 인덱스]
#
#  \AI[아이템 인덱스]
#  \방어구아이콘[아이템 인덱스]
#
#  \속도![대기프레임]      : 대기 카운트를 설정합니다.
#  \S[대기프레임]          : 대기 카운트를 설정합니다.
# 
#  \크기![텍스트크기]      : 텍스트 크기를 변경합니다.
#  \H[텍스트크기]          : 텍스트 크기를 변경합니다.
#  <B>텍스트</B>           : 텍스트를 굵게 표시합니다.
#  <I>텍스트</I>           : 텍스트를 기울임꼴로 표시합니다.
#
#  \이름<러닝은빛>        : 이름 윈도우를 메시지 윈도우의 왼쪽에 정렬하여 표시합니다.
#  \이름<러닝은빛:left>    : 이름 윈도우를 메시지 윈도우의 왼쪽에 정렬하여 표시합니다.
#  \이름<러닝은빛:right>  : 이름 윈도우를 메시지 윈도우의 오른쪽에 정렬하여 표시합니다.
#  \이름<러닝은빛:center> : 이름 윈도우를 메시지 윈도우의 중앙에 정렬하여 표시합니다.
#
# 메시지 윈도우를 말풍선 모드로 전환하는 명령어입니다.
#
#  \말풍선[-1] : 플레이어      :  플레이어 위에 말풍선을 띄웁니다.
#  \말풍선[0] : 이 이벤트      :  이 이벤트 위에 말풍선을 띄웁니다.
#  \말풍선[이벤트ID]           :  이벤트 ID에 해당하는 이벤트 위에 말풍선을 띄웁니다.
#
# 다음 텍스트 코드로 들여쓰기가 가능합니다.
#
#  \들여쓰기[X] 
#
# 텍스트 정렬 코드는 다음과 같습니다.
#
#  <CENTER>가운데</CENTER>
#  <RIGHT>오른쪽</RIGHT>
#  <LEFT>왼쪽</LEFT>
#
# 숫자를 100,000,000과 같은 형태로 표시하려면 다음과 같은 텍스트 코드를 사용하십시오.
# \숫자[100000000]
#
# 다음 텍스트 코드는 현재 페이지에만 유효합니다. 
# 아래 명령들은 다음 페이지에선 기본값으로 재설정됩니다.
#
# \테두리색[색상명]
# \그림자색[색상명]
# \배경색[색상명]
# \테두리굵기[크기]
# 
# 예를 들면, \배경색[빨강]이라고 하면 텍스트의 배경색이 빨강색으로 변하게 됩니다.
# 다음 명령들도 현재 페이지에만 유효합니다.
# 
# \테두리켜
# \테두리꺼 
# \그림자켜
# \그림자꺼
# \배경색켜
# \배경색꺼
#
# 다음 페이지로 넘어갈 땐 다시 기본값으로 설정되므로,
# 원천적으로 기능을 OFF 하려면 설정을 false로 바꾸거나 스크립트 호출을 사용하십시오.
# 
# RS::LIST["배경색 그리기"] = false
# RS::LIST["테두리"] = false
# RS::LIST["그림자"] = false
#
#==============================================================================
# ** 스크립트 호출
#==============================================================================
# 한글 메시지 시스템에서 불러오는 기본 설정 값들은 스크립트를 통해 변경이 가능합니다.
# 루비의 해시로 구성하였기 때문에 키 값만 적으면 값을 Read하고 Write 할 수 있습니다.
#
# 예를 들면, RS::LIST["라인"] = 8은 라인을 8줄로 변경합니다.
# RS::LIST["텍스트 사운드 사용"] = false는 텍스트 사운드 사용을 중단합니다.
#
#==============================================================================
#  ** 버전 로그
#==============================================================================
# 2019.04.11 (v1.0.0) - First Release.
# 2019.04.12 (v1.0.3) :
# - 텍스트 들여쓰기 기능 추가
# - 텍스트 정렬 기능 추가
# - new_page 메서드에서 y 값을 0으로 설정
# - 이름 윈도우에서 색상 변경 등 일부 텍스트 코드 사용 가능 (들여쓰기 제외)
# 2019.04.13 (v1.0.4) :
# - 네코 플레이어에서 실행할 때 추가 색상 로드 기능 예외로 설정
# 2019.04.15 (v1.0.5) :
# - 텍스트 폭 계산 함수 사용 시 폰트 설정이 임시로 리셋되는 문제 수정.
# - 텍스트 사운드 설정 추가
# 2019.04.16 (v1.0.6) : 
# - 캐릭터가 움직이고 있을 때 말풍선 창은 이동되지 않는 문제.
# - 숫자 포맷 텍스트 코드 추가
# 2019.04.17 (v1.0.7) :
# - 테두리, 그림자, 배경색 묘화 추가
# - 텍스트 옵션 추가
# - 토글 텍스트 코드 추가
# - 테두리 굵기 변경 텍스트 코드 추가
# 2019.04.30 (v1.0.8) :
# - 말풍선 모드에서 캐릭터 스프라이트 세로 길이 자동 감지 기능 추가
# 2019.06.17 (v1.0.9) :
# - 기본 텍스트 속도 매개변수 추가
# 2019.07.05 (v1.0.10) :
# - F12로 게임 재시작 시, Color의 new 메서드를 찾을 수 없다고 나오는 오류 수정
# 2019.07.22 (v1.0.11) :
# - 자동 개행 시 오류가 발생하는 문제를 수정하였습니다.
# 2019.07.23 (v1.0.12) :
# - 네코 플레이어에서 텍스트 테두리, 그림자 기능 지원
# 2019.08.26 (v1.0.13) : 
# - 타일셋 그래픽이 설정된 캐릭터에 말풍선 모드를 적용하면 오류가 났던 문제 수정.
# 2019.09.07 (v1.0.14) :
# - 이름 윈도우 사용 중에 F12 버튼을 누르면, 오류가 발생하는 문제 수정.
# 2019.11.14 (v1.0.16) :
# - 얼굴 이미지 띄우는 기능, 별도의 애드온으로 분리
#==============================================================================
# ** 사용 조건
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_HangulMessageSystem"] = true
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
    success = WritePrivateProfileStringW.call(param[0], param[1], param[2], param[3])
  end
  #--------------------------------------------------------------------------
  # * INI 파일의 내용을 읽어옵니다
  #--------------------------------------------------------------------------
  def read_string(app_name,key_name,file_name)
    if $NEKO_RUBY
      return neko_read_string(app_name, key_name, file_name)
    end
    buf = "\0" * 256
    path = ".\\" + file_name
    (param = [app_name,key_name,path]).collect! {|x| x.unicode!}
    GetPrivateProfileStringW.call(param[0], param[1], 0, buf, 256, param[2])
    buf.unicode_s.unpack('U*').pack('U*')
  end    
  #--------------------------------------------------------------------------
  # * INI 파일의 내용을 작성합니다
  #--------------------------------------------------------------------------  
  def neko_write_string(app, data, file_name)
    return if not $NEKO_RUBY
    
    Thread.new {
      path = "./#{file_name}"
      
      f = File.open(path, "wb+")
      
      f.write "[#{app}]\r\n"
      data.each do |k, v|
        f.write "#{k}=#{v.to_s}\r\n"
      end
      f.close
    }
  end
  #--------------------------------------------------------------------------
  # * INI 파일의 내용을 읽어옵니다
  #--------------------------------------------------------------------------  
  def neko_read_string(app, key, file_name)
    return "" if not $NEKO_RUBY
    
    # 파일을 읽는다
    path = "./#{file_name}"
    f = File.open(path, "r+")
    data = f.read
    f.close
    
    # app_name이 app과 일치 하는 지 확인한다.
    m = data.split(/[\r\n]+/)
    app_name = d[1, d.size - 2]
    return "" if app_name != app
    m.shift
    
    # 컬러 배열을 만든다
    color = {}
    m.each do |line|
      name, value = line.split("=")
      color[name] = value
    end
    
    # 컬러가 있으면 반환, 없으면 빈 문자열
    return color[key] || ""
    
  end
end

#==============================================================================
# ** Graphics
#==============================================================================
module Graphics
  # 프로그램의 가로 길이와 세로 길이 값을 구해 대화창의 폭과 높이를 설정한다.
  if not defined? $NEKO_RUBY
    FindWindowW = Win32API.new('user32', 'FindWindowW', 'pp', 'l')
    GetClientRect = Win32API.new('user32', 'GetClientRect', 'lp', 'i')  
    begin
      game_name = INI.read_string("Game", "Title", "Game.ini")
      hwnd = FindWindowW.call('RGSS Player'.unicode!, game_name.unicode!)
      if hwnd
        @handle = hwnd
      else
        @handle = FindWindowW.call('RGSS Player'.unicode!, nil)
      end    
      rect = [0, 0, 0, 0].pack('l4')
      GetClientRect.call(@handle, rect)
      @width,@height = rect.unpack('l4')[2..3]
    rescue
      @width, @height = 640, 480
    end
  
    extend self
    unless method_defined? :width
      define_method(:width) { @width }
    end
    unless method_defined? :height  
      define_method(:height) { @height } 
    end
  end
end

#==============================================================================
# ** RS
#------------------------------------------------------------------------------
# 기본 설정값입니다.
#==============================================================================

module RS
  LIST = {}
  CODE = {}
  
  # 폰트 리스트 예:) ["나눔고딕, "굴림"]
  # Fonts 폴더에 해당 폰트 파일에 있어야 합니다.
  # 폰트 파일과 글꼴명은 다를 수 있습니다.
  # 여기에 적는 것은 해당 폰트의 실제 글꼴명입니다.
  LIST["폰트명"] = Font.default_name
  
  # 폰트 크기를 변경합니다. 예:) Font.default_size는 기본 폰트 사이즈입니다.
  LIST["폰트크기"] = $NEKO_RUBY ? 16 : Font.default_size
  
  # 자동 개행 설정
  # true이면 창의 폭을 넘겼을 때 자동으로 개행합니다.
  # 사용 시 정렬 기능이 제대로 동작하지 않을 수 있으니 주의 바랍니다.
  LIST["자동개행"] = true
  
  # 기본 라인 갯수
  LIST["라인"] = 4
  
  # 대화창의 전체 투명도를 설정합니다.
  # 투명도의 경우, 배경 창의 투명도, 텍스트의 투명도가 따로 나뉘지만
  # 여기에서는 그 둘을 포함한 전체 투명도를 조절합니다.
  LIST["투명도"] = 255
  LIST["배경투명도"] = 160
  
  # 이름 윈도우의 X좌표는 얼굴 이미지가 왼쪽에 표시되면 왼쪽에 표시되고,
  # 오른쪽에 표시되면 오른쪽에 표시합니다.
  # 스크립트 커맨드에서 RS::LIST["이름윈도우X1"] = 10 등으로 수정이 가능합니다.
  LIST["이름윈도우X1"] = 10
  LIST["이름윈도우X2"] = 210
  
  # 이름 윈도우 Y. 
  # 메시지 윈도우 Y좌표 값을 기준으로 위(+) 또는 아래(-)로 내릴 수 있습니다.
  # 위는 메시지 박스의 위쪽을 말하며, 아래는 메시지 박스와 겹쳐지는 방향을 말합니다.
  LIST["이름윈도우Y"] = 0
  
  # 텍스트 속도 조절 텍스트 코드를 사용하실 때의 최소, 최대 속도입니다.
  # 텍스트 속도가 1이라면 일반 글자 묘화 처리 후, 1프레임을 대기합니다.
  # 대기는 메시지 처리를 중단하고 나머지 업데이트 함수를 실행합니다.
  LIST["텍스트속도-최소"] = 0
  LIST["텍스트속도-최대"] = 8
  
  # 기본 텍스트 속도 (기본값 : 1)
  LIST["기본 텍스트 속도"] = 1
  
  # 말풍선을 화면 영역 안으로 자동 조절하여 표시합니다.
  # 이 옵션을 설정하면 캐릭터가 가장 자리에 있을 경우, 
  # 말풍선의 중앙 지점(anchor)이 옮겨질 수 있습니다.
  LIST["화면영역내표시"] = true
  
  # 크기 및 오프셋 설정
  LIST["가로"] = (Graphics.width * 0.75).floor
  LIST["오프셋X"] = 0
  LIST["오프셋Y"] = -10
  
  # 텍스트 사운드 설정
  LIST["텍스트 사운드 사용"] = true
  LIST["텍스트 사운드"] = ["032-Switch01", "032-Switch01"]
  LIST["텍스트 사운드 볼륨"] = [70, 70]
  LIST["텍스트 사운드 피치"] = [100, 100]
  LIST["텍스트 사운드 주기"] = 3
  
  # 폰트 옵션
  LIST["배경색 그리기"] = false
  LIST["테두리"] = true
  LIST["그림자"] = true
  LIST["그림자 거리"] = 2
  LIST["테두리 굵기"] = 1
  LIST["배경색"] = ::Color.new(128, 128, 128, 200)
  LIST["테두리 색상"] = ::Color.new(0, 0, 0, 255)
  LIST["그림자 색상"] = ::Color.new(0, 0, 0, 200)  

  # 정규 표현식 (잘 아시는 분들만 건드리십시오)
  CODE["16진수"] = /#([a-zA-Z^\d]*)/i
  CODE["색상추출"] = /^[가-힣]+|c_[a-zA-z]+$/
  CODE["명령어"] = /^[\$#\.\|\^!><\{\}\\]|^[A-Z가-힣]+[!]*/i
  CODE["이름색상코드"] = /\[([가-힣]+[\d]*|c_[a-zA-Z]+)\]/
  CODE["웹색상"] = /([a-zA-Z\d]+)!/
  CODE["추출"] = /^([가-힣]+)/
  CODE["큰페이스칩"] = /^큰\_+/
  CODE["효과음"] = /^\[(.+?)\]/i
  CODE["처리!"] = /^([가-힣]+)!/
  CODE["이름"] = /\e이름\<(.+?)\>/
  CODE["말풍선"] = /\e말풍선\[(\d+|-\d+)\]/i
  CODE["이름추출"] = /\[(.*)\]/
  CODE["이름색상변경1"] = /\eC\[(.+)\]/
  CODE["이름색상변경2"] = /\e색\[(.+)\]/
    
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
# ** Array
#==============================================================================
class Array
  def to_s
    "[#{self.join(",")}]"
  end
end

#==============================================================================
# ** Hash
#------------------------------------------------------------------------------
# Hash의 원소(Key, Value)를 바탕으로 INI 파일을 만듭니다
#==============================================================================
class Hash
  def to_ini(file_name="Default.ini",app_name="Default")
    if $NEKO_RUBY
      INI.neko_write_string(app_name, self, file_name)
    else
      self.each { |k, v| INI.write_string(app_name,k.to_s.dup,v.to_s.dup,file_name) }
    end
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
# ** RS.import_color(string)
#==============================================================================
module RS
  extend self
  #--------------------------------------------------------------------------
  # 색상을 불러옵니다
  #--------------------------------------------------------------------------
  def import_color(string)
    default_color = ::Color.new(255, 255, 255, 255) 
    return default_color if defined? $NEKO_RUBY
    data = INI.read_string("색상목록",string,'Colors.ini')
    if data =~ /\[(\d+)\W\s*(\d+)\W\s*(\d+)\W\s*(\d+)\s*\]/i
      ::Color.new($1.to_i, $2.to_i, $3.to_i, $4.to_i)
    else
      default_color
    end
  end  
end

#==============================================================================
# ** Colour
#==============================================================================
module Colour
  include RGB
  # 색상을 추출합니다
  GET_COLOR = Proc.new {|cint| 
    c = int_to_rgb(cint)
    color = create(c, get_alpha)
    color
  }

  extend self
  
  @@c_alpha = 255
  @@c_base = Color.new(255,255,255,255)
  #--------------------------------------------------------------------------
  # * 색상 객체 생성
  #--------------------------------------------------------------------------  
  define_method :create do |c, alpha|
    Color.new(c[0], c[1], c[2], get_alpha)
  end  
  #--------------------------------------------------------------------------
  # * 색상 코드 처리
  #--------------------------------------------------------------------------
  def gm_color(string)
    case string
    when "청록",'청록색','c_aqua' then GET_COLOR.call(16776960)
    when "검은색","검정",'c_black' then GET_COLOR.call(0)
    when "파란색","파랑",'c_blue' then GET_COLOR.call(16711680)
    when "짙은회색",'c_dkgray' then GET_COLOR.call(4210752)
    when "자홍색","자홍",'c_fuchsia' then GET_COLOR.call(16711935)
    when "회색",'c_gray' then GET_COLOR.call(8421504)
    when "녹색",'c_green' then GET_COLOR.call(32768)
    when "밝은녹색","라임",'c_lime' then GET_COLOR.call(65280)
    when "밝은회색",'c_ltgray' then GET_COLOR.call(12632256)
    when "밤색","마룬",'c_maroon' then GET_COLOR.call(128)
    when "감청색","네이비",'c_navy'  then GET_COLOR.call(8388608)
    when "황록색","올리브",'c_olive' then GET_COLOR.call(32896)
    when "주황색","주황","오렌지",'c_orange' then GET_COLOR.call(4235519)
    when "보라색","보라",'c_purple' then GET_COLOR.call(8388736)
    when "빨간색","빨강",'c_red' then GET_COLOR.call(255)
    when "은색","은",'c_silver' then GET_COLOR.call(12632256)
    when "민트색",'c_teal'   then GET_COLOR.call(8421376)
    when "흰색","흰",'c_white'  then GET_COLOR.call(16777215)
    when "노란색","노랑",'c_yellow' then GET_COLOR.call(65535)
    when "기본","기본색",'c_normal' then get_base_color
    else
      RS.import_color(string)
    end
  end
  def table
    [
      "청록","검은색","파란색","짙은회색","자홍색","회색","녹색","밝은녹색","밝은회색",
      "밤색","감청색","황록색","주황색","주황색","보라색","빨간색","민트색","노란색",
    ]
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
    color_range = (0..7)
    color_range.each_with_index do |color,index|
      color_table["기본색#{index}"] = text_color(color).to_a
      Colour.table.each do |color_name|
        color_table[color_name] = Colour.gm_color(color_name).to_a
      end
    end
    # 추가로 정의된 색상을 추가합니다
    extend_color {|k,v| color_table[k] = v }
    # INI 파일을 생성합니다
    color_table.to_ini("Colors.ini","색상목록")
  end
  #--------------------------------------------------------------------------
  # * 색상을 추가합니다
  #--------------------------------------------------------------------------
  def extend_color
    yield "하늘색",[153,217,234,255]
    yield "연보라색",[200,191,231,255]
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
    Colour.create Color.hex_to_rgb(self), 255
  end
end

#==============================================================================
# ** RPG::Cache
#==============================================================================
module RPG::Cache
  def self.face(filename)
    self.load_bitmap("Graphics/Faces/", filename)
  end  
end

#==============================================================================
# ** Game_Temp
#==============================================================================
class Game_Temp
  attr_accessor :name_position
  attr_accessor :msg_owner
  attr_accessor :word_wrap_enabled
  
  attr_accessor :message_speed
  attr_accessor :balloon
  
  attr_accessor :ox
  
  attr_accessor :used_text_width_ex
  
  attr_accessor :highlight, :highlight_color
  attr_accessor :out_color, :outline, :outline_width
  attr_accessor :shadow, :shadow_color
  
  alias rs_message_system_initialize initialize
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------  
  def initialize
    rs_message_system_initialize
    message_clear
  end
  #--------------------------------------------------------------------------
  # *  메시지 클리어
  #--------------------------------------------------------------------------    
  def message_clear
    @name_position = 0
    @msg_owner = nil
    @word_wrap_enabled = RS::LIST["자동개행"]
    @line = RS::LIST["라인"]
    @message_speed = RS::LIST["기본 텍스트 속도"]
    @balloon = -2
    @ox = 0    
    @align = []
    @align_last = 0
    @used_text_width_ex = false
    @highlight = RS::LIST["배경색 그리기"]
    @highlight_color = RS::LIST["배경색"]
    @out_color = RS::LIST["테두리 색상"]
    @outline = RS::LIST["테두리"]
    @shadow = RS::LIST["그림자"]
    @shadow_color = RS::LIST["그림자 색상"]   
    @outline_width = RS::LIST["테두리 굵기"]
  end
  #--------------------------------------------------------------------------
  # *  add
  #--------------------------------------------------------------------------    
  def add_text(text)
    text = text || ""
    @message_text = "" if !@message_text 
    @message_text += text + "\n"
  end
  #--------------------------------------------------------------------------
  # *  message_size
  #--------------------------------------------------------------------------      
  def message_size
    @message_text.split(/[\r\n]+/i).size
  end
  #--------------------------------------------------------------------------
  # *  Set Line
  #--------------------------------------------------------------------------      
  def line=(val)
    RS::LIST["라인"] = val
  end
  #--------------------------------------------------------------------------
  # *  Get Line
  #--------------------------------------------------------------------------        
  def line() RS::LIST["라인"] end
  #--------------------------------------------------------------------------
  # *  Set Align
  #-------------------------------------------------------------------------- 
  def align=(n)
    @align = @align || []
    @align_last = n
    @align.push(n)
  end
  #--------------------------------------------------------------------------
  # *  Get Align
  #--------------------------------------------------------------------------     
  def align
    n = @align.shift
    n ? n : @align_last
  end
  #--------------------------------------------------------------------------
  # *  Clear Align Last
  #--------------------------------------------------------------------------       
  def clear_align_last
    @align_last = 0
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
    Audio.se_play(name) 
  end
end

#==============================================================================
# ** Interpreter
#==============================================================================
class Interpreter
  #--------------------------------------------------------------------------
  # * 선택지의 표시
  #--------------------------------------------------------------------------
  def setup_choices(parameters)
    # Set choice item count to choice_max
    $game_temp.choice_max = parameters[0].size
    # Set choice to message_text
    for text in parameters[0]
      $game_temp.message_text += text + "\n"
    end
    # Set cancel processing
    $game_temp.choice_cancel_type = parameters[1]
    # Set callback
    current_indent = @list[@index].indent
    $game_temp.choice_proc = Proc.new { |n| @branch[current_indent] = n }
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  전체 윈도우에 적용되는 속성이 추가된다.
#==============================================================================
class Window_Base
  
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------  
  alias rs_message_system_window_initialize initialize 
  def initialize(x, y, width, height)
    rs_message_system_window_initialize(x, y, width, height)
    @opening = false
    @closing = false
  end
  #--------------------------------------------------------------------------
  # * 컨텐츠 투명도 조절
  #--------------------------------------------------------------------------    
  def openness=(n)
    n = [[255, n].min, 0].max 
    self.contents_opacity = n
  end
  def openness() self.contents_opacity end  
  def open?() @opening end
  def close?() @closing end
  #--------------------------------------------------------------------------
  # * 열기
  #--------------------------------------------------------------------------    
  def open
    @opening = true if self.openness < 255
    @closing = false
    self.visible = true
  end
  #--------------------------------------------------------------------------
  # * 닫기
  #--------------------------------------------------------------------------    
  def close
    @closing = true if self.openness > 0
    @opening = false
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # * 여는 중
  #--------------------------------------------------------------------------    
  def update_open
    return if not @opening
    self.openness += 32
    @opening = false if self.openness >= 255
  end  
  #--------------------------------------------------------------------------
  # * 닫는 중
  #--------------------------------------------------------------------------    
  def update_close
    return if not @closing
    self.openness -= 32
    @closing = false if self.openness <= 0
  end    
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------      
  alias rs_message_system_window_update update
  def update
    rs_message_system_window_update
    update_open
    update_close
  end
end

#==============================================================================
# ** 이름 윈도우
#==============================================================================
class Window_Name < Window_Base
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------   
  def initialize(message_window)
    super(80, 304, 240, 60)
    self.contents = Bitmap.new(contents_width, contents_height)
    self.visible = false
    self.z = 9999    
    @name = ""
    @message_window = message_window
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------     
  def update
    super
    update_opacity
    update_position
  end
  #--------------------------------------------------------------------------
  # * 투명도 업데이트
  #--------------------------------------------------------------------------   
  def update_opacity
    return if @message_window.nil?
    self.opacity = @message_window.opacity
    self.back_opacity  = @message_window.back_opacity
    self.contents_opacity  = @message_window.contents_opacity  
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 크기 조정
  #--------------------------------------------------------------------------   
  def resize_window(text_width)
    self.width = text_width
    if self.contents != nil
      self.contents.dispose
    end
    self.contents = Bitmap.new(contents_width, contents_height)
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 정렬 위치 설정
  #--------------------------------------------------------------------------   
  def update_position
    
    pos = $game_temp.name_position
    case pos
    when 0 # 왼쪽
      self.x = @message_window.x
    when 1 # 중앙
      self.x = (@message_window.x + @message_window.width / 2) - self.width / 2
    when 2 # 오른쪽
      self.x = (@message_window.x + @message_window.width) - self.width
    else 
      self.x = @message_window.x
    end
    
    y = 0
    case $game_system.message_position
    when 0
      self.y = 0
      @message_window.y = self.visible ? (self.y + self.height) : 0
    else
      self.y = @message_window.y - self.height - RS::LIST["이름윈도우Y"]
    end
    
  end
  #--------------------------------------------------------------------------
  # * 라인 높이
  #--------------------------------------------------------------------------   
  def line_height
    return 32
  end
  #--------------------------------------------------------------------------
  # * 패딩
  #--------------------------------------------------------------------------   
  def standard_padding
    return 16
  end
  #--------------------------------------------------------------------------
  # * 컨텐츠 폭
  #--------------------------------------------------------------------------    
  def contents_width
    return self.width - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * 컨텐츠 높이
  #--------------------------------------------------------------------------    
  def contents_height
    return self.height - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 열기
  #--------------------------------------------------------------------------
  def open(name)
    @opening = true if self.openness < 255
    @closing = false
    self.visible = true
    @name = name
    if name =~ /(.*):right/i
      $game_temp.name_position = 2
      @name = $1.to_s
    elsif name =~ /(.*):center/i
      $game_temp.name_position = 1
      @name = $1.to_s
    else 
      $game_temp.name_position = 0
    end
    @name = @name.strip
    refresh
    self.visible = true
  end
  #--------------------------------------------------------------------------
  # * 닫기
  #--------------------------------------------------------------------------    
  def close
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # * 액터 명 반환
  #--------------------------------------------------------------------------
  def actor_name(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.name : ""
  end  
  #--------------------------------------------------------------------------
  # * 파티 멤버명 반환
  #--------------------------------------------------------------------------
  def party_member_name(n)
    actor = n >= 1 ? $game_party.actors[n - 1] : nil
    actor ? actor.name : ""
  end    
  #--------------------------------------------------------------------------
  # * 텍스트 폭
  #--------------------------------------------------------------------------    
  def text_width(text)
    text.gsub!(/\\/)            { "\e" }
    text.gsub!(/\e\e/)          { "\\" }    
    text.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }    
    text.gsub!(/(?:\eN|\e주인공)\[(\d+)\]/i) { actor_name($1.to_i) }
    text.gsub!(/(?:\eP|\e파티원)\[(\d+)\]/i) { party_member_name($1.to_i) }
    text.gsub!(/(?:\eG|\e골드)/i) { $data_system.words.gold }
    text.gsub!(/(?:\e아이템)\[(\d+)\]/i) { $data_items[$1.to_i].name || "" }
    text.gsub!(/(?:\e스킬)\[(\d+)\]/i) { $data_skills[$1.to_i].name || "" }
    text.gsub!(/(?:\e무기구)\[(\d+)\]/i) { $data_weapons[$1.to_i].name || "" }
    text.gsub!(/(?:\e방어구)\[(\d+)\]/i) { $data_armors[$1.to_i].name || "" }
    text.gsub!(/(?:\e적)\[(\d+)\]/i) { $data_enemies[$1.to_i].name || "" }
    text.gsub!(/(?:\e직업)\[(\d+)\]/i) { $data_classes[$1.to_i].name || "" }
    text.gsub!(/(?:\e상태)\[(\d+)\]/i) { $data_states[$1.to_i].name || "" }
    text.gsub!(/<(?:B)>/i) { "\eSB!" }
    text.gsub!(/<(?:\/B)>/i) { "\eEB!" }
    text.gsub!(/<(?:I)>/i) { "\eSI!" }
    text.gsub!(/<(?:\/I)>/i) { "\eEI!" }
    self.contents.text_size(text).width
  end
  #--------------------------------------------------------------------------
  # * 문자 처리
  #--------------------------------------------------------------------------
  def obtain_escape_code(text)
    text.slice!(RS::CODE["명령어"])
  end
  #--------------------------------------------------------------------------
  # * 텍스트 코드에서 정수 값 취득
  #--------------------------------------------------------------------------
  def obtain_escape_param(text)
    text.slice!(/^\[\d+\]/)[/\d+/].to_i rescue 0
  end  
  #--------------------------------------------------------------------------
  # * 색상 코드 처리
  #--------------------------------------------------------------------------
  def obtain_name_color(text)
    text.slice!(RS::CODE["이름색상코드"])[$1]
  end  
  #--------------------------------------------------------------------------
  # * 색상 변경
  #--------------------------------------------------------------------------    
  def change_color(color)
    if color.is_a?(Integer) and color >= 0 and color <= 7
      self.contents.font.color = text_color(color)
    elsif color.is_a?(Color)
      self.contents.font.color = color
    end
  end  
  #--------------------------------------------------------------------------
  # * 스킬/무기구/방어구 아이콘 그리기
  #--------------------------------------------------------------------------        
  def draw_item(pos, item)
    return if not item
    bitmap = RPG::Cache.icon(item.icon_name)
    rect = Rect.new(0, 0, 24, 24)
    self.contents.blt(pos[:x], pos[:y] + 4, bitmap, rect, RS::LIST["투명도"])
    pos[:x] += rect.width
    w = self.contents.text_size(item.name).width
    self.contents.draw_text(pos[:x], pos[:y], w, pos[:height], item.name, 0)
    pos[:x] += w
  end  
  #--------------------------------------------------------------------------
  # * draw_text_ex
  #--------------------------------------------------------------------------   
  def draw_text_ex(x, y, text)
    
    pos = {}
    pos[:x] = x
    pos[:y] = y
    pos[:left] = x
    pos[:height] = line_height
    
    process_character(pos, text.slice!(/./m), text) until text.empty?
    
    return pos[:x] - x
    
  end
  #--------------------------------------------------------------------------
  # * process_character for name window
  #--------------------------------------------------------------------------     
  def process_character(pos, c, text)
    case c
    when "\e"
      process_escape_character(obtain_escape_code(text), text, pos)
    else
      process_normal_character(c, pos)
    end
  end
  #--------------------------------------------------------------------------
  # * process_escape_character for name window
  #--------------------------------------------------------------------------   
  def process_escape_character(c, text, pos)
    case c
    when 'C'
      change_color(obtain_escape_param(text))
    when '색'
      color = Color.gm_color(obtain_name_color(text))
      change_color(color)      
    when '#'
      color = "##{to_hex(text)}".hex_to_color
      change_color(color)   
    when 'SI','스킬아이콘'
      data = $data_skills[obtain_escape_param(text)]
      draw_item(pos, data)
    when 'II','아이템아이콘'
      data = $data_items[obtain_escape_param(text)]
      draw_item(pos, data)
    when 'WI','무기구아이콘'
      data = $data_weapons[obtain_escape_param(text)]
      draw_item(pos, data)        
    when 'AI','방어구아이콘'
      data = $data_weapons[obtain_escape_param(text)]
      draw_item(pos, data)          
    when 'SB!'
      self.contents.font.bold = true
    when 'EB!'
      self.contents.font.bold = false
    when 'SI!'
      self.contents.font.italic = true
    when 'EI!'
      self.contents.font.italic = false
    end    
  end
  #--------------------------------------------------------------------------
  # * 그림자 묘화
  #--------------------------------------------------------------------------   
  def draw_shadow(c, pos, w)
    return if not $game_temp.shadow
    self.contents.font.color = $game_temp.shadow_color    
    n = 1
    tw = w    
    self.contents.draw_text(4 + pos[:x] + n, pos[:y] + n, tw, pos[:height], c)
  end  
  #--------------------------------------------------------------------------
  # * process_normal_character for name window
  #--------------------------------------------------------------------------     
  def process_normal_character(c, pos)    
    w = self.contents.text_size(c).width
    temp_color = self.contents.font.color.dup
    draw_shadow(c, pos, w)
    self.contents.font.color = temp_color
    self.contents.draw_text(4 + pos[:x], pos[:y], w * 2, pos[:height], c)
    pos[:x] += w
  end
  #--------------------------------------------------------------------------
  # * 재묘화
  #--------------------------------------------------------------------------    
  def refresh
    tw = draw_text_ex(0, contents_height + 6, @name.clone)
    resize_window(tw * 2)
    self.contents.clear   
    text_padding = 4
    cx = (contents_width - text_padding) / 2 - tw / 2
    draw_text_ex(cx, 0, @name)
  end
  #--------------------------------------------------------------------------
  # * 폰트 설정
  #--------------------------------------------------------------------------
  def set_font(name, size = Font.default_size )
    
    if $NEKO_RUBY
      text_height = size / 0.75 # pt에서 px
      max_font_size = (line_height - 2) * 0.75 # px에서 pt
      
      if text_height > line_height
        size = max_font_size 
      end
    end
    
    self.contents.font.name = name
    self.contents.font.size = size
  end
end

#==============================================================================
# ** Window_MessageGold
#------------------------------------------------------------------------------
#  소유 금전을 표시합니다.
#==============================================================================
class Window_MessageGold < Window_Gold
  def initialize
    super
    self.openness = 0
  end
  def update
    super
    self.opacity = background_opacity
    self.back_opacity = background_opacity
  end
  def background_opacity() 200 end
end

#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  윈도우 메시지 객체를 용도에 맞게 캡슐화 한다.
#==============================================================================
class Window_Message < Window_Selectable  
  
  include RS::Color

  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------
  def initialize
    super(80, 304, window_width, window_height)
    self.contents = Bitmap.new(contents_width, contents_height)
    self.visible = false
    self.z = 9998
    @fade_in = false
    @fade_out = false
    @contents_showing = false
    @cursor_width = 0
    @wait_count = 0
    self.active = false
    self.index = -1
    init_members
    create_name_window  
    create_gold_window
    Color.set_base_color = text_color(0)
    init_color_table
    set_height(RS::LIST["라인"])
  end
  #--------------------------------------------------------------------------
  # * 멤버 초기화
  #--------------------------------------------------------------------------  
  def init_members
    self.openness = 0
    @text_state = nil
    @wait_count = 0
    @opening = false
    @closing = false
    @is_used_text_width_ex = false  
        
    clear_flags
  end
  #--------------------------------------------------------------------------
  # * 플래그 초기화
  #--------------------------------------------------------------------------       
  def clear_flags
    @show_fast = false
    @line_show_fast = false
    @pause_skip = false
  end  
  #--------------------------------------------------------------------------
  # * 대기
  #--------------------------------------------------------------------------     
  def wait(count)
    @wait_count = count
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    RS::LIST["가로"]
  end  
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------   
  def window_height
    fitting_height(visible_line_number)
  end  
  #--------------------------------------------------------------------------
  # * 라인 높이
  #--------------------------------------------------------------------------     
  def line_height
    return 32
  end
  #--------------------------------------------------------------------------
  # * 패딩
  #--------------------------------------------------------------------------     
  def standard_padding
    return 16
  end
  #--------------------------------------------------------------------------
  # * 라인 갯수
  #--------------------------------------------------------------------------    
  def visible_line_number
    return $game_temp.line || 4
  end
  #--------------------------------------------------------------------------
  # * 컨텐츠 폭
  #--------------------------------------------------------------------------     
  def contents_width
    return window_width - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * 컨텐츠 높이
  #--------------------------------------------------------------------------     
  def contents_height
    return window_height - standard_padding * 2
  end
  #--------------------------------------------------------------------------
  # * 창 높이 맞춤
  #--------------------------------------------------------------------------    
  def fitting_height(line_number)
    line_number * line_height + standard_padding * 2
  end  
  #--------------------------------------------------------------------------
  # * 컨텐츠 생성
  #--------------------------------------------------------------------------
  def create_contents
    self.contents = Bitmap.new(contents_width, contents_height)
  end
  #--------------------------------------------------------------------------
  # * 메시지 윈도우의 높이를 변경합니다
  #--------------------------------------------------------------------------  
  def set_height(n)
    self.contents.clear
    $game_temp.line = n
    self.height = fitting_height(n)
    create_contents
    set_font(RS::LIST["폰트명"],RS::LIST["폰트크기"])
    reset_window
  end  
  #--------------------------------------------------------------------------
  # * 텍스트 크기
  #--------------------------------------------------------------------------     
  def text_width(text)
    self.contents.text_size(text).width
  end  
  #--------------------------------------------------------------------------
  # * 폰트 설정
  #--------------------------------------------------------------------------
  def set_font(name, size = Font.default_size )
    
    if $NEKO_RUBY
      text_height = size / 0.75 # pt에서 px
      max_font_size = (line_height - 2) * 0.75 # px에서 pt
      
      if text_height > line_height
        size = max_font_size 
      end
    end
    
    self.contents.font.name = name
    self.contents.font.size = size
    
  end  
  #--------------------------------------------------------------------------
  # * 이름 윈도우 생성하기
  #--------------------------------------------------------------------------   
  def create_name_window
    @name_window = Window_Name.new(self)
    @name_window.x = self.x + RS::LIST["이름윈도우X1"]
    @name_window.y = self.y - RS::LIST["이름윈도우Y"]
    @name_window.openness = 0
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 제거하기
  #--------------------------------------------------------------------------     
  def dispose_name_window
    if @name_window != nil
      @name_window.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 업데이트
  #--------------------------------------------------------------------------      
  def update_name_window
    @name_window.update
  end
  #--------------------------------------------------------------------------
  # * 이름 윈도우 닫기
  #--------------------------------------------------------------------------     
  def close_name_window
    if @name_window != nil
      if @name_window.visible == true
        @name_window.close
      end
    end    
  end
  #--------------------------------------------------------------------------
  # * 골드 윈도우 생성
  #--------------------------------------------------------------------------   
  def create_gold_window
    @gold_window = Window_MessageGold.new
    @gold_window.x = Graphics.width - @gold_window.width
    @gold_window.openness = 0
    @gold_window.visible = false
    
    if $game_temp.in_battle
      @gold_window.y = 192
    else
      pos = $game_system.message_position || 0
      @gold_window.y = (pos == 0) ? (Graphics.height - @gold_window.height) : 0      
    end
    @gold_window.opacity = self.opacity
    @gold_window.back_opacity = self.back_opacity    
    
  end
  #--------------------------------------------------------------------------
  # * 골드 윈도우 업데이트
  #--------------------------------------------------------------------------     
  def update_gold_window
    return if not @gold_window
    @gold_window.update
  end
  #--------------------------------------------------------------------------
  # * 골드 윈도우 제거
  #--------------------------------------------------------------------------     
  def dispose_gold_window
    return if not @gold_window
    @gold_window.dispose
  end  
  #--------------------------------------------------------------------------
  # * 이스케이프 문자 변환
  #--------------------------------------------------------------------------   
  def convert_escape_characters(text)
    text = text || $game_temp.message_text
    text = text.to_s.clone
    text.gsub!(/\\/)            { "\e" }
    text.gsub!(/\e\e/)          { "\\" }    
    text.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }    
    text.gsub!(/(?:\eN|\e주인공)\[(\d+)\]/i) { actor_name($1.to_i) }
    text.gsub!(/(?:\eP|\e파티원)\[(\d+)\]/i) { party_member_name($1.to_i) }
    text.gsub!(/(?:\eG|\e골드)/i) { $data_system.words.gold }
    text.gsub!(/(?:\e아이템)\[(\d+)\]/i) { $data_items[$1.to_i].name || "" }
    text.gsub!(/(?:\e스킬)\[(\d+)\]/i) { $data_skills[$1.to_i].name || "" }
    text.gsub!(/(?:\e무기구)\[(\d+)\]/i) { $data_weapons[$1.to_i].name || "" }
    text.gsub!(/(?:\e방어구)\[(\d+)\]/i) { $data_armors[$1.to_i].name || "" }
    text.gsub!(/(?:\e적)\[(\d+)\]/i) { $data_enemies[$1.to_i].name || "" }
    text.gsub!(/(?:\e직업)\[(\d+)\]/i) { $data_classes[$1.to_i].name || "" }
    text.gsub!(/(?:\e상태)\[(\d+)\]/i) { $data_states[$1.to_i].name || "" }
    text.gsub!(/<(?:B)>/i) { "\eSB!" }
    text.gsub!(/<(?:\/B)>/i) { "\eEB!" }
    text.gsub!(/<(?:I)>/i) { "\eSI!" }
    text.gsub!(/<(?:\/I)>/i) { "\eEI!" }
    
    # 선택지가 있는 경우, 크기 변환을 할 수 없다.
    text.gsub!(/\e크기!\[\d+\]/) { "" } if $game_temp.choice_max > 0
    
    text.gsub!(RS::CODE["이름"]) do 
      @name_window.open($1.to_s)
      ""
    end
        
    text.gsub!(/<\/LEFT>|<\/CENTER>|<\/RIGHT>/i) { "\eAEND" }    
    
    text.gsub!(RS::CODE["말풍선"]) { $game_temp.balloon = $1.to_i; "" }
    text
  end
  #--------------------------------------------------------------------------
  # * 액터 명 반환
  #--------------------------------------------------------------------------
  def actor_name(n)
    actor = n >= 1 ? $game_actors[n] : nil
    actor ? actor.name : ""
  end  
  #--------------------------------------------------------------------------
  # * 파티 멤버명 반환
  #--------------------------------------------------------------------------
  def party_member_name(n)
    actor = n >= 1 ? $game_party.actors[n - 1] : nil
    actor ? actor.name : ""
  end  
  #--------------------------------------------------------------------------
  # * 텍스트 처리
  #--------------------------------------------------------------------------   
  def process_character(c, text, pos)
    case c
    when "\f"
      pos[:y] = self.contents.height
      start_pause
    when "\n" # 텍스트 개행
      process_new_line(text, pos)    
    when "\e" # 텍스트 코드 처리
      process_escape_character(obtain_escape_code(text), text, pos)
    else # 일반 문자 처리
      process_normal_character(c, pos, text)
    end   
  end
  #--------------------------------------------------------------------------
  # * 문자 처리
  #--------------------------------------------------------------------------
  def obtain_escape_code(text)
    text.slice!(RS::CODE["명령어"])
  end
  #--------------------------------------------------------------------------
  # * 텍스트 코드에서 정수 값 취득
  #--------------------------------------------------------------------------
  def obtain_escape_param(text)
    text.slice!(/^\[\d+\]/)[/\d+/].to_i rescue 0
  end
  #--------------------------------------------------------------------------
  # * 색상 코드 처리
  #--------------------------------------------------------------------------
  def obtain_name_color(text)
    text.slice!(RS::CODE["이름색상코드"])[$1]
  end
  #--------------------------------------------------------------------------
  # * 웹 색상 코드 처리
  #--------------------------------------------------------------------------
  def to_hex(text)
    text.slice!(RS::CODE["웹색상"])[$1] rescue "#FFFFFF"
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
    @message_desc[:font_color] = contents.font.color
    @message_desc[:font_highlight] = $game_temp.highlight
    @message_desc[:font_highlight_color] = $game_temp.highlight_color
    @message_desc[:font_out_color] = $game_temp.out_color
    @message_desc[:font_outline] = $game_temp.outline
    @message_desc[:font_outline_width] = $game_temp.outline_width
    @message_desc[:font_shadow] = $game_temp.shadow
    @message_desc[:font_shadow_color] = $game_temp.shadow_color   
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
    contents.font.color = @message_desc[:font_color]
    $game_temp.highlight = @message_desc[:font_highlight]
    $game_temp.highlight_color = @message_desc[:font_highlight_color]
    $game_temp.out_color = @message_desc[:font_out_color]
    $game_temp.outline = @message_desc[:font_outline]
    $game_temp.outline_width = @message_desc[:font_outline_width]
    $game_temp.shadow = @message_desc[:font_shadow]
    $game_temp.shadow_color = @message_desc[:font_shadow_color]
    @message_desc = nil
  end  
  #--------------------------------------------------------------------------
  # * draw_text_ex
  #--------------------------------------------------------------------------
  def draw_text_ex(x, y, text)
    reset_font_settings
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    do_first_line_align(pos, text) if not @is_used_text_width_ex
    process_character(text.slice!(/./m), text, pos) until text.empty?
    return pos[:x] - x
  end  
  #--------------------------------------------------------------------------
  # * draw_text_ex_for_align
  #--------------------------------------------------------------------------  
  def draw_text_ex_for_align(x, y, text)
    text = convert_escape_characters(text)
    pos = {:x => x, :y => y, :new_x => x, :height => calc_line_height(text)}
    do_first_line_align(pos, text) if not @is_used_text_width_ex
    process_character(text.slice!(/./m), text, pos) until text.empty?
    return pos[:x] - x    
  end
  #--------------------------------------------------------------------------
  # * text_width_ex
  #--------------------------------------------------------------------------
  def text_width_ex(text)
    draw_text_ex(0, contents_height + 6, text)
  end
  #--------------------------------------------------------------------------
  # * text_width_ex2
  #--------------------------------------------------------------------------  
  def text_width_ex2(text)
    draw_text_ex_for_align(0, contents_height + 6, text)    
  end
  #--------------------------------------------------------------------------
  # * 라인 높이 계산
  #--------------------------------------------------------------------------
  def calc_line_height(text, restore_font_size = true)
    result = [line_height, self.contents.font.size].max
    last_font_size = contents.font.size
    
    text.slice(/^.*$/).scan(/\e(?:크기!|H)\[(\d+)\]/).each do |esc|
      set_text_size(esc[0].to_i) if esc
      result = [result, self.contents.font.size].max
    end
    self.contents.font.size = last_font_size if restore_font_size
    
    # 선택지가 있을 때 크기 변환을 하면 문제가 선택지 영역 계산에 문제가 생긴다.
    self.contents.font.size = last_font_size if $game_temp.choice_max > 0
    
    result
  end
  #--------------------------------------------------------------------------
  # * 텍스트 크기 설정
  #--------------------------------------------------------------------------        
  def set_text_size(n)
    self.contents.font.size = n
  end
  #--------------------------------------------------------------------------
  # * 스킬/무기구/방어구 아이콘 그리기
  #--------------------------------------------------------------------------        
  def draw_item(pos, item)
    return if not item
    bitmap = RPG::Cache.icon(item.icon_name)
    rect = Rect.new(0, 0, 24, 24)
    draw_highlight_color("", pos, rect.width)
    self.contents.blt(pos[:x], pos[:y] + 4, bitmap, rect, RS::LIST["투명도"])
    pos[:x] += rect.width
    draw_normal_character(item.name, pos, true)
  end
  #--------------------------------------------------------------------------
  # * 텍스트 코드 처리
  #--------------------------------------------------------------------------       
  def process_escape_character(code, text, pos)
    case code.upcase
    when 'C'
      change_color(obtain_escape_param(text))
    when '색'
      color = Color.gm_color(obtain_name_color(text))
      change_color(color)  
    when 'SI','스킬아이콘'
      data = $data_skills[obtain_escape_param(text)]
      draw_item(pos, data)
    when 'II','아이템아이콘'
      data = $data_items[obtain_escape_param(text)]
      draw_item(pos, data)
    when 'WI','무기구아이콘'
      data = $data_weapons[obtain_escape_param(text)]
      draw_item(pos, data)        
    when 'AI','방어구아이콘'
      data = $data_weapons[obtain_escape_param(text)]
      draw_item(pos, data)
    when '#'
      color = "##{to_hex(text)}".hex_to_color
      change_color(color)          
    when '$'
      @gold_window.refresh
      @gold_window.open
    when '!'
      start_pause
    when '.'
      (Graphics.frame_rate >= 60) ? wait(15) : wait(10)
    when '|'
      (Graphics.frame_rate >= 60) ? wait(60) : wait(40) 
    when '>'
      @line_show_fast = true
    when '<' 
      @line_show_fast = false
    when '^' 
      @page_skip = true
    when '속도!','S'
      set_text_speed(obtain_escape_param(text).to_i)      
    when '크기!','H'
      n = obtain_escape_param(text).to_i
      set_text_size(n)
    when 'SB!'
      self.contents.font.bold = true
    when 'EB!'
      self.contents.font.bold = false
    when 'SI!'
      self.contents.font.italic = true
    when 'EI!'
      self.contents.font.italic = false      
    when '굵게!'
      self.contents.font.bold = !self.contents.font.bold
    when '이탤릭!'
      self.contents.font.italic = !self.contents.font.italic
    when '들여쓰기'
      set_text_indent(pos, obtain_escape_param(text).to_i)
    when 'AEND'
      $game_temp.clear_align_last
    when '숫자'
      to_snumber(obtain_escape_param(text).to_s, pos)
    when '그림자켜' then $game_temp.shadow = true
    when '그림자꺼' then $game_temp.shadow = false
    when '테두리켜' then $game_temp.outline = true
    when '테두리꺼' then $game_temp.outline = false
    when '배경색켜' then $game_temp.highlight = true
    when '배경색꺼' then $game_temp.highlight = false  
    when '그림자색', 'SC'
      color = Color.gm_color(obtain_name_color(text))
      $game_temp.shadow_color = color      
    when '테두리색', 'OC'
      color = Color.gm_color(obtain_name_color(text))
      $game_temp.out_color = color
    when '배경색', 'BC'
      color = Color.gm_color(obtain_name_color(text))
      $game_temp.highlight_color  = color
    when '테두리굵기', 'OW'
      $game_temp.outline_width = obtain_escape_param(text).to_i
    end
  end
  #--------------------------------------------------------------------------
  # * 숫자 변환
  #--------------------------------------------------------------------------   
  def to_snumber(text, pos)
    begin
      n = text.reverse.scan(/\d{1,3}/i).collect! {|i| i.reverse }
      result = n.reverse.join(",")      
      draw_normal_character(result, pos, true)
      pos[:x] += w
      
    rescue
    end
  end
  #--------------------------------------------------------------------------
  # * 한국어 조사
  #--------------------------------------------------------------------------   
  def to_postpositional_word(text, a, b)
        
    last_word = text.slice(-1, 1)
    return last_word if not last_word.match(/[가-ퟻ]+/i)
    
    wide_char_code = last_word.unpack('U*')[0]
    distance = wide_char_code - 44032
    post_pointer = (distance % 28) > 0 ? a : b
 
    text + post_pointer
    
  end
  #--------------------------------------------------------------------------
  # * 텍스트 폭 계산
  #--------------------------------------------------------------------------   
  def calc_text_width(text)
    temp_text = text.clone
    temp_text = temp_text.split(/[\r\n]+/i)
    text_width = 0
    save
    @is_used_text_width_ex = true
    text_width = text_width_ex2(temp_text[0])
    restore
    @is_used_text_width_ex = false
    text_width
  end
  #--------------------------------------------------------------------------
  # * 텍스트 정렬
  #--------------------------------------------------------------------------  
  def process_align(pos, text)
    pos = pos || @text_state
    case $game_temp.align
    when 1
      set_align_center(pos, text)
    when 2
      set_align_right(pos, text)
    end
  end  
  #--------------------------------------------------------------------------
  # * 텍스트 정렬
  #--------------------------------------------------------------------------    
  def set_align_center(pos, text)
    padding = 6
    tx = calc_text_width(text)
    pos[:x] = (self.contents.width + padding) / 2 - tx / 2
    pos[:left] = pos[:x]
  end  
  #--------------------------------------------------------------------------
  # * 텍스트 정렬
  #--------------------------------------------------------------------------    
  def set_align_right(pos, text)
    padding = 6
    tx = calc_text_width(text)
    pos[:x] = (self.contents.width - padding) - tx
    pos[:left] = pos[:x]
  end
  #--------------------------------------------------------------------------
  # * 텍스트 정렬
  #--------------------------------------------------------------------------    
  def do_first_line_align(pos, text)
    is_valid = !@is_used_text_width_ex
    process_align(pos, text) if is_valid
  end
  #--------------------------------------------------------------------------
  # * 텍스트 들여쓰기
  #--------------------------------------------------------------------------  
  def set_text_indent(pos, indent)
    ret = pos[:x] + indent.abs
    min = indent.abs
    max = self.contents.width - indent.abs
    ret = [[ret, indent].max, max].min if ret > self.contents.width
    pos[:x] = ret
  end
  #--------------------------------------------------------------------------
  # * 텍스트 속도 조절
  #--------------------------------------------------------------------------
  def set_text_speed(text_speed)
    return if @is_used_text_width_ex
    $game_temp.message_speed = case text_speed
    when (RS::LIST["텍스트속도-최소"]..RS::LIST["텍스트속도-최대"])
      text_speed
    else
      RS::LIST["텍스트속도-최소"]
    end
  end  
  #--------------------------------------------------------------------------
  # * 색상 변경
  #--------------------------------------------------------------------------    
  def change_color(color)
    if color.is_a?(Integer) and color >= 0 and color <= 7
      self.contents.font.color = text_color(color)
    elsif color.is_a?(Color)
      self.contents.font.color = color
    end
  end
  #--------------------------------------------------------------------------
  # * 개행 처리
  #--------------------------------------------------------------------------     
  def process_new_line(text, pos)
    
    @line_show_fast = false
    
    # Update cursor width if choice
    if (pos[:y] / line_height) >= $game_temp.choice_start
      @cursor_width = [@cursor_width, pos[:x]].max
    end
    
    # Add 1 to y
    pos[:y] += pos[:height]
    pos[:x] = 0
    
    # Indent if choice
    if (pos[:y] / line_height) >= $game_temp.choice_start   
      pos[:x] = 8 
    end
        
    pos[:left] = pos[:x]
        
    if needs_new_page(pos) and !@text.empty?
      start_pause
    end
    
    process_align(pos, text) if !@is_used_text_width_ex
     
  end
  #--------------------------------------------------------------------------
  # * request_text_sound
  #--------------------------------------------------------------------------
  def request_text_sound
    return false if @is_used_text_width_ex
    return false unless RS::LIST["텍스트 사운드 사용"]
    id = Graphics.frame_count % RS::LIST["텍스트 사운드"].size
    name = RS::LIST["텍스트 사운드"][id]
    volume = RS::LIST["텍스트 사운드 볼륨"][id]
    pitch = RS::LIST["텍스트 사운드 피치"][id]
    path = "Audio/SE/" + name
    Audio.se_play(path, volume, pitch)
  end
  #--------------------------------------------------------------------------
  # * 배경색 묘화
  #--------------------------------------------------------------------------    
  def draw_highlight_color(c, pos, w)
    return if not $game_temp.highlight
    return if $NEKO_RUBY # 네코 플레이어에서 텍스트 블렌딩을 지원하지 않음
    highlight_color = $game_temp.highlight_color    
    self.contents.fill_rect(4 + pos[:x], pos[:y], w, pos[:height], highlight_color)
  end
  #--------------------------------------------------------------------------
  # * 그림자 묘화
  #--------------------------------------------------------------------------   
  def draw_shadow(c, pos, w)
    return if not $game_temp.shadow
    self.contents.font.color = $game_temp.shadow_color    
    n = RS::LIST["그림자 거리"]
    tw = w    
    self.contents.draw_text(4 + pos[:x] + n, pos[:y] + n, tw, pos[:height], c)
  end
  #--------------------------------------------------------------------------
  # * 테두리 묘화
  #--------------------------------------------------------------------------  
  def draw_outline(c, pos, w)
    return if not $game_temp.outline
    self.contents.font.color = $game_temp.out_color      
    n = $game_temp.outline_width
    tw = w
    r = (-n..n)
    for i in r
      for j in r
        if $NEKO_RUBY
          draw_text_for_neko(4 + pos[:x] + i, pos[:y] + j, tw, pos[:height], c)
        else 
          self.contents.draw_text(4 + pos[:x] + i, pos[:y] + j, tw, pos[:height], c)        
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 텍스트 묘화(네코 플레이어 용)
  #--------------------------------------------------------------------------    
  def draw_text_for_neko(x, y, width=0, height=nil, str=nil, align=0 )
    
    return if self.contents.entity.nil?
    
    if x.is_a? Rect
      rect  = x
      str   = y
      align = width

      x      = rect.x
      y      = rect.y
      width  = rect.width
      height = rect.height
      
    end    
    
    font = self.contents.font
    font_entity = self.contents.font.entity
        
    str = str.to_s
    if align == 2
      x += width - font_entity.textSize(str)[0]
    elsif align == 1
      x += (width - font_entity.textSize(str)[0]) / 2
    end

    y += (height - font_entity.textSize(str)[1]) / 2 if height
        
    tmp = font_entity.renderSolidUTF8(str, font.color.red, font.color.green, font.color.blue)
    tmp.setAlpha font.color.alpha
    tmp.setBlendMode  SDL::BLENDMODE_NONE
    
    self.contents.entity.put tmp, x, y
    
  end
  #--------------------------------------------------------------------------
  # * 일반 텍스트 묘화
  #--------------------------------------------------------------------------    
  def draw_normal_character(c, pos, half = false)
    w = self.contents.text_size(c).width
    
    temp_color = self.contents.font.color.dup
    
    tw = half ? w : (w * 2)
            
    # 배경색
    draw_highlight_color(c, pos, w)
    
    # 그림자
    draw_shadow(c, pos, tw)
    
    # 테두리
    draw_outline(c, pos, tw)          
    
    # 텍스트
    self.contents.font.color = temp_color
    if $NEKO_RUBY
      draw_text_for_neko(4 + pos[:x], pos[:y], tw, pos[:height], c)
    else
      self.contents.draw_text(4 + pos[:x], pos[:y], tw, pos[:height], c)
    end
    
    pos[:x] += w     
    
  end
  #--------------------------------------------------------------------------
  # * Normal Character Processing
  #--------------------------------------------------------------------------  
  def process_normal_character(c, pos, text)
    
    # 자동 개행 여부
    if $game_temp.word_wrap_enabled
      tw = self.contents.text_size(c).width
      if pos[:x] + (tw * 2) > contents_width
        process_new_line(text, pos)
      end
    end
    
    draw_normal_character(c, pos)
            
    unless @show_fast || @line_show_fast
      wait($game_temp.message_speed) 
      request_text_sound if (Graphics.frame_count % RS::LIST["텍스트 사운드 주기"]) == 0
    end
    
  end
  #--------------------------------------------------------------------------
  # * [오리지날] Dispose
  #--------------------------------------------------------------------------
  def dispose
    terminate_message
    $game_temp.message_window_showing = false
    if @input_number_window != nil
      @input_number_window.dispose
    end
    dispose_name_window
    dispose_gold_window
    super
  end
  #--------------------------------------------------------------------------
  # * [오리지날] Terminate Message
  #--------------------------------------------------------------------------
  def terminate_message
        
    close_name_window
    @gold_window.close
    
    $game_temp.message_clear
    
    self.active = false
    self.pause = false
    self.index = -1
    self.contents.clear
    
    # Clear showing flag
    @contents_showing = false
    
    # Call message callback
    if $game_temp.message_proc != nil
      $game_temp.message_proc.call
    end
    
    # Clear variables related to text, choices, and number input
    $game_temp.message_text = nil
    $game_temp.message_proc = nil
    $game_temp.choice_start = 99
    $game_temp.choice_max = 0
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_proc = nil
    $game_temp.num_input_start = 99
    $game_temp.num_input_variable_id = 0
    $game_temp.num_input_digits_max = 0
    
  end
  #--------------------------------------------------------------------------
  # * do_ruby_text_align
  #--------------------------------------------------------------------------
  def do_ruby_text_align(text)
    return text if @is_used_text_width_ex
    text.split(/[\r\n]+/i).each do |i|
      i.gsub!(/(?:<LEFT>)/i) { "\eTA[0]" }
      i.gsub!(/(?:<CENTER>)/i) { "\eTA[1]" }
      i.gsub!(/(?:<RIGHT>)/i) { "\eTA[2]" }      
      i.gsub!(/\eTA\[(\d+)\]/i) { 
        $game_temp.align = $1.to_i || 0
        ""
      }       
    end
    text.gsub!(/(?:<LEFT>)/i) { "" }
    text.gsub!(/(?:<CENTER>)/i) { "" }
    text.gsub!(/(?:<RIGHT>)/i) { "" }         
    text.gsub!(/\eTA\[(\d+)\]/i) { "" }
    text
  end
  #--------------------------------------------------------------------------
  # * 메시지 시작
  #--------------------------------------------------------------------------  
  def start_message
    return if $game_temp.message_text == nil
        
    @text = $game_temp.message_text
    @text.gsub!(/[\r\n]+/i, "") if $game_temp.word_wrap_enabled    
    @item_max = $game_temp.choice_max
    set_font(RS::LIST["폰트명"],RS::LIST["폰트크기"])
    get_balloon_text_rect(@text.clone)
    @text = convert_escape_characters(@text)  
    
    @text = do_ruby_text_align(@text)
    
    @text_state = {}
    @text_state[:x] = 0
    @text_state[:y] = 0
    @text_state[:text] = @text
    
    reset_window
    set_height(RS::LIST["라인"])        
    resize_message_system
    create_contents   
    set_font(RS::LIST["폰트명"],RS::LIST["폰트크기"])
    new_page(@text_state)
    process_align(@text_state, @text)        

    open    
    self.visible = true
  end
  #--------------------------------------------------------------------------
  # * 새로운 페이지 표시
  #--------------------------------------------------------------------------  
  def new_page(text_state)
        
    self.contents.clear
    reset_font_settings
    clear_flags
    
    @cursor_width = 0
    
    # 선택지가 있을 때 들여쓰기
    if $game_temp.choice_start == 0
      text_state[:x] = 8
    else
      text_state[:x] = 0
    end
    
    text_state[:y] = 0
    text_state[:left] = 0
    text_state[:height] = calc_line_height(text_state[:text])
    
  end
  #--------------------------------------------------------------------------
  # * 빠른 메시지 표시
  #--------------------------------------------------------------------------  
  def update_show_fast
    @show_fast = true if Input.trigger?(Input::C)
  end
  #--------------------------------------------------------------------------
  # * 메시지 업데이트
  #--------------------------------------------------------------------------
  def update_message
    
    if @text_state
        
      until @text.empty?  
        
        # 새로운 페이지가 필요한가?
        if needs_new_page(@text_state)
          new_page(@text_state)
        end
        
        # 빠른 표시 여부 판단
        update_show_fast
        
        # 문자를 하나 묘화한다.
        
        process_character(@text.slice!(/./m), @text, @text_state) 
        
        # 빠르게 표시해야 한다면 반복문을 탈출하지 못하므로 문자가 끝까지 묘화된다.
        break unless @show_fast or @line_show_fast
        
        # 다른 창이 활성화 되어있거나 대기가 걸려있다면 대기 처리를 위해 루프를 탈출한다.
        break if self.pause or @wait_count > 0
        
      end
      
      if @text == nil or @text.empty?
        finish_message
      end
    
    end
    
  end  
  #--------------------------------------------------------------------------
  # * 위치 재설정
  #--------------------------------------------------------------------------
  def reset_window
    
    # 위치 설정
    @position = $game_system.message_position
    @background = $game_system.message_frame
    
    # 노말 윈도우 인가?
    is_normal_window = (@background == 0)
    
    x = (Graphics.width / 2) - (window_width / 2) + RS::LIST["오프셋X"]
    y = @position * (Graphics.height - window_height) / 2 + RS::LIST["오프셋Y"]
    
    self.x = x
    self.y = $game_temp.in_battle ? 16 : y
    self.width = window_width
    self.height = fitting_height($game_temp.line || RS::LIST["라인"])
    
    self.opacity = is_normal_window ? RS::LIST["투명도"] : 0
    self.back_opacity = RS::LIST["배경투명도"]
    
    # 골드 윈도우 위치 업데이트
    @gold_window.y = (@position == 0) ? (Graphics.height - @gold_window.height) : 0
    
    # 이름 윈도우 위치 업데이트
    @name_window.update_position
    
  end
  #--------------------------------------------------------------------------
  # * 메시지를 계속 띄울 수 있는가?
  #--------------------------------------------------------------------------
  def continue?
    # 숫자 입력 모드이므로, 메시지 창을 띄워야 한다.
    return true if $game_temp.num_input_variable_id > 0
    # 텍스트가 비어있다면, close 메서드를 호출하여 창 닫기 처리를 한다.
    return false if $game_temp.message_text.nil?
    if open? and not $game_temp.in_battle
      return false if @background != $game_system.message_frame
      return false if @position != $game_system.message_position
    end
    return true
  end  
  #--------------------------------------------------------------------------
  # * 새로운 페이지가 필요한가?
  #--------------------------------------------------------------------------  
  def needs_new_page(pos)
    (pos[:y] + pos[:height]) > self.contents.height
  end
  #--------------------------------------------------------------------------
  # * 퍼지 / 다음 대화 표시
  #--------------------------------------------------------------------------
  def input_pause
    return if @is_used_text_width_ex

    if Input.trigger?(Input::C) or Input.trigger?(Input::B)
      Input.update
      self.pause = false
      terminate_message unless @text_state
    end
  end
  #--------------------------------------------------------------------------
  # * 특정 선택지 선택 및 취소
  #--------------------------------------------------------------------------      
  def input_choice
    if Input.trigger?(Input::B)
      if $game_temp.choice_cancel_type > 0
        $game_system.se_play($data_system.cancel_se)
        $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
        terminate_message
      end    
    elsif Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      $game_temp.choice_proc.call(self.index)
      terminate_message
    end        
  end
  #--------------------------------------------------------------------------
  # * 숫자 입력
  #--------------------------------------------------------------------------    
  def input_number
    if @input_number_window != nil
      @input_number_window.update
      # Confirm
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] =
          @input_number_window.number
        $game_map.need_refresh = true
        # Dispose of number input window
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end    
    end
  end  
  #--------------------------------------------------------------------------
  # * 프레임 업데이트
  #--------------------------------------------------------------------------    
  def update
    super
    
    update_name_window
    update_gold_window

    update_balloon_position if $game_temp.balloon != -2 and $game_map.msg_owner
    
    # 루비 계열에선 VXA가 가장 최상위 스타일이지만, 호환이 맞는 VX 스타일로 개편.
    unless @opening or @closing
      if @wait_count > 0 # 대기 카운트가 있는가?
        @wait_count -= 1            
      elsif self.pause
        input_pause                  
      elsif self.active  # 선택지가 활성화되었는가?
        input_choice
      elsif @input_number_window != nil # 숫자 입력칸이 활성화되었는가?
        input_number     
      elsif @text != nil # 텍스트가 있는가?
        update_message
      elsif continue? 
        # 텍스트 또는 숫자 입력이 있으면 
        start_message
        open
        $game_temp.message_window_showing = true
      else 
        # 그게 아니라면 창을 닫는다.
        close
        $game_temp.message_window_showing = @closing
      end
        
    end
  end
  #--------------------------------------------------------------------------
  # * 선택지 또는 숫자 입력 받기
  #--------------------------------------------------------------------------    
  def start_input
    if $game_temp.choice_max > 0
      self.active = true
      self.index = 0      
      return true 
    elsif $game_temp.num_input_variable_id > 0    
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8
      @input_number_window.y = self.y + $game_temp.num_input_start * 32          
      return true 
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # * 퍼지 시작
  #--------------------------------------------------------------------------    
  def start_pause
    return if @is_used_text_width_ex
    @wait_count = 10    
    self.pause = true        
  end
  #--------------------------------------------------------------------------
  # * 메시지 끝내기
  #--------------------------------------------------------------------------  
  def finish_message
    
    unless start_input
      unless @pause_skip
        start_pause
      else
        terminate_message
      end
    end
    
    @text = nil
    @text_state = nil
    
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    
    if @index >= 0
      n = $game_temp.choice_start + @index
      x_offset = 8
      y_offset = 32
      h = 32
      
      #~ if @text_state
        #~ ny = @text_state[:y]
        #~ max = $game_temp.choice_max * h
      #~ end
      
      self.cursor_rect.set(x_offset, n * y_offset, @cursor_width, h)
    else
      self.cursor_rect.empty
    end
  end    
end

#==============================================================================
# ** Interpreter
#------------------------------------------------------------------------------
# 말풍선 시스템과 관련되어있습니다.
#==============================================================================
class Interpreter
  def is_valid_multi_line?(line_count)
    codes = []
    prev_code = 401
    for i in (1..7)
      event_command = @list[@index+i]
      if event_command
        codes.push(event_command.code) 
        prev_code = event_command.code
        line_count += 1 if [101, 401].include? event_command.code
      end
    end
    # 중간에 선택지가 있으면 멀티 라인이 아님.
    return false if codes.include?(102)
    # 숫자 입력 모드가 있으면 멀티 라인이 아님.
    return false if codes.include?(103)
    # 표시할 라인이 4이하면 멀티 라인이 아님.
    return false if $game_temp.line <= 4
    # 실제 라인이 4보다 작으면 멀티 라인이 아니다.
    return false if line_count <= 4
    return true
  end
  #--------------------------------------------------------------------------
  # * Show Text
  #--------------------------------------------------------------------------
  def command_101
    # If other text has been set to message_text
    if $game_temp.message_text != nil
      # End
      return false
    end
    
    $game_map.msg_event = get_character(@event_id > 0? 0 : -1)
    
    # Set message end waiting flag and callback
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # Set message text on first line
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    
    
    if is_valid_multi_line?(line_count)
      until $game_temp.message_size >= $game_temp.line
        # 101, 401, 401, 401, 101, 401, 401, 401
        while [101, 401].include?(@list[@index+1].code)
          @index += 1
          $game_temp.add_text(@list[@index].parameters[0])
          line_count += 1
          break if line_count >= $game_temp.line
        end
        break if not @list[@index+1]
        break if not [101, 401].include? @list[@index+1].code
      end
    else
      # 루프
      loop do
        if @list[@index+1].code == 401
          $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
          line_count += 1
        else
          # 선택지
          if @list[@index+1].code == 102
            # 각 문자["예, 아니오"]가 메시지 창에 직적접으로 추가된다. (라인 하나씩을 차지한다)
            if @list[@index+1].parameters[0].size <= 4 - line_count
              # Advance index
              @index += 1
              # Choices setup
              $game_temp.choice_start = line_count
              setup_choices(@list[@index].parameters)
            end                    
          # 숫자 입력 모드 (라인 하나를 차지한다)
          elsif @list[@index+1].code == 103
            # If number input window fits on screen
            if line_count < 4
              # Advance index
              @index += 1
              # Number input setup
              $game_temp.num_input_start = line_count
              $game_temp.num_input_variable_id = @list[@index].parameters[0]
              $game_temp.num_input_digits_max = @list[@index].parameters[1]
            end
          end
          # Continue
          return true
        end
        # Advance index
        @index += 1
      end      
    end
  
  end
end

#==============================================================================
# ** Spriteset_Map
#==============================================================================
class Spriteset_Map
  def character(event_id)
    sprite = nil
    
    if event_id == -1
      sprite = @character_sprites.find do |i|
        i.class == Game_Player
      end
    else
      sprite = @character_sprites.find do |i|
        c = i.character
        if c and c.is_a?(Game_Event)
          c.id == event_id 
        end
      end
    end
    
    return 32, 32 if not sprite
    tile_id = sprite.instance_variable_get("@tile_id")
    
    if tile_id >= 384
      cw = sprite.bitmap.width
      ch = sprite.bitmap.height
    else
      cw = sprite.instance_variable_get("@cw")
      ch = sprite.instance_variable_get("@ch")
    end
    
    return cw, ch
    
  end
end
class Scene_Map
  attr_reader :spriteset
end

#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
# 말풍선 시스템과 관련되어있습니다.
#==============================================================================
class Window_Message
  include RS::BALLOON
  #--------------------------------------------------------------------------
  # * 새로운 페이지 설정
  #--------------------------------------------------------------------------
  alias balloon_new_page new_page
  def new_page(pos)
    open_balloon
    balloon_new_page(pos)
    wait(1)
  end
  #--------------------------------------------------------------------------
  # * 말풍선 설정
  #--------------------------------------------------------------------------
  def open_balloon(sign=$game_temp.balloon)
    # 말풍선 모드가 아니라면 메시지 재설정 후 반환된다.
    if sign == -2
      resize_message_system
      return nil
    end
    setup_owner(sign.to_i)
    update_balloon_position
    $game_temp.word_wrap_enabled = false
  end  
  #--------------------------------------------------------------------------
  # * 말풍선 높이
  #--------------------------------------------------------------------------  
  def calc_balloon_rect_height(text)
    temp_font_size = self.contents.font.size
    text2 = convert_escape_characters(text)
    height = calc_line_height(text2)
    self.contents.font.size = temp_font_size
    return height
  end  
  #--------------------------------------------------------------------------
  # *  라인 시작 위치
  #--------------------------------------------------------------------------    
  def new_line_x
    0
  end
  #--------------------------------------------------------------------------
  # * 말풍선 영역 계산
  #--------------------------------------------------------------------------
  def get_balloon_text_rect(text)    
    
    save
    
    # 라인 갯수를 구하기 위해 텍스트를 줄바꿈 문자를 기준으로 나눈다.
    tmp_text = text_processing(text)
    tmp_text = tmp_text.split(/[\r\n]+/m)
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
    
    # 폭을 계산한다.
    pw = 0
    for i in (0...num_of_lines)
      @is_used_text_width_ex = true
      x = text_width_ex(tmp_text[i])
      @is_used_text_width_ex = false
      if x >= pw
        pw = x
      end
    end
    
    @_width = pw + pad + 6
    @_height = height
    
    # 선택지가 있으면...
    if $game_temp.choice_max > 0
      @_width += new_line_x
      @_height = [@_height, fitting_height(4)].max
    end
    
    restore
    
  end  
  #--------------------------------------------------------------------------
  # * 텍스트 매칭 (모든 명령어 제거)
  #--------------------------------------------------------------------------
  def text_processing(text)
    f = text.clone
    f.gsub!("\\") { "\e" }
    f.gsub!("\e\e") { "\\" }
    f.gsub!(/\e[\$\.\|\!\>\<\^]/) { "" }
    f.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }
    f.gsub!(/(?:\eV|\e변수)\[(\d+)\]/i) { $game_variables[$1.to_i] }    
    f.gsub!(/(?:\eN|\e주인공)\[(\d+)\]/i) { actor_name($1.to_i) }
    f.gsub!(/(?:\eP|\e파티원)\[(\d+)\]/i) { party_member_name($1.to_i) }
    f.gsub!(/(?:\eG|\e골드)/i) { $data_system.words.gold }
    f.gsub!(/(?:\eC)\[(\d+)\]/i) { "" }
    f.gsub!(/\e색\[(.+?)\]/) { "" }
    f.gsub!(/\e테두리색!\[(.+)\]/) { "" }
    f.gsub!(/\e#([a-zA-Z\d]+)!/) { "" }
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
    return reset_window if $game_temp.balloon == -2

    # 말풍선 소유자의 화면 좌표
    mx = $game_map.msg_owner.screen_x rescue 0
    my = $game_map.msg_owner.screen_y rescue 0
    tx = @_width / 2
    ty = @_height
    scale_y = 1
    tile_height = 32
    
    class_type = $game_map.msg_owner.class
    
    if $scene.is_a?(Scene_Map) and [Game_Event, Game_Player].include?(class_type)
      event_id = class_type == Game_Event ? $game_map.msg_owner.id : -1
      pt = $scene.spriteset.character(event_id)
      tile_height = pt[1]
    end
    
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
    self.x = dx + RS::LIST["오프셋X"]
    self.y = dy + RS::LIST["오프셋Y"]
    self.width = @_width
    self.height = @_height
    
    # 대화창이 동작하고 있어도 캐릭터가 움직이므로 메시지 창도 같이 따라가야 한다.
    if self.contents.width != (@_width - 32) or self.contents.height != (@_height - 32)
      self.contents = Bitmap.new(@_width - 32 , @_height - 32)
      @cursor_width = @_width - 32
      update_cursor_rect
    end

    # 이름 윈도우 좌표 수정
    @name_window.y = ny

    # 투명도 설정
    self.opacity = RS::LIST["투명도"]
    
    @balloon_pause = false
    
    @background = $game_system.message_frame
    self.opacity = @background == 0 ? RS::LIST["투명도"] : 0
    self.back_opacity = RS::LIST["배경투명도"]
    
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
  # * Move
  #--------------------------------------------------------------------------  
  def move(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  end
  #--------------------------------------------------------------------------
  # * 크기 재설정
  #--------------------------------------------------------------------------
  def resize_message_system

    # 대화창의 소유자 설정
    $game_map.msg_owner = $game_player

    @balloon_pause = true

    # 대화창의 위치
    @position = $game_system.message_position

    # 대화창의 X좌표
    x = (Graphics.width / 2) - (window_width / 2) + RS::LIST["오프셋X"]
    
    # 대화창의 Y좌표
    y = @position * (Graphics.height - window_height) / 2 + RS::LIST["오프셋Y"]
    
    # 폭
    width = window_width
    
    # 높이
    height = fitting_height($game_temp.line || RS::LIST["라인"])

    # 위치 및 크기 설정
    self.move(x, y, width, height)    
    self.contents = Bitmap.new(width - 32 , height - 32)
    @cursor_width = width - 32
    update_cursor_rect
 
  end
end