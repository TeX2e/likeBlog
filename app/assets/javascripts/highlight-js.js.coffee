# js highlighting

$(document).ready ->
	$('div.markdown-body pre.js > code').each ->
		code = $(this).html()
		
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


