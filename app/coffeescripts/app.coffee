Memery ?= {}


class Memery.Router extends Backbone.Router
  routes:
    '/':          'index'
    '/memes/:id': 'show'

  index: ->
    console.log('index!')


class Memery.App extends Backbone.View
  initialize: ->
    # Router setup
    new Memery.Router
    Backbone.history.start()

    new Memery.ImageSearchView
      el: @$('#image-search-view')

    # Set up the new meme view, which is hidden until activated
    new Memery.NewMemeView
      el: @$('#new-meme-view')
      model: new Memery.Meme


class Memery.ImageSearchView extends Backbone.View
  events:
    'keyup .query':        'queryChanged'
    'click ol.results li': 'imageClicked'

  initialize: ->
    @queryInput  = @$('.query')
    @resultsList = @$('.results')
    # Set up Google's image search API
    @imageSearch = new google.search.ImageSearch()
    @imageSearch.setSearchCompleteCallback(this, @render)
    @imageSearch.setResultSetSize(8) # 8 is the max :(

  # Callback when the users types in the query box. Throttled with
  # underscore's debounce to prevent repeated calls for each keypress.
  queryChanged: _.debounce (->@search()), 1000

  imageClicked: ->
    console.log('clicked!')

  search: ->
    query = @queryInput.val()
    if query != @lastQuery
      @lastQuery = query
      @imageSearch.execute(query)

  render: ->
    @resultsList.empty()
    for obj in @imageSearch.results
      console.log obj
      li = @make 'li', {}, (@make 'img', src: obj.tbUrl)
      @resultsList.append(li)


class Memery.NewMemeView extends Backbone.View
  initialize: ->
    # Model event bindings
    @model.bind 'change:image_url', @loadImage, this
    @model.bind 'change:top',       @render,    this
    @model.bind 'change:bottom',    @render,    this
    # Canvas setup
    @canvas  = @$('canvas').get(0)
    @context = @canvas.getContext('2d')
    @context.textAlign   = 'center'
    @context.fillStyle   = '#fff'
    @context.strokeStyle = '#000'
    @context.lineWidth   = 3
    # Get started by loading the meme's image
    @loadImage()

  loadImage: ->
    if @model.has 'image_url'
      @image = new Image()
      @image.src = "/proxyimage?url=#{@model.get 'image_url'}"
      @image.onload = @render

  render: ->
    @width  = @image.width
    @height = @image.height
    @canvas.attr
      width:  @width
      height: @height
    # Clear the canvas, then set the text
    @context.drawImage @image, 0, 0
    this.drawTextLine @model.get('top'),    'top'
    this.drawTextLine @model.get('bottom'), 'bottom'

  drawTextLine: (text, pos) ->
    return unless text? && text.length > 0
    # Find a font size that fits within the canvas width
    fontSize = 60
    loop
      @context.font = "bold #{fontSize}px Impact"
      break if @context.measureText(text).width < @width
      fontSize--
    # Determine the y position of the text's baseline
    y = switch pos
      when 'top'    then fontSize
      when 'bottom' then @height - fontSize
    # Draw the text with a stroke, centered
    @context.strokeText text, @width/2, y
    @context.fillText   text, @width/2, y

class Memery.Meme extends Backbone.Model

delay = (ms, f) -> setTimeout f, ms


# Boot the app
$ -> Memery.app = new Memery.App(el: $('body'))
