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

  activate: (state) ->
    process.nextTick =>
      if not (atom.packages.getLoadedPackage 'markdown-preview')
        console.log 'markdown-preview-opener-view: markdown-preview package not found'
        return

    atom.workspace.onDidOpen(@subscribePane)

  subscribePane: (event) ->
    suffix = event?.uri?.match(/(\w*)$/)[1]
    if suffix in atom.config.get('markdown-preview-opener.suffixes')
      previewUrl = "markdown-preview://editor/#{event.item.id}"
      previewPane = atom.workspace.paneForURI(previewUrl)
      workspaceView = atom.views.getView(atom.workspace)
      if not previewPane
        atom.commands.dispatch workspaceView, 'markdown-preview:toggle'
        if atom.config.get('markdown-preview-opener.closePreviewWhenClosingEditor')
          event.item.onDidDestroy ->
            for pane in atom.workspace.getPanes()
              for item in pane.items when item.getURI() is previewUrl
                pane.destroyItem(item)
                break
