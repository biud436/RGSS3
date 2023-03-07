#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# Name　     　: RTP Reader
# Author       : biud436 (https://blog.naver.com/biud436)
# Date         : 2015.01.18
# Ver          : 1.1
#
# RTP Name
# RTP::Read.short_name("face")
#
# File Path
# RTP.face
#
# BGM Random Play
# $game_map.random_bgm_play
#
# Search BGM Play
# $game_map.search_bgm_play("Scene")
#
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_RTPReader"] = true

module RTP
  FN_EXT = "*.{png,ogg,mp3}"
  HOME = ENV["CommonProgramFiles"].split("\\")
  SUB  = 'Enterbrain\RGSS3\RPGVXAce'.split("\\")
  LOAD = ->(_fix,_pre="Graphics"){
  Get_Path = File.join(*HOME,*SUB,_pre,_fix,FN_EXT)
  return Files = Dir.glob(Get_Path) + Dir.glob(File.join(_pre,_fix,FN_EXT)) }
  extend self
  #--------------------------------------------------------------------------
  # * Methods
  #--------------------------------------------------------------------------
  def animation;      LOAD.("Animations") end
  def battleback1;    LOAD.("Battlebacks1") end
  def battleback2;    LOAD.("Battlebacks2") end
  def battler;        LOAD.("Battlers") end
  def character;      LOAD.("Characters") end
  def face;           LOAD.("Faces") end
  def parallax;       LOAD.("Parallaxes") end
  def system;         LOAD.("System") end
  def tileset;        LOAD.("Tilesets") end
  def title1;         LOAD.("Titles1") end
  def title2;         LOAD.("Titles2") end
  def bgm;            LOAD.("BGM","Audio") end
  def bgs;            LOAD.("BGS","Audio") end
  def me;            LOAD.("ME","Audio") end
  def se;            LOAD.("SE","Audio") end
end
  #--------------------------------------------------------------------------
  # * Read RTP
  #--------------------------------------------------------------------------
module RTP::Read
  extend self
  def short_name(string)
    RTP.method(string).call.map {|i| File.basename(i,File.extname(i))}
  end
end
  #--------------------------------------------------------------------------
  # * BGM Random Play
  #--------------------------------------------------------------------------
class Game_Map
  def random_bgm_play
    set_bgm = RTP::Read.short_name("bgm")
    @map.bgm.name = set_bgm[rand(set_bgm.size)]
    @map.bgm.play
  end
  #--------------------------------------------------------------------------
  # * Search BGM Play
  #--------------------------------------------------------------------------
  def search_bgm_play(string)
    set_bgm = RTP::Read.short_name("bgm")
    set_bgm = set_bgm.select {|i| i =~ /#{string}[\d]/ }
    @map.bgm.name = set_bgm[rand(set_bgm.size)]
    @map.bgm.play unless @map.bgm.name.nil?
  end
  #--------------------------------------------------------------------------
  # * BGS Random Play
  #--------------------------------------------------------------------------
  def random_bgs_play
    set_bgs = RTP::Read.short_name("bgs")
    @map.bgs.name = set_bgs[rand(set_bgs.size)]
    @map.bgs.play
  end
  #--------------------------------------------------------------------------
  # * Search BGS Play
  #--------------------------------------------------------------------------
  def search_bgs_play(string)
    set_bgs = RTP::Read.short_name("bgs")
    set_bgs = set_bgs.select {|i| i.scan(/#{string}[\d]/) }
    @map.bgs.name = set_bgs[rand(set_bgs.size)]
    @map.bgs.play unless @map.bgs.name.nil?
  end
end
