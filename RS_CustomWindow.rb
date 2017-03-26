#===============================================================================
# Name : Custom Window (Ruby) - RPG Maker VX Ace
# Author : biud436
# Date : 2017.03.21
# Introduction : This script allows you to create the custom window in the map
# Usage :
# In the event editor, you can use the script command, then use this method.
# ------------------------------------------------------------------------------
# create_custom_window(x, y, width, height, text, auto_dispose)
# ------------------------------------------------------------------------------
# x : x is the same as x-position of the custom window 
# y : y is the same as x-position of the custom window 
# width : width is the same as a maximum width of the custom window 
# height : height is the same as a maximum height of the custom window
# text : text is you can write the string as you want to indicate into the 
# screen, can use the text code.
# auto_dispose : auto_dispose is you can set whether the window automatically 
# ends up when pressing a decision key. 
# ------------------------------------------------------------------------------
# remove_custom_window(uid)
# ------------------------------------------------------------------------------
# If you want to remove already created custom window, you can try this.
# Notice that there is one important parameter.
# uid - when calling 'create_custom_window' method, it returns the variable 
# named 'uid'. So getting variable 'uid' there is two ways :
# - the way that uses the method called 'create_custom_window'
# - the way that uses a global variable called '$game_map.uid'
#===============================================================================
# The update Logs
#===============================================================================
# 2017.03.25 (v1.0.1) - Fixed an issue that didn't remove existing window.
# 2017.03.26 (v1.0.2) - Added the remove function for all custom windows
$Imported = $Imported || {}
$Imported["RS_CustomWindow"] = true
class Window_CustomText < Window_Base
  def initialize(*args)
    super(*args[0..3])
    @rect = args[0..3]
    @texts = args[4] || ''
    @auto_dispose = args[5] || false
    refresh
  end
  def auto_dispose?
    return @auto_dispose
  end
  def refresh
    draw_text_ex(0, 0, @texts)
  end
end
class Game_Map
  attr_accessor :custom_windows
  attr_accessor :uid
  alias xxxx_initialize initialize
  def initialize
    xxxx_initialize
    @custom_windows = {}
    @uid = 0
  end
end
class Game_Interpreter
  def create_custom_window(*args)
    SceneManager.scene.create_custom_window(*args)
  end
  def remove_custom_window(uid)
    SceneManager.scene.remove_custom_window(uid)
  end
  def remove_all_custom_windows
    SceneManager.scene.remove_all_custom_windows
  end
end
class Scene_Map < Scene_Base
  alias xxxx_start start
  def start
    xxxx_start
    @custom_windows = {}
    @disposing_windows = []
    restore_custom_windows
  end
  alias xxxx_update update
  def update
    xxxx_update
    @custom_windows.keys.each do |key|
      if @custom_windows[key].is_a?(Window_Base)  
        @custom_windows[key].update
        @disposing_windows.push(->(){
          if @custom_windows[key].auto_dispose? && Input.trigger?(:C)
            @custom_windows.delete(key)
            $game_map.custom_windows.delete(key)
          end
        })
      end
    end
    @disposing_windows.each {|i| i.call if i.is_a?(Proc)}
    @disposing_windows.clear 
  end
  alias xxxx_terminate terminate
  def terminate
    xxxx_terminate
    remove_all_custom_windows
  end
  def restore_custom_windows
    return unless $game_map.custom_windows.is_a?(Hash)
    $game_map.custom_windows.values.each do |args|
      create_custom_window(*args)
    end
  end
  def create_custom_window(*args)
    uid = ($game_map.uid += 1)
    $game_map.custom_windows[uid] = args
    new_window = Window_CustomText.new(*args)
    @custom_windows[uid] = new_window
    uid
  end
  def remove_custom_window(uid)
    return false unless @disposing_windows.is_a?(Array)
    return false unless @custom_windows.is_a?(Hash)
    if @custom_windows[uid].is_a?(Window_Base)
    @custom_windows[uid].visible = false
    @custom_windows.delete(uid)
    $game_map.custom_windows.delete(uid)
    end
  end
  def remove_all_custom_windows
    if @custom_windows.is_a?(Hash)
      @custom_windows.values.each do |window|
        window.dispose if window.is_a?(Window_Base)
      end
    end    
  end  
end