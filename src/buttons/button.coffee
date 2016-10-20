
class Button extends QingModule

  @opts:
    editor: null
    locales: null

  _tpl:
    item: '<li><a tabindex="-1" unselectable="on" class="toolbar-item" \
      href="javascript:;"><span></span></a></li>'
    menuWrapper: '<div class="toolbar-menu"></div>'
    menuItem: '<li><a tabindex="-1" unselectable="on" class="menu-item" \
      href="javascript:;"><span></span></a></li>'
    separator: '<li><span class="separator"></span></li>'

  name: ''

  icon: ''

  title: ''

  text: ''

  htmlTag: ''

  disableTag: ''

  menu: false

  active: false

  disabled: false

  needFocus: true

  shortcut: null

  _setOptions: (opts) ->
    super
    $.extend @opts, Button.opts, opts
    @editor = @opts.editor
    @toolbar = @opts.toolbar

  _init: ->
    @title = @_t(@name)
    @render()

    @el.on 'mousedown', (e) =>
      e.preventDefault()
      noFocus = @needFocus and !@editor.inputManager.focused
      return false if @el.hasClass('disabled') or noFocus

      if @menu
        @wrapper.toggleClass('menu-on')
          .siblings('li')
          .removeClass('menu-on')

        if @wrapper.is('.menu-on')
          exceed = @menuWrapper.offset().left + @menuWrapper.outerWidth() + 5 -
            @editor.wrapper.offset().left - @editor.wrapper.outerWidth()

          if exceed > 0
            @menuWrapper.css
              'left': 'auto'
              'right': 0

          @trigger 'menuexpand'

        return false

      param = @el.data('param')
      @command(param)
      false

    @wrapper.on 'click', 'a.menu-item', (e) =>
      e.preventDefault()
      btn = $(e.currentTarget)
      @wrapper.removeClass('menu-on')
      noFocus = @needFocus and !@editor.inputManager.focused
      return false if btn.hasClass('disabled') or noFocus

      @toolbar.wrapper.removeClass('menu-on')
      param = btn.data('param')
      @command(param)
      false

    @wrapper.on 'mousedown', 'a.menu-item', (e) ->
      false

    @editor.on 'blur', =>
      editorActive =
        @editor.body.is(':visible') and @editor.body.is('[contenteditable]')
      return unless editorActive and !@editor.clipboard.pasting
      @setActive false
      @setDisabled false


    if @shortcut?
      @editor.hotkeys.add @shortcut, (e) =>
        @el.mousedown()
        false

    for tag in @htmlTag.split ','
      tag = $.trim tag
      if tag && $.inArray(tag, @editor.formatter._allowedTags) < 0
        @editor.formatter._allowedTags.push tag

    @editor.on 'selectionchanged', (e) =>
      @_status() if @editor.inputManager.focused

  iconClassOf: (icon) ->
    if icon then "qing-editor-icon qing-editor-icon-#{icon}" else ''

  setIcon: (icon) ->
    @el.find('span')
      .removeClass()
      .addClass(@iconClassOf icon)
      .text(@text)

  render: ->
    @wrapper = $(@_tpl.item).appendTo @toolbar.list
    @el = @wrapper.find 'a.toolbar-item'

    @el.attr('title', @title)
      .addClass("toolbar-item-#{@name}")
      .data('button', @)

    @setIcon @icon

    return unless @menu

    @menuWrapper = $(@_tpl.menuWrapper).appendTo(@wrapper)
    @menuWrapper.addClass "toolbar-menu-#{@name}"
    @renderMenu()

  renderMenu: ->
    return unless $.isArray @menu

    @menuEl = $('<ul/>').appendTo @menuWrapper
    for menuItem in @menu
      if menuItem == '|'
        $(@_tpl.separator).appendTo @menuEl
        continue

      $menuItemEl = $(@_tpl.menuItem).appendTo @menuEl
      $menuBtnEl = $menuItemEl.find('a.menu-item')
        .attr(
          'title': menuItem.title ? menuItem.text,
          'data-param': menuItem.param
        )
        .addClass('menu-item-' + menuItem.name)
      if menuItem.icon
        $menuBtnEl.find('span').addClass @iconClassOf menuItem.icon
      else
        $menuBtnEl.find('span').text(menuItem.text)

  setActive: (active) ->
    return if active == @active
    @active = active
    @el.toggleClass('active', @active)

  setDisabled: (disabled) ->
    return if disabled == @disabled
    @disabled = disabled
    @el.toggleClass('disabled', @disabled)

  _disableStatus: ->
    startNodes = @editor.selection.startNodes()
    endNodes = @editor.selection.endNodes()
    disabled = startNodes.filter(@disableTag).length > 0 or
      endNodes.filter(@disableTag).length > 0
    @setDisabled disabled
    @setActive(false) if @disabled
    @disabled

  _activeStatus: ->
    startNodes = @editor.selection.startNodes()
    endNodes = @editor.selection.endNodes()
    startNode = startNodes.filter(@htmlTag)
    endNode = endNodes.filter(@htmlTag)
    active = startNode.length > 0 and endNode.length > 0 and
      startNode.is(endNode)
    @node = if active then startNode else null
    @setActive active
    @active

  _status: ->
    @_disableStatus()
    return if @disabled

    @_activeStatus()

  command: (param) ->

  _t: (key) ->
    @opts.locales[key]

module.exports = Button
