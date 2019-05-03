#==============================================================================
# Name : RS_ItemTempStorage
# Desc : 
# This script allows you to save or restore all items using simple commands.
# Author : biud436
# Usage :
# 저장
# $game_party.save_all_items
# 복구
# $game_party.restore_all_items
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_ItemTempStorage"] = true

class Game_Party
  
  def save_all_items
    
    # 아이템 해시를 직렬화합니다.
    @temp_storage = [
      Marshal.dump(@items),
      Marshal.dump(@weapons),
      Marshal.dump(@armors)    
    ]
    
    # 아이템을 비웁니다.
    @items = {}
    @weapons = {}
    @armors = {}
  end
  
  def restore_all_items
    
    # 직렬화 데이터가 없으면 반환
    return if not @temp_storage
    
    # 아이템 데이터를 역직렬화하여 복구합니다.
    @items = Marshal.load(@temp_storage[0])
    @weapons = Marshal.load(@temp_storage[1])
    @armors = Marshal.load(@temp_storage[2])
    
    # 메모리를 비웁니다.
    @temp_storage = nil
    
  end
  
end