window.Memery ||= {}

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