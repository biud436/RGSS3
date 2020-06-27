module Steam

    class IID
      attr_accessor :virtual_address, :size
    end
    
    class Header
      def initialize
        @data = []
      end
      def <<(value)
        @data << value
      end
      
      def name; @data[0] end
      def virtual_size; @data[1] end

      def virtual_address; @data[2] end
      def rva; @data[2] end

      def size_of_raw_data; @data[3] end
      def pointer_to_raw_data; @data[4] end
      def pointer_to_relocations; @data[5] end
      def pointer_to_linenumbers; @data[6] end
      def number_of_relocations; @data[7] end
      def number_of_linenumbers; @data[8] end
      def characteristics; @data[9] end   
      
      def rva_to_raw(rva)
        rva - virtual_address + pointer_to_raw_data
      end
      
    end

    class ImageExportDirectory
      def initialize
        @data = []
      end
      def <<(value)
        @data << value
      end

      def characteristics; @data[0] end
      def time_date_stamp; @data[1] end
      def major_version; @data[2] end
      def minor_version; @data[3] end
      def name; @data[4] end
      def base; @data[5] end
      def number_of_functions; @data[6] end
      def number_of_names; @data[7] end
      def address_of_functions; @data[8] end
      def address_of_names; @data[9] end
      def address_of_ordinals; @data[10] end
            
    end
  
    class Section
  
      def initialize(filename)
        @file = File.open(filename, "r")
        @pos = {
          :IMAGE_NT_HEADERS => 0
        }
        
        @section_headers = []
        @number_of_sections = 0
        @functions = []
      end
          
      def get_image_nt_header_pos
        f = @file
        
        stat = f.stat
        len = (stat.size / 16).floor
        pos = 0
        
        for i in (0..len)
          signature = f.read(16)[0, 2] rescue ""
          if signature == "PE"
            @pos[:IMAGE_NT_HEADERS] = i * 16
            break
          end
        end
        
        p f.pos = @pos[:IMAGE_NT_HEADERS]
        
      end
      
      def get_image_file_header_pos
        pos = @pos[:IMAGE_NT_HEADERS]
        pos += 4
        
        @pos[:IMAGE_FILE_HEADER] = pos
        
        @file.pos = pos + 2
        @number_of_sections = @file.read(2).unpack("s")[0]
        
        @file.pos = @pos[:IMAGE_FILE_HEADER]
        
      end    
      
      def get_image_optional_header_pos
        pos = @pos[:IMAGE_FILE_HEADER]
        pos += 20
        
        @pos[:IMAGE_OPTIONAL_HEADER] = pos
        @file.pos = @pos[:IMAGE_OPTIONAL_HEADER]
        
        magic = @file.read(2).unpack("S")[0]
        case magic
        when 0x10b
          p "magic : IMAGE_NT_OPTIONAL_HDR32_MAGIC"
        when 0x20b
          p "magic : IMAGE_NT_OPTIONAL_HDR64_MAGIC"
        end
              
        skip_pos = [1, 1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 4, 4, 4, 4, 4].inject(0, :+)
        
        @file.pos += skip_pos
        number_of_rva_and_sizes = @file.read(4).unpack("L")[0]
        
        pos = @file.pos
        max_pos = pos + (8 * number_of_rva_and_sizes)
        @image_data_directories = []
        
        while pos < max_pos
          iid = IID.new
          iid.virtual_address = @file.read(4).unpack("L")[0]
          iid.size = @file.read(4).unpack("L")[0]
          @image_data_directories.push(iid)
          pos += 8
        end
        
        @image_data_directories
        
      end
      
      def parse_image_section_headers
        pos = @file.pos
        size = 40
        max_size = pos + (size * @number_of_sections)
  
        while pos < max_size
          new_header = Header.new
          new_header << @file.read(8).delete("\0")
          new_header << @file.read(4).unpack("L")[0] rescue 0
          new_header << @file.read(4).unpack("L")[0] rescue 0
          new_header << @file.read(4).unpack("L")[0] rescue 0
          new_header << @file.read(4).unpack("L")[0] rescue 0
          new_header << @file.read(4).unpack("L")[0] rescue 0
          new_header << @file.read(4).unpack("L")[0] rescue 0
          new_header << @file.read(2).unpack("S")[0] rescue 0
          new_header << @file.read(2).unpack("S")[0] rescue 0
          new_header << @file.read(4).unpack("L")[0] rescue 0

          p "#{new_header.name} : #{new_header.rva.to_s 16}"
          @section_headers.push(new_header)

          pos += 40
        end
      end

      def rva_to_raw(rva)
        items = @section_headers.select { |i| i if rva >= i.rva }
        sec = items.last
        rva - sec.virtual_address + sec.pointer_to_raw_data
      end

      def get_image_export_directory_pos
        rva = @image_data_directories[0].virtual_address
        offset = rva_to_raw(rva)

        @file.pos = offset
        
        @image_export_directory = ImageExportDirectory.new
        @image_export_directory << @file.read(4).unpack("L")[0] rescue 0 # Characteristics
        @image_export_directory << @file.read(4).unpack("L")[0] rescue 0 # TimeDateStamp
        @image_export_directory << @file.read(2).unpack("S")[0] rescue 0 # MajorVersion
        @image_export_directory << @file.read(2).unpack("S")[0] rescue 0 # MinorVersion
        @image_export_directory << @file.read(4).unpack("L")[0] rescue 0 # Name
        @image_export_directory << @file.read(4).unpack("L")[0] rescue 0 # Base
        @image_export_directory << @file.read(4).unpack("L")[0] rescue 0 # NumberOfFunctions
        @image_export_directory << @file.read(4).unpack("L")[0] rescue 0 # NumberOfNames
        @image_export_directory << @file.read(4).unpack("L")[0] rescue 0 # AddressOfFunctions
        @image_export_directory << @file.read(4).unpack("L")[0] rescue 0 # AddressOfNames
        @image_export_directory << @file.read(4).unpack("L")[0] rescue 0 # AddressOfOrdinals

        # Table Read
        @file.pos = rva_to_raw(@image_export_directory.address_of_names)
        
        pos = @file.pos
        max = pos + (4 * @image_export_directory.number_of_names)
        names = []
        
        while pos < max
          names << rva_to_raw(@file.read(4).unpack("L")[0])
          pos += 4
        end

        names.each do |address|
          @file.pos = address
          
          name = ""
          while (c = @file.read(1)) != "\0"
            name += c
          end

          @functions.push(name)
        end

        f = File.open("exports.txt", "w+")
        
        @functions.each do |i|
          f << i + "\n"
        end

        f.close

        return @functions

      end
      
      def close
        @file.close if @file
      end
    end  
    
  end
  
sec = Steam::Section.new("steam_api.dll")
sec.get_image_nt_header_pos
sec.get_image_file_header_pos
sec.get_image_optional_header_pos
sec.parse_image_section_headers
sec.get_image_export_directory_pos
sec.close