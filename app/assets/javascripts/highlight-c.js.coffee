# c-lang highlighting

$(document).ready ->
	$('div.markdown-body pre.c > code').each ->
		console.time('c highlighting');
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
					when "Comment" 		then "<span class=\"comment\">#{text}</span>"
					when "Str", "Tag" 	then "<span class=\"yellow\">#{text}</span>"
					when "Num" 			then "<span class=\"purple\">#{text}</span>"
					when "Flag" 		then "<span class=\"purple\">#{text}</span>"
			# InitKeyword
			if ///^(int|float|char|long|double|unsigned|void|typedef|struct)///.test text
				type = "InitKeyword"
				highlight_text = "<span class=\"skyblue\">#{text}</span>"
			# Keyword
			if ///^(if|else|for|while|return|break|continue|include|sizeof|switch|case)///.test text
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
			if before2_type == "InitKeyword" && type == "Func" && after_type == "lParen"
				type = "DefFunc"
				text = "<span class=\"green\">#{text}</span>"
			# UseFunc
			else if type == "Func" && after_type == "lParen"
				type = "UseFunc"
				text = "<span class=\"skyblue\">#{text}</span>"
			tokens_tmp.push { type:type, text:text }
			
		tokens = tokens_tmp.concat()
		
		code = []
		for token in tokens
			code.push token.text
		code = code.join("")
		$(this).html(code)
		console.timeEnd('c highlighting');

		


