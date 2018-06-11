## Create DB Users

To create a user with name "foo" and password "plaintext_password", create the
following document in the `/_users` db:

```json
{
    "_id": "org.couchdb.user:foo",
    "name": "foo",
    "type": "user",
    "roles": [],
    "password": "plaintext_password"
}
```

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
      "robin"
    ],
    "roles": [
      "foo"
    ]
  }
}
