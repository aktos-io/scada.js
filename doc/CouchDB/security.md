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

> WARNING: A CouchDB bug enforces you to declare something in member.names or
> member.roles. Otherwise, db becomes PUBLIC. You have warned.

newdb/_security:

```json
{
  "_id": "_security",
  "couchdb_auth_only": true,
  "admins": {
    "names": [
      "foo"
    ],
    "roles": [
      "_admin"
    ]
  },
  "members": {
    "names": ["do-not-remove-me"],
    "roles": []
  }
}
```
