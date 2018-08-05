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

> **WARNING:** <br />
> A CouchDB bug enforces you to declare something in `member.names` or `member.roles`. <br />
> Otherwise, db becomes PUBLIC. See [couchdb/1490](https://github.com/apache/couchdb/issues/1490) <br />
> **You have warned**.

newdb/_security:

```json
{
  "_id": "_security",
  "couchdb_auth_only": true,
  "admins": {
    "names": [
      "foo"
    ],
    "roles": []
  },
  "members": {
    "names": ["do-not-remove-me"],
    "roles": []
  }
}
```
