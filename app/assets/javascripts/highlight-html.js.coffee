# html highlighting

$(document).ready ->
	$('div.markdown-body pre.html > code').each ->
		code = $(this).html()
		
		## tab -> space
		code = code.replace(/\t/g, "  ")

		## html tag
		code = code.replace(///
			&lt;
				(\/)?  # start or end tag
				(\w+)  # tag name
				(\s+(?:[^&]+|&(?!gt;))+)?  # attrs
			&gt;
			///g, 
			->
				slash    = RegExp.$1 || ""
				html_tag = RegExp.$2 || ""
				attrs    = RegExp.$3 || ""
				# 属性のハイライト
				# attr=" にマッチする
				attrs = attrs.replace(///
					\b([-\w]+\s*)=\s*"
					///g,
					->
						attr = RegExp.$1 || ""
						"${green:::#{attr}}=\""
				)
				# 文字列のハイライト
				attrs = attrs.replace(///
					("(?:[^\\"\n]+|\\.)*")
					///g,
					->
						attr = RegExp.$1 || ""
						"$s{yellow:::#{attr}}s$"
				)
				return "&lt;#{slash}${red:::#{html_tag}}#{attrs}&gt;"
		)

		# escape-squence
		code = code.replace(///
			(&amp;\w+;)
			///g,
			->
				escape = RegExp.$1 || ""
				"${purple:::#{escape}}"
		)

		## 中間言語をhtmlタグに変換する
		## convert ${xxx:::content} -> <div class="xxx">content</div>
		code = code.replace(///
			\$\{   #  { で囲まれた中間言語  # 普通
				([^:]+):::([^}]+)
			\}
			|
			\$s\{  # h{ で囲まれた中間言語  # 文字列
				([^:]+):::((?:[^}]+|\}r\$)+)
			\}s\$
			///g, 
			->
				class_name = RegExp.$1 || RegExp.$3 || RegExp.$5 || ""
				content    = RegExp.$2 || RegExp.$4 || RegExp.$6 || ""
				"<dvi class=\"#{class_name}\">#{content}</dvi>"
		)

		## comment
		code = code.replace(///
			( &lt;!--
				(?:[^-]+|-(?!-&gt;))*
			--&gt; )
			///g,
			->
				comment = RegExp.$1 || ""
				comment = comment.replace(/<[^>]+>/g, "")
				"<dvi class=\"comment\">#{comment}</dvi>"
		)

		code = $(this).html(code)



