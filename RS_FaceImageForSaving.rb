#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# ** RS_FaceImageForSaving
# Author : biud436
# Date : 2014.10.30
# Version : 1.0
# Update Log : 
# 2017.04.18 : 
# -dest_rect 수정
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_FaceImageForSaving"] = true

class Window_SaveFile
    def draw_face(face_name, face_index, x, y, enabled = true)
      bitmap = Cache.face(face_name)
      src_rect = Rect.new(face_index % 4 * 96,face_index / 4 * 96, 96, 96)
      dest_rect = Rect.new(x, 0, 76, 76)
      contents.stretch_blt(dest_rect, bitmap, src_rect) 
      bitmap.dispose
    end  
    
    def draw_party_characters(x, y)
      header = DataManager.load_header(@file_index)
      return unless header
      header[:characters].each_with_index do |data, i|
        draw_face(data[0], data[1], x + i * 78, y)
      end
    end
  end
   
  class Game_Party
    def characters_for_savefile
      battle_members.collect do |actor|
        [actor.face_name , actor.face_index]
      end
    end
  end
  