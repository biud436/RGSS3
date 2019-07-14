#============================================================================
# RPG Maker VX
#============================================================================

$imported = {} if $imported.nil?
$imported["RS_BootManager"] = true

module BootManager
	#=============================================================================
	# Create Tile
	#=============================================================================
	def create_temp_tile
		for y in 0...$game_map.height
			for x in 0...$game_map.width
				$game_map.data[x, y, 0] = 2816
			end
		end
	end
	#=============================================================================
	# Gain Item
	#=============================================================================
	def gain_item
		item = $data_items
		$game_party.gain_item(item[1], 1)
	end
end
class Scene_Map < Scene_Base
	include BootManager
	#=============================================================================
	# Start
	#=============================================================================
	alias xxxx_start start
	def start
		xxxx_start
		create_temp_tile
	end
end