window.Memery ||= {}

# A place to store object data on pageload
Memery.data = {}

class Memery.App extends Backbone.View
  events:
    'click #create-button': 'toggleCreateView'

  initialize: ->
    _.bindAll this, 'hideCreateView'
    # Create collection global
    Memery.memes = new Memery.Memes(Memery.data.memes)
    Memery.memes.bind 'add', @hideCreateView
    new Memery.MemeListView
      el: @$('#meme-list')
      collection: Memery.memes

  hideCreateView: ->
    if @createView
      @createView.el.fadeOut()
      @createView = null
      @$('#create-button').removeClass('active')

  toggleCreateView: ->
    if @createView
      @createView.el.fadeOut()
      @createView = null
    else
      @createView = new Memery.CreateMemeView(el: $('#create-meme'))
      @createView.el.fadeIn()
    @$('#create-button').toggleClass('active')

# Boot the app when the DOM is ready
$ -> Memery.app = new Memery.App(el: $('body'))
