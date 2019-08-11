# ======================================================================
# Name : Anti-Aliasing Picture
# Author : biud436
# Desc :
# This script allows you to apply the anti-aliasing to your picture.
#
# Notice that this script must require below stuff.
#
# DirectX Implementation of RGSS3
# Link : https://forums.rpgmakerweb.com/index.php?threads/rgd-directx-implementation-of-rgss3.95228/
#
# ======================================================================

Graphics.add_shader("
texture my_tex;
sampler2D mySampler = sampler_state
{
    Texture = <my_tex>;
    AddressU = Wrap;
    AddressV = Wrap;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;       
};
PS_OUTPUT PS_AntiAliasing(float4 color : COLOR0,
  float2 tex : TEXCOORD0) : COLOR
{
  float4 res = tex2D(mySampler, tex);
  return GetOutput(res * color);
}", "
pass AntiAliasing
{
  AlphaBlendEnable = true;
  SeparateAlphaBlendEnable = false;
  BlendOp = MAX;
  SrcBlend = ONE;
  DestBlend = ONE;
  
  PixelShader = compile ps_2_0 PS_AntiAliasing();
}
")
class Sprite_Picture < Sprite
  alias iuiu_initialize initialize
  def initialize(viewport, picture)
    iuiu_initialize(viewport, picture)
    self.effect_name = "AntiAliasing"
  end
  def update_bitmap
    
    if @picture.name.empty?
      self.bitmap = nil
    else
      self.bitmap = Cache.picture(@picture.name)
      bitmap = Cache.picture(@picture.name)
      self.set_effect_param("my_tex", bitmap)
    end
  end  
end