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
    items = raw.split("")
    ch = items[0]
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

class JNode
  attr_accessor :parent, :key, :value

  def initialize(key = "", value = "")
    @key = key
    @value = value
    @parent = nil
    @nodes = []
  end

  def add(child)
    @value = child
    @value.parent = self

    return @value
  end

  def to_json

  end

end

raw = File.open("test.json", "r+").read
tokens = Tokenizer::Converter.start(raw)
p tokens