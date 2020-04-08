require 'optparse'
require 'ostruct'
require 'json'

# Author biud436
# ruby get_font_name.rb --font="C:\Users\U\Documents\RPGXP\Project8\Fonts\08SeoulNamsanB.ttf"
# ruby get_font_name.rb --font="C:\Users\U\Documents\RPGXP\Project8\Fonts\NanumGothic.ttf"

class App
  attr_accessor :options, :fonts

  def initialize
    @options = {}
    @fonts = {}
    init_options
  end

  def init_options

    OptionParser.new do |opts|
      opts.on("-f", "--font=FONT_NAME", "Type the name of TTF file") do |v|
        @options[:font] = v.gsub(/\\/, "/")
      end
      opts.on("-h", "--help", "prints all commands") do |v|
        puts opts
        exit
      end
    end.parse!

    p @options

    self
  end

  def parse
    font = @options[:font]
    if !File::exist?(font)
      raise "파일이 없습니다"
    end

    f = File.open(font, "r")
    font_offset_table_buffer = f.read(12)
    major_version, minor_version, num_of_tables, padding = font_offset_table_buffer.unpack("nnnn")

    @offset_table = OpenStruct.new
    @offset_table.major_version = major_version
    @offset_table.minor_version = minor_version
    @offset_table.num_of_tables = num_of_tables
    @offset_table.padding = padding

    is_found_name_table = false

    name_table = OpenStruct.new

    for i in (0...@offset_table.num_of_tables)
      puts tag_name = f.read(4).force_encoding("ASCII")
      data = f.read(12)

      if tag_name == "name"
        is_found_name_table = true
        p m = data.unpack("NNN")
        name_table.check_sum = m[0]
        name_table.offset = m[1]
        name_table.length = m[2]
        break
      end
    end

    if !is_found_name_table
      raise "이름 테이블을 찾지 못했습니다."
    end

    f.pos = name_table.offset

    name_header = OpenStruct.new
    name_header.format_selector = f.read(2).unpack("n").first
    name_header.name_record_count = f.read(2).unpack("n").first
    name_header.storage_offset = f.read(2).unpack("n").first

    if name_header.format_selector == 1
      p "langTagCount detect"
      p "langTagRecord[langTagCount] detect"
    end

    name_record_table = []

    for i in (0...name_header.name_record_count)
      name_record = OpenStruct.new
      name_record.platform_id = f.read(2).unpack("n")[0]
      name_record.encoding_id = f.read(2).unpack("n")[0]
      name_record.language_id = f.read(2).unpack("n")[0]
      name_record.name_id = f.read(2).unpack("n")[0]
      name_record.string_length = f.read(2).unpack("n")[0]
      name_record.string_offset = f.read(2).unpack("n")[0]
      name_record.name = ""

      # ! Font Family 취득
      if name_record.name_id == 4
        temp_file_pos = f.pos
        f.pos = name_table.offset + name_record.string_offset + name_header.storage_offset
        
        name_record.hex_offset = f.pos.to_s(16)
        
        len = name_record.string_length

        name_record.name = f.read(len).delete("\0").encode("UTF-16BE", "EUC-KR", :invalid => :replace, :undef => :replace, :replace => "")
        name_record_table.push(name_record)
        f.pos = temp_file_pos
      end

      # language_id: 1033 => United States	
      # language_id: 1042 => 대한민국

      # name_record_table.select! {|i| i[:platform_id] == 3}

      json_f = File.open("result.json", "w+")
      name_record_table.map! do |i|
        openstruct_to_hash(i)
      end
      json_f.puts JSON.pretty_generate(name_record_table)
      json_f.close

    end

    @fonts = name_record_table

    self
  end

  def openstruct_to_hash(object, hash = {})
    object.each_pair do |key, value|
      hash[key] = value.is_a?(OpenStruct) ? openstruct_to_hash(value) : value
    end
    hash
  end
    
end

$app = App.new
$app.parse
puts $app.fonts.select{|i| i[:language_id] == 23}