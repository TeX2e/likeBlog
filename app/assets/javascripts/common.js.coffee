
# window.onload = ->

# markdown_pre_code = $('div.markdown-body pre > code')
# markdown_pre_code.ready ->

window.onload = ->
  $('div.markdown-body pre > code').each ->
    code = $(this).html()
    # string
    code = code.replace(///
      (
        "(?:[^\\"]+|\\.)*"
        |
        '(?:[^\\']+|\\.)*'
      )
      ///g, 
      ->
        string = RegExp.$1
        return "<dvi class=\"string\">#{string}</dvi>"
    )
    # keyword
    code = code.replace(///
      \b( #capture
        end|do
        |if|elsif|unless
        |for|while|until
        # |def
        |class|module
        |public|protected
        |case|when
        |begin|rescue
        |attr_(?:writer|reader|accessor)
        |return
        |require
      )\b
      ([^=])
      ///g, 
      ->
        "<dvi class=\"keyword\">#{RegExp.$1}#{RegExp.$2}</dvi>"
    )
    # def function
    code = code.replace(///
      \b
      def \s+
      ( 
        \w[\w\d]+[?!=]?
        |===?|>[>=]?|<=>|<[<=]?|[%&`/\|]|\*\*?|=?~|[-+]@?|\[\]=? # the method name
      )
      (?:
        (\() # right paren
        ([\w\d\s,*&]+)? # args
        (\)) # left paren
      )?
      ///gi, 
      ->
        def_func = "<dvi class=\"keyword\">def</dvi> <dvi class=\"func\">#{RegExp.$1}</dvi>"
        r_paren = RegExp.$2 || ""
        args    = RegExp.$3 || ""
        l_paren = RegExp.$4 || ""
        args = "<dvi class=\"args\">#{args}</dvi>"
        return def_func + r_paren + args + l_paren
    )
    # number
    code = code.replace(///
      ([^\w])
      (
        \d+(?:\.\d+)?  # match int (and float)
      )
      ([^\w])
      |
      (\d[\d_]+\d)  # include underscore
      ///g, 
      ->
        # jsは否定の先読み、否定の後読みが出来ないため、前後のキャプチャを行った
        if RegExp.$1?
          before = RegExp.$1 || ""
          number = RegExp.$2 || ""
          after  = RegExp.$3 || ""
          return "#{before}<dvi class=\"number\">#{number}</dvi>#{after}"
        else
          number = RegExp.$4 || ""
          return "<dvi class=\"number\">#{number}</dvi>"
    )
    # symbol
    code = code.replace(///
      ([^:])
      ( :[\w\d]+ | [\w\d]+: )
      ([^:])
      ///g, 
      ->
        symbol = RegExp.$2
        return "#{RegExp.$1}<dvi class=\"symbol\">#{symbol}</dvi>#{RegExp.$3}"
    )
    # boolean and null
    code = code.replace(///
      \b(true|false|nil)\b
      ///g, 
      ->
        symbol = RegExp.$1
        return "<dvi class=\"symbol\">#{symbol}</dvi>"
    )
    # regexp
    code = code.replace(///
      ([^<])
      (
        \/(?:[^\\/<]+|\\.|<[^/])*\/
        [gimx]*
      )
      ///g, 
      ->
        regexp = RegExp.$2
        return "#{RegExp.$1}<dvi class=\"regexp\">#{regexp}</dvi>"
    )
    # operator
    code = code.replace(///
      (\s)
      (
        &lt;&lt;= # <<=
        |&lt;&lt; # <<
        |%=|&=|\*=|\*\*=|\+=|\-=|\^=|\|{1,2}=
        |&lt;=&gt; # <=>
        |&lt;  # <
        |&gt;  # >
        |&lt;= # <=
        |&gt;= # >=
        |={1,3}|=~|!=|!~|\?
        |!+|\bnot\b|&amp;&amp;|\band\b|\|\|?|\bor\b|\^
        |%|&amp;|\*\*|\*|\+|\-|/
      )
      (\s)
      ///g, 
      ->
        operator = RegExp.$2
        return "#{RegExp.$1}<dvi class=\"operator\">#{operator}</dvi>#{RegExp.$3}"
    )
    # escape sequence
    code = code.replace(///
      (\\.)
      ///g, 
      ->
        escape = RegExp.$1
        return "<dvi class=\"escape-sequence\">#{escape}</dvi>"
    )

    $(this).html(code) # replace hightlight code
    return

  ###
  codes = document.getElementsByTagName('code');
  for code in codes
    code.innerHTML = "text"
    console.log code
  ###
  
