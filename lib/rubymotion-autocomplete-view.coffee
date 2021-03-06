_ = require 'underscore-plus'
AutocompleteView = require(atom.packages.resolvePackagePath('autocomplete') + '/lib/autocomplete-view')

module.exports =
class RubyMotionAutocompleteView extends AutocompleteView
  snippetPrefixes: []

  initialize: (@editorView) ->
    super

  buildWordList: ->
    @wordList = @snippetPrefixes

  handleEvents: ->
    @list.on 'mousewheel', (event) -> event.stopPropagation()

    @editorView.on 'editor:path-changed', => @setCurrentBuffer(@editor.getBuffer())
    @editorView.command 'rubymotion-autocomplete:toggle', =>
      if @hasParent()
        @cancel()
      else
        @attach()
    @editorView.command 'rubymotion-autocomplete:next', => @selectNextItemView()
    @editorView.command 'rubymotion-autocomplete:previous', => @selectPreviousItemView()

    @filterEditorView.preempt 'textInput', ({originalEvent}) =>
      text = originalEvent.data
      unless text.match(@wordRegex)
        @confirmSelection()
        @editor.insertText(text)
        false

  attach: ->
    word = @editor.getWordUnderCursor(includeNonWordCharacters: false)
    return if word.replace(/^\s*|\s*$/, '') is ''
    super

  confirmed: (match) ->
    @editor.getSelection().clear()
    @cancel()
    return unless match
    @replaceSelectedTextWithMatch match
    position = @editor.getCursorBufferPosition()
    @editor.setCursorBufferPosition([position.row, position.column + match.suffix.length])
    @editorView.trigger 'snippets:expand'
