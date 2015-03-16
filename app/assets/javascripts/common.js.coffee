
$(document).ready ->
	$('.markdown-body p').each ->
		code_discription = $(this).html()

		## :code{code-type}{caption}
		code_type = ""
		code_discription = code_discription.replace(///
			:code{([^}\n]*)}\s*(?:{([^}\n]*)})?
			///, 
			->
				code_type    = RegExp.$1 || ""
				code_caption = RegExp.$2 || ""
				hidden = if code_caption == "" then ' hidden' else ''
				"<span class=\"#{code_type}#{hidden}\">#{code_caption}</span>"
		)
		$(this).html(code_discription) # pタグに対する置き換えを保存

		return if not code_type? or code_type == ""
		
		## cody-type が指定されたとき、上のcodeから順に class="cody-type" を割り当てる
		changed = false
		$('.markdown-body pre').each ->
			if changed == true
				return
			class_name = $(this).prop("class")
			if not class_name? or class_name == ""
				$(this).prop("class", code_type)  # ex: <div class="ruby">
				changed = true
				return
		return

# 主にソースコード
bright_mode = [
	"ruby", "c", "cpp", "csharp", "java", "js", "html", "css", "php", "python"
]

# 主に出力結果
little_bright_mode = [
	"console"
]

## ソースコード上部の説明
$(document).ready ->
	# hidden
	$('.markdown-body p span.hidden').each ->
		$(this).hide()
		return

$(document).ready ->
	## preのclass="type"によってソースコードの背景色を変える
	for type in bright_mode
		$("div.markdown-body pre.#{type}").each ->
			$(this).css("color", "rgba(250,250,250,1)")
			$(this).css("background-color", "rgba(40,40,40,1)")

	for type in little_bright_mode
		$("div.markdown-body pre.#{type}").each ->
			$(this).css("color", "rgba(250,250,250,1)")
			$(this).css("background-color", "rgba(60,60,60,1)")


# highlight all pre>code 
$(document).ready ->
	## text
	$('div.markdown-body pre.text > code').each ->
		code = $(this).html()
		# tab -> space
		code = code.replace(/\t/g, "    ")  # タブを空白4つに置き換え
		$(this).html(code)

	















