#===============================================================================
# Name : RS_JSON
# Author : biud436
# Version : v1.0.0
# Usage : 
# 
# json.exe 파일을 실행 파일과 같은 위치에 두세요.
#
# JSON 파일을 작성하려면 다음과 같이 하세요.
# JSON.to_json({:mode => "안녕하세요", :name => "러닝은빛"}, "output.json")
#
# JSON 파일을 파싱하려면 다음과 같이 하세요.
# JSON.parse("output.json")
#
#===============================================================================
$imported = {} if $imported.nil?
$imported["RS_JSON"] = true
module JSON  
  @@mode = "r"
  @@data = {}.to_s
  @@filename = "output.json"
  
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
