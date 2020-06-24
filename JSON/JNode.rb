class JToken
  attr_reader :type

  def initialize(type, value)
    @type = type
    @value = value
  end

  def raw
    @value.to_s
  end

end

class JString < JToken
  def initialize(value)
    super(:STRING, value)
  end
  def raw
    "\"#{@value.to_s}\""
  end
end

class JArray < JToken
  def initialize(value)
    super(:ARRAY, value)
  end  
  def raw
    @value.to_s
  end  
end

class JWhiteSpace < JToken

end

class JNode
  attr_accessor :parent, :key, :value, :level, :nodes

  def initialize(key = "", value = "", level = 0)
    @key = key
    @value = value
    @parent = nil
    @nodes = []
    @level = level
  end

  def add(child)
    @nodes.push(child)
    return @value
  end

end


module Tokenizer

  DEFAULT_TOKEN_TABLE = {
    "{" => :LBRACE,
    "}" => :RBRACE,
    ":" => :COLON,
    "," => :COMMA,
    "true" => :TRUE,
    "false" => :FALSE,
    "null" => :NULL
  }

  module_function

  def init_type
    for i in ('0'..'9')
      DEFAULT_TOKEN_TABLE[i] = :NUMBER
    end
  
    for i in ('a'..'z')
      DEFAULT_TOKEN_TABLE[i] = :STRING
    end  
  
    for i in ('A'..'Z')
      DEFAULT_TOKEN_TABLE[i] = :STRING
    end
  
    for i in ('가'..'힣')
      DEFAULT_TOKEN_TABLE[i] = :STRING
    end  

    DEFAULT_TOKEN_TABLE["%"] = :STRING
    DEFAULT_TOKEN_TABLE["+"] = :STRING
    DEFAULT_TOKEN_TABLE["-"] = :STRING
    DEFAULT_TOKEN_TABLE["="] = :STRING
    DEFAULT_TOKEN_TABLE["$"] = :STRING
    DEFAULT_TOKEN_TABLE["*"] = :STRING
    DEFAULT_TOKEN_TABLE["_"] = :STRING
    DEFAULT_TOKEN_TABLE[","] = :COMMA
  
    DEFAULT_TOKEN_TABLE[" "] = :WHITESPACE
    DEFAULT_TOKEN_TABLE["\r"] = :WHITESPACE
    DEFAULT_TOKEN_TABLE["\n"] = :WHITESPACE
    DEFAULT_TOKEN_TABLE["\t"] = :WHITESPACE  
    
    DEFAULT_TOKEN_TABLE['['] = :LBRACKET
    DEFAULT_TOKEN_TABLE[']'] = :RBRACKET
    DEFAULT_TOKEN_TABLE["\""] = :DBL_Q
  end
  
  def make_lbrace
    JToken.new(:LBRACE, "{")
  end
  def make_rbrace
    JToken.new(:RBRACE, "}")
  end
  def make_colon
    JToken.new(:COLON, ":")
  end
  def make_comma
    JToken.new(:COMMA, ",")
  end
  def make_true
    JToken.new(:TRUE, "true")
  end
  def make_false
    JToken.new(:FALSE, "false")
  end  
  def make_null
    JToken.new(:NULL, "null")
  end
  def make_array(value)
    JArray.new(value)
  end
  def make_whitespace(type)
    validation = {
      :SPACE => JWhiteSpace.new(:WHITESPACE, " "),
      :LINEFEED => JWhiteSpace.new(:WHITESPACE, "\n"),
      :CR => JWhiteSpace.new(:WHITESPACE, "\r"),
      :HT => JWhiteSpace.new(:WHITESPACE, "\t"),
    }

    return validation[type] if validation[type]
    return validation[:SPACE]
  end
  def make_string(value)
    JString.new(value)
  end
end

class JDocument
  def initialize
    @nodes = []
    @current_pairs = JNode.new(nil, nil, 0)
    @last_node = @current_pairs
    @last_node_idx = 0
    @stacks = []
    @level = 0
    @change_level = false
  end
  def level_up
    @level += 1
    @change_level = true
    
    @stacks.push(@current_pairs)
  end
  def level_down
    if @level < 0
      raise "}가 맞지 않습니다"
    end
    @last_node = @stacks.pop
    @level -= 1
  end
  def empty_pairs(level)
    @current_pairs = JNode.new(nil, nil, level)
  end
  def set_key(node)
    @current_pairs.key = node.raw
    @current_pairs.level = @level
  end
  def set_value(node)
    @current_pairs.value = node.raw
    add_pair
  end
  def add_pair
    level = @level
    case level
    when 1
      @nodes.push(@current_pairs)
      @last_node_idx = @nodes.index(@current_pairs)
      empty_pairs(@level)
    else
      @last_node = @nodes[@last_node_idx]

      if @current_pairs.level > @last_node.level
        if @last_node.nodes[0]
          @last_node = @last_node.nodes[0]
        end
      end 

      if @last_node.is_a?(JNode)
        if @last_node.level == @current_pairs.level
        else
          @last_node.add(@current_pairs)
        end
      else
        raise "마지막 노드가 없습니다"
      end
      @last_node = @current_pairs
      empty_pairs(@level - 1)
    end        
  end
  def add(node)
    if !node.is_a?(JToken)
      raise "JDocument에는 JToken만 추가할 수 있습니다."
    end

    if @change_level
      if @current_pairs.key
        temp_level = @level
        @level = temp_level - 1
        @current_pairs.value = "@"
        add_pair
        @level = temp_level
      end
      @change_level = false
    end

    if !@current_pairs.key
      set_key(node)
    elsif @current_pairs.key && !@current_pairs.value
      set_value(node)
    end
  
    return @current_pairs
  end
  def nodes
    @nodes
  end
end

module Tokenizer::Converter
  extend self

  # Make a token
  # +raw+:: the raw string that reads in the file.
  def start(raw)
    typ = Tokenizer::DEFAULT_TOKEN_TABLE
    letters = raw.dup.split("")
    tokens = []

    while (ch = letters.shift) != nil
      tokens.push(typ[ch])
    end

    return tokens
  end

  # Make a JToken
  def try_parse(tokens, raw)
    letters = raw.split("")
    index = -1
    text = ""

    next_index = Proc.new do 
      index += 1
      index
    end

    compose_type = :KEY
    main_node = JNode.new
    last_node = nil
    nodes = []
    document = JDocument.new

    # 마지막 글자를 만날 때 까지 읽는다
    while (ch = letters[next_index.call]) != nil
      
      # 공백을 스킵한다
      while tokens[index] == :WHITESPACE
        ch = letters[next_index.call]
      end

      # 문자열이라면
      case tokens[index]
      when :DBL_Q
        ch = letters[next_index.call]
        while ch != "\""
          if ch == nil
            break
          end
          text += ch
          ch = letters[next_index.call]
        end
        if ch == "\""
          ch = letters[next_index.call]
        else
          raise "문자열 리터럴이 잘못되었습니다"
        end
        document.add(Tokenizer.make_string(text))
        text = ""

      when :LBRACE
        document.level_up
        p "{"
      when :RBRACE
        document.level_down
        p "}"
      when :LBRACKET
        p "["
        ch = letters[next_index.call]
        while ch != "]"
          if ch == nil
            break
          end
        end
        if ch == "]"

        else
          raise "배열 리터럴이 잘못되었습니다"
        end
      when :COLON
        p ":"
      when :COMMA
        p ","
      end
    end

    document

  end

  def value_to_token(raw)
    items = raw.split("")
    ch = items[0]
    ret = []
    index = 0

    if ch == "\""
      while (next_c = items[index]) != "\""
        if next_c == nil
          break
        end
        ret.push(next_c)
        index += 1
      end
    end

    return [make_string(ret.join("")), index]

  end  
end

Tokenizer.init_type

raw = File.open("test.json", "r+").read
tokens = Tokenizer::Converter.start(raw.dup)
document = Tokenizer::Converter.try_parse(tokens, raw)

def print_nodes(nodes)
  for i in nodes
    item = i
    if !i.nodes.empty?
      p "KEY : #{i.key} / LEVEL : #{i.level}"
      print_nodes(i.nodes)
    else
      p "KEY : #{i.key} / VALUE : #{i.value} / LEVEL : #{i.level}"
    end
  end
end

p document.nodes
print_nodes(document.nodes)
