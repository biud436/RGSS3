#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
class Scene_Tool < Scene_Base
  def start
    super
    @map_editor = MapEditor.new
  end
  def update
    super
    @map_editor.update
  end
  def terminate
    super
    @map_editor.terminate
  end
end

module SceneManager
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_Tool
  end
end