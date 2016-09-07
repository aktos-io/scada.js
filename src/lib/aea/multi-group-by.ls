require! 'prelude-ls': {group-by, keys}
require! './merge': {merge}
x =
    * client: \eee
      entries:
          * product:
                container:
                    inlet-mold-type: 11    # mold-type
                product-id: _id: 2     # recipe
            lot: _id: \cc   # lot
            amount: 111
          * product:
                container:
                    inlet-mold-type: 12
                product-id: _id: 2
            lot: _id: \bb
            amount: 111
      b: 2

    * client: \iii
      entries:
          * product:
                container:
                    _id: 1
                    inlet-mold-type: 12
                    capacity: 5000gr
                product-id: _id: 3
            lot: _id: \aa
            amount: 111
          * product:
                container:
                    _id: 1
                    inlet-mold-type: 12
                    capacity: 5000gr
                product-id: _id: 3
            lot: _id: \aa
            amount: 222
          * product:
                container:
                    inlet-mold-type: 14
                product-id: _id: 5
            lot: _id: \aa
            amount: 111
      b: 3

vres =
    11:
        2:
            cc:
                client: \eee
                entries:
                    * product:
                          container:
                              inlet-mold-type: 11
                          product-id: _id: 2
                      lot: _id: \cc
                    ...
    12:
        2:
            bb:
                client: \eee
                entries:
                    * product:
                          container:
                              inlet-mold-type: 12
                          product-id: _id: 2
                      lot: _id: \bb
                    ...

        3:
            aa:
                client: \iii
                entries:
                    * product:
                          container:
                              inlet-mold-type: 12
                          product-id: _id: 3
                      lot: _id: \aa
                    ...

    14:
        5:
            aa:
                client: \iii
                entries:
                    * product:
                          container:
                              inlet-mold-type: 14
                          product-id: _id: 5
                      lot: _id: \aa
                    ...


obj-copy = (x) -> JSON.parse JSON.stringify x

dynamic-obj = (...x) ->
    o = {}
    val = x.pop!
    key = x.pop!

    #console.log "key, val: ", x, key, val
    if key
        o[key] = val
    else
        return val
    dynamic-obj.apply this, (x ++ o)


attach = (arr, key, val) ->
    if key of arr
        arr[key].push val
    else
        arr[key] = [val]

res = {}
for o in x
    o.entries = group-by (.product.container.inlet-mold-type), o.entries

    for i in keys o.entries
        o__ = obj-copy o
        o__.entries = o.entries[i]
        attach res, i, o__

#console.log "res: ", JSON.stringify res, null, 2


res2 = {}
for k, oo of res
    for o in oo
        o.entries = group-by (.product.product-id._id), o.entries

        for i in keys o.entries
            o__ = obj-copy o
            o__.entries = o.entries[i]
            res2 `merge` dynamic-obj k, i, o__

#console.log "res2: ", JSON.stringify res2, null, 2

res3 = {}
for k, oo of res2
    for kk, o of oo
        o.entries = group-by (.lot._id), o.entries

        for i in keys o.entries
            o__ = obj-copy o
            o__.entries = o.entries[i]
            res3 `merge` dynamic-obj k, kk, i, o__

#console.log "res3: ", JSON.stringify res3, null, 2

res4 = {}
for k, ooo of res3
    for kk, oo of ooo
        for kkk, o of oo
            o.entries = group-by (.amount), o.entries

            for i in keys o.entries
                o__ = obj-copy o
                o__.entries = o.entries[i]
                res4 `merge` dynamic-obj k, kk, kkk, i, o__

console.log "res4: ", JSON.stringify res4, null, 2
