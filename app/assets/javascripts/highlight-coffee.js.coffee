# coffee highlighting

$(document).ready ->
	$('div.markdown-body pre.coffee > code').each ->
		console.time('coffee highlighting');
		code = $(this).html()
		
		# split token
		tokens = new SplitCoffeeScriptToken(code).tokens

		# for token in tokens
		# 	console.log "#{token.type} : #{token.text}"

		# markup token
		tokens_tmp = []
		for token in tokens
			type = token.type
			text = token.text
			highlight_text = 
				switch type
					when "Comment" 	then "<span class=\"comment\">#{text}</span>"
					when "Str" 		then "<span class=\"yellow\">#{text}</span>"
					when "Reg", "RegMul"		then "<span class=\"orange\">#{text}</span>"
					when "Num", "Sym", "Flag" 	then "<span class=\"purple\">#{text}</span>"
					when "Keyword", "Ope"		then "<span class=\"red\">#{text}</span>"
					when "Func" 				then "<span class=\"skyblue\">#{text}</span>"
					when "Const" 				then "<span class=\"skyblue\">#{text}</span>"
					when "DefClass"
						match = ///^class\s([^\s]+)(?:\s(extends)\s([^\s]+))?///.exec text
						className        = "<span class=\"red\">#{match[1]}</span>"
						extendsKeyword   = if match[2] then " <span class=\"red\">#{match[2]}</span>"   else ""
						extendsClassName = if match[2] then " <span class=\"green\">#{match[3]}</span>" else ""
						"<span class=\"skyblue\">class</span> #{className}#{extendsKeyword}#{extendsClassName}"
					when "DefFunc"
						match = ///^(\w+) (\s?[=:]\s?) (?:(\([\w\s@,]+\)))?(\s?-&gt;)///.exec text
						func_name  = "<span class=\"green\">#{match[1]}</span>"
						assignment = "<span class=\"red\">#{match[2]}</span>"
						func_args  = if match[3] then "<span class=\"orange\">#{match[3]}</span>" else ""
						func_arrow = "<span class=\"skyblue\">#{match[4]}</span>"
						"#{func_name}#{assignment}#{func_args}#{func_arrow}"
			tokens_tmp.push( {
				type: type,
				text: highlight_text || text
			} )
		tokens = tokens_tmp.concat()

		code = []
		for token in tokens
			code.push token.text
		code = code.join("")

		# escape sequence
		code = code.replace(/(\\.)/g, ->
			"<span class=\"purple\">#{RegExp.$1}</span>")

		$(this).html(code)
		console.timeEnd('coffee highlighting');
