Button = require './button.coffee'
ListButton = require './list.coffee'

class UnorderListButton extends ListButton
  type: 'ul'
  name: 'ul'
  icon: 'list-ul'
  htmlTag: 'ul'
  shortcut: 'cmd+.'
  _init: ->
    if @editor.util.os.mac
      @title = @title + ' ( Cmd + . )'
    else
      @title = @title + ' ( Ctrl + . )'
      @shortcut = 'ctrl+.'
    super

module.exports = UnorderListButton
