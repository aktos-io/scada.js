# Document Update Hooks

It's possible to prevent a document from updating (such as preventing changing
document owner or document creation time):

Add `validate_doc_update` attribute to any design document:

```ls
...

validate_doc_update: (new-doc, old-doc, user-ctx, sec-obj) ->
    # start defining utility functions
    function in$ x, xs
        i = -1; l = xs.length .>>>. 0
        while ++i < l
            if x is xs[i] then return true
        return false
    # end of utility functions

    if new-doc.timestamp isnt old-doc.timestamp
        throw {forbidden: "Timestamp can not be changed."}

    if new-doc.owner isnt old-doc.owner
        throw {forbidden: "Document owner can not be changed."}

```
