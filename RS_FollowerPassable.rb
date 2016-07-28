#==============================================================================
#  Name : Follwer Passable
#  Date : 2016.06.01
#  Author : biud436
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================
class Game_Player < Game_Character
  alias xxxx_passable? passable?
  def passable?(x, y, d)
    x2 = $game_map.round_x_with_direction(x, d)
    y2 = $game_map.round_y_with_direction(y, d)
    return false if $game_player.follower_passable?(x2, y2)
    xxxx_passable?(x, y, d)
  end
  def follower_passable?(x, y)
    @followers.follower_passable?(x, y)
  end
end

class Game_Follower < Game_Character
  alias xxxx_initialize initialize
  def initialize(member_index, preceding_character)
    xxxx_initialize(member_index, preceding_character)
    @through = false
  end
end

class Game_Followers
  def follower_passable?(x, y)
    visible_folloers.any? {|follower| follower.pos_nt?(x, y) }
  end
end
