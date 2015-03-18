
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
little_bright_mode = [
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

	for type in little_bright_mode
		$("div.markdown-body pre.#{type}").each ->
			$(this).css("color", "rgba(250,250,250,1)")
			$(this).css("background-color", "rgba(35,35,35,1)")


class SplitToken
	constructor: (@code)->
		@tokens = []
		# split token
		current_pos = 0
		while true
			stil_read_code = @code.slice(current_pos, -1)
			token = take_token(stil_read_code)
			type = token.type
			text = token.text
			current_pos += text.length
			if type != "EOF"
				@tokens.push( { type:type, text:text } )
			else 
				break

	# ソースコードから最初のtokenを返す
	take_token = (code)->
		return { type:"Space",	text:RegExp.$1 } if /^(\s+)/.test code
		return { type:"Comment",text:RegExp.$1 } if /^(\/\/.*)/.test code # // comment
		return { type:"Comment",text:RegExp.$1 } if /^(\/\*(?:[^*]+|\*[^\/])*\*\/)/.test code # /* comment */
		return { type:"Func",	text:RegExp.$1 } if /^(\w+)(?=\()/.test code # func_name()
		return { type:"Str",	text:RegExp.$1 } if /^('(?:[^\\'\n]*|\\.)*')/.test code # 'str'
		return { type:"Str",	text:RegExp.$1 } if /^("(?:[^\\"\n]*|\\.)*")/.test code # "str"
		return { type:"Tag",	text:RegExp.$1 } if /^(&lt;[^&\n]+&gt;)/.test code # <stdio.h>
		return { type:"Reg",	text:RegExp.$1 } if /^([=([,]\s?\/(?:[^\\/]+|\\.)*\/[gimx]*)(?=[\s,)\]])/.test code # /regexp/
		return { type:"Num",	text:RegExp.$1 } if /^(\d[\d_]+)/.test code # 10_000
		return { type:"Num",	text:RegExp.$1 } if /^(0x?[\da-f]+)/i.test code # 0xfff
		return { type:"Num",	text:RegExp.$1 } if /^(\.?\d+\.?(?:\d+)?(?:e[-+]\d+)?)/i.test code # 12.34e+5
		return { type:"Ope",	text:RegExp.$1 } if ///^(
				\*|\+|\-|/|%|&amp;|\*\*|%=|&=|\*=|\*\*=|\+=|\-=|\^=|\|{1,2}=
				|&lt;&lt;=|&lt;&lt;|&lt;=&gt;|&lt;|&gt;|&lt;=|&gt;=  # <<=|<<|>|<|<=|>=|<=>
				|={1,3}|=~|!=|!~|\?|!+|\bnot\b|&amp;&amp;|\band\b|\|\|?|\bor\b|\^
			)///.test code
		return { type:"lParen",	text:RegExp.$1 } if /^([({])/.test code
		return { type:"rParen",	text:RegExp.$1 } if /^([)}])/.test code
		return { type:"EOE",	text:RegExp.$1 } if /^(;)/.test code
		return { type:"Flag",	text:RegExp.$1 } if /^(true|false|null|nil|EOF)/i.test code
		return { type:"Const",	text:RegExp.$1 } if /^([A-Z]\w+)/.test code
		return { type:"Ident",	text:RegExp.$1 } if /^(\w+)/.test code
		return { type:"UnIdent",text:RegExp.$1 } if /^(.)/.test code
		return { type:"EOF",	text:RegExp.$1 } if /^()$/.test code

window.SplitToken = SplitToken

# # ソースコードから最初のtokenを返す
# take_token = (code)->
# 	return { type:"Space",	text:RegExp.$1 } if /^(\s+)/.test code
# 	return { type:"Comment",text:RegExp.$1 } if /^(\/\/.*)/.test code # // comment
# 	return { type:"Comment",text:RegExp.$1 } if /^(\/\*(?:[^*]+|\*[^\/])*\*\/)/.test code # /* comment */
# 	return { type:"Func",	text:RegExp.$1 } if /^(\w+)(?=\()/.test code # func_name()
# 	return { type:"Str",	text:RegExp.$1 } if /^('(?:[^\\'\n]*|\\.)*')/.test code # 'str'
# 	return { type:"Str",	text:RegExp.$1 } if /^("(?:[^\\"\n]*|\\.)*")/.test code # "str"
# 	return { type:"Str",	text:RegExp.$1 } if /^(&lt;[a-z.]+&gt;)/.test code # <stdio.h>
# 	return { type:"Reg",	text:RegExp.$1 } if /^(\/(?:[^\\/]+|\\.)*\/[gimx]*)(?=[\s,)\]])/.test code # /regexp/
# 	return { type:"Num",	text:RegExp.$1 } if /^(0x?[\da-f]+)/i.test code # 0xfff
# 	return { type:"Num",	text:RegExp.$1 } if /^(\.?\d+\.?(?:\d+)?(?:e[-+]\d+)?)/i.test code # 12.34e+5
# 	return { type:"Ope",	text:RegExp.$1 } if ///^(
# 			\*|\+|\-|/|%|&amp;|\*\*|%=|&=|\*=|\*\*=|\+=|\-=|\^=|\|{1,2}=
# 			|&lt;&lt;=|&lt;&lt;|&lt;=&gt;|&lt;|&gt;|&lt;=|&gt;=  # <<=|<<|>|<|<=|>=|<=>
# 			|={1,3}|=~|!=|!~|\?|!+|\bnot\b|&amp;&amp;|\band\b|\|\|?|\bor\b|\^
# 		)///.test code
# 	return { type:"lParen",	text:RegExp.$1 } if /^([({])/.test code
# 	return { type:"rParen",	text:RegExp.$1 } if /^([)}])/.test code
# 	return { type:"EOE",	text:RegExp.$1 } if /^(;)/.test code
# 	return { type:"Const",	text:RegExp.$1 } if /^([A-Z]\w+)/.test code
# 	return { type:"Ident",	text:RegExp.$1 } if /^(\w+)/.test code
# 	return { type:"UnIdent",text:RegExp.$1 } if /^(.)/.test code
# 	return { type:"EOF",	text:RegExp.$1 } if /^()$/.test code

# window.take_token = take_token













