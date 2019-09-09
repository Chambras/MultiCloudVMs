# Multi-Cloud Vm Creation

It creates all the networking requirements, security groups, subnets in order to deploy a VM on each cloud.

## Pre-requists

It is assumed that you have Terraform, Azure, AWS and GCP CLI installed and configured.
More information on this topic [here](https://docs.microsoft.com/en-us/azure/terraform/terraform-overview) for azure,
[here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) for AWS and [here](https://cloud.google.com/sdk/docs/) for GCP.

### versions
These scripts have been tested using:
* Terraform =>0.12.7
* Azure provider = 1.33.1
* AWS provider = 2.16.0
* Google provider = 2.5.1

## Folder Structure
```
.
|-- AWS
|   `-- TestNodes
|       |-- main.tf
|       `-- outputs.tf
|-- Azure
|   `-- TestNodes
|       |-- CentOSVM.tf
|       |-- WindowsVM.tf
|       |-- main.tf
|       |-- networking.tf
|       |-- outputs.tf
|       |-- security.tf
|       `-- variables.tf
|-- GCP
|   `-- TestNodes
|       |-- main.tf
|       `-- outputs.tf
|-- LICENSE
`-- README.md
```
## Usage
Just run these commands to initialize terraform, get a plan and approve it to apply it.

```
terraform init
terraform plan
terraform apply
```

## Clean resources
It will destroy everything that was created.
```
terraform destroy --force
```

## Caution
Be aware that by running this script your accounts might get billed.
Also it is recommended to use a remote state instead of a local one.