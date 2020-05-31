require 'json'
require "colorize"
require "base64"

module MIT

  HEADER = [
    "#================================================================",
    "# The MIT License",
    "# Copyright (c) 2020 biud436",
    "# ---------------------------------------------------------------",
    "# Free for commercial and non commercial use.",
    "#================================================================",
  ].join("\n")

end

class App
  def initialize
    if ARGV.include? "-r"
      rebase
    else
      run
    end
  end

  def read_folder(project_root = nil, files = [])
    project_root = File.dirname(File.absolute_path(__FILE__)) if !project_root
    Dir.glob([project_root + "/*.rb", project_root + "/*"]) do |file| 
      if File.directory?(file)
        read_folder(file, files)
      elsif File.extname(file) == ".rb"
        files.push(file)
      end
    end
  
    return files
  end  

  def config_file
    "config.json"
  end

  def load_config
    # 설정 파일을 불러옵니다
    config = if File.exist?(config_file)
      puts "config.json file is found in this directory".red
      json = File.open(config_file, "r+").read
      parsed = JSON.parse(json)
    else
      puts "config.json file cannot find in this directory".red
      JSON.parse "{}"
    end

    config["_config.rb"] = true  
    
    return config
  end

  def save_config(config)
    f = File.open(config_file, "w+")
    f.puts JSON.pretty_generate(config)
    f.close
    puts "config.json file has changed".blue.on_red.uncolorize       
  end

  def run

    # 설정 파일을 로드합니다.
    config = load_config

    # 모든 루비 파일을 탐색한다.
    read_folder.uniq.each do |file|

      # 헤더가 이미 작성되어있다면 다음으로
      next if config[File.basename(file)]

      puts "validation ==> #{file}".blue.on_red.blink

      f = File.open(file, 'r+')
      contents = f.read
      f.close
      
      f = File.open(file, 'w+')
      f << MIT::HEADER
      f << "\n"
      f << contents
      f.close

      config[File.basename(file)] = Base64.encode64(contents)

      puts "#{File.basename(file)} is written successfully".colorize(:light_blue)
    end

    save_config(config)  
  end

  # 이전 파일로 복구합니다.
  def rebase
    # 설정 파일을 로드합니다.
    config = load_config

    # 모든 루비 파일을 탐색한다.
    read_folder.uniq.each do |file|

      name = File.basename(file)
      next if name == "_config.rb"
      next if !config[name]

      puts "validation ==> #{file}".black.on_white.blink

      enc = config[name]
      plain = Base64.decode64(enc)

      f = File.open(file, 'w+')
      f << plain
      f.close

      config[name] = nil

    end

    # 설정 파일을 저장합니다.
    save_config(config)
  end

end

app = App.new