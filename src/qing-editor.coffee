locales = require './i18n.coffee'
util = require './util.coffee'
Hotkeys = require './hotkeys.coffee'
InputManager = require './input-manager.coffee'
Selection = require './selection.coffee'
UndoManager = require './undo-manager.coffee'
Keystroke = require './keystroke.coffee'
Formatter = require './formatter.coffee'
Toolbar = require './toolbar.coffee'
Indentation = require './indentation.coffee'
Clipboard = require './clipboard.coffee'
Button = require './buttons/button.coffee'
Popover = require './buttons/popover.coffee'

class QingEditor extends QingModule

  name: 'QingEditor'

  @opts:
    el: null
    placeholder: ''
    defaultImage: 'images/image.png'
    params: {}
    upload: false
    indentWidth: 40
    pasteImage: false
    cleanPaste: false
    allowedTags: []
    allowedAttributes: {}
    allowedStyles: {}
    tabIndent: true
    toolbar: true
    toolbarFloat: true
    toolbarHidden: false
    toolbarFloatOffset: 0
    locales: locales

  @count: 0

  @_tpl: """
    <div class="qing-editor">
      <div class="qing-editor-wrapper">
        <div class="qing-editor-placeholder"></div>
        <div class="qing-editor-body" contenteditable="true">
        </div>
      </div>
    </div>
  """

  _setOptions: (opts) ->
    super
    $.extend @opts, QingEditor.opts, opts

  _init: ->
    @textarea = $(@opts.el)
    @opts.placeholder = @opts.placeholder || @textarea.attr('placeholder')
    @locales = @opts.locales
    @util = util

    unless @textarea.length
      throw new Error 'qing-editor: param el is required.'
      return

    editor = @textarea.data 'qing-editor'
    if editor?
      editor.destroy()

    @id = ++ QingEditor.count
    @_render()
    @_initChildComponents()

    form = @textarea.closest 'form'
    if form.length
      form.on 'submit.qing-editor-' + @id, =>
        @sync()
      form.on 'reset.qing-editor-' + @id, =>
        @setValue ''

    if @opts.placeholder
      @on 'valuechanged', =>
        @_placeholder()

    @setValue @textarea.val().trim() || ''

    if @textarea.attr 'autofocus'
      @focus()

    # Disable the resizing of `img` and `table`
    if @util.browser.mozilla
      @util.reflow()
      try
        document.execCommand 'enableObjectResizing', false, false
        document.execCommand 'enableInlineTableEditing', false, false
      catch e

  _render: ->
    @el = $(QingEditor._tpl).insertBefore @textarea
    @wrapper = @el.find '.qing-editor-wrapper'
    @body = @wrapper.find '.qing-editor-body'
    @placeholderEl = @wrapper.find('.qing-editor-placeholder')
      .append(@opts.placeholder)

    @el.data 'qingEditor', @
    @wrapper.append(@textarea)
    @textarea.data('qingEditor', @).blur()
    @body.attr 'tabindex', @textarea.attr('tabindex')

    if @util.os.mac
      @el.addClass 'qing-editor-mac'
    else if @util.os.linux
      @el.addClass 'qing-editor-linux'

    if @util.os.mobile
      @el.addClass 'qing-editor-mobile'

    if @opts.params
      for key, val of @opts.params
        $('<input/>', {
          type: 'hidden'
          name: key,
          value: val
        }).insertAfter(@textarea)

  _initChildComponents: ->
    @hotkeys = new Hotkeys
      el: @body

    if @opts.upload and simpleUploader
      uploadOpts = if typeof @opts.upload == 'object' then @opts.upload else {}
      @uploader = new QingUploader uploadOpts

    @inputManager = new InputManager
      editor: @
      tabIndent: @opts.tabIndent

    @selection = new Selection
      editor: @

    @undoManager = new UndoManager
      editor: @

    @keystroke = new Keystroke
      editor: @

    @formatter = new Formatter
      editor: @
      allowedTags: @opts.allowedTags
      allowedAttributes: @opts.allowedAttributes
      allowedStyles: @opts.allowedStyles

    @toolbar = new Toolbar
      editor: @
      toolbar: @opts.toolbar
      toolbarFloat: @opts.toolbarFloat
      toolbarHidden: @opts.toolbarHidden
      toolbarFloatOffset: @opts.toolbarFloatOffset

    @indentation = new Indentation
      tabIndent: @opts.tabIndent
      editor: @

    @clipboard = new Clipboard
      editor: @
      pasteImage: @opts.pasteImage
      cleanPaste: @opts.cleanPaste

  _placeholder: ->
    children = @body.children()
    if children.length == 0 or (children.length == 1 and
        @util.isEmptyNode(children) and
        parseInt(children.css('margin-left') || 0) < @opts.indentWidth)
      @placeholderEl.show()
    else
      @placeholderEl.hide()

  setValue: (val) ->
    @hidePopover()
    @textarea.val val
    @body.get(0).innerHTML = val

    @formatter.format()
    @formatter.decorate()

    @util.reflow @body
    @inputManager.lastCaretPosition = null
    @trigger 'valuechanged'

  getValue: () ->
    @sync()

  sync: ->
    cloneBody = @body.clone()
    @formatter.undecorate cloneBody
    @formatter.format cloneBody

    # generate `a` tag automatically
    @formatter.autolink cloneBody

    # remove empty `p` tag at the start/end of content
    children = cloneBody.children()
    lastP = children.last 'p'
    firstP = children.first 'p'
    while lastP.is('p') and @util.isEmptyNode(lastP)
      emptyP = lastP
      lastP = lastP.prev 'p'
      emptyP.remove()
    while firstP.is('p') and @util.isEmptyNode(firstP)
      emptyP = firstP
      firstP = lastP.next 'p'
      emptyP.remove()

    # remove images being uploaded
    cloneBody.find('img.uploading').remove()

    val = $.trim(cloneBody.html())
    @textarea.val val
    val

  focus: ->
    unless @body.is(':visible') and @body.is('[contenteditable]')
      @el.find('textarea:visible').focus()
      return

    if @inputManager.lastCaretPosition
      @undoManager.caretPosition @inputManager.lastCaretPosition
      @inputManager.lastCaretPosition = null
    else
      $blockEl = @body.children().last()
      unless $blockEl.is('p')
        $blockEl = $('<p/>').append(@util.phBr).appendTo(@body)
      range = document.createRange()
      @selection.setRangeAtEndOf $blockEl, range

  blur: ->
    if @body.is(':visible') and @body.is('[contenteditable]')
      @body.blur()
    else
      @body.find('textarea:visible').blur()

  hidePopover: ()->
    @el.find('.qing-editor-popover').each (i, popover) ->
      popover = $(popover).data('popover')
      popover.hide() if popover.active

  destroy: ->
    @trigger 'destroy'

    @textarea.closest('form')
      .off('.qing-editor .qing-editor-' + @id)

    @selection.clear()
    @inputManager.focused = false

    @textarea.insertBefore(@el)
      .hide()
      .val('')
      .removeData 'qingEditor'

    @el.remove()
    $(document).off '.qing-editor-' + @id
    $(window).off '.qing-editor-' + @id
    @off()

QingEditor.Toolbar = Toolbar
QingEditor.Button = Button
QingEditor.Popover = Popover

module.exports = QingEditor
