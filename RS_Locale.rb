#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
# Author : biud436 
# Date : 2019.05.12
# Usage : 
#   Font.default_name = if Locale.check?('ko-KR')
#     ["나눔고딕", "VL Gothic"]
#   elsif Locale.check?('ja-JP')
#     ["Meiryo", "VL Gothic"]
#   else
#     ["VL Gothic"]
#   end
$imported = {} if $imported.nil?
$imported["RS_Locale"] = true
module Locale
  GetUserDefaultLCID = Win32API.new('Kernel32', 'GetSystemDefaultUILanguage', 'v', 'l')
  GetUserDefaultLocaleName = Win32API.new('Kernel32', 'GetUserDefaultLocaleName', 'pl', 'l')
  
  @@locale = ""
  c = "\0" * 255
  GetUserDefaultLocaleName.call(c, 255)
  @@locale = c.delete("\0")
  
  def self.check?(locale)
    @@locale.include?(locale)
  end
  
  def self.get
    @@locale
  end
  
end

