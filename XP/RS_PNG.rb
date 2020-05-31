#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
module PNG
  COLOR_TYPE = {
    :GRAY_SCALE => "그레이 스케일",
    :TRUE_COLOR => "트루 컬러",
    :INDEXED_COLOR => "인덱시드 컬러",
    :GRAY_SCALE_WITH_ALPHA => "그레이 스케일 (알파 포함)",
    :TRUE_COLOR_WITH_ALPHA => "트루 컬러 (알파 포함)",
  }
end

##
# 이 클래스는 PNG 이미지의 폭과 높이를 구할 때 사용합니다.
# 
# @author 러닝은빛(biud436)
#
# image = PNG::Magic.new("./Graphics/Faces/Actor1-1.png")
# p image.size
# p image.bit_depth
# p image.color_type
# 
# 주석은 yardoc 용으로 작성되었습니다 (jsdoc와 비슷)
# https://rubydoc.info/gems/yard/file/docs/GettingStarted.md
#  
class PNG::Magic < RS::Size
  include PNG
          
  attr_accessor :bit_depth, :width, :height
  
  #
  # 상위 버전에선 더 짧게 코딩할 수 있습니다.
  #
  #   IO.binread(path, 100)[0x10..0x14].unpack('N')[0]
  #
  # 다음 코드는 Ruby 1.8.2에서 돌아갈 수 있게 변환된 코드입니다.
  #
  # @param path [String] 
  def initialize(path)
    f = File.open(path, 'rb')
    
    # ---- 파일 시그니처 ----
    @signature = f.read(8)
    
    # ---- IHDR 청크 ----
    length = f.read(4).unpack('c4')[3]
    @ihdr = f.read(4)
    @width = f.read(4).unpack('N')[0]
    @height = f.read(4).unpack('N')[0]
    @bit_depth = f.read(1).unpack('C')[0]
    @color_type = f.read(1).unpack('C')[0] 
    @compression_method = f.read(1).unpack('C')[0] 
    @filter_method = f.read(1).unpack('C')[0] 
    @interlace_method = f.read(1).unpack('C')[0] 
    @crc = f.read(4).unpack('N')[0] 
    
    # 체크섬(CRC) 계산
    f.pos = 0
    f.read(12)
    data = f.read(4 * 3 + 5)
    
    p "#{f.path}의 crc가 일치함" if Zlib.crc32(data) == @crc
    
    # ---- PLTE 청크 ----
    # ---- IDAT 청크 ----
    # ---- IEND 청크 (IEND + CRC) ----
    
    f.close
    
  end
  
  #
  # 컬러 타입을 구합니다
  # 결과는 한국어 문자열로 반환됩니다.
  # @return [String]
  def color_type
    type = case @color_type
    when 0
      :GRAY_SCALE
    when 2
      :TRUE_COLOR
    when 3
      :INDEXED_COLOR
    when 4
      :GRAY_SCALE_WITH_ALPHA
    when 6
      :TRUE_COLOR_WITH_ALPHA
    end
    
    return COLOR_TYPE[type]
  end
  
  #
  # 이미지의 크기를 구합니다
  # @return [Array<Numeric, Numeric>]
  def size
    return @width, @height
  end
  
end