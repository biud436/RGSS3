# Author : biud436
# 자바스크립트로 작성하면 시간이 오래 걸리므로 상대적으로 쉬운 루비를 선택하여 프로토타이핑을 했습니다.
# 루비로 만든 초기 모델은 최종적으로 다른 언어로 변환됩니다.
# Date : 
# 2019.06.18 (v1.0.0) :
# - XML 파일을 쓰고 읽는 기능을 추가하였습니다.

module MapEidtorConfig
  # Setting the view section on the screen.
  VIEW = {}
  
  ww = (Graphics.width / 3).floor + (Graphics.width / 7).floor
  
  VIEW[:LEFT] = Rect.new(0, 0, Graphics.width - ww, Graphics.height)
  VIEW[:RIGHT] = Rect.new(VIEW[:LEFT].width, 0, ww, Graphics.height)
end

# A class that manages children for many of sprites.
class Children
  def initialize
    @children = []
  end
  def add_child(child)
    @children.push(child)
  end
  def remove_child(child)
    @children.delete(child)
  end
  def update
    @children.each do |child|
      child.update if child
    end
  end
  def dispose
    @children.each do |child|
      child.dispose if child
    end    
  end
  def <<(child)
    add_child(child)
  end
  def []=(index, child)
    @children[index] = child
  end
end

# A component that executes the contents like as button.
class Component < Sprite
  def initialize(bitmap)
    super(nil)
    self.bitmap = bitmap
    @clicked = false
    @clicked_callback = nil
  end
  def update
    super
    
    # Check collision with mouse pointer.
    tx = TouchInput.x
    ty = TouchInput.y
    x = self.x
    y = self.y
    width = self.width
    height = self.height
      
    # if it is inside, it will execute callback method that specified contents before.
      if TouchInput.trigger?(:LEFT)
        if (tx > x and tx < x + width) and (ty > y and ty < (y + height))
          @clicked = true          
          do_clicked_callback
          @clicked = false
        end
      end
    
    end
    
  def dispose
    super
  end
  
  def set_clicked_callback(method)
    @clicked_callback = method
  end
  
  def do_clicked_callback
    @clicked_callback.call(self) if @clicked_callback and @clicked
  end

end

# 선택 툴을 그린다
class SelectTool < Sprite
  def initialize(viewport=nil)
    super(viewport)
    create_bitmap
  end
  def create_bitmap
    self.bitmap = Bitmap.new(32, 32)
    
    border = 2
    
    c = Color.new(255, 255, 255, 255)
    b = Color.new(0, 0, 0, 255)
    
    # 위
    self.bitmap.fill_rect(0, 0, 32, border, b)
    self.bitmap.fill_rect(0, 0, 32 - 1, border - 1, c)    
    # 왼
    self.bitmap.fill_rect(0, 0, border, 32, c)
    self.bitmap.fill_rect(1, 1, border - 1, 32 - 1, b)
    # 오른쪽
    self.bitmap.fill_rect(32 - border, 0, border, 32, c)
    self.bitmap.fill_rect(32 - border + 1, 1, border - 1, 32 - 1, b)
    # 아래
    self.bitmap.fill_rect(0, 32 - border, 32, border, c)
    self.bitmap.fill_rect(1, 32 - border + 1, 32 - 1, border - 1, b)
    
    self.z = 210
    
  end
end

module XMLWriter
  RSCreateDoc = Win32API.new('XMLWriter.dll', 'RSCreateDoc', 'p', 'l')
  
  RSNewXmlDoc = Win32API.new('XMLWriter.dll', 'RSNewXmlDoc', 'v', 'l')
  RSSaveXmlDoc = Win32API.new('XMLWriter.dll', 'RSSaveXmlDoc', 'lp', 'l')  
  RSRemoveXmlDoc = Win32API.new('XMLWriter.dll', 'RSRemoveXmlDoc', 'l', 'l')
  RSCreateXmlElement = Win32API.new('XMLWriter.dll', 'RSCreateXmlElement', 'p', 'l')
  
  RSLinkEndChildFromDoc = Win32API.new('XMLWriter.dll', 'RSLinkEndChildFromDoc', 'll', 'v')
  RSLinkEndChild = Win32API.new('XMLWriter.dll', 'RSLinkEndChild', 'll', 'v')
  RSSetAttribute = Win32API.new('XMLWriter.dll', 'RSSetAttribute', 'llll', 'v')
  
  RSLoadXmlFile = Win32API.new('XMLWriter.dll', 'RSLoadXmlFile', 'lp', 'l')
  RSGetRootElement = Win32API.new('XMLWriter.dll', 'RSGetRootElement', 'l', 'l')
  RSGetTileIds = Win32API.new('XMLWriter.dll', 'RSGetTileIds', 'lp', 'l')
  
  MAX_SIZE = 50
  
  def self.write_test(buffers)
    
    # DOC 생성
    xml_doc = RSNewXmlDoc.call
    
    # 루트 노드 생성
    xml_root = RSCreateXmlElement.call("MapEditor")
    
    # 루트 노드 삽입
    RSLinkEndChildFromDoc.call(xml_doc, xml_root)
    
    buffers.each do |buf|
      
      # 자식 노드 생성
      xml_element = RSCreateXmlElement.call("TileIds")
      
      # 자식 노드에 타일 ID 설정
      RSSetAttribute.call(xml_element, *buf)
      
      # 루트 노드에 자식 노드 삽입
      RSLinkEndChild.call(xml_root, xml_element)
            
    end
    
    # 저장
    RSSaveXmlDoc.call(xml_doc, "MapEidtorTest.xml")
    
    # 메모리 해제
    RSRemoveXmlDoc.call(xml_doc)
    
  end
  
  def self.read_test
    
    # DOC 생성
    xml_doc = RSNewXmlDoc.call    
    
    if RSLoadXmlFile.call(xml_doc, "MapEidtorTest.xml") == -1
      p "XML 파일 로드에 실패했습니다"
      return false
    end
    
    # 루트 노트 
    xml_root = RSGetRootElement.call(xml_doc)
    
    ids_struct = ([0,0,0] * MAX_SIZE).pack('l*')
    
    RSGetTileIds.call(xml_root, ids_struct)
    
    ids = ids_struct.unpack('l*')
    
    # 메모리 해제
    RSRemoveXmlDoc.call(xml_doc)    
    
    ret = ids.each_slice(3).to_a
    ret.delete([0,0,0])
    ret
    
  end
  
end

class MapEditor
  
  def initialize
    
    # Create both views
    @map_view = create_image(MapEidtorConfig::VIEW[:LEFT])
    @right_view = create_image(MapEidtorConfig::VIEW[:RIGHT])
    
    # Getting the rect
    lr = MapEidtorConfig::VIEW[:LEFT]
    rr = MapEidtorConfig::VIEW[:RIGHT]
    
    # Fill both rects
    @map_view.bitmap.fill_rect(0, 0, lr.width, lr.height, Color.new(10, 10, 10, 255))
    @right_view.bitmap.fill_rect(0, 0, rr.width, rr.height, Color.new(0, 0, 0, 255))

    # Create children
    @children = Children.new
    @components = Children.new
    @tiles = Children.new
    @select_tool = SelectTool.new    
    @tile_select_tool = SelectTool.new
    
    @children << @map_view
    @children << @right_view
    @children << @components
    @children << @tiles
    @children << @select_tool     
    @children << @tile_select_tool
    
    create_component
    create_text_layer
    
    @index = 0
    
    @saved_time = 0
    
    on_load
    
    on_component(MapEidtorConfig::VIEW[:RIGHT])
    
  end
  
  def update
    # Update all children
    @children.update
    update_text_layer
    
    # if the mouse button is pressed as left button?
    if TouchInput.trigger?(:LEFT)
      l = MapEidtorConfig::VIEW[:LEFT]
      tx = TouchInput.x
      ty = TouchInput.y
      if (tx >= l.x and tx < l.width) and (ty >= l.y and ty < l.height)
        dx = (tx / 32).floor * 32
        dy = (ty / 32).floor * 32
        on_draw(dx, dy)
      end
    end
    
    saved = false
    
    # if the save button is pressed?
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
    dispose_text_layer
  end
  
  private
  
  def create_image(rect)
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(rect.width, rect.height)
    sprite.x = rect.x
    sprite.y = rect.y
    sprite
  end  
    
  def create_component
    
    rr = MapEidtorConfig::VIEW[:RIGHT]
    
    src_bitmap = Cache.tileset("Outside_A5")
    
    for y in (0...32)
      for x in (0...8)
        
        # Create a rect
        rect = Rect.new(0,0,32,32)
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
        src_rect = Rect.new(x * 32, y * 32,32,32)
        
        new_component.bitmap.stretch_blt(dest_rect, src_bitmap, src_rect)
        
        new_component.set_clicked_callback(method(:on_component))        
        @components << new_component        
        
      end
    end
    
  end
  
  def create_text_layer
    @text_layer = create_image(MapEidtorConfig::VIEW[:LEFT])
  end
  
  def update_text_layer
    return if not @text_layer
    rl = MapEidtorConfig::VIEW[:LEFT]
    texts = [
      "선택된 버튼은 #{@index}번 버튼입니다.",
      "데이터 저장은 CTRL + S 입니다"
    ]
    @text_layer.bitmap.clear
    texts.each_with_index do |text, i|
      rect = @text_layer.bitmap.text_size(text)      
      @text_layer.bitmap.draw_text(0, i * rect.height, rect.width, rect.height, text)
    end
  end
  
  def dispose_text_layer
    @text_layer.dispose if @text_layer
  end
  
  def on_component(event)
    rr = MapEidtorConfig::VIEW[:RIGHT]
    w = 32
    h = 32
    mx = (event.x - rr.x) / w
    my = (event.y - rr.y) / h
    
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
    y = index / 8
    
    src_bitmap = Cache.tileset("Outside_A5")
    l = MapEidtorConfig::VIEW[:RIGHT]
    rect = Rect.new(0,0,32,32)
    rect.x = dx
    rect.y = dy
    
    bitmap = Bitmap.new(rect.width, rect.height)
    
    # Create a new component
    new_component = Component.new(bitmap)
    new_component.x = rect.x
    new_component.y = rect.y
    new_component.z = @map_view.z + 1
    
    # Set the tile area 
    dest_rect = Rect.new(0, 0, rect.width, rect.height)
    src_rect = Rect.new(x * 32, y * 32, 32, 32)
    
    new_component.bitmap.stretch_blt(dest_rect, src_bitmap, src_rect)
    
    new_component.set_clicked_callback(method(:on_clicked_tile))   
    
    @tiles[(dy * 32) + dx] = new_component
    
    if not is_on_load
      @tile_buffers << [dx, dy, @index]
    end
    
  end
  
  def on_save

    XMLWriter.write_test(@tile_buffers)
    
    p "데이터가 저장되었습니다"
    
  end
  
  def on_load
    @tile_buffers = []    
    
    if not FileTest.exist?("MapEidtorTest.xml") 
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

class Scene_Tool < Scene_Base
  def start
    super
    @map_editor = MapEditor.new
  end
  def update
    super
    @map_editor.update
  end
  def terminate
    super
    @map_editor.terminate
  end
end

module SceneManager
  def self.first_scene_class
    $BTEST ? Scene_Battle : Scene_Tool
  end
end