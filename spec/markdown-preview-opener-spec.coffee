describe "MarkdownPreviewOpener", ->
  [workspaceElement, markdownPreviewactivAtionPromise, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    markdownPreviewactivAtionPromise = atom.packages.activatePackage('markdown-preview')
    activationPromise = atom.packages.activatePackage('markdown-preview-opener')

  describe "when a markdown file is opened a 'markdown-preview:toggle' event ", ->
    it "is triggered if the file has the right extension", ->
      waitsForPromise ->
        expectedLength = atom.workspace.getPanes().length + 1
        atom.workspace.open('c.md').then (editor) ->
          expect(atom.workspace.getPanes().length).toEqual(expectedLength)
          expect(atom.workspace.getPanes()[1].items[0].constructor.name).toEqual('MarkdownPreviewView')
