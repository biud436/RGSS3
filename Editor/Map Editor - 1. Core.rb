#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
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

module MapEditorConfig
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
  
  # 스크롤 속도
  SCROLL_SPEED = 32
  
  # 뷰 크기
  VIEW[:LEFT] = Rect.new(0, 0, Graphics.width - ww, Graphics.height)
  VIEW[:RIGHT] = Rect.new(VIEW[:LEFT].width, 0, ww, Graphics.height)
  
end

%Q(
<MapEditorConfig>
  <VIEW>
    <LEFT>
      <Rect x="0" y="0" width="Graphics.width - ww" height="Graphics.height" />
    </LEFT>
    <RIGHT>
      <Rect x="0" y="0" width="Graphics.width - ww" height="Graphics.height" />
    </RIGHT>    
  </VIEW>
</MapEditorConfig>
)

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
    RSSaveXmlDoc.call(xml_doc, MapEditorConfig::SAVE_XML_NAME)
    
    # 메모리 해제
    RSRemoveXmlDoc.call(xml_doc)
    
  end
  
  def self.read_test
    
    # DOC 생성
    xml_doc = RSNewXmlDoc.call    
    
    if RSLoadXmlFile.call(xml_doc, MapEditorConfig::SAVE_XML_NAME) == -1
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
    self.bitmap = Bitmap.new(MapEditorConfig::TW, MapEditorConfig::TH)
    
    border = 2
    
    c = Color.new(255, 255, 255, 255)
    b = Color.new(0, 0, 0, 255)
    
    tw = MapEditorConfig::TW
    th = MapEditorConfig::TH
    
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