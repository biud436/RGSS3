# Disable Multiple Instance via mutex
module InstanceManager
  CreateMutex = Win32API.new('Kernel32','CreateMutex','llp','l')
  GetLastError = Win32API.new('Kernel32','GetLastError','v','l')
  HMUTEX = CreateMutex.call(0,1,"BARISTAR")
  GetLastError.call == 183? Kernel.exit : ""
end