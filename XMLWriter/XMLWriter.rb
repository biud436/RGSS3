# Author : biud436
# Date : 2019.06.18 (v1.0.0)
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