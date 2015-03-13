# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

###
$("script.tag-into-space").append ->
  addStr = (elm, str)->
    elm  = $( "#" + elm ).get(0)　# $("#" + elm)[0]; でも可
    sPos = elm.selectionStart
    ePos = elm.selectionEnd
    addStr = elm.value.substr(0, sPos) + str + elm.value.substr(ePos);
    cPos = sPos + str.length
    $(elm).val(addStr)
    elm.setSelectionRange(cPos, cPos)
    return
  
  $("textarea").focus ->
    window.document.onkeydown = (e)->
      if e.keyCode == 9  # 9 = Tab
        addStr(this.activeElement.id, "  ") # 空白を追加文字として引数に
        e.preventDefault(); # デフォルト動作停止
        return

  $("textarea").blur ->
    window.document.onkeydown = (e)->
      true


window.textarea_auto_height = ->
  $("textarea").each ->
    textarea_val = $(this).text()
    console.log textarea_val
    line_match = textarea_val.match(/\n|\r\n/g)
    if textarea_val == ""
      $(this).css("height", "10em")
      return
    if line_match?
      line_num = line_match.length + 1
    else 
      return
    if line_num == 10
      return
    $(this).css("height", line_num + "em")
    return

###





