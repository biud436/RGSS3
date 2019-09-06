# Author : biud436

$imported = {} if $imported.nil?
$imported["RS_SCG_MessageSystem"] = true

class Object
  def ptr; object_id << 1; end
end

module Easing

  GetTickCount = Win32API.new('kernel32.dll', 'GetTickCount', 'v', 'l')
  LoadLibrary = Win32API.new('kernel32.dll', 'LoadLibrary', 'p', 'l')
  Init = Win32API.new('Easing.dll', 'Initialize', 'l', 'v')
  EchoMessage = Win32API.new('Easing.dll', 'EchoMessage', 'l', 'l')

  @@handle = LoadLibrary.call('System/RGSS301.dll')

  Init.call(@@handle)
  
  EASE = {}

  METHODS = [
    "BackEaseIn", "BackEaseOut", "BackEaseInOut",
    "BounceEaseIn", "BounceEaseOut", "BounceEaseInOut",
    "CircEaseIn", "CircEaseOut", "CircEaseInOut",
    "CubicEaseIn", "CubicEaseOut", "CubicEaseInOut",
    "ElasticEaseIn", "ElasticEaseOut", "ElasticEaseInOut",
    "ExpoEaseIn", "ExpoEaseOut", "ExpoEaseInOut",
    "LinearEaseNone", "LinearEaseIn", "LinearEaseOut", "LinearEaseInOut",
    "QuadEaseIn", "QuadEaseOut", "QuadEaseInOut",
    "QuartEaseIn", "QuartEaseOut", "QuartEaseInOut",
    "QuintEaseIn", "QuintEaseOut", "QuintEaseInOut",
    "SineEaseIn", "SineEaseOut", "SineEaseInOut",
  ]

  def self.set(name)
    EASE[name] = Win32API.new('Easing.dll', name, 'llll', 'l')
  end

  METHODS.each {|func_name| Easing.set(func_name)}  

  def self.VALUE2obj(cvalue)
    return ObjectSpace._id2ref(cvalue >> 1)
  end    

  def self.echo(x)
    ret = EchoMessage.call(x.ptr)
    VALUE2obj(ret)
  end  

  def self.t
    GetTickCount.call
  end  
  
  module Base
    def base(*args)
      name = self.name.to_s.gsub("Easing::", "") 
      f = EASE[name + args[0]]
      args.slice!(0)
      data = args.collect {|a| a.ptr }
      ret = f.call( *data )
      Easing.VALUE2obj(ret)          
    end
    def ease_in(*args)
      base("EaseIn", *args[0..3])
    end   
    def ease_out(*args)
      base("EaseOut", *args[0..3])
    end        
    def ease_in_out(*args)
      base("EaseInOut", *args[0..3])
    end        
  end  
  
  module Back
  end
  
  module Bounce
  end
  
  module Circ
  end
  
  module Cubic
  end
  
  module Elastic
  end
  
  module Expo
  end
  
  module Linear
  end
  
  module Quad
  end
  
  module Quart
  end
  
  module Quint
  end
  
  module Sine
  end
    
  [Back, Bounce, Circ, Cubic, Elastic, Expo, Linear, Quad, Quart, 
  Quint, Sine].each do |i| 
    i.module_exec {
      class << self
        include Base 
      end
    }
  end
  
  module Linear
    def self.ease_none(*args)
      self.base("EaseNone", *args[0..3])
    end        
  end  
    
end

p Easing.echo(0.5)
p Easing::Back.ease_in(0.2, 1.0, 0.8, 1.0)
p Easing::Back.ease_out(0.2, 1.0, 0.8, 1.0)
p Easing::Back.ease_in_out(0.2, 1.0, 0.8, 1.0)
p Easing::Expo.ease_in(0.2, 1.0, 0.8, 1.0)
p Easing::Linear.ease_none(0.2, 1.0, 0.8, 1.0)
p Easing::Bounce.ease_out(0.2, 1.0, 0.8, 1.0)