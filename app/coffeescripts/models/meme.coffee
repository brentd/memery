window.Memery ||= {}

class Memery.Meme extends Backbone.Model
  url: '/memes'

class Memery.Memes extends Backbone.Collection
  url: '/memes'