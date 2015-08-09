describe "MarkdownPreviewPlusOpener", ->
  [workspaceElement, markdownPreviewPlusactivAtionPromise, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    markdownPreviewPlusactivAtionPromise = atom.packages.activatePackage('markdown-preview-plus')
    activationPromise = atom.packages.activatePackage('markdown-preview-plus-opener')

  describe "when a markdown file is opened a 'markdown-preview-plus:toggle' event ", ->
    it "is triggered if the file has the right extension", ->
      waitsForPromise ->
        expectedLength = atom.workspace.getPanes().length + 1
        atom.workspace.open('c.md').then (editor) ->
          expect(atom.workspace.getPanes().length).toEqual(expectedLength)
          expect(atom.workspace.getPanes()[1].items[0].constructor.name).toEqual('MarkdownPreviewView')
