#==============================================================================
#  ** 한글 메시지 시스템 애드온 - Bust
#==============================================================================
#  ** 사용법
#==============================================================================
# Graphics/Faces 폴더에 얼굴 이미지를 위치시키십시오.
# 얼굴 이미지는 다음 명령으로 표시할 수 있으며 총 4개까지 표시할 수 있습니다.
# ID 값은 0과 2는 왼쪽에 표시되고, 홀수 번 1과 3은 오른쪽에 표시됩니다.
# 
# \얼굴<ID, 이미지명>
# \얼위<ID, X, Y>
#
# 이미지 애니메이션 기능으로 이미지가 화면 바깥에서 날아오게 합니다.
#
# \트윈<ID>
#
# 얼굴 이미지의 톤을 변경할 수 있는 기능입니다.
#
# \얼톤<ID, red, green, blue, gray>
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_BustFaces"] = true

module RS
  LIST["얼굴"] = {
    0 => {
      :name => "Actor1-1",
      :sx => 0,
      :sy => 0,
      :tx => Graphics.width / 2,
      :ty => Graphics.height / 2
    },
    1 => {
      :name => "Actor1-2",
      :sx => Graphics.width,
      :sy => Graphics.height,
      :tx => Graphics.width / 2,
      :ty => Graphics.height / 2
    },   
  }
end

module RS::BustFace
  class Data
    attr_accessor :name, :sx, :sy, :tx, :ty
    def initialize(name="", sx=0, sy=0, tx=0, ty=0)
      @name = name
      @sx = sx
      @sy = sy
      @tx = tx
      @ty = ty
      @method = :LEFT
    end
    def tween
      case @method
      when :LEFT
        left_to_right
      when :RIGHT
        right_to_left
      end
    end
    def left_to_right
    end
    def right_to_left
    end
  end
end

#==============================================================================
# ** BaseEase
#------------------------------------------------------------------------------
# Robert Penner (http://www.robertpenner.com/easing/)
#==============================================================================
module BaseEase

  PI_2 = Math::PI * 2
  KEY_FRAME = 24
 
  def quadratic_ease_out(t)
    return -(t * (t - 2))
  end   
  def quadratic_ease_in_out(t)
    if t < 0.5
      return 2 * t * t
    else
      return (-2 * t * t) + (4 * t) - 1
    end
  end  
  def sine_ease_out(t)
    Math.sin(t * PI_2)
  end
  def elastic_ease_in(t)
    Math.sin(13 * PI_2 * t) * (2 ** (10 * (t - 1)))
  end
  def back_ease_in(t)
    t * t * t - t * Math.sin(t * Math::PI)
  end
end

#==============================================================================
# ** Bust
#==============================================================================
class Bust < Sprite
  include BaseEase

  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------   
  def initialize(viewport=nil)
    super(viewport)
    @tween_start = false
    @dirty = false
  end
  #--------------------------------------------------------------------------
  # * 더티 플래그; 반대편으로 날아들게 합니다
  #--------------------------------------------------------------------------   
  def dirty
    @dirty = true
  end
  #--------------------------------------------------------------------------
  # * 초기 위치로 리셋합니다
  #--------------------------------------------------------------------------   
  def reset
    if @dirty 
      self.x = Graphics.width / 2
    else
      self.x = 0
    end
  end
  #--------------------------------------------------------------------------
  # * 트위닝 시작
  #--------------------------------------------------------------------------   
  def start_tween(start_x = nil, target_x = nil)
    @id = 0
    @data = RS::LIST["얼굴"][@id]    
    @tween_start = true
    if @dirty
      @start_x = self.x
      @target_x = self.x + @data[:tx]
    else
      @start_x = self.x - @data[:sx]
      @target_x = self.x
    end
    self.x = @start_x   

    @t = 0.0
    @dt = 1.0 / KEY_FRAME
    @frame = 0 

  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------   
  def update
    super
    update_tick if @tween_start   
  end
  #--------------------------------------------------------------------------
  # * 틱 업데이트
  #--------------------------------------------------------------------------   
  def update_tick

    @t += @dt
    
    if @t < 1.0
      self.x = (1 - @t) * @start_x + (@target_x * @t)
    end

    @frame += 1

    if @frame > KEY_FRAME
      self.x = @target_x
      @tween_start = false
    end

  end
end

#==============================================================================
# ** BustManager
#==============================================================================
class BustCommander
  #--------------------------------------------------------------------------
  # * 생성자
  #--------------------------------------------------------------------------   
  def initialize(max)
    @max = max
    @default_z = 300
    @face_sprites = []
    create
    hide      
  end
  #--------------------------------------------------------------------------
  # * 생성
  #--------------------------------------------------------------------------   
  def create
    for i in (0...@max)
      @face_sprites[i] = Bust.new
      # 홀수인가?
      if (i % 2) != 0
        @face_sprites[i].dirty
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------   
  def update
    @face_sprites.each {|i| i.update if i }
  end  
  #--------------------------------------------------------------------------
  # * 표시
  #--------------------------------------------------------------------------   
  def show
    @face_sprites.each do |e| 
      e.reset
      e.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # * 트위닝 시작
  #--------------------------------------------------------------------------   
  def tween(id)
    return if not (0...@max).include?(id)
    return if !@face_sprites[id]    
    @face_sprites[id].start_tween
  end
  #--------------------------------------------------------------------------
  # * 톤 조절
  #--------------------------------------------------------------------------   
  def set_tone(id, red, green, blue, gray)
    return if not (0...@max).include?(id)
    return if !@face_sprites[id]    
    @face_sprites[id].tone = Tone.new(red, green, blue, gray)
  end  
  #--------------------------------------------------------------------------
  # * 감추기
  #--------------------------------------------------------------------------   
  def hide
    @face_sprites.each do |i| 
      i.visible = false
      i.reset
    end
  end
  #--------------------------------------------------------------------------
  # * 메모리 해제
  #--------------------------------------------------------------------------   
  def dispose
    @face_sprites.each do |i| 
      i.bitmap.dispose if i.bitmap
      i.dispose
    end
  end
  #--------------------------------------------------------------------------
  # * 비트맵 로드 및 z 좌표 설정
  #--------------------------------------------------------------------------   
  def load(id, bitmap, x=0, y=0)
    return if not (0...@max).include?(id)
    return if !@face_sprites[id]
    @face_sprites[id].bitmap = bitmap
    @face_sprites[id].z = @default_z + 3 * id
  end
  #--------------------------------------------------------------------------
  # * 위치 설정
  #--------------------------------------------------------------------------   
  def set_position(id, x, y)
    return if not (0...@max).include?(id)
    return if !@face_sprites[id]    
    @face_sprites[id].x = x
    @face_sprites[id].y = y
  end    
      
end  

class BustManager
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------   
  def initialize(max)
    @max = max
    @commander = BustCommander.new(@max)
    @commands = []
  end
  #--------------------------------------------------------------------------
  # * 생성
  #--------------------------------------------------------------------------   
  def create
    @commands.push([:create, []])
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------   
  def update
    @commander.update
  end 
  #--------------------------------------------------------------------------
  # * 표시
  #--------------------------------------------------------------------------   
  def show
    @commander.show
  end
  #--------------------------------------------------------------------------
  # * 트위닝 시작
  #--------------------------------------------------------------------------   
  def tween(id)
    @commands.push([:tween, [id]])
  end
  #--------------------------------------------------------------------------
  # * 톤 조절
  #--------------------------------------------------------------------------   
  def set_tone(id, red, green, blue, gray)
    @commands.push([:set_tone, [id, red, green, blue, gray]])
  end  
  #--------------------------------------------------------------------------
  # * 감추기
  #--------------------------------------------------------------------------   
  def hide
    @commander.hide
  end
  #--------------------------------------------------------------------------
  # * 메모리 해제
  #--------------------------------------------------------------------------   
  def dispose
    @commands.dispose
  end
  #--------------------------------------------------------------------------
  # * 비트맵 로드 및 z 좌표 설정
  #--------------------------------------------------------------------------   
  def load(id, bitmap, x=0, y=0)
    @commands.push([:load, [id, bitmap, x, y]])
  end
  #--------------------------------------------------------------------------
  # * 위치 설정
  #--------------------------------------------------------------------------   
  def set_position(id, x, y)
    @commands.push([:set_position, [id, x, y]])
  end
  #--------------------------------------------------------------------------
  # * 리셋
  #--------------------------------------------------------------------------    
  def reset
    @commander.reset
  end
  #--------------------------------------------------------------------------
  # * 위치 설정
  #--------------------------------------------------------------------------  
  def flush
    return if @commands.size == 0
    @commands.each do |i|
      method_symbol = i[0]
      args = i[1]
      if @commander.respond_to? method_symbol
        @commander.send(method_symbol, *args)
      end
    end
    @commands.clear
  end
  
end

class Window_Message < Window_Selectable  
  #--------------------------------------------------------------------------
  # * 초기화
  #--------------------------------------------------------------------------   
  alias rs_message_bust_initialize initialize
  def initialize
    rs_message_bust_initialize
    @bust_manager = BustManager.new(4)
  end
  #--------------------------------------------------------------------------
  # * 문자열 추출
  #--------------------------------------------------------------------------       
  def obtain_string(text)
    
    flag = false
    len = 0
    index = 0
  
    text.split("").each_with_index do |e, i| 
      if e == "<"
        flag = true
        index = i
        next
      end
      if i > 0 && !flag
        throw "\얼굴 명령어에 < 문자가 없습니다."
        break
      end
      if flag
        len += 1
        if e == ">"
          break
        end
      end
    end
    
    ret = ""
    
    if flag
      ret = text.dup.slice!(index + 1, len - 1)
      text.slice!(index, len + 1)
    end
    
    ret

  end      
  #--------------------------------------------------------------------------
  # * 텍스트 코드 처리
  #--------------------------------------------------------------------------   
  alias rs_message_bust_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    rs_message_bust_process_escape_character(code, text, pos)
    case code.upcase
    when '얼굴', 'F'
      set_face_image(text)
    when '얼위', 'FP'
      set_face_position(text)
    when '트윈', 'FT'
      set_face_tween(text)
    when '얼톤', 'FN'
      set_face_tone(text)
    end
  end
  #--------------------------------------------------------------------------
  # * Set Face Image
  #--------------------------------------------------------------------------   
  def set_face_image(text)
    bytes = obtain_string(text).split(",")
    return if @is_used_text_width_ex      
    id = bytes[0].strip.to_i
    name = bytes[1].strip
    x, y = 0, 0
    if bytes.size == 4
      x = bytes[2].strip.to_i
      y = bytes[3].strip.to_i
    end
    bitmap = RPG::Cache.face(name)
    @bust_manager.load(id, bitmap, x, y)    
  end
  #--------------------------------------------------------------------------
  # * Set Face Position
  #--------------------------------------------------------------------------  
  def set_face_position(text)  
    bytes = obtain_string(text).split(",")
    return if @is_used_text_width_ex      
    id = bytes[0].slice!(/[0-9]/).to_i
    x = bytes[1].strip.to_i
    y = bytes[2].strip.to_i
    @bust_manager.set_position(id, x, y)    
  end
  #--------------------------------------------------------------------------
  # * Set Face Tween
  #--------------------------------------------------------------------------  
  def set_face_tween(text)  
    bytes = obtain_string(text).split(",")
    return if @is_used_text_width_ex      
    id = bytes[0].slice!(/[0-9]/).to_i
    @bust_manager.tween(id)    
  end  
  #--------------------------------------------------------------------------
  # * Set Face Tone
  #--------------------------------------------------------------------------  
  def set_face_tone(text)  
    bytes = obtain_string(text).split(",")
    return if @is_used_text_width_ex      
    id = bytes[0].slice!(/[0-9]/).to_i
    red = bytes[1].strip.to_i
    green = bytes[2].strip.to_i
    blue = bytes[3].strip.to_i
    gray = bytes[4].strip.to_i
    @bust_manager.set_tone(id, red, green, blue, gray)
  end      
  #--------------------------------------------------------------------------
  # * 메모리 해제
  #--------------------------------------------------------------------------     
  alias rs_message_bust_dispose dispose
  def dispose
    @bust_manager.dispose if @bust_manager    
    rs_message_bust_dispose
  end
  #--------------------------------------------------------------------------
  # * 메시지 종료
  #--------------------------------------------------------------------------     
  alias rs_message_bust_terminate_message terminate_message
  def terminate_message
    rs_message_bust_terminate_message
    @bust_manager.hide    
  end
  #--------------------------------------------------------------------------
  # * 메시지 시작
  #--------------------------------------------------------------------------    
  alias rs_message_bust_start_message start_message
  def start_message
    rs_message_bust_start_message
    @bust_manager.show
    @bust_manager.flush    
  end
  #--------------------------------------------------------------------------
  # * 퍼지 / 다음 대화 표시
  #--------------------------------------------------------------------------  
  alias rs_message_bust_input_pause input_pause
  def input_pause
    return if @is_used_text_width_ex
    @bust_manager.flush  
    rs_message_bust_input_pause
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------    
  alias rs_message_bust_update update
  def update
    rs_message_bust_update
    @bust_manager.update if @bust_manager    
  end
end
