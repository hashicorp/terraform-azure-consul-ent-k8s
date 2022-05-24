# Consul Enterprise on AKS Module

This is a Terraform module for provisioning two
[federated](https://www.consul.io/docs/k8s/installation/multi-cluster) Consul
Enterprise clusters on [AKS](https://azure.microsoft.com/en-us/services/kubernetes-service/) using Consul version
1.11.15+.

## How to Use This Module

- Ensure you have installed the [Azure
  CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and are
  able to
  [authenticate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)
  to your account.
  - [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)
    role or equivalent is required.

- Install [kubectl](https://kubernetes.io/docs/reference/kubectl/) (this will be
  used to verify Consul cluster federation status).

- This module assumes you have an existing Azure Virtual Network (VNet) and two
  existing AKS clusters along with an Azure Key Vault that you can use for
  Consul federation secrets. If you do not, you may use the following
  [quickstart](https://github.com/hashicorp/terraform-azure-consul-ent-k8s/tree/main/examples/prereqs_quickstart)
  to deploy these resources.

- If you would like deploy this module into existing AKS clusters, please make sure they able to access each other at their [AKS API server endpoints](https://docs.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges#overview-of-api-server-authorized-ip-ranges)

- You will create two files named `main.tf` and place them each in a different
  directory.

- Your first `main.tf` should look like this (note that `primary_datacenter` is
  set to `true`). This will install your primary Consul cluster.

```hcl
provider "azurerm" {
  features {}
}

module "primary_consul_cluster" {
  source  = "hashicorp/consul-ent-k8s/azure"
  version = "0.1.0"

  azure_key_vault_id   = "<Azure Key Vault ID (ex: /subscriptions/...)>"
  azure_key_vault_name = "<Azure Key Vault name>"
  resource_group_name  = "<Resource Group name>"
  cluster_name         = "<name of your first AKS cluster>"

  consul_license       = file("<path to Consul Enterprise license")
  primary_datacenter   = true
}
```

- Your second `main.tf` should look like this (note that `primary_datacenter` is
  set to `false`). This will install your secondary Consul cluster.

```hcl
provider "azurerm" {
  features {}
}

module "secondary_consul_cluster" {
  source  = "hashicorp/consul-ent-k8s/azure"
  version = "0.1.0"

  azure_key_vault_id   = "<Azure Key Vault ID (ex: /subscriptions/...)>"
  azure_key_vault_name = "<Azure Key Vault name>"
  resource_group_name  = "<Resource Group name>"
  cluster_name         = "<name of your first AKS cluster>"

  consul_license       = file("<path to Consul Enterprise license")
  primary_datacenter   = false
}
```

- Run `terraform init` and `terraform apply` first in the directory that
  contains the `main.tf` file that will set up your primary Consul cluster. Wait
  for the apply to complete before moving on to the next step.

- Run `terraform init` and `terraform apply` in the directory containing the
  `main.tf` file that will set up your secondary Consul cluster. Once this is
  complete, you should have two federated Consul clusters. 

To verify that both datacenters are federated, run the consul members -wan
command on one of the Consul server pods (if you need help on configuring
kubectl, please see the
[following](https://github.com/hashicorp/terraform-azure-consul-ent-k8s/blob/main/examples/prereqs_quickstart/README.md#a-note-on-using-kubectl)):

```shell
$ kubectl exec statefulset/consul-server --namespace=consul -- consul members -wan
```

Your output should show servers from both `dc1` and `dc2` similar to what is
show below:

```shell
Node                 Address           Status  Type    Build       Protocol  DC   Partition  Segment
consul-server-0.dc1  10.244.3.6:8302   alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-0.dc2  10.244.7.8:8302   alive   server  1.11.5+ent  2         dc2  default    <all>
consul-server-1.dc1  10.244.4.4:8302   alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-1.dc2  10.244.4.11:8302  alive   server  1.11.5+ent  2         dc2  default    <all>
consul-server-2.dc1  10.244.5.4:8302   alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-2.dc2  10.244.5.8:8302   alive   server  1.11.5+ent  2         dc2  default    <all>
consul-server-3.dc1  10.244.6.5:8302   alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-3.dc2  10.244.3.8:8302   alive   server  1.11.5+ent  2         dc2  default    <all>
consul-server-4.dc1  10.244.7.5:8302   alive   server  1.11.5+ent  2         dc1  default    <all>
consul-server-4.dc2  10.244.6.8:8302   alive   server  1.11.5+ent  2         dc2  default    <all>
```

You can also use the consul catalog services command with the -datacenter flag
to ensure each datacenter can read each other's services. In this example, the
kubectl context is `dc1` and is querying for the list of services in `dc2`:

```shell
$ kubectl exec statefulset/consul-server --namespace=consul -- consul catalog services -datacenter dc2
```

Your output should show the following:

```shell
consul
mesh-gateway
```

## Deploying Example Applications

To deploy and configure some example applications, please see the
[apps](https://github.com/hashicorp/terraform-azure-consul-ent-k8s/tree/main/examples/apps)
directory.

**NOTE: when running `terraform destroy` on this module to uninstall Consul,
please run `terraform destroy` on your secondary Consul cluster and wait for it
to complete before destroying your primary consul cluster.**

## License

This code is released under the Mozilla Public License 2.0. Please see
[LICENSE](https://github.com/hashicorp/terraform-azure-consul-ent-k8s/blob/main/LICENSE)
for more details.
