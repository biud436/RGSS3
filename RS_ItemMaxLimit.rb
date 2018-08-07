#==============================================================================
# ** RS_ItemMaxLimit
#==============================================================================
# Name       : RS_ItemMaxLimit
# Author     : biud436
# Version    : 1.0.0 (2018.08.07)
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_ItemMaxLimit"] = true
class Game_Party < Game_Unit  
  alias xxxx_max_item_number max_item_number
  def max_item_number(item)
    number = 99
    if item and item.note =~ /<(?:MAX LIMIT):[ ]*(\d+)>/i
      number = $1.to_i || number
    else
      number = xxxx_max_item_number(item)
    end
    return number
  end
end