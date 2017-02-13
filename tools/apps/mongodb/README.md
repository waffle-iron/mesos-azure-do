# MongoDB 3 node replicaset

This will create a 3 node mongodb replicaset in your ACS cluster.

To create this cluster, we need to build a custom MongoDB image which adds an init script that allows the MongoDB replicaset to be initialized without having to enter any of the mongo containers.

## Create Custom Mongo Image

Make sure that your local registry is running and pointed to the same backing storage as the registry in the DCOS cluster.

``` bash
cd Docker
./buildimage.sh
```

This should build and push the custom image to the private registry.

## Deploy the MongoDB containers

To Deploy the cluster, simply run `deploy-mongo.sh`.  This will spin up 3 nodes of Mongo, wait for them to fully initialize, deploy a 4th app to tell those Mongo Containers to link up as a replica set, and then destroy the cluster-ini app.
