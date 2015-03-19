
$(document).ready ->
	$('.markdown-body p').each ->
		code_discription = $(this).html()

		## :code{code-type}{caption}
		code_type = ""
		code_discription = code_discription.replace(///
			:code{([^}\n]*)}\s*(?:{([^}\n]*)})?
			///, 
			->
				code_type    = RegExp.$1 || ""
				code_caption = RegExp.$2 || ""
				hidden = if code_caption == "" then ' hidden' else ''
				"<span class=\"#{code_type}#{hidden}\">#{code_caption}</span>"
		)
		$(this).html(code_discription) # pタグに対する置き換えを保存

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

# 主にソースコード
bright_mode = [
	"ruby", "c", "cpp", "csharp", "java", "js", "html", "css", "php", "python"
]

# 主に出力結果
more_bright_mode = [
	"console"
]

## ソースコード上部の説明
$(document).ready ->
	# hidden
	$('.markdown-body p span.hidden').each ->
		$(this).hide()
		return

## preのclass="type"によってソースコードの背景色を変える
$(document).ready ->
	for type in bright_mode
		$("div.markdown-body pre.#{type}").each ->
			$(this).css("color", "rgba(250,250,250,1)")
			$(this).css("background-color", "rgba(40,40,40,1)")

	for type in more_bright_mode
		$("div.markdown-body pre.#{type}").each ->
			$(this).css("color", "rgba(250,250,250,1)")
			$(this).css("background-color", "rgba(35,35,35,1)")


class window.SplitToken
	constructor: (@code)->
		@tokens = []
		# split token
		current_pos = 0
		while true
			still_read_code = @code.slice(current_pos, -1)
			token = @take_token(still_read_code)
			type = token.type
			text = token.text
			current_pos += text.length
			if type != "EOF"
				@tokens.push( { type:type, text:text } )
			else 
				break

	# ソースコードから最初のtokenを返す
	take_token: (code)->
		return { type:"Space",	text:RegExp.$1 } if /^(\s+)/.test code
		return { type:"Func",	text:RegExp.$1 } if /^(\w+)(?=\()/.test code # func_name()
		return { type:"Str",	text:RegExp.$1 } if /^('(?:[^\\'\n]*|\\.)*')/.test code # 'str'
		return { type:"Str",	text:RegExp.$1 } if /^("(?:[^\\"\n]*|\\.)*")/.test code # "str"
		return { type:"Reg",	text:RegExp.$1 } if ///^(
				[=([,]\s? \/(?:[^\\/]+|\\.)*\/[gimx]*) (?=[\s,)\];]
			)///.test code # /regexp/
		return { type:"Num",	text:RegExp.$1 } if /^(0x?[\da-f]+)/i.test code # 0xfff
		return { type:"Num",	text:RegExp.$1 } if /^(\.?\d+\.?(?:\d+)?(?:e[-+]\d+)?)/i.test code # 12.34e+5
		return { type:"Ope",	text:RegExp.$1 } if ///^(
				\*|\+|\-|/|%|&amp;|\*\*|%=|&=|\*=|\*\*=|\+=|\-=|\^=|\|{1,2}=
				|&lt;&lt;=|&lt;&lt;|&lt;=&gt;|&lt;|&gt;|&lt;=|&gt;=  # <<=|<<|>|<|<=|>=|<=>
				|={1,3}|=~|!=|!~|\?|!+|\bnot\b|&amp;&amp;|\band\b|\|\|?|\bor\b|\^
			)///.test code
		return { type:"lParen",	text:RegExp.$1 } if /^([({])/.test code
		return { type:"rParen",	text:RegExp.$1 } if /^([)}])/.test code
		return { type:"Flag",	text:RegExp.$1 } if /^(true|false|null|nil|EOF)\b/i.test code
		return { type:"Const",	text:RegExp.$1 } if /^([A-Z]\w+)/.test code
		return { type:"Ident",	text:RegExp.$1 } if /^(\w+)/.test code
		return { type:"UnIdent",text:RegExp.$1 } if /^(.)/.test code
		return { type:"EOF",	text:RegExp.$1 } if /^()$/.test code
		return { type:"EOF",	text:"Error"   }

## Ruby
class window.SplitRubyToken extends SplitToken
	take_token: (code)->
		return { type:"Comment",text:RegExp.$1 } if /^(#.*)/.test code # # comment
		return { type:"Func",	text:RegExp.$1 } if /^(\w+[?!=])/.test code # func_name?
		return { type:"Def",	text:RegExp.$1 } if /^(def)\b/.test code
		return { type:"Keyword",text:RegExp.$1 } if ///^(
				end|do|if|unless|elsif|else|for|while|until|return|require
				|class|module|public|protected|attr_(?:writer|reader|accessor)
				|case|when|begin|rescue
			)\b///.test code
		return { type:"Num",	text:RegExp.$1 } if /^(\d[\d_]*\.?\d*)/.test code # 10_000
		return { type:"Range",	text:RegExp.$1 } if /^(\.\.\.?)/.test code # 10_000
		return { type:"Sym",	text:RegExp.$1 } if /^(:\w+|\w+:)(?!:)/.test code # :symbol
		return { type:"Chain",	text:RegExp.$1 } if /^(\.|::)/.test code # Array::Module.method
		super code

## C
class window.SplitCToken extends SplitToken
	take_token: (code)->
		return { type:"Comment",	text:RegExp.$1 } if /^(\/\/.*)/.test code # // comment
		return { type:"Comment",	text:RegExp.$1 } if /^(\/\*(?:[^*]+|\*[^\/])*\*\/)/.test code # /* comment */
		return { type:"InitKeyword",text:RegExp.$1 } if ///^(
				int|float|char|long|double|unsigned|void|typedef|struct
			)\b///.test code
		return { type:"Keyword",	text:RegExp.$1 } if ///^(
				if|else|for|while|return|break|continue|include|sizeof|switch|case
			)\b///.test code
		return { type:"Def",		text:RegExp.$1 } if /^(define)/.test code
		return { type:"Tag",	text:RegExp.$1 } if /^(&lt;[^&\n]+&gt;)/.test code # <stdio.h>
		super code

## HTML
class window.SplitHTMLToken extends SplitToken
	take_token: (code)->
		return { type:"Comment",	text:RegExp.$1 } if ///^( # TODO: comment
				&lt;!--(?:[^-]+|-(?!-&gt;))*--&gt;
			)///.test code # <!-- comment -->
		return { type:"DocType",	text:RegExp.$1 } if /^(&lt;!(?:[^&]+|&(?!gt;))*&gt;)/.test code # <!DOCTYPE html>
		return { type:"lt",			text:RegExp.$1 } if /^(&lt;)/.test code # <
		return { type:"gt",			text:RegExp.$1 } if /^(&gt;)/.test code # >
		super code

## CSS
class window.SplitCSSToken extends SplitToken
	take_token: (code)->
		return { type:"Comment",	text:RegExp.$1 } if /^(\/\/.*)/.test code # // comment
		return { type:"Comment",	text:RegExp.$1 } if /^(\/\*(?:[^*]+|\*[^\/])*\*\/)/.test code # /* comment */
		return { type:"HTMLTag",	text:RegExp.$1 } if ///^(
				a|abbr|acronym|address|area|article|aside|audio|b|base|big|blockquote
				|body|br|button|canvas|caption|cite|code|col|colgroup|datalist|dd|del
				|details|dfn|dialog|div|dl|dt|em|eventsource|fieldset|figure|figcaption
				|footer|form|frame|frameset|(h[1-6])|head|header|hgroup|hr|html|i|iframe
				|img|input|ins|kbd|label|legend|li|link|main|map|mark|menu|meta|meter|nav
				|noframes|noscript|object|ol|optgroup|option|output|p|param|pre|progress
				|q|samp|script|section|select|small|span|strike|strong|style|sub|summary
				|sup|table|tbody|td|textarea|tfoot|th|thead|time|title|tr|tt|ul|var|video
			)\b(?![-:;]\s)///.test code
		return { type:"Num",		text:RegExp.$1 } if /^(\#[0-9a-f]{6}|\#[0-9a-f]{3})/i.test code # #fff #a0a0a0
		return { type:"Num",		text:RegExp.$1 } if /^(-?\d+(?:\.\d+)?)/.test code # -7 16
		return { type:"Prop",		text:RegExp.$1 } if /^([-\w]+)(?=:)/.test code # text-aline:
		return { type:"Func",		text:RegExp.$1 } if /^([-\w]+)(?=\()/.test code # func()
		return { type:"Attr",		text:RegExp.$1 } if /^([.\#:][-\w]+(?!;))/.test code # .class #id :clicked
		return { type:"Attr",		text:RegExp.$1 } if /^([-\w]+)(?==|\]|~)/.test code # [attr="hidden"]
		return { type:"Unit",		text:RegExp.$1 } if /^(px\b|em\b|%|!important)/.test code # 10px 1.2em 100%
		return { type:"Str",		text:RegExp.$1 } if /^("(?:[^\\"]*|\\.)*")/.test code # "str"
		return { type:"Selector",	text:RegExp.$1 } if /^(&amp;|&gt;|\*)/.test code # css selector & > *
		return { type:"Control",	text:RegExp.$1 } if /^(@\w+(?:\sif)?)/.test code # @if
		return { type:"Variable",	text:RegExp.$1 } if /^(\$\w+)/.test code # @if
		super code

## JavaScript
class window.SplitJavaScriptToken extends SplitToken
	take_token: (code)->
		return { type:"Comment",	text:RegExp.$1 } if /^(\/\/.*)/.test code # // comment
		return { type:"Comment",	text:RegExp.$1 } if /^(\/\*(?:[^*]+|\*[^\/])*\*\/)/.test code # /* comment */
		return { type:"Def",		text:RegExp.$1 } if /^(function)\b/.test code # function
		return { type:"Chain",		text:RegExp.$1 } if /^(\.)/.test code # document.method
		return { type:"InitKeyword",text:RegExp.$1 } if /^(var)\b/.test code
		return { type:"Keyword",	text:RegExp.$1 } if ///^(
				if|else|for|while|return|break|continue|switch|case
				|do|try|catch|finally|throws|default
				|new|typeof|in|instanceof|delete|with
			)\b///.test code
		super code







