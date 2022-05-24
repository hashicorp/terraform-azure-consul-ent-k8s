# Example Prerequisite Configuration for Consul on AKS Module

The quickstart directory provides example code that will create one Azure VNet
and two AKS clusters along with an Azure Key Vault to store Consul federation
data.

## How to Use This Module

- Ensure you have installed the [Azure
  CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) and are
  able to
  [authenticate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)
  to your account.
  - [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)
    role or equivalent is required.

- Install [kubectl](https://kubernetes.io/docs/reference/kubectl/)

Run `terraform init` and `terraform apply` inside this directory to create the
VPC and two EKS clusters. The whole provisioning process takes approximately 20
minutes.

## Required Variables

- `aks_1_cluster_name` - The name of your first AKS cluster
- `aks_2_cluster_name` - The name of your second AKS cluster
- `resource_name_prefix` - Prefix for resource names VNet

Note: the default Azure region is `East US`. If you wish to change this region,
you may select another region from the list provided
[here](https://azure.microsoft.com/en-us/global-infrastructure/geographies/#geographies).

# A note on using kubectl

If you want to run `kubectl` commands against your cluster, be sure to update
your kubeconfig as shown for each cluster:

```shell
$ az aks get-credentials --resource-group "<resource group name>" --name "<name of cluster>"
```

If you want to switch kubectl
[context](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#context),
be sure to run the following:

```shell
$ kubectl config use-context "<your cluster name>"
```

# Note:

- If you have used the main module to install the Consul helm chart, please be
  sure to run `terraform destroy` from there to uninstall the helm chart BEFORE
  destroying these prerequisite resources. Failure to uninstall Consul from the
  main module will result in a failed `terraform destroy` and lingering
  resources in your VPC.
