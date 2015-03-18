# css highlighting

$(document).ready ->
	$('div.markdown-body pre.css > code').each ->
		console.time('css highlighting');
		code = $(this).html()

		# split token
		tokens = new SplitCSSToken(code).tokens

		# for token in tokens
		# 	console.log "#{token.type} : #{token.text}"
		
		# markup token
		tokens_tmp = []
		for token in tokens
			type = token.type
			text = token.text
			highlight_text = 
				switch type
					when "Comment" 			then "<span class=\"comment\">#{text}</span>"
					when "Str"				then "<span class=\"yellow\">#{text}</span>"
					when "HTMLTag", "Unit"	then "<span class=\"red\">#{text}</span>"
					when "Attr"				then "<span class=\"green\">#{text}</span>"
					when "Prop"				then "<span class=\"skyblue\">#{text}</span>"
					when "Num"				then "<span class=\"purple\">#{text}</span>"
					when "Ident", "Const"	then "<span class=\"yellow\">#{text}</span>"
					when "Func"				then "<span class=\"skyblue\">#{text}</span>"
					when "Selector", "Control"	then "<span class=\"red\">#{text}</span>"
			tokens_tmp.push( {
				type: type,
				text: highlight_text || text
			} )
		tokens = tokens_tmp.concat()

		# array -> string
		code = []
		for token in tokens
			code.push token.text
		code = code.join("")

		$(this).html(code)
		console.timeEnd('css highlighting');

		###
		
		## tab -> space
		code = code.replace(/\t/g, "    ")

		code = code.replace(///
			([^-])\b(
				a|abbr|acronym|address|area|article|aside|audio|b|base|big|blockquote
				|body|br|button|canvas|caption|cite|code|col|colgroup|datalist|dd|del
				|details|dfn|dialog|div|dl|dt|em|eventsource|fieldset|figure|figcaption
				|footer|form|frame|frameset|(h[1-6])|head|header|hgroup|hr|html|i|iframe
				|img|input|ins|kbd|label|legend|li|link|map|mark|menu|meta|meter|nav
				|noframes|noscript|object|ol|optgroup|option|output|p|param|pre|progress
				|q|samp|script|section|select|small|span|strike|strong|style|sub|summary
				|sup|table|tbody|td|textarea|tfoot|th|thead|time|title|tr|tt|ul|var|video
			)\b(?![-;])
			///g,
			->
				before  = RegExp.$1 || ""
				htmltag = RegExp.$2 || ""
				"#{before}${red:::#{htmltag}}"
		)

		## className, id, status
		code = code.replace(///
			([^:])  # not started with colon
			([:.\#][-\w]+)  # capture :name or .name or #name
			(?=\s|,)
			///g,
			->
				before = RegExp.$1 || ""
				attr   = RegExp.$2 || ""
				"#{before}${green:::#{attr}}"
		)

		## prop (ex: [prop="val"]
		code = code.replace(///
			\[
				([-\w]+)
				(?: (\s*~?=\s*) ("[^"]*") )?
			\]
			///g,
			->
				prop = RegExp.$1 || ""
				eq   = RegExp.$2 || ""
				val  = RegExp.$3 || ""
				"[${green:::#{prop}}#{eq}${yellow:::#{val}}]"
		)

		## propaty
		code = code.replace(///
			([-\w]+):(?!:) # capture prop
			([^;]+);       # capture val
			///g,
			->
				prop = RegExp.$1 || ""
				val  = RegExp.$2 || ""
				# replace words
				val = val.replace(///
					([^\d\#])\b([-a-z_]+)\b(?!\()
					///gi, 
					"$1${yellow:::$2}"
				)
				# replace function
				val = val.replace(///
					([^\d\#])\b([-a-z_]+)\b\(
					///gi, 
					"$1${sky-blue:::$2}("
				)
				# replace number
				val = val.replace(///
					( -?\d+ | \#[\da-f]{6} | \#[\da-f]{3} )
					///gi, 
					"${purple:::$1}"
				)
				# replace unit
				val = val.replace(///
					( em|px|% )
					///gi, 
					"${red:::$1}"
				)

				"${sky-blue:::#{prop}}:#{val};"
		)

		## 中間言語をhtmlタグに変換する
		## convert ${xxx:::content} -> <div class="xxx">content</div>
		code = code.replace(///
			\$\{   #  { で囲まれた中間言語
				([^:]+):::([^}]*)
			\}
			///g, 
			->
				class_name = RegExp.$1 || RegExp.$3 || RegExp.$5 || ""
				content    = RegExp.$2 || RegExp.$4 || RegExp.$6 || ""
				"<dvi class=\"#{class_name}\">#{content}</dvi>"
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

