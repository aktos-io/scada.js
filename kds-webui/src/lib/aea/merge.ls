export function merge (obj1, ...sources)
  for obj2 in sources
    for p of obj2
      try
        throw if obj2[p] not instanceof Object
        obj1[p] = obj1[p] `merge` obj2[p]
      catch
        if obj2[p] isnt void
            obj1[p] = obj2[p]
        else
            delete obj1[p]
  obj1


function pack x
    JSON.stringify x

tests =
  * ->
        # simple merge
        a=
          a: 1
          b: 2
          c:
            ca: 1
            cb: 2
        b=
          c:
            cb: 5

        result = a `merge` b

        expected =
            a: 1
            b: 2
            c:
                ca: 1
                cb: 5

        {result, expected}
  * ->
        # delete
        a=
          a: 1
          b: 2
          c:
            ca: 11
            cb: 2

        result = merge a, {c: void}

        expected =
            a: 1
            b: 2

        {result, expected}
  * ->
        # force overwrite
        a=
          a: 1
          b: 2
          c:
            ca: 11
            cb: 2
        b=
          c:  # do not merge, force overwrite
            cb: 5

        result = merge a, {c: void}, b

        expected =
            a: 1
            b: 2
            c:
                cb: 5

        {result, expected}

try
    for test in tests
        {result, expected} = test!
        throw if pack(result) isnt pack(expected)
catch
    console.log "Test failed in merge.ls: ", e
