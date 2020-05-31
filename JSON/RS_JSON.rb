#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#===============================================================================
# Name : RS_JSON
# Author : biud436
# Version : v1.0.0
# Usage : 
# Before using this script, You must place the file called 'json.exe' to the root directory.
#
# To write the *.json, Try to do as follows.
# 
# ex)
# JSON.to_json({:mode => "안녕하세요", :name => "러닝은빛"}, "output.json")
#
# To parse a json from the input string, as follows.
#
# ex)
# JSON.parse("output.json") => Hash
#
#===============================================================================
$imported = {} if $imported.nil?
$imported["RS_JSON"] = true
module JSON  
  @@mode = "r"
  @@data = {}.to_s
  @@filename = "output.json"
  
  def self.valid_library?
    FileTest.exist?("json.exe")
  end
  
  def self.test_json
    `powershell "$test = @{name='WOW';data=0}; $test | ConvertTo-Json"`
  end
  
  def self.pipe
    
    # 백틱을 통해 다른 프로세스를 실행합니다
    # JSON을 파싱합니다.
    str = @@data.to_s.unpack("U*")
    command = %Q(json.exe /f '#{str}' #{@@filename})

    if @@mode == "r"
      command = %Q(json.exe /r #{@@filename})  
    end

    t = Thread.new do
      Thread.current[:data] = `#{command}`
    end

    # 프로세스는 비동기적이므로 반환 값을 바로 받을 수 없습니다.
    # 따라서 쓰레드가 멈출 때까지 대기합니다.
    t.join

    # JSON 값을 받았습니다
    # 파일로 저장합니다.
    if @@mode == "r"
      return t[:data]
    end    
  end
  
  def self.to_json(*args)
    @@mode = "w"
    @@data = args[0].to_s 
    @@filename = args[1]
    pipe
  end
  
  def self.parse(*args)
    @@mode = "r"
    @@filename = args[0]
    data = eval(pipe)
    if data
      data = data.pack("U*")
      data = eval(data)
      return data
    end
    return {}
  end
end

