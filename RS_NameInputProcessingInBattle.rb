#==============================================================================
# Author : biud436
# Date : 2017.08.10
# Version : 1.0.0
# Version Log : 
# 2017.08.10 - First Release
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_NameInputProcessingInBattle"] = true

#==============================================================================
# ** Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # * Name Input Processing
  #--------------------------------------------------------------------------
  def command_303
    if $data_actors[@params[0]]
      unless $game_party.in_battle
        SceneManager.call(Scene_Name)
        SceneManager.scene.prepare(@params[0], @params[1])
        Fiber.yield
      else
        SceneManager.scene.name_processing_prepare(@params[0], @params[1]) if SceneManager.scene.is_a?(Scene_Battle)
        Fiber.yield
      end
    end
  end  
end

#==============================================================================
# ** Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base

  #--------------------------------------------------------------------------
  # * name_processing_prepare
  #--------------------------------------------------------------------------   
  def name_processing_prepare(actor_id, max_char)
    @name_window = {}
    @name_window[:actor] = $game_actors[actor_id]
    @name_window[:window] = Window_NameEdit.new(@name_window[:actor], max_char)
    @name_window[:input] = Window_NameInput.new(@name_window[:window])
    @name_window[:input].set_handler(:ok, method(:on_input_ok))
    lock_battle_scene
  end
  
  #--------------------------------------------------------------------------
  # * lock_battle_scene
  #--------------------------------------------------------------------------    
  def lock_battle_scene
    @is_lock_scene = true
    deactive_all_window
  end
  
  #--------------------------------------------------------------------------
  # * unlock_battle_scene
  #--------------------------------------------------------------------------    
  def unlock_battle_scene
    @is_lock_scene = false        
    destroy_name_input_window
    restore_all_window
    refresh_status
    @name_window = {}
  end      
  
  #--------------------------------------------------------------------------
  # * on_input_ok
  #--------------------------------------------------------------------------    
  def on_input_ok
    return if not @name_window[:actor]
    @name_window[:actor].name = @name_window[:window].name
    unlock_battle_scene
  end 
  
  #--------------------------------------------------------------------------
  # * deactive_all_window
  #--------------------------------------------------------------------------  
  def deactive_all_window
    @name_window[:status] = []
    instance_variables.each_with_index do |varname, index|
      ivar = instance_variable_get(varname)
      if ivar.is_a?(Window)
        @name_window[:status][index] = ivar.visible
        ivar.visible = false
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * restore_all_window
  #--------------------------------------------------------------------------  
  def restore_all_window
    instance_variables.each_with_index do |varname, index|
      ivar = instance_variable_get(varname)
      if ivar.is_a?(Window)
        ivar.visible = @name_window[:status][index]
      end
    end
  end  
  
  #--------------------------------------------------------------------------
  # * alias : update
  #--------------------------------------------------------------------------    
  alias xxxx_update update
  def update
    xxxx_update if not @is_lock_scene
    name_input_window_update
  end  
  
  #--------------------------------------------------------------------------
  # * name_input_window_update
  #--------------------------------------------------------------------------      
  def name_input_window_update
    return if not @is_lock_scene
    Graphics.update
    Input.update    
    @name_window[:window].update if @name_window[:window]
    @name_window[:input].update if @name_window[:input]
  end
  
  #--------------------------------------------------------------------------
  # * destroy_name_input_window
  #--------------------------------------------------------------------------   
  def destroy_name_input_window
    @name_window[:window].dispose if not @name_window[:window].disposed?
    @name_window[:input].dispose if not @name_window[:input].disposed?
    @name_window[:window] = nil
    @name_window[:input] = nil
  end
    
end