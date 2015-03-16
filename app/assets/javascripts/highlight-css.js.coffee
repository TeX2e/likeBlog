# css highlighting

$(document).ready ->
	$('div.markdown-body pre.css > code').each ->
		code = $(this).html()
		
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

