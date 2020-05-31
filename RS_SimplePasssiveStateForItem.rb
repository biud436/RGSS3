#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# ** RS_SimplePasssiveStateForItem (2018.08.19)
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_SimplePasssiveStateForItem"] = true

module PassiveItem
  PASSIVE_ITEMS = 
  {
    # 아이템 ID => 상태 ID
    1 => 26,
  }
  def update_my_passive_state
    actor = $game_party.members[0]
    # 플레이어가 있는가?
    return if not actor    
    PASSIVE_ITEMS.each do |index, state_id|
      # 아이템을 소지 중인가?
      if $game_party.has_item?($data_items[index])
        # 패시브 상태를 추가한다
        actor.add_state(state_id)
      else 
        # 패시브 상태를 제거한다
        actor.remove_state(state_id)
      end      
    end
  end  
end

# 맵
class Scene_Map
  include PassiveItem
  alias xxxx_my_passive_update update
  def update
    xxxx_my_passive_update
    update_my_passive_state
  end
end

# 전투
class Scene_Battle
  include PassiveItem
  alias xxxx_my_passive_update update
  def update
    xxxx_my_passive_update
    update_my_passive_state
  end
end

# 메뉴
class Scene_MenuBase
  include PassiveItem
  alias xxxx_my_passive_update update
  def update
    xxxx_my_passive_update
    update_my_passive_state
  end
end