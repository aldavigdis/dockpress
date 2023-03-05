# Kubernetes on Google Cloud Services

The following is instructions on how to set up a *minimal* infrastructure to
run containerised WordPress in Kubernetes (GKE) on the Google Cloud Services
platform. For production instances, you may need or want to do things
differently, depending on scale.

We assume that all the GCS APIs to be used have been enabled and that you have a
VPC network named `default` and in the examples below, we are working in the
`europe-west1-b` region.

Furthermore, we assume that `kubectl` has been installed and set up to work with
your GKE environment and that the Artifact Registry is in use.

## Setting up a MySQL service

In ths case, we are setting up a minimal MySQL service:

```bash
gcloud sql instances create dockpress-database --tier=db-f1-micro \
                                               --region="europe-west1" \
                                               --network="default"
                                               --root-password="V3rySecur3P455w0rd"
```

After creation, you will see information about your new MySQL instance. Note
down the IP address listed as `PRIVATE_ADDRESS` and add it to the
`secrets/credentials.json` file along with the root user and the password that
you chose.

```bash
gcloud sql databases create wordpress --instance=dockpress-database
```

In a proper production instance you may want to create a non-root user and a
database that isn't called WordPress, but we'll make do with what we have here.

## Set up a Memcached instance

The following `gcloud` command sets up a minimal Memcached Memorystore service
that our Kubernetes pod can communicate with:

```bash
gcloud memcache instances create --project=dockerpress-379014 \
                                 dockpress-memcached-2 \
                                 --region=europe-west1 \
                                 --authorized-network=projects/dockerpress-379014/global/networks/default \
                                 --node-count=1 \
                                 --node-cpu=1 \
                                 --node-memory=1024
```

Once the instance has been depolyed, you will see information about it. Note
down the IP address and port listed under `discoveryEndpoint` and add add it to
the `secrets/credentials.json` file.

## Build and push the docker image

Start by loading your WordPress site's source code, configuration files,
plugins, themes and all to the `wordpress_site` directory, as if you are
uploading it to the web.

Now build a new docker image by running:

```bash
docker build -t dockpress .
```

This is probably where you should read the manual on the GCS Artifact Registry
and Docker Registry, choose between the two and find the best way to build,
commit and push images into your own container registry.

This is how the author builds, commits and pushes the Docker image into her
Artifact Registry:

```bash
$ docker build -t dockpress . -f Dockerfile
$ docker run -dp 80:80 dockpress
$ docker commit [hash] [registry path]
$ docker push [registry path]
```

## Set up persistent file storage

This is where we go into the details of setting up file storage for the files
that end up in the WordPress Media Library and are stored in
`wp-content/uploads`. As each node itself is "stateless", we need to
share those files with the rest of the cluster/swarm.

Start by setting up a Filestore service for handling the uploads directory,
which on the command line is done like this:

```bash
gcloud filestore instances create dockpress-uploads-storage \
    --tier="BASIC_HDD" \
    --file-share="name=uploads,capacity=1TB" \
    --network="name=default" --region="europe-west1-b"
```

Remember to fill in the correct information for your network and region.

For the WordPress file storage, I prefer to use the less expensive but slower
`BASIC_HDD` service tier as in a perfect world, the K8S pod will mainly write to
the filestore because we would be using a load balancer with a GCS CDN service
handling static assets when everything has been set up.

Now, find the IP address assigned to the File Store instance:

```bash
gcloud filestore instances describe dockpress-uploads-storage --region="europe-west1-b"
```

We are going to assume that it is `10.123.81.66` from now on, but yours is
almost guaranteed to be different.

As before, remember to fill in your network and region settings correctly.

## Deploy to GKE

### Cluster creation

Open up the Google Cloud Console and open up the Kubernetes Engine.

Under clusters, create a new one named `dockpress` using Autopilot. Use your
default network and subnet, and make it a *public cluster* in this case, as we
are simply going to access WordPress unencrypted on port 80 because we are lazy.

Once the cluster has been created, you can start deploying to it.

### Authentication with GKE

We are going to start by authenticating and getting access to the cluster that
we just set up. The best resource about it is the GCS docs. Read and follow
[Install kubectl and configure cluster access](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
before taking the next step.

In short we need to authenticate with and set the `dockpress` cluster as our default cluster.

```bash
gcloud container clusters get-credentials dockpress --region=europe-west1
kubectl config set-cluster dockpress
```

##$ Manage credentials

Start by observing `secrets/credentials.json` to make sure that all the
information in there is correct. Then commit it as a secret to GKS like so:

```bash
kubectl create secret generic credentials --from-file secrets/credentials.json
```

This creates a "credentials" volume that our pods can mount after they start,
and in fact the deployment will not work without it.

### The actual deployment

Kubernetes uses YAML files to deploy and to set things up. This repository has
two such files that need minimal editing:

`k8s_examples/deployment.yml`: Here you need to replace the value for the
container image location to refer to your own (at `spec.template.spec.containers.image`)

`k8s_examples/storage.yml`: Here you need to replace the values the Filestore
server (`spec.nfs`) to reflect its IP address.

When you have edited the examples, you can start by deploying the storage claim:

```bash
kubectl apply -f k8s_examples/storage.yml
```

Then wait until the process is finished and then deploy the app:

```bash
kubectl apply -f k8s_examples/deployment.yml
```

This should deploy 3 workloads to our cluster.

### Exposing as a public service

I know this is unorthodox, but we are going to expose the cluster publicly on
the public Internet on port 80. But I also know that you know that we just want
to try things out and figure the rest out later.

```bash
kubectl apply -f k8s_examples/service.yml
```

Now wait for a bit and issue the following command to see the external IP
address for our service:

```bash
kubectl get service dockpress-service
```

You can enter this until we see an external IP address.

In a production environment, we would do something like exposing an internal IP
to the cluster and set up NAT and Load Balancing with SSL/TLS certificates to
take care of this bit.

```bash
kubectl create secret generic credentials --from-file secrets/credentials.json
kubectl apply -f dockpress-persistent-storage.yml
kubectl apply -f dockpress-deployment.yml
```

```bash
kubectl get pod
kubectl exec -it dockpress-58f768bc99-kdbbt -- /bin/bash
```
