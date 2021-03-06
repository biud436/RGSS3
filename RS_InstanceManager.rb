#================================================================
# The MIT License
# Copyright (c) 2020 biud436
# ---------------------------------------------------------------
# Free for commercial and non commercial use.
#================================================================
#==============================================================================
# ** Terms of Use
#==============================================================================
# Free for commercial and non-commercial use
#==============================================================================

$imported = {} if $imported.nil?
$imported["RS_InstanceManager"] = true

module InstanceManager
  CreateMutex = Win32API.new('Kernel32','CreateMutex','llp','l')
  GetLastError = Win32API.new('Kernel32','GetLastError','v','l')
  HMUTEX = CreateMutex.call(0,1,"BARISTAR")
  GetLastError.call == 183? Kernel.exit : ""
end
