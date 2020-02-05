#==============================================================================
# ** Hangul Message Effects (RPG Maker VX Ace)
#==============================================================================
# Name       : Hangul Message Effects
# Author     : 러닝은빛(biud436)
#==============================================================================
# ** 업데이트 로그
#==============================================================================
# Version    :
# 2020.02.05 (v1.0.0) - First Release
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
  CODE["텍스트 이펙트"] = /^\<(.*)\>/
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
  def start
    @power = 1
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
    if @power <= 60
      self.ox = -3 * rand
      self.oy = -3 * rand
    else
      flush
    end
  end
end

RS::Messages::Effects[:Shock] = Shock

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
      RS::LIST["텍스트 이펙트"] = obtain_text_effects(text)
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
    if [:HighRotation, :NormalRotation, :RandomRotation].include?(effect_type)
      target_viewport = self.viewport
    end

    # 텍스트 레이어 생성
    sprite = TextEffectFactory.create(effect_type, target_viewport)
    rect = text_size(c)
    w = rect.width + 1
    h = rect.height
    
    # 일부 텍스트 효과는 창 밖에서도 그려져야 하므로 뷰포트를 직접 구성해야 함
    if ((self.x + self.contents.width) < self.x + padding + pos[:x] + w) &&
        (target_viewport != @text_layer_viewport)
      return
    end
    
    sprite.bitmap = Bitmap.new(w * 2, pos[:height])
    sprite.bitmap.font = self.contents.font
    
    b = sprite.bitmap
    sprite.bitmap.draw_text(0, 0, b.width, b.height, c)
    padding = standard_padding
    sprite.x = self.x + padding + pos[:x]
    sprite.y = self.y + padding + pos[:y]
    sprite.z = self.z + 60
    sprite.start
    
    update_text_layer_viewport
    
    # 화면에 텍스트 추가
    @layers.push(sprite)
    
    pos[:x] += w
            
    # 텍스트 사운드 재생
    unless @line_show_fast or @show_fast
      request_text_sound if (Graphics.frame_count % RS::LIST["텍스트 사운드 주기"]) == 0
    end
    
    # Pause 아이콘 위치 조절
    if $imported["RS_PauseIconPosition"]
      mx = standard_padding + pos[:x] + 8
      my = standard_padding + pos[:y] + pos[:height]
      move_pause_sign(mx, my)      
    end
    
  end
end