#==============================================================================
# ** Self Variables
# Author : biud436
# Date : 2015.03.21
# Version Log :
# 1.0
# 1.1
#==============================================================================
# ** 스크립트 소개
#==============================================================================
# 셀프 변수 스크립트입니다.
#
#==============================================================================
# ** 스크립트 설치
#==============================================================================
# Main 위 소재 밑 사이의 빈 공간에 추가 삽입해주세요.
#
#==============================================================================
# ** 사용법
#==============================================================================
# 이벤트 편집창- 고급 - 스크립트 커맨드 쪽에서 아래와 같은 형식으로 작성하세요
#
# $self_variables["이름"] = "EV001"
# $self_variables["공격력"] = 12
# $self_variables["체력"] = 50
# $self_variables["마력"] = 100
# $self_variables[3] = 150
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_SelfVariables"] = true

class Game_SelfVariables
  def initialize
    @data = {}
  end
  def map_id
    $game_map.map_id
  end
  def event_id
    $game_map.interpreter.event_id
  end
  def [](index)
    @data[[map_id,event_id,index]] || 0
  end
  def []=(index,value)
    @data[[map_id,event_id,index]] = value
    on_change
  end
  def on_change
    $game_map.need_refresh = true
  end
end

module DataManager
 class << self
    alias self_var_create_game_objects create_game_objects
    def create_game_objects
      self_var_create_game_objects
      $self_variables = Game_SelfVariables.new
    end
    alias self_var_extract_save_contents extract_save_contents
    def extract_save_contents(contents)
      self_var_extract_save_contents(contents)
      $self_variables = contents[:self_variables]
    end
    alias self_var_make_save_contents make_save_contents
    def make_save_contents
      contents = self_var_make_save_contents
      contents[:self_variables] = $self_variables
      contents
    end
  end
end

class Game_SelfVariables
  def set_data(mid, eid, id, value)
    @data[[mid,eid,id]] = value
    on_change
  end
  def get_data(mid, eid, id)
    @data[[mid,eid,id]] || 0
  end
end

class Game_Event < Game_Character
  alias xxxx_eval eval
  def eval(*args)
    if args[0] && args[0].match(/\$(?:SELF_VARIABLES)\[(.+?)\][ ]*=[ ]*(.*)/i)
      id = $1.to_s
      value = $2.to_i
      $self_variables.set_data(@map_id, @event_id, id, value)
    elsif args[0] && args[0].match(/\$(?:SELF_VARIABLES)\[(.+?)\]/i)
      $self_variables.get_data(@map_id, @event_id, $1.to_s)
    else
      xxxx_eval(*args)
    end
  end
end
