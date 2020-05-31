#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
=begin

스프라이트는 뷰포트의 z 값이 높아야 나중에 그려집니다.
뷰포트 z 값이 같은 경우, 스프라이트의 z 좌표 값으로 판단합니다.

요약해보면,

애니메이션에 연결된 뷰포트의 z 좌표 값 : 0
창에 연결된 뷰포트의 z좌표 : 200
그림에 연결된 뷰포트의 z좌표 : 50

따라서 z좌표가 200보다 큰 뷰포트로 바꿔주면 위로 올라오게 됩니다.

=end

$imported = {} if $imported.nil?
$imported["RS_TopMostAnimationViewport"] = true

module TopmostViewport
  def create_viewport_for_ani
    @viewport_for_ani = Viewport.new
    @viewport_for_ani.z = 600
  end
  def update_viewport_for_ani
    return if !@animation or !@viewport_for_ani
    @ani_sprites.each do |sprite|
      sprite.viewport = @viewport_for_ani if sprite.viewport != @viewport_for_ani
    end
  end  
end

class Sprite_Character < Sprite_Base
  include TopmostViewport
  alias rs_animation_for_viewport_initialize initialize
  def initialize(viewport, character = nil)
    create_viewport_for_ani    
    rs_animation_for_viewport_initialize(viewport, character)
  end  
  alias rs_animation_for_viewport_update update
  def update
    rs_animation_for_viewport_update
    update_viewport_for_ani
  end
  alias rs_animation_for_viewport_dispose dispose
  def dispose
    rs_animation_for_viewport_dispose
    @viewport_for_ani.dispose if @viewport_for_ani
    @viewport_for_ani = nil
  end
  
end

class Sprite_Battler < Sprite_Base
  include TopmostViewport
  alias rs_animation_for_viewport_initialize initialize
  def initialize(viewport, battler = nil)
    create_viewport_for_ani
    rs_animation_for_viewport_initialize(viewport, battler)
  end
  alias rs_animation_for_viewport_update update
  def update
    rs_animation_for_viewport_update
    update_viewport_for_ani
  end
  alias rs_animation_for_viewport_dispose dispose
  def dispose
    rs_animation_for_viewport_dispose
    @viewport_for_ani.dispose if @viewport_for_ani
    @viewport_for_ani = nil
  end  
end