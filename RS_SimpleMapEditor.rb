# ==============================================================================
# Author : biud436
# Desc : 
# 자바스크립트로 작성하면 시간이 오래 걸리므로 상대적으로 쉬운 루비를 선택하여 
# 프로토타이핑을 했습니다. 루비로 만든 초기 모델은 최종적으로 다른 언어로 변환됩니다.
#
# Usage :
# Ctrl + S를 누르면 Save 됩니다.
#
# Change Log : 
# 2019.06.18 (v1.0.0) :
# - XML 파일을 쓰고 읽는 기능을 추가하였습니다.
# 2019.06.19 (v1.0.1) :
# - 퍼포먼스 저하로 인해 텍스트 레이어 제거
# - 타일 배치 시 TouchInput.trigger?에서 TouchInput.press?로 변경
# - 타일뷰에 스크롤 기능 추가
# - 타일 최대치 50에서 100으로 변경.

module MapEidtorConfig
  # Setting the view section on the screen.
  VIEW = {}
  
  ww = (Graphics.width / 3).floor + (Graphics.width / 7).floor
  
  # 저장할 XML 파일명
  SAVE_XML_NAME = "MapEditorTest.xml"
  
  # 타일셋 명
  TILES = "Outside_A5"
  
  # 타일 크기
  TW = 32
  TH = 32
  
  # 뷰 크기
  VIEW[:LEFT] = Rect.new(0, 0, Graphics.width - ww, Graphics.height)
  VIEW[:RIGHT] = Rect.new(VIEW[:LEFT].width, 0, ww, Graphics.height)
end

# A class that manages children for many of sprites.
class Children
  attr_reader :children
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

class TileComponent < Component
  def update
    
    Sprite.instance_method(:update).bind(self).call
    
    # Check collision with mouse pointer.
    tx = TouchInput.x
    ty = TouchInput.y
    x = self.x
    y = self.y
    width = self.width
    height = self.height
      
    # if it is inside, it will execute callback method that specified contents before.
    if TouchInput.press?(:LEFT)
      if (tx > x and tx < x + width) and (ty > y and ty < (y + height))
        do_clicked_callback
      end
    end
    
  end  
    
  def do_clicked_callback
    if @clicked_callback
      @clicked_callback.call(self) 
    end
  end    
end

# 선택 툴을 그린다
class SelectTool < Sprite
  def initialize(viewport=nil)
    super(viewport)
    create_bitmap
  end
  def create_bitmap
    self.bitmap = Bitmap.new(MapEidtorConfig::TW, MapEidtorConfig::TH)
    
    border = 2
    
    c = Color.new(255, 255, 255, 255)
    b = Color.new(0, 0, 0, 255)
    
    tw = MapEidtorConfig::TW
    th = MapEidtorConfig::TH
    
    # 위
    self.bitmap.fill_rect(0, 0, tw, border, b)
    self.bitmap.fill_rect(0, 0, tw - 1, border - 1, c)    
    # 왼
    self.bitmap.fill_rect(0, 0, border, th, c)
    self.bitmap.fill_rect(1, 1, border - 1, th - 1, b)
    # 오른쪽
    self.bitmap.fill_rect(tw - border, 0, border, th, c)
    self.bitmap.fill_rect(tw - border + 1, 1, border - 1, th - 1, b)
    # 아래
    self.bitmap.fill_rect(0, th - border, tw, border, c)
    self.bitmap.fill_rect(1, th - border + 1, tw - 1, border - 1, b)
    
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
  
  # 저장할 수 있는 타일 최대치
  MAX_SIZE = 100
  
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
    RSSaveXmlDoc.call(xml_doc, MapEidtorConfig::SAVE_XML_NAME)
    
    # 메모리 해제
    RSRemoveXmlDoc.call(xml_doc)
    
  end
  
  def self.read_test
    
    # DOC 생성
    xml_doc = RSNewXmlDoc.call    
    
    if RSLoadXmlFile.call(xml_doc, MapEidtorConfig::SAVE_XML_NAME) == -1
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
    
    # 뷰 생성
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
    
    @index = 0
    
    @saved_time = 0
    
    on_load
    
    on_component(MapEidtorConfig::VIEW[:RIGHT])
    
  end
  
  def update
    
    # Update all children
    @children.update
    
    # if the mouse button is pressed as left button?
    if TouchInput.press?(:LEFT)
      l = MapEidtorConfig::VIEW[:LEFT]
      tx = TouchInput.x
      ty = TouchInput.y
      if (tx >= l.x and tx < l.width) and (ty >= l.y and ty < l.height)
        dx = (tx / MapEidtorConfig::TW).floor * MapEidtorConfig::TW
        dy = (ty / MapEidtorConfig::TH).floor * MapEidtorConfig::TH
        on_draw(dx, dy)
      end
    end
    
    # 오른쪽 타일셋 뷰에서 마우스 휠을 위로 스크롤 했을 때
    if TouchInput.z < 0
      @components.children.each do |i|
        i.y -= 16
      end
      @select_tool.y -= 16
    end
    
    # 오른쪽 타일셋 뷰에서 마우스 휠을 아래로 스크롤 했을 때
    if TouchInput.z > 0
      @components.children.each do |i|
        i.y += 16
      end
      @select_tool.y += 16 
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
    
    src_bitmap = Cache.tileset(MapEidtorConfig::TILES)
    
    tw = MapEidtorConfig::TW
    th = MapEidtorConfig::TH
    
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
    rr = MapEidtorConfig::VIEW[:RIGHT]
    w = MapEidtorConfig::TW
    h = MapEidtorConfig::TH
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
    
    src_bitmap = Cache.tileset(MapEidtorConfig::TILES)
    l = MapEidtorConfig::VIEW[:RIGHT]
    tw = MapEidtorConfig::TW
    th = MapEidtorConfig::TH
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
    
    if not FileTest.exist?(MapEidtorConfig::SAVE_XML_NAME) 
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