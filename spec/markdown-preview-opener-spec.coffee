path = require 'path'

describe "MarkdownPreviewOpener", ->
  [workspaceElement] = []

  beforeEach ->
    fixturesPath = path.join(__dirname, 'fixtures')
    atom.project.setPaths([fixturesPath])

    workspaceElement = atom.views.getView(atom.workspace)
    jasmine.attachToDOM(workspaceElement)

    waitsForPromise ->
      atom.packages.activatePackage('markdown-preview')
    waitsForPromise ->
      atom.packages.activatePackage('markdown-preview-plus')
    waitsForPromise ->
      atom.packages.activatePackage('markdown-preview-opener')

  describe "when a markdown file with a matching extension is opened", ->
    it 'triggers event markdown-preview[-plus]:toggle', ->
      waitsForPromise -> atom.workspace.open('README.md')
      runs ->
        expect(atom.workspace.getPanes()).toHaveLength 2
        expect(atom.workspace.getPanes()[1].items[0].constructor.name).toEqual('MarkdownPreviewView')
