require 'json'

exit if defined? Ocra

OPT = false

args = ARGV

mode = args[0] || "\f"

# ext /f "{:a => 1, :b => 2}" output.json
# ext /r output.json

case mode
when "/f"
  target = eval(args[1]).pack("U*") || "{:a => 1, :b => 2}"
  target_hash = eval(target)
  filename = args[2] || "output.json"
  data = JSON.pretty_generate(target_hash)
  f = File.open(filename, "w+")
  f.puts data
  f.close
when '/r'
  filename = args[1] || "output.json"
  f = File.open(filename, "r+")
  data = f.read
  f.close
  
  ret_hash = JSON.parse(data)
  p ret_hash.to_s.unpack("U*")
  
end