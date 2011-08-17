(function() {
  var delay;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
    if (typeof Memery !== "undefined" && Memery !== null) {
    Memery;
  } else {
    Memery = {};
  };
  Memery.Router = (function() {
    __extends(Router, Backbone.Router);
    function Router() {
      Router.__super__.constructor.apply(this, arguments);
    }
    Router.prototype.routes = {
      '/': 'index',
      '/memes/:id': 'show'
    };
    Router.prototype.index = function() {
      return console.log('index!');
    };
    return Router;
  })();
  Memery.App = (function() {
    __extends(App, Backbone.View);
    function App() {
      App.__super__.constructor.apply(this, arguments);
    }
    App.prototype.initialize = function() {
      new Memery.Router;
      Backbone.history.start();
      new Memery.ImageSearchView({
        el: this.$('#image-search-view')
      });
      return new Memery.NewMemeView({
        el: this.$('#new-meme-view'),
        model: new Memery.Meme
      });
    };
    return App;
  })();
  Memery.ImageSearchView = (function() {
    __extends(ImageSearchView, Backbone.View);
    function ImageSearchView() {
      ImageSearchView.__super__.constructor.apply(this, arguments);
    }
    ImageSearchView.prototype.events = {
      'keyup .query': 'queryChanged',
      'click ol.results li': 'imageClicked'
    };
    ImageSearchView.prototype.initialize = function() {
      this.queryInput = this.$('.query');
      this.resultsList = this.$('.results');
      this.imageSearch = new google.search.ImageSearch();
      this.imageSearch.setSearchCompleteCallback(this, this.render);
      return this.imageSearch.setResultSetSize(8);
    };
    ImageSearchView.prototype.queryChanged = _.debounce((function() {
      return this.search();
    }), 1000);
    ImageSearchView.prototype.imageClicked = function() {
      return console.log('clicked!');
    };
    ImageSearchView.prototype.search = function() {
      var query;
      query = this.queryInput.val();
      if (query !== this.lastQuery) {
        this.lastQuery = query;
        return this.imageSearch.execute(query);
      }
    };
    ImageSearchView.prototype.render = function() {
      var li, obj, _i, _len, _ref, _results;
      this.resultsList.empty();
      _ref = this.imageSearch.results;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        obj = _ref[_i];
        console.log(obj);
        li = this.make('li', {}, this.make('img', {
          src: obj.tbUrl
        }));
        _results.push(this.resultsList.append(li));
      }
      return _results;
    };
    return ImageSearchView;
  })();
  Memery.NewMemeView = (function() {
    __extends(NewMemeView, Backbone.View);
    function NewMemeView() {
      NewMemeView.__super__.constructor.apply(this, arguments);
    }
    NewMemeView.prototype.initialize = function() {
      this.model.bind('change:image_url', this.loadImage, this);
      this.model.bind('change:top', this.render, this);
      this.model.bind('change:bottom', this.render, this);
      this.canvas = this.$('canvas').get(0);
      this.context = this.canvas.getContext('2d');
      this.context.textAlign = 'center';
      this.context.fillStyle = '#fff';
      this.context.strokeStyle = '#000';
      this.context.lineWidth = 3;
      return this.loadImage();
    };
    NewMemeView.prototype.loadImage = function() {
      if (this.model.has('image_url')) {
        this.image = new Image();
        this.image.src = "/proxyimage?url=" + (this.model.get('image_url'));
        return this.image.onload = this.render;
      }
    };
    NewMemeView.prototype.render = function() {
      this.width = this.image.width;
      this.height = this.image.height;
      this.canvas.attr({
        width: this.width,
        height: this.height
      });
      this.context.drawImage(this.image, 0, 0);
      this.drawTextLine(this.model.get('top'), 'top');
      return this.drawTextLine(this.model.get('bottom'), 'bottom');
    };
    NewMemeView.prototype.drawTextLine = function(text, pos) {
      var fontSize, y;
      if (!((text != null) && text.length > 0)) {
        return;
      }
      fontSize = 60;
      while (true) {
        this.context.font = "bold " + fontSize + "px Impact";
        if (this.context.measureText(text).width < this.width) {
          break;
        }
        fontSize--;
      }
      y = (function() {
        switch (pos) {
          case 'top':
            return fontSize;
          case 'bottom':
            return this.height - fontSize;
        }
      }).call(this);
      this.context.strokeText(text, this.width / 2, y);
      return this.context.fillText(text, this.width / 2, y);
    };
    return NewMemeView;
  })();
  Memery.Meme = (function() {
    __extends(Meme, Backbone.Model);
    function Meme() {
      Meme.__super__.constructor.apply(this, arguments);
    }
    return Meme;
  })();
  delay = function(ms, f) {
    return setTimeout(f, ms);
  };
  $(function() {
    return Memery.app = new Memery.App({
      el: $('body')
    });
  });
}).call(this);
