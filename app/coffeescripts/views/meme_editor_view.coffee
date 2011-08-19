window.Memery ||= {}

class Memery.MemeEditorView extends Backbone.View
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
