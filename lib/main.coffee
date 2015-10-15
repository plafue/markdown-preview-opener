class MarkdownPreviewOpener

  config:
    suffixes:
      type: 'array'
      default: ['markdown', 'md', 'mdown', 'mkd', 'mkdow']
      items:
        type: 'string'
    closePreviewWhenClosingEditor:
      type: 'boolean'
      default: false
    activatePreviewOnActivatingEditor:
      type: 'boolean'
      default: false

  activate: (state) ->
    process.nextTick =>
      if not (previewPackage = atom.packages.getLoadedPackage 'markdown-preview')
        if not (previewPackage = atom.packages.getLoadedPackage 'markdown-preview-plus')
          console.log 'markdown-preview-opener: markdown preview packages not found'
          return

      @previewName = previewPackage.name

      {CompositeDisposable} = require 'atom'
      @subs                 = new CompositeDisposable

      @subs.add atom.workspace.onDidOpen (event) =>
        @checkMarkdown(event.item, true)

      if atom.config.get('markdown-preview-opener.activatePreviewOnActivatingEditor')
        @subs.add atom.workspace.onDidChangeActivePaneItem (item) =>
          @checkMarkdown(item, false)

  deactivate: ->
    @subs.dispose()

  checkMarkdown: (editor, openIfClosed) ->
    process.nextTick =>
      {TextEditor} = require 'atom'
      if editor? and (editor instanceof TextEditor)
        suffix = editor.getBuffer()?.getUri()?.match(/(\w*)$/)[1]
        if suffix in atom.config.get('markdown-preview-opener.suffixes')
          previewUri = "#{@previewName}://editor/#{editor.id}"
          previewPane = atom.workspace.paneForURI(previewUri)
          if previewPane?
            previewPane.activateItemForURI(previewUri)
          else if openIfClosed
            @openMarkdownPreview(editor)

  openMarkdownPreview: (editor) ->
    workspaceView = atom.views.getView(atom.workspace)
    atom.commands.dispatch workspaceView, "#{@previewName}:toggle"
    if atom.config.get('markdown-preview-opener.closePreviewWhenClosingEditor')
      @subs.add editor.onDidDestroy =>
        previewUri = "#{@previewName}://editor/#{editor.id}"
        for pane in atom.workspace.getPanes()
          for item in pane.items when item.getURI() is previewUri
            pane.destroyItem(item)
            break

module.exports = new MarkdownPreviewOpener
