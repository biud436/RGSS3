#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
# Author : 러닝은빛
# 사용법 :
# $game_map.save_parallax를 호출하여 현재 맵의 원경 정보를 저장할 수 있습니다.
# $game_map.load_parallax를 호출하여 저장한 원경 정보를 불러올 수 있습니다.

$imported = {} if $imported.nil?
$imported["RS_LoadTempParallax"] = true

module ParallaxCopyBase
  DATA = [
    "name",
    "loop_x", 
    "loop_y", 
    "sx", 
    "sy", 
    "x", 
    "y", 
  ]
end

class DataMan
  attr_reader :data
  def initialize(filename)
    @filename = filename
    @data = {}
  end
  def []=(id, data)
    @data[id] = data
  end
  def save
    save_data(@data, @filename)
  end  
  def load
    filename = @filename
    if not FileTest.exist?(@filename)
      @data = {} 
      return self
    end
    @data = load_data(@filename)
    flush
    return self
  end
  def nil?
    return !FileTest.exist?(@filename)
  end
  def flush
    return if not FileTest.exist?(@filename)
    File.delete(@filename)
  end
end

class Game_Map
  def save_parallax
    obj = ParallaxCopyBase::DATA
    data = DataMan.new("./CurrentParallax.data")
    obj.each do |k| 
      data[k] = self.instance_variable_get("@parallax_#{k}")
    end
    data.save
  end
  def load_parallax
    obj = ParallaxCopyBase::DATA
    data = DataMan.new("./CurrentParallax.data")
    return if data.nil?
    data = data.load.data
    obj.each do |k| 
      self.instance_variable_set("@parallax_#{k}", data[k])
    end    
  end
end