QingEditor = require '../src/qing-editor.coffee'
expect = chai.expect

describe 'QingEditor', ->

  $el = null
  qingEditor = null

  before ->
    $el = $('<textarea id="editor"></textarea>').appendTo 'body'

  after ->
    $el.remove()
    $el = null

  beforeEach ->
    qingEditor = new QingEditor
      el: '#editor'

  afterEach ->
    qingEditor.destroy()
    qingEditor = null

  it 'should inherit from QingModule', ->
    expect(qingEditor).to.be.instanceof QingModule
    expect(qingEditor).to.be.instanceof QingEditor

  it 'should throw error when element not found', ->
    spy = sinon.spy QingEditor
    try
      new spy
        el: '.not-exists'
    catch e

    expect(spy.calledWithNew()).to.be.true
    expect(spy.threw()).to.be.true
