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
					# when "Reg"
					# 	match = ///^([=\(\[,]\s?) ((\/\/\/|\/) (?:[^\\/]+|\\.)* \3 [gimx]*)///.exec text
					# 	before = match[1]
					# 	text   = match[2]
					# 	before = "<span class=\"red\">#{RegExp.$1}</span>" if /^(=\s?)/.test before
					# 	"#{before}<span class=\"orange\">#{text}</span>"
					when "Reg", "RegMul"		then "<span class=\"orange\">#{text}</span>"
					when "Num", "Sym", "Flag" 	then "<span class=\"purple\">#{text}</span>"
					when "Keyword", "Ope"		then "<span class=\"red\">#{text}</span>"
					when "DefFunc" 				then "<span class=\"skyblue\">#{text}</span>"
					when "Const" 				then "<span class=\"skyblue\">#{text}</span>"
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