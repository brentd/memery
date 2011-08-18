window.Memery ||= {}

class Memery.CreateMemeView extends Backbone.View
  events:
    'click .results img': 'imageClicked'

  initialize: ->
    @el = $(@el)
    @showView new Memery.ImageSearchView

  showView: (newView) ->
    if @view
      @view.el.fadeOut =>
        @el.html newView.el.fadeIn()
    else
      @el.html newView.el
    @view = newView

  imageClicked: (e) ->
    info = $(e.target).data('info')
    meme = new Memery.Meme
      image_url: info.url
      width:     info.width
      height:    info.height
    @showView new Memery.MemeEditorView(model: meme)