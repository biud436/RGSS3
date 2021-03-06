#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# ** 한글 비트맵 텍스트
# Desc :
# Version Log :
# 2019.05.04 (v1.0.0) - First Release.
#==============================================================================
$imported = {} if $imported.nil?
$imported["RS_HangulBitmapText"] = true

if not defined?(RGSS_VERSION)
  RGSS_VERSION = case RUBY_VERSION
  when "1.8.1"
    defined?(Game_Interpreter) ? 2 : 1
  when "1.9.2"
    3
  end
end

class CharDescriptor
  attr_accessor :x, :y, :width, :height, :xoffset, :yoffset
  attr_accessor :xadvance, :page, :kerning
  def initialize
    @x = 0
    @y = 0
    @width = 0
    @height = 0
    @xoffset = 0
    @yoffset = 0
    @xadvance = 0
    @page = 0
    @kerning = {}
  end
end

m = []
if RGSS_VERSION == 1
  m << "module RPG::Cache"
else
  m << "module Cache"
end
  m << "def self.font(filename)"
  m << '  self.load_bitmap("Graphics/Hangul/", filename)'
  m << "end  "
  m << "end"

  eval(m.join("\r\n"))

class Charset
  attr_accessor :line_height, :base, :width, :height
  attr_accessor :pages, :chars, :ready, :texture_ready
  def initialize
    @line_height = 0
    @base = 0
    @width = 0
    @height = 0
    @pages = 0
    @chars = {}
    @ready = false
    @texture_ready = false
  end
end

class BMFont
  attr_accessor :size
  
  def initialize(fnt_name)
    @file = IO.readlines("Graphics/Hangul/#{fnt_name}")
    @desc = Charset.new
    @texture = []
    @size = Font.default_size
  end
  def get_data(stream, hash)
    stream.each do |i|
      attribute = i.split("=")
      key = attribute[0]
      value = attribute[1]
      hash[key] = value
    end    
    hash
  end
  def parse_common(stream)
    common = get_data(stream, {})
    @desc.line_height = common["lineHeight"].to_i
    @desc.base = common["base"].to_i
    @desc.width = common["scaleW"].to_i
    @desc.height = common["scaleH"].to_i
    @desc.pages = common["pages"].to_i    
  end
  def parse_page(stream)
    pages = get_data(stream, {})
    filename = pages["file"].gsub(/[\"]*/i, "")
    @texture.push(RGSS_VERSION == 1 ? RPG::Cache.font(filename) : Cache.font(filename))
  end
  def parse_char(stream)
    chars = get_data(stream, {})
    id = chars["id"].to_i
    @desc.chars[id] = CharDescriptor.new
    @desc.chars[id].x = chars["x"].to_i
    @desc.chars[id].y = chars["y"].to_i
    @desc.chars[id].width = chars["width"].to_i
    @desc.chars[id].height = chars["height"].to_i
    @desc.chars[id].xoffset = chars["xoffset"].to_i
    @desc.chars[id].yoffset = chars["yoffset"].to_i
    @desc.chars[id].xadvance = chars["xadvance"].to_i
    @desc.chars[id].page = chars["page"].to_i  
  end
  def parse_kernings(stream)
    kerning = get_data(stream, {})
    first = kerning["first"].to_i
    second = kerning["second"].to_i
    amount = kerning["amount"].to_i
    @desc.chars[second].kerning[first] = amount
  end
  def parse_font
    # 라인을 하나씩 읽습니다.
    @file.each_with_index do |line, index|
      # 라인을 공백을 기준으로 자릅니다.
      stream = line.split
      # 타입을 구합니다 (common, page, chars, char 등)
      type = stream.shift
      case type
      when "common"        
        parse_common(stream)
      when "page"
        parse_page(stream)
      when "char"
        parse_char(stream)
      when "kerning"
        parse_kernings(stream)
      end
    end
    
    @desc.ready = true
    @desc.texture_ready = true if @texture.size > 0
        
  end
  def remove
    return if not @texture
    @texture.each do |bitmap| 
      bitmap.dispose
    end
  end
  def draw_text(x, y, tw, th, text, &block)
    base = @desc.base
    line_height = @desc.line_height
    width = @desc.width
    height = @desc.height
    cursor_x = x
    cursor_y = y
    prev_cursor_x = 0
    line_width = [0]
    
    bitmap = Bitmap.new(tw, th)
    
    scale = @size / line_height.to_f
    
    prev_code = 0
    
    return if not @desc.texture_ready
    
    text.split("").each_with_index do |c, index|
      
      # ID 값을 구합니다. 
      id = c.unpack('U*')[0]
      
      # 한글 또는 영어 범위인지 확인합니다.
      if (id >= 32 and id <= 255) || (id >= 0xAC00 and id <= 0xD7A3)
        desc = @desc.chars[id]
        
        next if not desc
        
        cx = desc.x
        cy = desc.y
        cw = desc.width
        ch = desc.height
        ox = desc.xoffset * scale
        oy = desc.yoffset * scale
        page = desc.page
        
        src_bitmap = @texture[page]
        src_rect = Rect.new(cx, cy, cw, ch)
        dest_rect = Rect.new(cursor_x + ox, cursor_y + oy, cw * scale, ch * scale)
        bitmap.stretch_blt(dest_rect, src_bitmap, src_rect)
        
        if prev_code != 0 and desc.kerning[prev_code] and desc.kerning[prev_code] > 0
          cursor_x += desc.kerning[prev_code]
        end
        
        cursor_x += desc.xadvance * scale
        line_width << cursor_x
        prev_code = id
      else 
        # 이외의 문자 중 개행 문자가 있으면 처리합니다.
        if id == 10
          cursor_x = x
          cursor_y += line_height * scale
        end
        line_width << cursor_x
      end
    end
    
    data = {
      :x => x,
      :y => y,
      :bitmap => bitmap, 
      :cursor_x => cursor_x, 
      :cursor_y => cursor_y, 
      :src_rect => Rect.new(0, 0, width, height)
    }
    
    block.call(data) if block
    
    return line_width.max
    
  end
  def draw_text_ex(sprite, x, y, width, height, text)
    draw_text(x, y, width, height, text) do |i|
      sprite.bitmap.blt(i[:x], i[:y], i[:bitmap], i[:src_rect])
    end    
  end
end