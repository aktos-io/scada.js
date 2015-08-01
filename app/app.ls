module.exports = class XYZ
    ~>

    init: ->
      tail = prelude.tail
      console.log tail [1,2,3]
      console.log 'hello world from class App.init!'
