# c-lang highlighting

$(document).ready ->
	$('div.markdown-body pre.c > code').each ->
		console.time('c highlighting');
		code = $(this).html()

		# split token
		tokens = new SplitCToken(code).tokens

		# markup token
		tokens_tmp = []
		for token in tokens
			type = token.type
			text = token.text
			highlight_text = 
				switch type
					when "Comment" 		then "<span class=\"comment\">#{text}</span>"
					when "Str", "Tag" 	then "<span class=\"yellow\">#{text}</span>"
					when "Num", "Flag" 	then "<span class=\"purple\">#{text}</span>"
					when "InitKeyword"	then "<span class=\"skyblue\">#{text}</span>"
					when "Keyword", "Def"	then "<span class=\"red\">#{text}</span>"
			tokens_tmp.push( {
				type: type,
				text: highlight_text || text
			} )
		tokens = tokens_tmp.concat()
		
		# markup Func and Const
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
			if (before2_type == "InitKeyword" || before2_type == "Ident" || before2_type == "Const") && 
					type == "Func" && after_type == "lParen"
				type = "DefFunc"
				text = "<span class=\"green\">#{text}</span>"
			# UseFunc
			else if type == "Func" && after_type == "lParen"
				type = "UseFunc"
				text = "<span class=\"skyblue\">#{text}</span>"
			# DefConst
			else if before2_type == "Def" && type == "Const"
				type = "DefConst"
				text = "<span class=\"green\">#{text}</span>"
			tokens_tmp.push { type:type, text:text }

			
		tokens = tokens_tmp.concat()
		
		code = []
		for token in tokens
			code.push token.text
		code = code.join("")
		$(this).html(code)
		console.timeEnd('c highlighting');

		


