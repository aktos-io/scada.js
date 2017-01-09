require! './packing': {pack}

/** /
export merge = (obj1, obj2) ->
    if (typeof! obj1 is \Array) and (typeof! obj2 is \Array)
        for i in obj2
            try
                for j in obj1
                    throw if pack(i) is pack(j)
                # append if item is not found in first one
                obj1.push i
        return obj1
    else
        for p of obj2
            try
                throw if typeof! obj2[p] isnt \Object
                throw if typeof! obj1[p] isnt \Object
                # go on if and only if right hand is object
                obj1[p] `merge` obj2[p]
            catch
                if Array.isArray obj1[p]
                    # array, merge with current one
                    for i, j of obj2[p]
                        try
                            for a in obj1[p]
                                throw if pack(a) is pack(j)
                            obj1[p].push j
                else if obj2[p] isnt void
                    obj1[p] = obj2[p]
                else
                    delete obj1[p]
        obj1

/**/

export function merge obj1, obj2
    if (typeof! obj1 is \Array) and (typeof! obj2 is \Array)
        for i in obj2
            try
                for j in obj1
                    throw if pack(i) is pack(j)
                # append if item is not found in first one
                obj1.push i
        return obj1
    else
        for p of obj2
            t-obj1 = typeof! obj1[p]
            if typeof! obj2[p] in <[ Object Array ]>
                if t-obj1 in <[ Object Array ]>
                    obj1[p] `merge` obj2[p]
                else
                    obj1[p] = obj2[p]
            else
                if obj2[p] isnt void
                    obj1[p] = obj2[p]
                else
                    delete obj1[p]
        obj1
/**/
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

    'merge lists of objects': ->
        a=
          a: 1
          b: 2
          c: [{a: 1, b: 2}, {a: 3, b: 4}]
        b=
          b: 8
          c: [{a: 1, b: 2}, {a: 5, b: 6}]

        result = a `merge` b

        expected =
            a: 1
            b: 8
            c: [{a: 1, b: 2}, {a: 3, b: 4}, {a: 5, b: 6}]

        {result, expected}

    'merge lists of objects2': ->
        x =
            * a: 1
              b: 2
            * a: 3
              b: 4

        y =
            * a: 5
              b: 6
            * a: 7
              b: 8
            * a: 9
              b: 10
            * a: 11
              b: 12

        result = x `merge` y

        expected =
            * a: 1
              b: 2
            * a: 3
              b: 4
            * a: 5
              b: 6
            * a: 7
              b: 8
            * a: 9
              b: 10
            * a: 11
              b: 12

        {result, expected}

    'deleting something': ->
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

start = Date.now!
test-count = 1  # use 5_000 for a significiant amount of time
for i from 0 to test-count
    for name, test of tests
        {result, expected} = test!
        if pack(expected) isnt pack(result)
            console.log "merge test failed test: ", name
            console.log "EXPECTED: ", expected
            console.log "RESULT  : ", result
            throw "Test failed in merge.ls!, test: #{name}"

if test-count > 1
    console.log "Merge tests took: #{Date.now! - start} milliseconds..."
