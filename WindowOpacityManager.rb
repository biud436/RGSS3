#==============================================================================
# ** WindowManager
# Desc    : This script allows you to adjust the transparency for main program.
# Author  : biud436
# Usage :
# You should add a new script above the section called '(Insert Here)' by
# copying script itself. You can add an new script command and try below code.
#
# WindowManager.alpha = x
#
# 'x' is a number between 0 and 255.
# If its value is close to with 255, it will absolutely set as an opaque.
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_WindowManager"] = true

module WindowManager

  FindWindow = Win32API.new('User32','FindWindow',['P','P'],'L')
  HWND = FindWindow.call('RGSS Player', 0)
  GetWindowLong = Win32API.new('User32', 'GetWindowLong', ['L','L'],'L')
  SetWindowLong = Win32API.new("User32", 'SetWindowLong', ['L','L','L'],'L')
  ShowWindow = Win32API.new('User32','ShowWindow',['L','L'],'L')
  SetLayered = Win32API.new('User32', 'SetLayeredWindowAttributes', ['L','L','L','L'],'L')

  GWL_EXSTYLE = -20
  LWA_ALPHA = 0x00000002
  WS_EX_LAYERED = 0x00080000

  def self.alpha=(args)
    begin
      if args.to_i.between?(0,255)
        SetWindowLong.call(HWND,GWL_EXSTYLE,GetWindowLong.call(0,GWL_EXSTYLE) | WS_EX_LAYERED)
        SetLayered.call(HWND,0,args,LWA_ALPHA);
        ShowWindow.call(HWND,5)
      end
    rescue
    end
  end

end
