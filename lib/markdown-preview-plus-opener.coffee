{CompositeDisposable} = require 'atom'

previewMarkdown = (editor, openIfClosed) ->
  if not (editor? and editor is atom.workspace.getActiveTextEditor())
    return

  suffix = editor.getBuffer().getUri().match(/(\w*)$/)[1]
  if not (suffix in atom.config.get('markdown-preview-plus-opener.suffixes'))
    return

  previewUri = "markdown-preview-plus://editor/#{editor.id}"
  previewPane = atom.workspace.paneForURI(previewUri)
  if previewPane?
    previewPane.activateItemForURI(previewUri)
    return

  if not openIfClosed
    return

  workspaceView = atom.views.getView(atom.workspace)
  atom.commands.dispatch workspaceView, 'markdown-preview-plus:toggle'
  if atom.config.get('markdown-preview-plus-opener.closePreviewWhenClosingEditor')
    editor.onDidDestroy ->
      for pane in atom.workspace.getPanes()
        for item in pane.items when item.getURI() is previewUri
          pane.destroyItem(item)
          break

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
    activatePreviewOnActivatingEditor:
      type: 'boolean'
      default: false

  activate: (state) ->
    process.nextTick =>
      if not (atom.packages.getLoadedPackage 'markdown-preview-plus')
        console.log 'markdown-preview-plus-opener-view: markdown-preview-plus package not found'
        return

      atom.workspace.onDidOpen(@subscribePane)
      if atom.config.get('markdown-preview-plus-opener.activatePreviewOnActivatingEditor')
        atom.workspace.onDidChangeActivePaneItem(@subscribePaneItem)

  subscribePane: (event) ->
    process.nextTick => previewMarkdown(event.item, true)

  subscribePaneItem: (item) ->
    process.nextTick => previewMarkdown(item, false)

