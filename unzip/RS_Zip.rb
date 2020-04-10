# Author : biud436
# Desc :
# This script allows you to decompress certain zip file in the RGSS1, RGSS2, RGSS3
#
# Try this :
# Zip.extract("Initial2D.zip")
#
module Zip
  ExtractZip = Win32API.new("un_zip.dll", "extractZip", "p", "l")
  
  def self.extract(filename)
    filename = File.join(Dir.pwd, filename)
    return if not File::exist?(filename)
    ExtractZip.call(filename)    
  end

end