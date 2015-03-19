# js highlighting

$(document).ready ->
	$('div.markdown-body pre.js > code').each ->
		code = $(this).html()
		
		# split token
		tokens = new SplitJavaScriptToken(code).tokens

		for token in tokens
			console.log "#{token.type} : #{token.text}"

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
					when "Num", "Sym", "Flag" 	then "<span class=\"purple\">#{text}</span>"
					when "Keyword", "Ope"		then "<span class=\"red\">#{text}</span>"
					when "Def", "InitKeyword" 	then "<span class=\"skyblue\">#{text}</span>"
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
			before_type  = if tokens[key-1] then tokens[key-1].type else "_out_of_bounds"
			type = token.type
			text = token.text
			after_type  = if tokens[key+1] then tokens[key+1].type else "_out_of_bounds"
			after2_type = if tokens[key+2] then tokens[key+2].type else "_out_of_bounds"
			after4_type = if tokens[key+4] then tokens[key+4].type else "_out_of_bounds"
			# DefFunc ex: function func(val){}
			if before2_type == "Def" && type == "Func"
				type = "DefFunc"
				text = "<span class=\"green\">#{text}</span>"
			# DefFunc ex: var func = function(){}
			if type == "Ident" && after2_type == "Ope" && after4_type == "Def"
				type = "DefFunc"
				text = "<span class=\"green\">#{text}</span>"
			# method chain
			if before_type == "Chain" && (type == "Func" || type == "Ident")
				type = "MethodChain"
				text = "<span class=\"skyblue\">#{text}</span>"
			tokens_tmp.push { type:type, text:text }
		tokens = tokens_tmp.concat()

		# markup DefFuncArgs
		tokens_tmp = []
		isArgs = false
		for key, token of tokens
			key = Number(key)
			before_type = if tokens[key-1] then tokens[key-1].type else "_out_of_bounds"
			type = token.type
			text = token.text
			# DefFuncArgs
			if (before_type == "DefFunc" || before_type == "Def") && type == "lParen"
				text = "#{text}<span class=\"orange\">"
				isArgs = true
			if isArgs == true && type == "rParen"
				text = "</span>#{text}"
				isArgs = false
			tokens_tmp.push { type:type, text:text }
		tokens = tokens_tmp.concat()

		code = []
		for token in tokens
			code.push token.text
		code = code.join("")

		# escape sequence
		code = code.replace(/(\\.)/g, ->
			"<span class=\"purple\">#{RegExp.$1}</span>")

		$(this).html(code)
		console.timeEnd('ruby highlighting');

		###
		## tab -> space
		code = code.replace(/\t/g, "    ")

		## def function 1
		code = code.replace(///
			\b function \s+ (\w+) \s* \( ([\w\s,]*) \)
			///g, 
			"function ${green:::$1}(${orange:::$2})"
		)
		## def function 2
		code = code.replace(///
			(\w+) \s* = \s*\b function \s* \( ([\w\s,]*) \)
			///g, 
			"${green:::$1} = function(${orange:::$2})"
		)

		## init keyword
		code = code.replace(///
			\b( var|function|void )\b
			///g,
			"${sky-blue:::$1}"
		)

		## strong keyword
		code = code.replace(///
			\b(
				break|case|catch|continue|default|do|else|finally
				|for|if|return|switch|try|while|finally|throws
				|delete|in|instanceof|new|typeof|with
			)\b
			///g,
			"${red:::$1}"
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

		## number
		code = code.replace(///
			([^\w\\])(
				\d+(?:\.\d+)?  # match int (and float)
			)(?!\w)
			|
			\b(Infinity|NaN|undefined)\b
			///g, 
			->
				before = RegExp.$1 || ""
				number = RegExp.$2 || RegExp.$3 || ""
				"#{before}${purple:::#{number}}"
		)

		## boolean and null
		code = code.replace(///
			([^\\])(true|false|null)\b
			///g, 
			->
				before = RegExp.$1 || ""
				symbol = RegExp.$2 || ""
				"#{before}${purple:::#{symbol}}"
		)

		## operator
		code = code.replace(///
			(\s)(
				%|\-|\+|\*|\/|={1,3}|!={1,2}
				|&lt;=|&gt;=|&lt;&lt;=|&gt;&gt;=|&gt;&gt;&gt;=|&lt;&gt;|&lt;|&gt;
				|&amp;&amp;|\|\||\?|\*=|%=|\+=|\-=|&amp;=|\^=
				|\b(?:in|instanceof|new|delete|typeof|void)\b
			)(\s)
			|
			( !\b |\+\+|\-\- )
			///g, 
			->
				before   = RegExp.$1 || ""
				operator = RegExp.$2 || RegExp.$4 || ""
				after    = RegExp.$3 || ""
				"#{before}${red:::#{operator}}#{after}"
		)

		## use prop or function
		code = code.replace(///
			\.(\w+)	
			///g, 
			".${sky-blue:::$1}"
		)

		## 中間言語をhtml形式に変換する
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
			( \/\*
				(?:[^*]+|\*[^/])*
			\*\/ )
			///g,
			->
				comment = RegExp.$1 || ""
				comment = comment.replace(/<[^>]+>/g, "")
				"<dvi class=\"comment\">#{comment}</dvi>"
		)

		$(this).html(code)
		###

