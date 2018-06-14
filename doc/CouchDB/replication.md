# Replication:

1. Create a new DB user (eg. foo) (see ./security.md)
2. Add this DB user as admin to the source database (see ./security.md)
3. Check your user has correct permissions:

    curl https://foo:yourpassword@example.com/yourdb/_security
    # if you see the security document, then everything is set up correctly.

3. Create a replication task by using GUI or by creating a replication
document.

## Tips for Common Pitfalls

1. If you reach the Web GUI by port forwarding, adding the replication task
via GUI simply may fail because target database url might be constructed erroneously.

    FIX: After creating your replication task, edit the replication document and
    fix the target url port.


## Creating replication document

Design documents will only replicate if you are authenticated as an admin, or a db admin, on your target. Try something like setting your target as

Create the following document in the `_replicator` db:

```json
{
  "_id": "197d5186-402d-4de4-8d4b-d3acf90157b7",
  "source": "https://theadmin:theadminpassword@example.cloudant.com/sourcedb",
  "target": "http://theotheradmin:theotheradminpassword@127.0.0.1/targetdb",
  "create_target": true,
  "continuous": true
}
```
