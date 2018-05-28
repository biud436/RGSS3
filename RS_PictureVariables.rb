#==============================================================================
# Author : biud436
# Date : 2018.05.28
# Description : 그림의 크기를 특정 변수에 대입합니다.
#==============================================================================
module RS
  SCAN_IMAGE_WIDTH = /(?:이미지 가로 크기)/i
  SCAN_IMAGE_HEIGHT = /(?:이미지 세로 크기)/i
end
class Sprite_Picture < Sprite
  alias get_size_update update
  def update
    get_size_update
    get_size
  end
  def get_size
    return false if @picture.name.empty? or self.bitmap == nil
    return false if not @picture.valid_variable_size?
    w = self.bitmap.width
    h = self.bitmap.height
    @picture.get_size(w, h)
  end
end
class Game_Picture
  attr_reader :width, :height
  alias variable_ids_initialize initialize
  def initialize(number)
    variable_ids_initialize(number)
    init_variables
  end
  def init_variables
    @variable_ids = [0, 0]
    @width = 0
    @height = 0
  end
  def set_ids(*arg)
    return if arg == nil
    @variable_ids[0] = arg[0]
    @variable_ids[1] = arg[1]
  end
  def ids
    @variable_ids
  end
  def get_size(w, h)
    @width = w
    @height = h
    if valid_variable_size?
      $game_variables[ids[0]] = @width
      $game_variables[ids[1]] = @height
    end
  end
  def valid_variable_size?
    return !@variable_ids.include?(0)
  end
end
class Game_Interpreter
  alias xxxx_command_231 command_231
  def command_231
    xxxx_command_231
    valid = @params[3] != 0
    valid = $data_system.variables[@params[4]].slice(RS::SCAN_IMAGE_WIDTH) if valid 
    valid = $data_system.variables[@params[5]].slice(RS::SCAN_IMAGE_HEIGHT) if valid 
    screen.pictures[@params[0]].set_ids(@params[4], @params[5]) if valid 
  end
end