#==============================================================================
# ** All Save files delete
# Author : biud436
# Date : 2016.02.25
# Version : 1.0
# Usage : SaveManager.delete_all
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_DeleteAllSaveFiles"] = true

module SaveManager
  extend self
  def delete_all
    arr = Dir["Save[0-9][0-9].rvdata2"]
    arr.each do |i|
      File.delete(i) if File.exist?(i)
    end
  end
end
