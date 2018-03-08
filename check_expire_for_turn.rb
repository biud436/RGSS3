class Game_Player
  attr_reader :steps
  alias xxxx_initialize initialize
  def initialize
    xxxx_initialize
    @steps = 0
  end
  alias xxxx_update update
  def update
    last_moving = moving?    
    xxxx_update
    unless moving?
      if last_moving
        @steps += 1
        check_expire_for_steps
      end
    end
  end
  def check_expire_for_steps
    # 걸을 때 마다 최대 체력의 2%를 증감
    d = $game_party.actors[0].maxhp * 0.02 
    $game_party.actors[0].hp += d.round
  end
end

class Scene_Battle
  alias xxxx_start_phase2 start_phase2
  def start_phase2
    check_expire_for_turn
    xxxx_start_phase2
  end
  def check_expire_for_turn
    # 최대 체력의 2%를 증감
    return if $game_temp.battle_turn < 1
    $game_party.actors.each do |actor| 
      d = (actor.maxhp * 0.02).round
      actor.hp += d.round
      actor.damage = "HP #{d}만큼 증감"
      actor.damage_pop = true
      @wait_count = 8
    end
  end  
end
