
class Toolbar extends QingModule

  @name: 'Toolbar'

  @opts:
    el: null
    toolbar: true
    toolbarFloat: true
    toolbarHidden: false
    toolbarFloatOffset: 0

  _tpl:
    wrapper: '<div class="qing-editor-toolbar"><ul></ul></div>'
    separator: '<li><span class="separator"></span></li>'

  _setOptions: (opts) ->
    super
    $.extend @opts, Toolbar.opts, opts

  _init: ->
    @editor = @opts.editor
    return unless @opts.toolbar

    unless $.isArray @opts.toolbar
      @opts.toolbar = ['bold', 'italic', 'underline', 'strikethrough', '|',
        'ol', 'ul', 'blockquote', 'code', '|', 'link', 'image', '|',
        'indent', 'outdent']

    @_render()

    @list.on 'click', (e) ->
      false

    @wrapper.on 'mousedown', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    $(document).on 'mousedown.qing-editor' + @editor.id, (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    if not @opts.toolbarHidden and @opts.toolbarFloat
      @wrapper.css 'top', @opts.toolbarFloatOffset
      toolbarHeight = 0

      initToolbarFloat = =>
        @wrapper.css 'position', 'static'
        @wrapper.width 'auto'
        @editor.util.reflow @wrapper
        @wrapper.width @wrapper.outerWidth() # set width for fixed element
        @wrapper.css 'left', if @editor.util.os.mobile
          @wrapper.position().left
        else
          @wrapper.offset().left
        @wrapper.css 'position', ''
        toolbarHeight = @wrapper.outerHeight()
        @editor.placeholderEl.css 'top', toolbarHeight
        true

      floatInitialized = null
      $(window).on 'resize.qing-editor-' + @editor.id, (e) ->
        floatInitialized = initToolbarFloat()

      $(window).on 'scroll.qing-editor-' + @editor.id, (e) =>
        return unless @wrapper.is(':visible')
        topEdge = @editor.wrapper.offset().top
        bottomEdge = topEdge + @editor.wrapper.outerHeight() - 80
        scrollTop = $(document).scrollTop() + @opts.toolbarFloatOffset

        if scrollTop <= topEdge or scrollTop >= bottomEdge
          @editor.wrapper.removeClass('toolbar-floating')
            .css('padding-top', '')
          if @editor.util.os.mobile
            @wrapper.css 'top', @opts.toolbarFloatOffset
        else
          floatInitialized ||= initToolbarFloat()
          @editor.wrapper.addClass('toolbar-floating')
            .css('padding-top', toolbarHeight)
          if @editor.util.os.mobile
            @wrapper.css 'top', scrollTop - topEdge + @opts.toolbarFloatOffset

    @editor.on 'destroy', =>
      @buttons.length = 0

    $(document).on "mousedown.qing-editor-#{@editor.id}", (e) =>
      @list.find('li.menu-on').removeClass('menu-on')

  _render: ->
    @buttons = []
    @wrapper = $(@_tpl.wrapper).prependTo(@editor.wrapper)
    @list = @wrapper.find('ul')

    for name in @opts.toolbar
      if name == '|'
        $(@_tpl.separator).appendTo @list
        continue

      unless @constructor.buttons[name]
        throw new Error "qing-editor: invalid toolbar button #{name}"
        continue

      @buttons.push new @constructor.buttons[name]
        editor: @editor
        toolbar: @
        locales: @editor.locales

    @wrapper.hide() if @opts.toolbarHidden

  findButton: (name) ->
    button = @list.find('.toolbar-item-' + name).data('button')
    button ? null

  @addButton: (btn) ->
    @buttons[btn::name] = btn

  @buttons: {}


Toolbar.addButton require('./buttons/alignment.coffee')
Toolbar.addButton require('./buttons/blockquote.coffee')
Toolbar.addButton require('./buttons/bold.coffee')
Toolbar.addButton require('./buttons/code.coffee')
Toolbar.addButton require('./buttons/color.coffee')
Toolbar.addButton require('./buttons/font-scale.coffee')
Toolbar.addButton require('./buttons/hr.coffee')
Toolbar.addButton require('./buttons/image.coffee')
Toolbar.addButton require('./buttons/indent.coffee')
Toolbar.addButton require('./buttons/italic.coffee')
Toolbar.addButton require('./buttons/link.coffee')
Toolbar.addButton require('./buttons/order-list.coffee')
Toolbar.addButton require('./buttons/unorder-list.coffee')
Toolbar.addButton require('./buttons/outdent.coffee')
Toolbar.addButton require('./buttons/popover.coffee')
Toolbar.addButton require('./buttons/strikethrough.coffee')
Toolbar.addButton require('./buttons/table.coffee')
Toolbar.addButton require('./buttons/title.coffee')
Toolbar.addButton require('./buttons/underline.coffee')

module.exports = Toolbar
