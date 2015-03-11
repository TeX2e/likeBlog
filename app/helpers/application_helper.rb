module ApplicationHelper
  # 字数制限をつける
  # cut_off("testtext", 6) -> "testte..."
  def cut_off(text, length)
    return text unless text
    raise ArgumentError, "argument[1]: length should be positive number" \
      unless length.kind_of?(Numeric) && length >= 0

    # 指定された長さlengthより1文字多ければ、その1文字を"..."に置き換える
    cut_text = text.scan(/^.{#{length + 1}}/m)[0]
    if cut_text
      cut_text[0, length] + "..."
    else
      text
    end
  end
end
