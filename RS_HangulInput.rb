#===========================================================
# Author : biud436
#
# This script allows you to type the Korean in your game.
#
# This script combines the korean alphabet so you can type 
# the Korean, without Input Method Editor.
#
# $hangul = HangulIME.new
# $hangul.start_with_composite($hangul.decompress("니 결에 있을게 my love"), Proc.new {|ret| p ret })  
#
#===========================================================

$imported = {} if $imported.nil?
$imported["RS_HangulInput"] = true

module HangulConfig
  CHOSUNG = ["ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
  JOONGSUNG = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ", "ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
  JONGSUNG = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
end

class HangulIME

  STEP11 = 1;   STEP12 = 2
  STEP21 = 3;   STEP22 = 4 
  STEP31 = 5;   STEP32 = 6
  STEP42 = 7;   STEP43 = 8
  
  def initialize
    init_members
  end

  def init_members
    @composing = false
    @mess_texts = nil
    @han_texts = {
      :first => -1,
      :middle => -1,
      :final => -1,
    }
    @ret_texts = ""
    @index = 0
    @last_index = 0
    @current_step = STEP11
    @previous_index = 0
  end

  def clear
    init_members
  end
  
  def clear?
    
  end

  def start_with_composite(texts, func)
    init_members
    @mess_texts = decompress(texts)
    @index = 0
    
    depth = 0

    Thread.new do
      loop do 
        if 1000 < depth
          func.call @ret_texts
          break
        end

        if @index > @mess_texts.size
          func.call @ret_texts
          break
        end

        case @current_step
        when STEP11 
          # 초성이 종성으로 대체되고 겹받침이 되었나? (ㄱㄴㄹㅂ)
          start_step_11
        when STEP12 
          # 쌍자음 또는 1.1이 아닌 정상 범주라면 정상 추가한다.
          start_step_12
        when STEP21 
          # 중성이 겹모음이 될 가능성이 있나? ㅗㅜㅡ인가?
          start_step_21
        when STEP22 
          # 중성이 2.1에 위배되지 않고 정상 범주인가?
          start_step_22
        when STEP31 
          # 종성이 겹받침이 될 수 있나? (ㄱㄴㄹㅂ)
          start_step_31
        when STEP32 
          # 종성이 공백 또는 정상 범주인가?
          start_step_32
        when STEP42 
          # 마지막 글자를 추가하고 조합 완료 (커서가 굵은 것만 남는다)
          start_step_42
        when STEP43 
          # 조합 완료 후 글자 추가 (커서가 굵은 것만 남는다), 
          # 영어나 특수 문자, 숫자 등 한글 범주(인덱스)가 아니라면
          start_step_43
        end

        depth += 1

      end
    end

  end

  def start_step_11
    current_char = @mess_texts[@index]
    next_char = @mess_texts[@index + 1]
    last_char = @mess_texts[@index + 2]
    ret = false

    if current_char.nil? || current_char == ""
      @index += 1
      return
    end

    ret = process_double_final_consonant(current_char, next_char, last_char)
    @current_step = ret ? STEP42 : STEP12
    @previous_index = @index

  end

  def hangul?(text)
    pattern = /[\u1100-\u11FF\uAC00-\uD7AF]/
    pattern.match(text)
  end

  def wansung_hangul?(text)
    pattern = /[\uAC00-\uD7AF]/
    pattern.match(text)
  end

  def decompress(texts, is_number=false)
    
    ret = []

    for i in (0...texts.size)
      
      c = texts[i]

      if !hangul?(c)
        ret.push(c)
        next
      end

      code = c.unpack('U')[0]
      offset = code - 0xAC00

      first = (offset / 588).floor
      middle = ((offset % 588) / 28).floor
      final = offset % 28

      ret.push(HangulConfig::CHOSUNG[first])
      ret.push(HangulConfig::JOONGSUNG[middle])
      ret.push(HangulConfig::JONGSUNG[final])

    end

    ret

  end

  def start_step_12
    c = @mess_texts[@index]
    idx = first?(c)
    
    if idx >= 0
      @composing = true
      set_first(idx)
      @index += 1
      @current_step = STEP21
      return true
    else
      if middle?(c) >= 0
        @current_step = STEP21
        return true
      else
        @composing = false
        @current_step = STEP43             
        return false
      end
    end

  end

  def start_step_21
    current_char = @mess_texts[@index]
    next_char = @mess_texts[@index + 1]
    last_char = @mess_texts[@index + 2]
    ret = false
    
    ret = process_double_vowel(current_char, next_char, last_char)
    @current_step = ret ? STEP31 : STEP22
  end

  def start_step_22
    c = @mess_texts[@index]
    cc = @mess_texts[@index + 1]
    ccc = @mess_texts[@index + 2]
    idx = middle?(c)

    if idx >= 0
      set_middle(idx)
      @current_step = STEP31
      @index += 1
      return true
    else      
      @index -= 1
      @current_step = STEP43
      return false
    end
  end

  def start_step_31
    current_char = @mess_texts[@index]
    next_char = @mess_texts[@index + 1]
    last_char = @mess_texts[@index + 2]
    ret = false    

    if @han_texts[:final] <= 0
      set_final(0)
    end
    ret = process_double_final_consonant(current_char, next_char, last_char)
    
    if ret
      @composing = false
      @current_step = STEP42
    else
      if first?(current_char) >= 0 && middle?(next_char) >= 0
        @composing = false
        @current_step = STEP42
        return false
      end

      if current_char.nil? || current_char == ""
        @current_step = STEP42
        return false
      end

      @current_step = STEP32

    end

  end

  def start_step_32
    c = @mess_texts[@index]
    cc = @mess_texts[@index + 1]    
    idx = final?(c)

    if idx >= 0
      set_final(idx)
      @composing = false
      @current_step = STEP42
      @index += 1
      return true
    else
      @composing = false
      @current_step = STEP42
      return false
    end
  end

  def start_step_42
    c = @han_texts
    @ret_texts += make_wansung(c[:first], c[:middle], c[:final])
    @last_index = @index
    @han_texts[:first] = -1
    @han_texts[:middle] = -1
    @han_texts[:final] = -1
    @current_step = STEP11
    return true
  end

  def start_step_43
    @ret_texts += @mess_texts[@index]
    @current_step = STEP11
    @index += 1
    return true
  end

  def set_first(index)
    @han_texts[:first] = index
  end

  def set_middle(index)
    @han_texts[:middle] = index
  end

  def set_final(index)
    @han_texts[:final] = index
  end

  def first?(text)
    return -1 if text == ""
    ret = HangulConfig::CHOSUNG.index(text) || -1
    return ret ? ret : -1
  end

  def middle?(text)
    return -1 if text == ""
    ret = HangulConfig::JOONGSUNG.index(text) || -1
    return ret ? ret : -1
  end
  
  def final?(text)
    return -1 if text == ""
    ret = HangulConfig::JONGSUNG.index(text) || -1
    return ret ? ret : -1
  end

  def composite?
    @composing
  end

  def special_character?(text)
    /[~\`!\#$%\^&*+=\-\[\]\';,\.\/{}|\":<>\?]/.match(text)
  end

  def process_double_final_consonant(current_char, next_char, last_char)
    ret = ""

    if current_char == ""
      return false
    end
    
    if middle?(current_char) >= 0
      process_double_vowel(current_char, next_char, last_char)
      return false
    end

    if first?(next_char) >= 0 && middle?(last_char) >= 0
      return false
    end

    if current_char == "ㄱ" && next_char == "ㅅ"
      ret = 'ㄳ'
    elsif current_char == "ㄴ" && next_char == "ㅈ"
      ret = 'ㄵ'
    elsif current_char == "ㄴ" && next_char == "ㅎ"
      ret = 'ㄶ'
    elsif current_char == "ㄹ" && next_char == "ㄱ"
      ret = 'ㄺ'
    elsif current_char == "ㄹ" && next_char == "ㅁ"
      ret = 'ㄻ'
    elsif current_char == "ㄹ" && next_char == "ㅂ"
      ret = 'ㄼ'
    elsif current_char == "ㄹ" && next_char == "ㅅ"
      ret = 'ㄽ'
    elsif current_char == "ㄹ" && next_char == "ㅌ"
      ret = 'ㄾ'
    elsif current_char == "ㄹ" && next_char == "ㅍ"
      ret = 'ㄿ'
    elsif current_char == "ㄹ" && next_char == "ㅎ"
      ret = 'ㅀ'
    elsif current_char == "ㅂ" && next_char == "ㅅ"
      ret = 'ㅄ'
    end

    if ret != ""
      @index += 2

      idx = final?(ret)
      if idx >= 0
        if @current_step < STEP21
          set_first(-1)
          set_middle(-1)
        end
        set_final(idx)
        return true
      else
        return false
      end

    else
      return false
    end
  
  end

  def process_double_vowel(current_char, next_char, last_char)

    middles = "ㅗㅜㅡ"
    
    if current_char.nil? || current_char == ""
      return false
    end
    
    safe_value = middles.index(current_char) || -1

    if safe_value.nil? || safe_value < 0
      return false 
    end

    ret = ""

    if current_char == "ㅗ"
      ret = "ㅘ" if next_char == "ㅏ"
      ret = "ㅙ" if next_char == "ㅐ"
      ret = "ㅚ" if next_char == "ㅣ"
    elsif current_char == "ㅜ"
      ret = "ㅝ" if next_char == "ㅓ"
      ret = "ㅞ" if next_char == "ㅔ"
      ret = "ㅟ" if next_char == "ㅣ"      
    elsif current_char == "ㅡ"
      ret = "ㅢ" if next_char == "ㅣ" 
    end

    if ret != ""
      @index += 2

      idx = middle?(ret)

      if idx >= 0
        set_middle(idx)
        if @current_step < STEP21
          @current_step = STEP11 
        end
        return true
      end

    end

    return false

  end

  def make_wansung(first, middle, final)
    if (first >= 0) && (middle < 0) && final < 0
      return HangulConfig::CHOSUNG[first]
    end

    if (first < 0) && (middle < 0) && final > 0
      return HangulConfig::JONGSUNG[final]
    end

    final = 0 if (final < 0 || final == "")

    code = 44032 + (first * 588) + (middle * 28) + final
    ret = [code].pack('U')

    ret

  end

end

$hangul = HangulIME.new
$hangul.start_with_composite($hangul.decompress("니 결에 있을게 my love"), Proc.new {|ret| p ret })