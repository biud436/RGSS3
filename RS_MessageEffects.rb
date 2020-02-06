#==============================================================================
# ** Hangul Message Effects (RPG Maker VX Ace)
#==============================================================================
# Name       : Hangul Message Effects
# Author     : 러닝은빛(biud436)
#==============================================================================
# ** 텍스트 코드
#==============================================================================
# \텍스트효과<텍스트효과명> 또는 \TE<텍스트효과명>
#
# 현재까지 추가된 텍스트 효과 :
#   PingPong
#   Slide
#   HighRotation
#   NormalRotation
#   RandomRotation
#   Shock
#   ZoomOut
#   Marquee
#   Wave
#   Spread
#
# RS_Input 필요 :
#   MouseTracking
#
#==============================================================================
# ** 업데이트 로그
#==============================================================================
# Version    :
# 2020.02.05 (v1.0.0) - First Release
# 2020.02.06 (v1.0.1) :
# - 타입이 없을 때 오류 메시지 추가
# - MouseTracking 효과 추가 
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_MessageEffects"] = true

if !$imported["RS_HangulMessageSystem"]
  raise %Q(텍스트 효과 스크립트는 한글 메시지 시스템 스크립트가 필요합니다.)
end

module RS
  LIST["텍스트 이펙트"] = :Shock
  CODE["텍스트 이펙트"] = /^\<([a-zA-Z]+)\>/
end

module RS::Messages
  Effects = {}
end

#==============================================================================
# ** TextEffect
#============================================================================== 
class TextEffect < Sprite
  
  PI_2 = Math::PI * 2
  DEG_TO_RAD = Math::PI / 180.0
  RAD_TO_DEG = 180.0 / Math::PI
  
  #--------------------------------------------------------------------------
  # * 생성자
  #--------------------------------------------------------------------------  
  def initialize(viewport)
    super(viewport)
    @started = false
    init_members
  end  
  #--------------------------------------------------------------------------
  # * 멤버 초기화
  #--------------------------------------------------------------------------   
  def init_members
    @started = false
    @power = 0
  end
  #--------------------------------------------------------------------------
  # * 업데이트
  #--------------------------------------------------------------------------     
  def update
    super
    update_effects
  end
  #--------------------------------------------------------------------------
  # * 이펙트 업데이트
  #--------------------------------------------------------------------------   
  def update_effects
  end
  #--------------------------------------------------------------------------
  # * 종료
  #--------------------------------------------------------------------------   
  def flush
    self.x = @origin[:x]
    self.y = @origin[:y]    
    self.angle = @origin[:angle]
    self.ox = @origin[:ox]
    self.oy = @origin[:oy]
    self.zoom_x = @origin[:zoom_x]
    self.zoom_y = @origin[:zoom_y]
    self.wave_amp = @origin[:wave_amp]
    self.wave_length = @origin[:wave_length]
    self.wave_speed = @origin[:wave_speed]
    self.wave_phase = @origin[:wave_phase]
    self.opacity = @origin[:opacity]
    self.color = @origin[:color]
    self.tone = @origin[:tone]
    
    # clear
    @origin = {}
    
    @started = false
    
  end
  #--------------------------------------------------------------------------
  # * 시작
  #--------------------------------------------------------------------------   
  def start(index)
    @power = 1
    @index = index
    @started = true
    @random = (rand * 60).floor
    @origin = {
      :x => self.x,
      :y => self.y,
      :angle => self.angle,
      :ox => self.ox,
      :oy => self.oy,
      :zoom_x => self.zoom_x,
      :zoom_y => self.zoom_y,
      :wave_amp => self.wave_amp,
      :wave_length => self.wave_length,
      :wave_speed => self.wave_speed, 
      :wave_phase => self.wave_phase,   
      :opacity => self.opacity,
      :color => self.color,
      :tone => self.tone,
    }    
  end
end

#==============================================================================
# ** PingPong
#============================================================================== 
class PingPong < TextEffect
  def update_effects
    return if !@started
    if @power <= 60
      self.y = @origin[:y] + (PI_2 / @power) * 4.0
      @power += 1
    else
      flush
    end
  end
end

RS::Messages::Effects[:PingPong] = PingPong

#==============================================================================
# ** Slide
#============================================================================== 
class Slide < TextEffect
  def update_effects
    return if !@started
    if @power <= 60
      self.x = @origin[:x] + (PI_2 / @power) * (@origin[:x] % 4) * 4
      self.opacity = 4 * @power
      @power += 1      
    else
      flush      
    end
  end
end

RS::Messages::Effects[:Slide] = Slide

#==============================================================================
# ** HighRotation
#==============================================================================
class HighRotation < TextEffect
  def update_effects
    return if !@started
    if @power <= @random
      dist = @random - @power
      tm = Time.now.to_i
      r = DEG_TO_RAD * dist * (@random % 2 == 0 ? -tm : tm)
      c = Math.cos(r)
      s = Math.sin(r)
      tx = @origin[:x] - dist
      ty = @origin[:y] - dist
      self.x = tx * c - ty * s
      self.y = tx * s + ty * c
      @power += 1 
    else
      flush
    end
  end
end

RS::Messages::Effects[:HighRotation] = HighRotation

#==============================================================================
# ** NormalRotation
#==============================================================================
class NormalRotation < TextEffect
  def update_effects
    return if !@started
    if @power <= @random
      dist = @random - @power
      tm = Time.now.to_i
      r = DEG_TO_RAD * dist * (@origin[:x] % 3 == 0 ? -1 : 1)
      c = Math.cos(r)
      s = Math.sin(r)
      tx = @origin[:x] - dist
      ty = @origin[:y] - dist
      self.x = tx * c - ty * s
      self.y = tx * s + ty * c
      @power += 1 
    else
      flush
    end
  end
end

RS::Messages::Effects[:NormalRotation] = NormalRotation

#==============================================================================
# ** RandomRotation
#==============================================================================
class RandomRotation < TextEffect
  def update_effects
    return if !@started
    if @power <= @random
      dist = @random - @power
      tm = Time.now.to_i
      r = DEG_TO_RAD * dist * (@random % 2 == 0 ? -1 : 1)
      c = Math.cos(r)
      s = Math.sin(r)
      tx = @origin[:x] - dist
      ty = @origin[:y] - dist
      self.x = tx * c - ty * s
      self.y = tx * s + ty * c
      @power += 1 
    else
      flush
    end
  end
end

RS::Messages::Effects[:RandomRotation] = RandomRotation

#==============================================================================
# ** Shock
#==============================================================================
class Shock < TextEffect
  def update_effects
    return if !@started
    if @power <= 360 # 6초 동안 흔들립니다
      self.ox = -3 * rand
      self.oy = -3 * rand
      @power += 1 # 영원히 흔들리게 하고 싶다면 이 라인을 삭제
    else
      flush
    end
  end
end

RS::Messages::Effects[:Shock] = Shock

#==============================================================================
# ** ZoomOut
#==============================================================================
class ZoomOut < TextEffect
  def update_effects
    return if !@started
    self.zoom_x = (200 - @power) / 100.0
    self.zoom_y = (200 - @power) / 100.0
    if self.zoom_x <= 1.0
      flush
    end    
    @power += 10
  end
  def start(index)
    super(index)
    self.zoom_x = 1.5
    self.zoom_y = 1.5
  end
end

RS::Messages::Effects[:ZoomOut] = ZoomOut

#==============================================================================
# ** Marquee
#==============================================================================
class Marquee < TextEffect
  def flush
    super
    @message_window = nil
  end
  def update_effects
    return if !@started
    self.ox -= 4
    if self.ox < 0
      flush
    end
  end
  def start(index, message_window)
    super(index)
    @message_window = message_window
    self.ox += message_window.width
  end
end

RS::Messages::Effects[:Marquee] = Marquee

#==============================================================================
# ** Wave (빠른 흔들기)
#==============================================================================
class Wave < TextEffect
  def update_effects
    return if !@started
    self.wave_speed = 60 * [@origin[:x] % 5, 1].max
    self.wave_phase = RAD_TO_DEG * @power
    if @power >= 60
      flush
    end
    @power += 1
  end
  def start(index)
    super(index)
    self.wave_amp = self.height / 3
  end
end

RS::Messages::Effects[:Wave] = Wave

#==============================================================================
# ** Spread
#==============================================================================
class Spread < TextEffect
  def update_effects
    return if !@started
    return if !(Time.now.to_i - @lazy >= 2)
    case @index
    when 3
      self.x = @origin[:x] - @power
    when 1
      self.x = @origin[:x] + @power
    when 0
      self.y = @origin[:y] - @power
    when 2
      self.y = @origin[:y] + @power
    end
    if @power >= 60 * 10 # 잠시 후 텍스트가 표시됨.
      flush
    end
    @power += 4
  end
  def start(index)
    super(index)
    @lazy = Time.now.to_i
    @index = index % 4
  end
end

RS::Messages::Effects[:Spread] = Spread

if $imported["RS_Input"]

  class MouseTracking < TextEffect
    def distance(x1,y1,x2,y2)
      Math.sqrt(((x2 - x1) ** 2) + ((y2 - y1) ** 2))
    end
    def update_effects
      return if !@started      
            
      move_speed = @dist / 30.0
      
      x_dist = if (@origin[:x] - self.x) < 0
        move_speed
      elsif (@origin[:x] - self.x) > 0
        -move_speed
      else
        0
      end
      
      y_dist = if (@origin[:y] - self.y) < 0
        move_speed
      elsif (@origin[:y] - self.y) > 0
        -move_speed
      else
        0
      end
              
      tx = self.x - x_dist
      ty = self.y - y_dist
      
      self.x = tx
      self.y = ty
      
      dist = distance(@origin[:x], @origin[:y], self.x, self.y).round(1)
      if dist < 16
        flush
      end
      
    end
    def start(index)
      super(index)
      self.x = TouchInput.x
      self.y = TouchInput.y
      @dist = distance(@origin[:x], @origin[:y], self.x, self.y).floor
    end
  end
  
  RS::Messages::Effects[:MouseTracking] = MouseTracking

end

#==============================================================================
# ** 텍스트 이펙트 팩토리 객체
#============================================================================== 
class TextEffectFactory
  def self.create(type, viewport)
    return if !RS::Messages::Effects.has_key?(type)
    effect_class = RS::Messages::Effects[type]
    return effect_class.new(viewport)
  end
end

#==============================================================================
# ** 텍스트 레이어 초기화
#============================================================================== 
class Window_Message < Window_Base
  alias rm_message_text_effects_initialize initialize
  def initialize
    rm_message_text_effects_initialize
    create_text_layers
  end
  
  alias rm_message_text_effects_dispose dispose
  def dispose
    rm_message_text_effects_dispose
    dispose_text_layers
  end
  
  alias rm_message_text_effects_clear_flags clear_flags
  def clear_flags
    rm_message_text_effects_clear_flags
    clear_text_effects
  end
  
  alias rm_message_text_effects_update update
  def update
    rm_message_text_effects_update
    update_text_effects if $game_message.busy?
  end  
end

#==============================================================================
# ** 텍스트 레이어를 기본 프레임워크와 연동
#============================================================================== 
class Window_Message < Window_Base
  def create_text_layers
    @text_layer_viewport = Viewport.new
    @text_layer_viewport.z = SceneManager.scene.instance_variable_get("@viewport").z * 2
    update_text_layer_viewport
    @layers = []
  end
  def dispose_text_layers
    @text_layer_viewport.dispose
    @layers = nil
  end
  def clear_text_effects
    @layers = [] if not @layers
    @layers.each do |s|
      s.visible = false
      s.dispose
    end
    @layers = []
  end
  def update_text_layer_viewport
    pad = standard_padding
    pad2 = standard_padding * 2
    
    @text_layer_viewport.rect.set(
      self.x + pad, 
      self.y + pad, 
      self.width - pad2, 
      self.height - pad2
    )
    @text_layer_viewport.ox = self.x + pad
    @text_layer_viewport.oy = self.y + pad
  end
  def update_text_effects
    @text_layer_viewport.update
    @layers.each do |sprite|
      sprite.update
    end
  end
  alias rs_text_effects_close_and_wait close_and_wait
  def close_and_wait
    rs_text_effects_close_and_wait
    clear_text_effects
  end  
end

#==============================================================================
# ** 텍스트 묘화
#============================================================================== 
class Window_Message < Window_Base
  alias rs_message_effects_new_page new_page
  def new_page(text, pos)
    rs_message_effects_new_page(text, pos)
  end  
  #--------------------------------------------------------------------------
  # * 텍스트 코드 처리
  #--------------------------------------------------------------------------
  alias rs_message_effects_process_escape_character process_escape_character
  def process_escape_character(code, text, pos)
    case code
    when '텍스트효과'
    when 'TE'
      effect = obtain_text_effects(text)
      if !@is_used_text_width_ex
        RS::LIST["텍스트 이펙트"] = effect
      end
    else
      rs_message_effects_process_escape_character(code, text, pos)
    end
  end  
  #--------------------------------------------------------------------------
  # * 텍스트 이펙트 추출
  #--------------------------------------------------------------------------
  def obtain_text_effects(text)
    effect_type = text.slice!(RS::CODE["텍스트 이펙트"])[$1] rescue "PingPong"
    effect_type.to_sym
  end    
  #--------------------------------------------------------------------------
  # * 텍스트 묘화 처리
  #--------------------------------------------------------------------------  
  alias rs_message_effects_process_normal_character process_normal_character
  def process_normal_character(c, pos, text)

    effect_type = RS::LIST["텍스트 이펙트"]
    if not effect_type
      return rs_message_effects_process_normal_character(c, pos, text)
    end
    
    valid = !@is_used_text_width_ex

    # 자동 개행 여부 판단
    if $game_message.word_wrap_enabled and valid and $game_message.balloon == -2
      tw = text_size(c).width
      if pos[:x] + (tw * 2) > contents_width
        process_new_line(text, pos)
      end
    end    
    
    target_viewport = @text_layer_viewport
    
    if effect_type == :MouseTracking
      target_viewport = self.viewport
    end

    # 텍스트 레이어 생성
    sprite = TextEffectFactory.create(effect_type, target_viewport)
    rect = text_size(c)
    w = rect.width + 1
    h = rect.height
    
    if !sprite
      raise "#{effect_type.to_s}타입이 없습니다."
    end
        
    sprite.bitmap = Bitmap.new(w * 2, pos[:height])
    sprite.bitmap.font = self.contents.font

    b = sprite.bitmap
    sprite.bitmap.draw_text(0, 0, b.width, b.height, c)
    padding = standard_padding
    sprite.x = self.x + padding + pos[:x]
    sprite.y = self.y + padding + pos[:y]
    sprite.z = self.z + 60
    
    case effect_type
    when :Marquee
      sprite.start(@layers.size + 1, self)
    else  
      sprite.start(@layers.size + 1)
    end
    
    update_text_layer_viewport
    
    # 화면에 텍스트 추가
    @layers.push(sprite) if !@is_used_text_width_ex
    
    pos[:x] += w
                    
    # 텍스트 사운드 재생
    unless @line_show_fast or @show_fast
      request_text_sound if (Graphics.frame_count % RS::LIST["텍스트 사운드 주기"]) == 0
      wait($game_message.message_speed || 0) if valid       
    end
        
    # Pause 아이콘 위치 조절
    if $imported["RS_PauseIconPosition"]
      mx = standard_padding + pos[:x] + 8
      my = standard_padding + pos[:y] + pos[:height]
      move_pause_sign(mx, my)      
    end
    
  end
end