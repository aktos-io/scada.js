separate-file-test = ->
  console.log 'separate file works!'


#separate-file-test!

require! {
  'weblib': {
    test
  }
}

test!
