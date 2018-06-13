#==============================================================================
# ** Tone_Base
# Name : Tone_Base
# Desc : This script allows you to change certain character's tone.
# Author : biud436
# Version : 1.0
#==============================================================================
# ** How to Use
#==============================================================================
# This provides useful methods how the player's tone can change during playing
# the game. In script command in an event editor, You can also use as follows.
#
# This code can set player's image tone as a number between -255 and 255.
# get_character(0)._tone(Red,Green,Blue)
# get_character(0)._tone(Red,Green,Blue,Gray)
#
# This code can return or set player's image tone as a type of Tone. the object
# named 'nil' indicates to set as original tone.
# get_character(0).tone = nil
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_CharacterTone"] = true

module Tone_Base
  $tone = ->(red=0,green=0,blue=0,gray=0){rl = Tone.new(red,green,blue,gray); rl}
end
class Game_CharacterBase
  alias xxxx_init_public_members init_public_members
  attr_accessor :tone
  def init_public_members
    xxxx_init_public_members
    @tone || nil
  end
  def _tone(*args)
    params = args[0..2].select {|i| i.between?(-255,255)}
    params << args[3] if args.size >= 4 and args[3].between?(0,255)
    @tone = $tone.call(*params)
  end
end
class Sprite_Character
  alias xxxx_set_character_bitmap set_character_bitmap
  alias xxxx_update_other update_other
  def set_character_bitmap
    xxxx_set_character_bitmap
    @original_tone = Tone.new
  end
  def update_other
    xxxx_update_other
    self.tone = @character.tone || @original_tone
  end
end
