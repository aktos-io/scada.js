include docs in views -> add "?include_docs=true" parameter in the query

## Security per database:

{{db}}/_security:

{
  "_id": "_security",
  "couchdb_auth_only": true,
  "admins": {
    "names": [
      "demeter"
    ],
    "roles": [
      "_admin"
    ]
  },
  "members": {
    "names": [
      "batman",
      "robin",
      "mahmut1"
    ],
    "roles": [
      "cici"
    ]
  }
}
