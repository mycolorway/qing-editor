Button = require './button.coffee'
ListButton = require './list.coffee'

class OrderListButton extends ListButton
  type: 'ol'
  name: 'ol'
  icon: 'list-ol'
  htmlTag: 'ol'
  shortcut: 'cmd+/'
  _init: ->
    if @editor.util.os.mac
      @title = @title + ' ( Cmd + / )'
    else
      @title = @title + ' ( ctrl + / )'
      @shortcut = 'ctrl+/'
    super

module.exports = OrderListButton
