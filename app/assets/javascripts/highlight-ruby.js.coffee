# ruby highlighting

$(document).ready ->
	$('div.markdown-body pre.ruby > code').each ->
		console.time('ruby highlighting');
		code = $(this).html()

		# split token
		tokens = new SplitToken(code).tokens

		# markup token
		tokens_tmp = []
		for token in tokens
			type = token.type
			text = token.text
			highlight_text = 
				switch type
					when "Comment" 	then "<span class=\"comment\">#{text}</span>"
					when "Str" 		then "<span class=\"yellow\">#{text}</span>"
					when "Reg"
						match = ///^([=\(\[,]\s?)(\/(?:[^\\/]+|\\.)*\/[gimx]*)///.exec text
						before = match[1]
						text   = match[2]
						before = "<span class=\"red\">#{RegExp.$1}</span>" if /^(=\s?)/.test before
						"#{before}<span class=\"orange\">#{text}</span>"
					when "Num" 		then "<span class=\"purple\">#{text}</span>"
					when "Flag" 	then "<span class=\"purple\">#{text}</span>"
					when "Ope" 		
						if text != "|"  # 縦棒は記号としない ex: do |i|; end
							"<span class=\"red\">#{text}</span>"
			# Keyword
			if ///^(end|do|if|unless|elsif|else|for|while|until|return|require
					|def
					|class|module|public|protected|attr_(?:writer|reader|accessor)
					|case|when|begin|rescue
					)///.test text
				type = "Keyword"
				highlight_text = "<span class=\"red\">#{text}</span>"
			tokens_tmp.push( {
				type: type,
				text: highlight_text || text
			} )
		tokens = tokens_tmp.concat()
		
		# markup Func
		tokens_tmp = []
		for key, token of tokens
			key = Number(key)
			before2_type = if tokens[key-2] then tokens[key-2].type else "_out_of_bounds"
			before2_text = if tokens[key-2] then tokens[key-2].text else "_out_of_bounds"
			type = token.type
			text = token.text
			after_type  = if tokens[key+1] then tokens[key+1].type else "_out_of_bounds"
			after_text  = if tokens[key+1] then tokens[key+1].text else "_out_of_bounds"
			# DefFunc
			if before2_type == "Keyword" && type == "Func" && after_type == "lParen"
				type = "DefFunc"
				text = "<span class=\"green\">#{text}</span>"
			tokens_tmp.push { type:type, text:text }
			
		tokens = tokens_tmp.concat()
		
		code = []
		for token in tokens
			code.push token.text
		code = code.join("")
		$(this).html(code)
		console.timeEnd('ruby highlighting');

###


$(document).ready ->
	$('div.markdown-body pre.ruby > code').each ->
		code = $(this).html()
		
		## tab -> space
		code = code.replace(/\t/g, "  ")

		## keyword
		code = code.replace(///
			((?:\n|^)\s*)
			(
				end
				# |do|if|unless
				|elsif|else|for|while|until|return|require
				# |def
				|class|module|public|protected|attr_(?:writer|reader|accessor)
				|case|when|begin|rescue
			)\b
			|
			(\s)(
				do|if|unless
			)(?=\s)
			///g, 
			->
				before  = RegExp.$1 || RegExp.$3 || ""
				keyword = RegExp.$2 || RegExp.$4 || ""
				"#{before}${red:::#{keyword}}"
		)

		## def function
		code = code.replace(///
			((?:\n|^)\s*) def \s+
			( 
				\w[\w\d]+[?!=]?  # the method name
				|===?|>[>=]?|<=>|<[<=]?|[%&`/\|]|\*\*?|=?~|[-+]@?|\[\]=?  # syntactic sugar
			)
			(?:
				(\() # right paren
				((?:[\w\d\s,*]+|&amp;)+)? # args
				(\)) # left paren
			)?
			///g, 
			->
				before    = RegExp.$1 || ""
				func_name = RegExp.$2 || ""
				def_func  = "#{before}${red:::def} ${green:::#{func_name}}"
				r_paren   = RegExp.$3 || ""
				args      = RegExp.$4 || ""
				l_paren   = RegExp.$5 || ""
				args = "${orange:::#{args}}" unless args == ""
				return def_func + r_paren + args + l_paren
		)
		
		## regexp
		# スラッシュ/は割り算の記号なのか判断する必要があるので、
		#       / / -> 2つの演算子
		#     = / / -> 正規表現
		# のようにスラッシュの前のイコールの有無で判断しています
		# その他に配列内の正規表現オブジェクトの見つけるため
		#     [/regexp/, /regexp/]
		#     str.replace(/regexp/, "match")
		# のように [ と , と ( でも正規表現として認めます
		code = code.replace(///
			([=(\[,~]\s*) 
			(
				\/(?:[^\\/]+|\\.)*\/
				[gimx]*
			)
			///g, 
			->
				before = RegExp.$1 || ""
				regexp = RegExp.$2 || ""
				regexp = regexp.replace(/\$\{keyword:::(if|do|unless)\}/g, "$1") # 変換されてしまったkeywordを戻す
					.replace(/"/g, " __quote__ ") # 文字列と認識しないようにする
					.replace(/:/g, " __colon__ ") # シンボルと認識しないようにする
					.replace(/\}/g, " __brace__ ") # 中間言語の終了タグと認識しないようにする
					.replace(/(\d)/g, " \\$1 ") # 数値と認識しないようにする
					.replace(/(true|false|nil)/g, " \\$1 ") # booleanと認識しないようにする
				"#{before}$r{orange:::#{regexp}}r$"
		)
		
		## string
		code = code.replace(///
			([^\\])
			(
				"(?:[^\\"\n]+|\\.)*"
				|
				'(?:[^\\'\n]+|\\.)*'
			)
			///g, 
			->
				before = RegExp.$1 || ""
				string = RegExp.$2 || ""
				string = string.replace(/\$\{keyword:::(if|do|unless)\}/g, "$1") # 変換されてしまったkeywordを戻す
					.replace(/\//g, " __slash__ ") # 正規表現と認識しないようにする
					.replace(/:/g, " __colon__ ") # シンボルと認識しないようにする
					.replace(/\}/g, " __brace__ ") # 中間言語の終了タグと認識しないようにする
					.replace(/(\d)/g, " \\$1 ") # 数値と認識しないようにする
					.replace(/([-\+\*!%&()=^~|@`\[\];<>,.])/g, " \\$1 ") # 演算子と認識しないようにする
					.replace(/(true|false|nil)/g, " \\$1 ") # booleanと認識しないようにする
				"#{before}$s{yellow:::#{string}}s$"
		)

		## symbol
		code = code.replace(///
			([^:\\])
			( :[\w\d]+ | [\w\d]+: )
			([^:])
			///g, 
			->
				before = RegExp.$1 || ""
				symbol = RegExp.$2 || ""
				after  = RegExp.$3 || ""
				"#{before}${purple:::#{symbol}}#{after}"
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
				before = RegExp.$1 || ""
				number = RegExp.$2 || RegExp.$3 || ""
				return "#{before}${purple:::#{number}}"
		)

		## boolean and null
		code = code.replace(///
			([^\\])(true|false|nil)\b
			///g, 
			->
				before = RegExp.$1 || ""
				symbol = RegExp.$2 || ""
				"#{before}${purple:::#{symbol}}"
		)
		
		## operator
		code = code.replace(///
			(\s)(
				&lt;&lt;=|&lt;&lt; # <<=|<<
				|%=|&=|\*=|\*\*=|\+=|\-=|\^=|\|{1,2}=
				|&lt;=&gt;|&lt;|&gt;|&lt;=|&gt;=  # >|<|<=|>=|<=>
				|={1,3}|=~|!=|!~|\?
				|!+|\bnot\b|&amp;&amp;|\band\b|\|\|?|\bor\b|\^
				|%|&amp;|\*\*|\*|\+|\-|/
			)(\s)
			///g, 
			->
				before   = RegExp.$1 || ""
				operator = RegExp.$2 || ""
				after    = RegExp.$3 || ""
				"#{before}${red:::#{operator}}#{after}"
		)

		## replace ${xxx:::content} -> <div class="xxx">content</div>
		code = code.replace(///
			\$\{   #  { で囲まれた中間言語  # 普通
				([^:]+):::([^}]*)
			\}
			|
			\$s\{  # s{ で囲まれた中間言語  # 文字列オブジェクト
				([^:]+):::((?:[^}]+|\}r\$)*)
			\}s\$
			|
			\$r\{  # r{ で囲まれた中間言語  # 正規表現オブジェクト
				([^:]+):::((?:[^}]+|\}s\$)+)
			\}r\$
			///g, 
			->
				class_name = RegExp.$1 || RegExp.$3 || RegExp.$5 || ""
				content    = RegExp.$2 || RegExp.$4 || RegExp.$6 || ""
				"<dvi class=\"#{class_name}\">#{content}</dvi>"
		)
		code = code.replace(/\ __slash__\ /g,"/")
			.replace(/\ __quote__\ /g,"\"")
			.replace(/\ __colon__\ /g,":")
			.replace(/\ __brace__\ /g,"}")
			.replace(/\ \\(\d)\ /g,"$1")
			.replace(/\ \\([-\+\*!%&()=^~|@`\[\];<>,.])\ /g,"$1")
			.replace(/\ \\(true|false|nil)\ /g,"$1")

		## --- 以下は中間言語ではない --- ##

		## escape sequence
		code = code.replace(///
			( 
				\\. # escape-sequence in string
			)
			///g,
			->
				escape_sequence = RegExp.$1 || ""
				"<dvi class=\"purple\">#{escape_sequence}</dvi>"
		)

		## comment
		code = code.replace(///
			(\#[^\n]*)
			///g,
			->
				comment = RegExp.$1 || ""
				comment = comment.replace(/<[^>]+>/g, "")
				"<dvi class=\"comment\">#{comment}</dvi>"
		)

		$(this).html(code) # replace hightlight code
		return
	# end ruby
###