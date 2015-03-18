# html highlighting

$(document).ready ->
	$('div.markdown-body pre.html > code').each ->
		code = $(this).html()
		
		# split token
		tokens = new SplitHTMLToken(code).tokens

		# for token in tokens
		# 	console.log "#{token.type} : #{token.text}"
		
		# markup token
		tokens_tmp = []
		isInHTMLTag = false
		for token in tokens
			type = token.type
			text = token.text

			if type == "lt"
				isInHTMLTag = true
			if type == "gt"
				isInHTMLTag = false

			highlight_text = ""
			if type == "Comment"
				highlight_text = "<span class=\"comment\">#{text}</span>"
			if isInHTMLTag
				highlight_text = 
					switch type
						when "Str"		then "<span class=\"yellow\">#{text}</span>"
						when "Ident"	then type = "HTMLIdent"; text
			tokens_tmp.push( {
				type: type,
				text: highlight_text || text
			} )
		tokens = tokens_tmp.concat()
		
		# markup html tag
		tokens_tmp = []
		for key, token of tokens
			key = Number(key)
			before2_type = if tokens[key-2] then tokens[key-2].type else "_out_of_bounds"
			before_type  = if tokens[key-1] then tokens[key-1].type else "_out_of_bounds"
			type = token.type
			text = token.text
			after_type  = if tokens[key+1] then tokens[key+1].type else "_out_of_bounds"
			if (before_type == "lt" || before2_type == "lt") && type == "HTMLIdent"
				type = "HTMLTag"
				text = "<span class=\"red\">#{text}</span>"
			if type == "HTMLIdent"
				text = "<span class=\"green\">#{text}</span>"
			tokens_tmp.push { type:type, text:text }
		tokens = tokens_tmp.concat()

		# array -> string
		code = []
		for token in tokens
			code.push token.text
		code = code.join("")

		# escape sequence
		code = code.replace(/(&amp;[a-z#\d]+;)/g, ->
			"<span class=\"purple\">#{RegExp.$1}</span>")

		code = $(this).html(code)




