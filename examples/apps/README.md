# Example Application for Consul on AKS Module

This directory provides an example application that consists of two
microservices (`dashboard` and `counting`). The Terraform code provided in this
directory does the following:

- Installs the `counting` microservice
- Installs the `dashboard` microservice that displays the information it
  receives from the `counting` microservice 
- Configures Consul service intentions so the two microservices can talk to each
  other

## How to Use This Example

- Install [kubectl](https://kubernetes.io/docs/reference/kubectl/) (you will
  need this to view the dashboard service).

Run `terraform init` and `terraform apply` inside this directory to deploy the
two sample microservices and configure Consul service intentions into your
chosen AKS cluster. 

To demonstrate cross cluster Consul service discovery, this example app should
be deployed on each AKS cluster containing a Consul datacenter.

To verify service discovery, run the following command from the cluster
containing Consul datacenter `dc1` (this assumes your kubernetes namespace is
called `consul` and your secondary Consul datacenter is named `dc2`):

```shell
$ kubectl exec statefulset/consul-server --namespace=consul -- consul catalog services -datacenter dc2
```

To lookup services in Consul datacenter `dc1` from `dc2`, [change your kubectl
context](https://github.com/hashicorp/terraform-azure-consul-ent-k8s/tree/main/examples/prereqs_quickstart#a-note-on-using-kubectl)
to your cluster containing your secondary Consul datacenter `dc2` and run the
following command:

```shell
$ kubectl exec statefulset/consul-server --namespace=consul -- consul catalog services -datacenter dc1
```

## Required Variables

- `cluster_name` - The name of your AKS cluster
- `resource_group_name` - The Azure resource group name of your AKS cluster

You can run the following command on the cluster you have chosen to deploy these
microservices into and locally view the dashboard service on port `9002`. For
help configuring the kubectl command, please see the
[following](https://github.com/hashicorp/terraform-azure-consul-ent-k8s/blob/main/examples/prereqs_quickstart/README.md#a-note-on-using-kubectl).

```shell
$ kubectl port-forward deployment/dashboard 9002 -n consul
```

You should now be able to see the `dashboard` service at the following address:

http://localhost:9002/

**Note**: Please run `terraform destroy` to uninstall these services and service
intentions before uninstalling Consul from the main module. Failure to uninstall
these services before uninstalling Consul will result in a failed destroy due to
lingering resources in the consul namespace.
