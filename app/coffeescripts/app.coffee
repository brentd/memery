window.Memery ?= {}

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


class Memery.MemeListView extends Backbone.View
  initialize: ->
    @el = $(@el)
    @list = @el
    _.bindAll this, 'added'
    @collection.bind 'add', @added
    @render()

  added: (model) ->
    @list.prepend @makeListItem(model).fadeIn()

  makeListItem: (model) ->
    if model.has 'url'
      $ @make('li', null, @make('img', src: model.get('url')))

  render: ->
    @list.empty()
    for model in @collection.models
      @list.append @makeListItem(model)


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
    @showView new Memery.MemeEditor(model: meme)



class Memery.ImageSearchView extends Backbone.View
  id: 'image-search'

  events:
    'keyup .query': 'queryChanged'

  initialize: ->
    @el = $(@el)
    console.log @el
    @el.html $('#image-search-template').html()
    @queryInput = @$('.query')
    @resultsTable = @$('.results')
    # Set up Google's image search API
    @imageSearch = new google.search.ImageSearch()
    @imageSearch.setSearchCompleteCallback(this, @render)
    @imageSearch.setResultSetSize(8) # 8 is the max :(

  # Callback when the users types in the query box. Throttled with
  # underscore's debounce to prevent repeated calls for each keypress.
  queryChanged: _.debounce (->@search()), 1000

  search: ->
    query = @queryInput.val()
    if query != @lastQuery
      @lastQuery = query
      @imageSearch.execute(query)

  render: ->
    @resultsTable.empty()
    for obj, i in @imageSearch.results
      if i == 0 or i % 4 == 0
        @resultsTable.append(tr = $(@make 'tr'))
      # Create the img element and store the API info for future use
      img = $(@make 'img', src: obj.tbUrl)
      img.data(info: obj)
      tr.append(@make 'td', null, img)


class Memery.MemeEditor extends Backbone.View
  id: 'meme-editor'

  events:
    'keyup input': 'textChanged'

  initialize: ->
    @el = $(@el)
    @el.html $('#meme-editor-template').html()
    @topInput = @$('input.top')
    @bottomInput = @$('input.bottom')
    # Canvas setup
    @canvas  = @$('canvas').get(0)
    @context = @canvas.getContext('2d')
    # Get started by loading the meme's image
    @loadImage()

  textChanged: (event) ->
    @model.set top: @topInput.val(), bottom: @bottomInput.val()
    @render()
    if event.keyCode == 13
      @save()

  save: ->
    # Save the canvas' base64 PNG representation to the model so it can be sent up
    @model.set base64: @canvas.toDataURL()
    @model.save {},
      success: => Memery.memes.add @model

  loadImage: ->
    @setDimensions()
    if @model.has 'image_url'
      @image = new Image()
      @image.src = "/proxyimage?url=#{@model.get 'image_url'}"
      @image.onload = =>
        @complete = true
        @render()

  setDimensions: ->
    if @model.has('width') and @model.has('height')
      $(@canvas).attr
        width:  @model.get 'width'
        height: @model.get 'height'

  render: ->
    return unless @image and @complete
    # Reset the models' width/height based on the loaded image
    @model.set width: @image.width, height: @image.height
    @setDimensions()
    # Clear the canvas, then set the text
    @context.drawImage @image, 0, 0
    this.drawTextLine 'top', @model.get('top')
    this.drawTextLine 'bottom', @model.get('bottom')

  drawTextLine: (pos, text) ->
    return unless text? && text.length > 0
    width  = @model.get('width')
    height = @model.get('height')
    # Find a font size that fits within the canvas width
    fontSize = 100
    loop
      @context.font = "bold #{fontSize}px Impact"
      break if @context.measureText(text).width < width - 15
      fontSize--
    # Determine the y position of the text's baseline
    y = switch pos
      when 'top'    then fontSize
      when 'bottom' then height - 15
    # Draw the text with a stroke, centered
    @context.textAlign   = 'center'
    @context.fillStyle   = '#fff'
    @context.strokeStyle = '#000'
    @context.lineWidth   = 6
    @context.strokeText text, width/2, y
    @context.fillText   text, width/2, y


class Memery.Meme extends Backbone.Model
  url: '/memes'

class Memery.Memes extends Backbone.Collection
  url: '/memes'

delay = (ms, f) -> setTimeout f, ms


# Boot the app
$ -> Memery.app = new Memery.App(el: $('body'))
