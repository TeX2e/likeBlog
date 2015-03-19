# js highlighting

$(document).ready ->
	$('div.markdown-body pre.js > code').each ->
		console.time('js highlighting');
		code = $(this).html()
		
		# split token
		tokens = new SplitJavaScriptToken(code).tokens

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
					when "Reg"
						match = ///^([=\(\[,]\s?)(\/(?:[^\\/]+|\\.)*\/[gimx]*)///.exec text
						before = match[1]
						text   = match[2]
						before = "<span class=\"red\">#{RegExp.$1}</span>" if /^(=\s?)/.test before
						"#{before}<span class=\"orange\">#{text}</span>"
					when "Num", "Sym", "Flag" 	then "<span class=\"purple\">#{text}</span>"
					when "Keyword", "Ope"		then "<span class=\"red\">#{text}</span>"
					when "Def", "InitKeyword" 	then "<span class=\"skyblue\">#{text}</span>"
					when "Const" 				then "<span class=\"skyblue\">#{text}</span>"
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
		console.timeEnd('js highlighting');

		

