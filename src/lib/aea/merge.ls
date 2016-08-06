require! './packing': {pack}

/* */
export function merge (obj1, obj2)
    for p of obj2
        try
            throw if typeof! obj2[p] isnt \Object
            throw if typeof! obj1[p] isnt \Object
            # if and only if second hand is object
            obj1[p] = obj1[p] `merge` obj2[p]
        catch
            if Array.isArray obj1[p]
                # array, merge with current one
                for i, j of obj2[p]
                    if obj1[p].index-of(j) is -1
                        obj1[p] ++= j
            else if obj2[p] isnt void
                obj1[p] = obj2[p]
            else
                delete obj1[p]
    obj1

/* * /
export function merge obj1, obj2
    for p of obj2
        if typeof! obj2[p] is \Object
            if obj1[p]
                obj1[p] `merge` obj2[p]
            else
                obj1[p] = obj2[p]
        else
            if Array.isArray obj1[p]
                # array, merge with current one
                for i, j of obj2[p]
                    if obj1[p].index-of(j) is -1
                        obj1[p] ++= j
            else if obj2[p] isnt void
                obj1[p] = obj2[p]
            else
                delete obj1[p]
    obj1
/* */
export function merge-all (obj1, ...sources)
    for obj2 in sources
        # merge rest one by one
        obj1 `merge` obj2
    obj1





tests =
  'simple merge': ->
        a=
          a: 1
          b: 2

        b=
          c: 5

        result = a `merge` b

        expected =
            a: 1
            b: 2
            c: 5

        {result, expected}

  'simple merge2': ->
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

  'merge lists': ->
        a=
          a: 1
          b: 2
          c: [1, 2]
        b=
          b: 8
          c: [1, 4]

        result = a `merge` b

        expected =
            a: 1
            b: 8
            c: [1, 2, 4]

        {result, expected}

  'deleting something': ->
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
  'force overwrite': ->
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

        result = merge-all a, {c: void}, b

        expected =
            a: 1
            b: 2
            c:
                cb: 5

        {result, expected}
  'merging object with functions': ->
        # object with functions
        a=
          a: 1
          b: 2
          c:
            ca: 11
            cb: 2
        b=
          c:
            cb: (x) -> x

        result = merge a, b

        expected =
            a: 1
            b: 2
            c:
                ca: 11
                cb: (x) -> x

        {result, expected}

  'Field or method does not already exist, and cant create it on String': ->
        # object with functions
        a=
          a: 1
          b: 2
          c: "hey"
        b=
          c:
            cb: "aa"

        result = merge a, b

        expected =
            a: 1
            b: 2
            c:
                cb: "aa"

        {result, expected}

try
    for name, test of tests
        {result, expected} = test!
        throw if result is undefined
        throw if expected is undefined
        throw if (pack expected) isnt pack(result)
catch
    console.log "merge test failed test: ", name
    console.log "EXPECTED: ", expected
    console.log "RESULT  : ", result
    throw "Test failed in merge.ls!, test: #{name}"
