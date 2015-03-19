# ruby highlighting

$(document).ready ->
	$('div.markdown-body pre.ruby > code').each ->
		console.time('ruby highlighting');
		code = $(this).html()

		# split token
		tokens = new SplitRubyToken(code).tokens

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
					when "Keyword", "Def" 		then "<span class=\"red\">#{text}</span>"
					when "Ope" 		
						if text != "|" # 縦棒は記号としない ex: do |i|; end
							"<span class=\"red\">#{text}</span>"
			tokens_tmp.push( {
				type: type,
				text: highlight_text || text
			} )
		tokens = tokens_tmp.concat()
		
		# markup Func and Class
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
			if before2_type == "Def" && (type == "Func" || type == "Ident" || type == "Ope")
				type = "DefFunc"
				text = text.replace(/<[^>]*>/g, "")
				text = "<span class=\"green\">#{text}</span>"
			# Class
			if type == "Const" && after_type == "Chain"
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
			if before_type == "DefFunc" && type == "lParen"
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





