# c-lang highlighting

$(document).ready ->
  $('div.markdown-body pre.c > code').each ->
    code = $(this).html()
    
    ## tab -> space
    code = code.replace(/\t/g, "    ")

    ## keyword
    code = code.replace(///
      \b(
        if|else|for|while|return|break|continue
        |include|sizeof|switch|case
        # |define
      )\b
      ///g, 
      ->
        keyword = RegExp.$1 || ""
        "${red:::#{keyword}}"
    )

    ## def struct
    code = code.replace(///
      \#define \s+
      (\w+)\b   # struct_name
      ///g, 
      ->
        strucn_name = RegExp.$1 || ""
        "#${red:::define} ${green:::#{strucn_name}}"
    )

    ## def function
    code = code.replace(///
      (\w)
      \s+
      (\w+)\s*(?=\()   # function_name
      ///g, 
      ->
        before    = RegExp.$1 || ""
        func_name = RegExp.$2 || ""
        "#{before} ${green:::#{func_name}}"
    )

    ## init val
    code = code.replace(///
      \b(
        int|float|char|long|double|unsigned|void|typedef|struct
      )\b
      ///g, 
      ->
        type = RegExp.$1 || ""
        "${sky-blue:::#{type}}"
    )

    ## use function
    code = code.replace(///
      ([^\w\d]\s*)
      \b( [\w\d]+ )\b\(
      ///g, 
      ->
        before = RegExp.$1 || ""
        func   = RegExp.$2 || ""
        "#{before}${sky-blue:::#{func}}("
    )

    ## string
    code = code.replace(///
      ([^\\])
      (
        "(?:[^\\"\n]+|\\.)*"
        |
        '(?:[^\\'\n]+|\\.)*'
        |
        &lt;[\w.]*?&gt;
      )
      ///g, 
      ->
        before = RegExp.$1 || ""
        string = RegExp.$2 || ""
        string = string.replace(/\$\{keyword:::(if|do|unless)\}/g, "$1") # 変換されてしまったkeywordを戻す
          .replace(/\//g, " __slash__ ") # 正規表現と認識しないようにする
          .replace(/:/g,  " __colon__ ") # シンボルと認識しないようにする
          .replace(/\}/g, " __brace__ ") # 中間言語の終了タグと認識しないようにする
          .replace(/(\d)/g, " \\$1 ") # 数値と認識しないようにする
          .replace(/([-\+\*!%&()=^~|@`\[\];<>,.])/g, " \\$1 ") # 演算子と認識しないようにする
          .replace(/(TRUE|FALSE|NULL|EOF)/g, " \\$1 ") # booleanと認識しないようにする
        "#{before}$s{yellow:::#{string}}s$"
    )

    ## number
    code = code.replace(///
      ([^\w\\])(
        \d+(?:\.\d+)?  # match int (and float)
      )(?!\w)
      |
      (\d[\d_]+\d)  # include underscore
      ///g, 
      ->
        # jsは否定の先読み、否定の後読みが出来ないため、前後のキャプチャを行った
        if RegExp.$1?
          before = RegExp.$1 || ""
          number = RegExp.$2 || ""
          "#{before}${purple:::#{number}}"
        else
          number = RegExp.$3 || ""
          "${purple:::#{number}}"
    )

    ## boolean and null
    code = code.replace(///
      ([^\\])(TRUE|FALSE|NULL|EOF)\b
      ///g, 
      ->
        before = RegExp.$1 || ""
        symbol = RegExp.$2 || ""
        "#{before}${purple:::#{symbol}}"
    )

    ## 中間言語をhtmlタグに変換する
    ## convert ${xxx:::content} -> <div class="xxx">content</div>
    code = code.replace(///
      \$\{   #  { で囲まれた中間言語  # 普通
        ([^:]+):::([^}]+)
      \}
      |
      \$s\{  # s{ で囲まれた中間言語  # 文字列オブジェクト
        ([^:]+):::((?:[^}]+|\}r\$)+)
      \}s\$
      ///g, 
      ->
        class_name = RegExp.$1 || RegExp.$3 || RegExp.$5 || ""
        content    = RegExp.$2 || RegExp.$4 || RegExp.$6 || ""
        "<dvi class=\"#{class_name}\">#{content}</dvi>"
    )

    ## stringのときにエスケープした記号を元に戻す
    code = code.replace(/\ __slash__\ /g,"/")
      .replace(/\ __quote__\ /g,"\"")
      .replace(/\ __colon__\ /g,":")
      .replace(/\ __brace__\ /g,"}")
      .replace(/\ \\(\d)\ /g,"$1")
      .replace(/\ \\([-\+\*!%&()=^~|@`\[\];<>,.])\ /g,"$1")
      .replace(/\ \\(TRUE|FALSE|NULL|EOF)\ /g,"$1")

    ## --- 以下は中間言語ではない --- ##

    ## escape sequence
    code = code.replace(///
      ( 
        \\. # escape-sequence in string
        | # or
        %   # format
        -?  # flag
        [\d.]* # digit
        l?  # long
        [csduoxfeg] # format
      )
      ///g,
      ->
        escape_sequence = RegExp.$1 || ""
        "<dvi class=\"purple\">#{escape_sequence}</dvi>"
    )

    ## comment
    code = code.replace(///
      (\/\/[^\n]*)
      ///g,
      ->
        comment = RegExp.$1 || ""
        comment = comment.replace(/<[^>]+>/g, "")
        "<dvi class=\"comment\">#{comment}</dvi>"
    )

    $(this).html(code) # replace hightlight code
    return


