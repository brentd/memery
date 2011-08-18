window.Memery ||= {}

class Memery.ImageSearchView extends Backbone.View
  id: 'image-search'

  events:
    'keyup .query': 'queryChanged'

  initialize: ->
    @el = $(@el)
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