#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#===============================================
# 스크립트를 삽입하시고, 좌표 설정해서 사용 하시기 바랍니다.
# 특정 그리드에 정렬하려면 좌표를 아래와 같이 설정해야 합니다.
# X 좌표 * 32(타일 가로 크기)
# Y 좌표 * 32(타일 세로 크기)
#===============================================

$imported = {} if $imported.nil?
$imported["RS_FixSpritePicture"] = true

$RM_VERSION = {
	'XP'=>false,
	'VX'=>false,
	'VXA'=>false
}

case RUBY_VERSION
when "1.9.2"
	if Object.const_defined?("SceneManager")
		$RM_VERSION[:VXA] = true
	end
when "1.8.1"
	if Object.const_defined?("Vocab")
		$RM_VERSION[:VX] = true
	else
		$RM_VERSION[:XP] = true
	end
end

module PIC
  # 맵에 고정되는 그림의 범위(그림 번호 기입)
  RANGE = (1..10)
end

class Sprite_Picture < Sprite

if $RM_VERSION[:VX]
  def update
    super
    if @picture_name != @picture.name
      @picture_name = @picture.name
      if @picture_name != ""
        self.bitmap = Cache.picture(@picture_name)
      end
    end
    if @picture_name == ""
      self.visible = false
    else
      self.visible = true
      update_origin
      self.x = @picture.x
      self.y = @picture.y
      self.z = 100 + @picture.number
      self.zoom_x = @picture.zoom_x / 100.0
      self.zoom_y = @picture.zoom_y / 100.0
      self.opacity = @picture.opacity
      self.blend_type = @picture.blend_type
      self.angle = @picture.angle
      self.tone = @picture.tone
    end
	end
end
  def update_origin
    if @picture.origin == 0
      if PIC::RANGE === @picture.number
        # 특정 그림을 맵에 고정합니다
				if $RM_VERSION[:VX]
					self.ox = $game_map.display_x / 8
					self.oy = $game_map.display_y / 8
				end
				if $RM_VERSION[:VXA]
					self.ox = $game_map.display_x * 32
					self.oy = $game_map.display_y * 32
				end
      else
        # 화면 좌표에 고정합니다
        self.ox = 0
        self.oy = 0
      end
    else
      self.ox = self.bitmap.width / 2
      self.oy = self.bitmap.height / 2
    end
  end
end
