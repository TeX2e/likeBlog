
$(document).ready ->
  $('.markdown-body p').each ->
    code_deco = $(this).html()

    ## :caption{caption}{code-type}
    code_type = ""
    code_deco = code_deco.replace(///
      :caption{([^}\n]*)}\s*(?:{([^}\n]*)})?
      ///, 
      ->
        code_type    = RegExp.$1 || ""
        code_caption = RegExp.$2 || ""
        hidden = if code_caption == "" then ' hidden' else ''
        "<span class=\"#{code_type}#{hidden}\">#{code_caption}</span>"
    )
    $(this).html(code_deco) # pタグに対する置き換えを保存

    return if not code_type? or code_type == ""
    
    ## cody-type が指定されたとき、上のcodeから順に class="cody-type" を割り当てる
    changed = false
    $('.markdown-body pre').each ->
      if changed == true
        return
      class_name = $(this).prop("class")
      if not class_name? or class_name == ""
        $(this).prop("class", code_type)  # ex: <div class="ruby">
        changed = true
        return
    return


bright_mode = [
  "console", "ruby", "c", "cpp", "csharp", "java", "javascript", "html", "php", "python"
]

## ソースコード上部の説明
$(document).ready ->
  # source code or console
  for type in bright_mode
    $(".markdown-body p span.#{type}").each ->
      # $(this).css("color", "rgba(250,250,250,1)")
      # $(this).css("background-color", "rgba(80,80,80,1)")
      return

  # hidden
  $('.markdown-body p span.hidden').each ->
    $(this).hide()
    return

$(document).ready ->
  ## preのclass="type"によってソースコードの背景色を変える
  for type in bright_mode
    $("div.markdown-body pre.#{type}").each ->
      $(this).css("color", "rgba(250,250,250,1)")
      $(this).css("background-color", "rgba(40,40,40,1)")


# highlight all pre>code 
$(document).ready ->
  ## text
  $('div.markdown-body pre.text > code').each ->
    code = $(this).html()
    # tab -> space
    code = code.replace(/\t/g, "    ")  # タブを空白4つに置き換え
    $(this).html(code)

  















