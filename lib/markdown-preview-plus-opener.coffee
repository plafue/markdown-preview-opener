{CompositeDisposable} = require 'atom'

module.exports = MarkdownPreviewPlusOpener =
  config:
    suffixes:
      type: 'array'
      default: ['markdown', 'md', 'mdown', 'mkd', 'mkdow']
      items:
        type: 'string'
    closePreviewWhenClosingEditor:
      type: 'boolean'
      default: false

  activate: (state) ->
    process.nextTick =>
      if not (atom.packages.getLoadedPackage 'markdown-preview-plus')
        console.log 'markdown-preview-plus-opener-view: markdown-preview-plus package not found'
        return

    atom.workspace.onDidOpen(@subscribePane)

  subscribePane: (event) ->
    suffix = event?.uri?.match(/(\w*)$/)[1]
    if suffix in atom.config.get('markdown-preview-plus-opener.suffixes')
      previewUrl = "markdown-preview-plus://editor/#{event.item.id}"
      previewPane = atom.workspace.paneForURI(previewUrl)
      workspaceView = atom.views.getView(atom.workspace)
      if not previewPane
        atom.commands.dispatch workspaceView, 'markdown-preview-plus:toggle'
        if atom.config.get('markdown-preview-plus-opener.closePreviewWhenClosingEditor')
          event.item.onDidDestroy ->
            for pane in atom.workspace.getPanes()
              for item in pane.items when item.getURI() is previewUrl
                pane.destroyItem(item)
                break
