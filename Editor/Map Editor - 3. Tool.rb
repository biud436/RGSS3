#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
class MapEditor
  
  def initialize
    
    create_base_view
    
    flush_all_view
        
    # Create children
    create_children
        
    # 타일 선택 창 생성
    create_component
  
    # 멤버 초기화
    init_members
    
    on_load
    
    on_component(MapEditorConfig::VIEW[:RIGHT])
    
  end
  
  def create_base_view
    @map_view = create_image(MapEditorConfig::VIEW[:LEFT])
    @right_view = create_image(MapEditorConfig::VIEW[:RIGHT])    
  end
  
  def create_children
    @children = Children.new    
    @components = Children.new
    @tiles = Children.new
    @select_tool = SelectTool.new    
    @tile_select_tool = SelectTool.new    
    
    create_scroll_bar
    
    @children << @map_view
    @children << @right_view
    @children << @components
    @children << @tiles
    @children << @select_tool     
    @children << @tile_select_tool
    @children << @scroll_bar
    @children << @scale_y
    @children << @scroll_bar_thumb    
  end
  
  def create_scroll_bar
    
    @scroll_bar = ScrollBar.new
    @scroll_bar.z = 500
    
    @scale_y = ScrollBase.new
    @scale_y.y = 32
    @scale_y.z = 501
    
    @scroll_bar_thumb = ScrollBarThumb.new    
    @scroll_bar_thumb.x = Graphics.width - 8
    @scroll_bar_thumb.z = 502
    
  end  

  def update
        
    # Update all children
    @children.update
    
    # 왼쪽 마우스 버튼을 누르고 있을 때
    if TouchInput.press?(:LEFT)
      l = MapEditorConfig::VIEW[:LEFT]
      tx = TouchInput.x
      ty = TouchInput.y
      if (tx >= l.x and tx < l.width) and (ty >= l.y and ty < l.height)
        dx = (tx / MapEditorConfig::TW).floor * MapEditorConfig::TW
        dy = (ty / MapEditorConfig::TH).floor * MapEditorConfig::TH
        on_draw(dx, dy)
      end
    end
    
    # 스크롤바의 최소 Y 값과 최대 Y 값을 계산한다
    @scroll_bar.min = @components.children.min {|a, b| a.y <=> b.y }.y
    @scroll_bar.max = @components.children.max {|a, b| a.y <=> b.y }.y 
    
    # 스크롤 속도
    scr_speed = MapEditorConfig::SCROLL_SPEED
            
    # 오른쪽 타일셋 뷰에서 마우스 휠을 아래로 스크롤 했을 때
    if TouchInput.z < 0 && (@scroll_y.abs - scr_speed) < @scroll_bar.max
      @components.children.each do |i|
        i.y -= scr_speed
      end
      @select_tool.y -= scr_speed
      @scroll_y += scr_speed
    end
    
    # 오른쪽 타일셋 뷰에서 마우스 휠을 위로 스크롤 했을 때
    if TouchInput.z > 0 && @scroll_y.abs > 0
      @components.children.each do |i|
        i.y += scr_speed
      end
      @select_tool.y += scr_speed
      @scroll_y -= scr_speed
    end        
        
    # 디버그 텍스트 바인딩
    @scroll_bar.action = Proc.new do 
      sprintf("min / max : %d / %d", @min, @max - @min)
    end
    
    document_view_height = @scroll_bar.max - @scroll_bar.min
    current_view_y = document_view_height - @scroll_y
    
    # 현재 뷰의 Y 값
    # 누적된 스크롤 바의 Y값과 동일하다.
    current_view_y = @scroll_y.abs
    
    scroll_bar_y_height = Graphics.height
    
    # 스크롤바는 일정 비율로 축소된 모양이므로 나눗셈을 통해 축소 비율을 구할 수 있다.
    scale_y = document_view_height / scroll_bar_y_height.to_f
    @scale_y.action = Proc.new do 
      sprintf("Scale Y : %f", scale_y)
    end
            
    @scroll_bar_thumb.height = (Graphics.height / scale_y)
    ny = current_view_y / scale_y
    
    if ny < (document_view_height / scale_y)
      @scroll_bar_thumb.y = 12 + ny
    end        
    
    saved = false
    
    # CTRL + S 버튼을 눌렀을 때 저장
    if Input.press?(:VK_LCONTROL)
      if Input.press?('S')
        @saved_time += 1
      end
    end
    
    if @saved_time > 10
      saved = true
    end
    
    if saved
      @saved_time = 0
      on_save
    end
    
  end
  
  def dispose
    # Dispose all children
    @children.dispose
  end
      
  def init_members
    @index = 0
    @scroll_y = 0
    @saved_time = 0    
  end
  
  def flush_all_view
    # Getting the rect
    lr = MapEditorConfig::VIEW[:LEFT]
    rr = MapEditorConfig::VIEW[:RIGHT]
    
    # Fill both rects
    @map_view.bitmap.fill_rect(0, 0, lr.width, lr.height, Color.new(10, 10, 10, 255))
    @right_view.bitmap.fill_rect(0, 0, rr.width, rr.height, Color.new(0, 0, 0, 255))    
  end  
  
  def create_image(rect)
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(rect.width, rect.height)
    sprite.x = rect.x
    sprite.y = rect.y
    sprite
  end  
    
  def create_component
    
    rr = MapEditorConfig::VIEW[:RIGHT]
    
    src_bitmap = Cache.tileset(MapEditorConfig::TILES)
    
    tw = MapEditorConfig::TW
    th = MapEditorConfig::TH
    
    for y in (0...32)
      for x in (0...8)
        
        # Create a rect
        rect = Rect.new(0,0,tw,th)
        rect.x = rr.x + (x * rect.width)
        rect.y = rr.y + (y * rect.height)
        
        # Create a bitmap
        bitmap = Bitmap.new(rect.width, rect.height)
        
        # Create a new component
        new_component = Component.new(bitmap)
        new_component.x = rect.x
        new_component.y = rect.y
        
        # Set the tile area 
        dest_rect = Rect.new(0,0,rect.width, rect.height)
        src_rect = Rect.new(x * tw, y * th,tw,th)
        
        new_component.bitmap.stretch_blt(dest_rect, src_bitmap, src_rect)
        
        new_component.set_clicked_callback(method(:on_component))        
        @components << new_component        
        
      end
    end
    
  end
  
  def on_component(event)
    rr = MapEditorConfig::VIEW[:RIGHT]
    w = MapEditorConfig::TW
    h = MapEditorConfig::TH
    my = rr.y
    if @components.children[0].y < my
      my = @components.children[0].y
    end
      
    mx = (event.x - rr.x) / w
    my = (event.y - my) / h
    
    @index = (my * 8) + mx
    
    @select_tool.x = event.x
    @select_tool.y = event.y
    
  end
  
  def on_clicked_tile(event)
    @tile_select_tool.x = event.x
    @tile_select_tool.y = event.y
  end
  
  def on_draw(dx, dy, index = @index, is_on_load=false)
  
    x = index % 8
    y = index/ 8
    
    src_bitmap = Cache.tileset(MapEditorConfig::TILES)
    l = MapEditorConfig::VIEW[:RIGHT]
    tw = MapEditorConfig::TW
    th = MapEditorConfig::TH
    rect = Rect.new(0,0,tw,th)
    rect.x = dx
    rect.y = dy
    
    bitmap = Bitmap.new(rect.width, rect.height)
    
    # Create a new component
    new_component = TileComponent.new(bitmap)
    new_component.x = rect.x
    new_component.y = rect.y
    new_component.z = @map_view.z + 1
    
    # Set the tile area 
    dest_rect = Rect.new(0, 0, rect.width, rect.height)
    src_rect = Rect.new(x * tw, y * th, tw, th)
    
    new_component.bitmap.stretch_blt(dest_rect, src_bitmap, src_rect)
    
    new_component.set_clicked_callback(method(:on_clicked_tile))   
    
    @tiles[(dy * tw) + dx] = new_component
    
    if not is_on_load
      new_array = [dx, dy, @index]
      @tile_buffers << new_array
      @tile_buffers.uniq!
    end
    
  end
  
  def on_save

    XMLWriter.write_test(@tile_buffers)
    
    p "데이터가 저장되었습니다"
    
  end
  
  def on_load
    @tile_buffers = []    
    
    if not FileTest.exist?(MapEditorConfig::SAVE_XML_NAME) 
      return false 
    end

    @tile_buffers = XMLWriter.read_test

    return false if @tile_buffers.nil?
    
    last_tile = nil
    
    @tile_buffers.each do |tile|
      on_draw(*tile, true)
      last_tile = tile
    end
    
    if last_tile
      dx, dy, index = *last_tile
      @tile_select_tool.x = dx
      @tile_select_tool.y = dy
    end
    
    p "데이터가 로드되었습니다"
    
  end  
end