#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
class ScrollBase < Sprite
  attr_accessor :min, :max, :action
  
  def initialize
    super
    init_members
    self.bitmap = Bitmap.new(256, 32 * 2)
  end
  
  def init_members
    @action = Proc.new { "not" }
    @min = 0
    @max = 0
  end  
  
  def update
    super
    draw_text
  end
        
  def dispose
    super
    if self.bitmap
      self.bitmap.clear
      self.bitmap.dispose
      self.bitmap = nil
    end
  end
  
  def draw_text
    self.bitmap.clear
    w = self.width || self.bitmap.width
    h = self.height || self.bitmap.height
    action = @action
    text = instance_eval(&action)
    self.bitmap.draw_text(0, 0, w, h, text, 0)
  end
  
end

class ScrollBar < ScrollBase
  def initialize
    super
  end
end

class ScrollBarThumb < Sprite
  def initialize
    super
    create_base_bitmap
    create_background
    create_up_arrow
    create_down_arrow
  end
  def init_members
    @virtual_height = 0
  end
  def dispose
    super
    if self.bitmap
      self.bitmap.clear
      self.bitmap.dispose
      self.bitmap = nil
    end
    if @up_arrow
      @up_arrow.bitmap.dispose
      @up_arrow.dispose
    end
    if @down_arrow
      @down_arrow.bitmap.dispose
      @down_arrow.dispose
    end    
  end
  
  def background_color
    d = 2 ** 5
    Color.new(d, d, d, 255)
  end
  
  def normal_color
    d = 2 ** 7
    Color.new(d, d, d, 255)
  end
  
  def arrow_color
    d = -1 + 2 ** 8
    Color.new(d, d, d, 255)
  end
  
  def create_base_bitmap
    self.bitmap = Bitmap.new(12, 32)
    self.bitmap.fill_rect(0, 0, 12, 32, normal_color)
  end
  def height
    @virtual_height
  end
  def height=(value)
    @virtual_height = value
    self.bitmap = Bitmap.new(12, value)
    self.bitmap.fill_rect(0, 0, 12, value, normal_color)
  end
  
  def create_background
    @background = Sprite.new
    bitmap = Bitmap.new(15, Graphics.height)
    @background.bitmap = bitmap
    color = background_color
    @background.bitmap.fill_rect(0, 0, bitmap.width, bitmap.height, color)
  end  
  
  def create_up_arrow
    @up_arrow = Sprite.new
    @up_arrow.bitmap = Bitmap.new(12, 12)
    
    gray = arrow_color
    bitmap = Bitmap.new(1, 3)
    bitmap.fill_rect(0, 0, 1, 3, gray)
    
    h = @up_arrow.bitmap.height / 2
        
    @up_arrow.bitmap.blt(0, h - 0, bitmap, bitmap.rect, 255)
    @up_arrow.bitmap.blt(1, h - 1, bitmap, bitmap.rect, 255)
    @up_arrow.bitmap.blt(2, h - 2, bitmap, bitmap.rect, 255)
    @up_arrow.bitmap.blt(3, h - 3, bitmap, bitmap.rect, 255)
    @up_arrow.bitmap.blt(4, h - 2, bitmap, bitmap.rect, 255)
    @up_arrow.bitmap.blt(5, h - 1, bitmap, bitmap.rect, 255)
    @up_arrow.bitmap.blt(6, h - 0, bitmap, bitmap.rect, 255)
    
  end
    
  def create_down_arrow
    @down_arrow = Sprite.new
    @down_arrow.bitmap = Bitmap.new(12, 12)
    
    gray = Color.new(255, 255, 255, 255)
    bitmap = Bitmap.new(1, 3)
    bitmap.fill_rect(0, 0, 1, 3, gray)
    
    h = @down_arrow.bitmap.height / 2
    
    @down_arrow.bitmap.blt(0, h + 0, bitmap, bitmap.rect, 255)
    @down_arrow.bitmap.blt(1, h + 1, bitmap, bitmap.rect, 255)
    @down_arrow.bitmap.blt(2, h + 2, bitmap, bitmap.rect, 255)
    @down_arrow.bitmap.blt(3, h + 3, bitmap, bitmap.rect, 255)
    @down_arrow.bitmap.blt(4, h + 2, bitmap, bitmap.rect, 255)
    @down_arrow.bitmap.blt(5, h + 1, bitmap, bitmap.rect, 255)
    @down_arrow.bitmap.blt(6, h + 0, bitmap, bitmap.rect, 255)
    
  end    
  def update
    super
    
    @background.x = self.x    
    @background.y = 0
    @background.z = self.z - 1
    
    @up_arrow.x = self.x
    @up_arrow.y = 0
    @up_arrow.z = self.z + 2
    
    @down_arrow.x = self.x
    @down_arrow.y = Graphics.height - 12
    @down_arrow.z = self.z + 2
  end
end

