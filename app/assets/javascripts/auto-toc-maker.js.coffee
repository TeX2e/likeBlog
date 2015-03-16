# auto TOC maker

# add_indent = (level)->
#   indent = ""
#   for i in [1..level]
#     indent += "　"
#   return indent

$(document).ready ->
	toc = document.getElementById('TOC')
	if not toc
		toc = document.createElement('div')
		toc.id = "TOC"
		document.body.insertBefore(toc, document.body.firstChild)

	body = document.body.innerHTML

	headings = document.querySelectorAll('h1,h2,h3,h4,h5,h6')

	sectionNumbers = [0,0,0,0,0,0]

	for heading in headings
		continue if heading.parentNode == toc
		level = parseInt(heading.tagName.charAt(1))
		continue if isNaN(level) or level < 2 or 6 < level 
		sectionNumbers[level - 1] += 1
		for i in [level..6]
			sectionNumbers[i] = 0

		sectionNumber = sectionNumbers.slice(1,level).join(".")

		span = document.createElement('span')
		span.className = "TOCSectNum"
		span.innerHTML = "<span style=\"font-size: 80%;\">#{sectionNumber}</span> "
		# span.innerHTML = add_indent(level)
		heading.insertBefore(span, heading.firstChild)

		anchor = document.createElement('a')
		anchor.name = "TOC" + sectionNumber
		heading.parentNode.insertBefore(anchor, heading)

		link = document.createElement('a')
		link.href = "#TOC" + sectionNumber
		link.innerHTML = heading.innerHTML

		entry = document.createElement('div')
		entry.className = "TOCEntry TOCLevel" + level
		entry.appendChild(link)

		toc.appendChild(entry)
			