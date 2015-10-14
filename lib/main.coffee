{CompositeDisposable} = require 'atom'

module.exports = MarkdownPreviewOpener =

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

      atom.workspace.onDidOpen (event) =>
        @previewMarkdown(event.item, true)

      if atom.config.get('markdown-preview-opener.activatePreviewOnActivatingEditor')
        atom.workspace.onDidChangeActivePaneItem (item) =>
          @previewMarkdown(item, false)

  previewMarkdown: (editor, openIfClosed) ->
    process.nextTick =>
      if not (editor is atom.workspace.getActiveTextEditor())
        return

      suffix = editor?.getBuffer()?.getUri()?.match(/(\w*)$/)[1]
      if not (suffix in atom.config.get('markdown-preview-opener.suffixes'))
        return

      previewUri = "#{@previewName}://editor/#{editor.id}"
      previewPane = atom.workspace.paneForURI(previewUri)
      if previewPane?
        previewPane.activateItemForURI(previewUri)
        return

      if not openIfClosed
        return

      workspaceView = atom.views.getView(atom.workspace)
      command = "#{@previewName}:toggle"
      atom.commands.dispatch workspaceView, command
      if atom.config.get('markdown-preview-opener.closePreviewWhenClosingEditor')
        editor.onDidDestroy ->
          for pane in atom.workspace.getPanes()
            for item in pane.items when item.getURI() is previewUri
              pane.destroyItem(item)
              break
