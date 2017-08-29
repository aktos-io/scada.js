# Addressing CouchDB Limitations

## How to create incremental document `id`s: 

1. Design your document ids something like: `{_id: mytype/1, ...}` 
2. Create a view that returns the numeric part of the document 
3. Before creating a new document, get the greatest document id with the view.
4. Increment the id by 1
5. Try to put the document. 
6. If you get `401`, go to step 3.


## How to add owner, timestamp, etc. to the document

Use a microservice that resides between the actual application and the database, add timestamp and document owner at this step. 

## How to make a transaction

TODO: https://en.wikipedia.org/wiki/Two-phase_commit_protocol
