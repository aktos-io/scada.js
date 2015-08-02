module.exports = class App
    ~>

    init: ->
      tail = prelude.tail
      console.log tail [1,2,3]
      console.log 'hello world from class App.init!'
      x = new Foo
      x.naber!


class Foo
  ~>
    console.log "this is foo.init!"

  naber: ->
    console.log "foo.naber..."
