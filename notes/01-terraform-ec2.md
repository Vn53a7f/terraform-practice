# Terraform practice notes — 01: Creating an EC2 instance

## Scope

Our starting goal is to create an EC2 instance using Terraform and understand configuration, planning, outputs, and errors. We are covering basic cloud resources, providers, EC2, AMIs, and introductory security groups. Detailed networking comes later.

## 1. Basic cloud concepts

A cloud resource is something we create or manage through a cloud platform, such as a virtual server, storage bucket, or security group. AWS is a cloud platform. EC2 is its virtual server service; an EC2 instance is one virtual server. Terraform lets us describe resources in configuration files and manage their lifecycle.

## 2. Providers: requirements versus configuration

Terraform uses provider plugins to communicate with platforms such as AWS.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.71.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

The version above is from our practice configuration, not a claim about the latest release.

- `required_providers` declares the plugins this configuration needs.
- `aws` is the local provider name.
- `source` identifies the provider and publisher.
- `version` requires exactly this AWS provider version, not the Terraform CLI version.
- The `provider` block configures the plugin, including its region.
- Credentials can come from an AWS profile, environment, or assigned role. They do not need to be written in the configuration.

Java connection: provider requirements resemble Maven dependencies; provider configuration resembles settings used by the dependency.

## 3. Why each practice folder has provider settings

Each independent exercise folder is a separate Terraform configuration. Terraform combines the `.tf` files in the directory where we run it. It does not automatically load files from parent or sibling directories.

```text
01-ec2/
  provider.tf
  ec2.tf
  outputs.tf
```

These files form one configuration. We declare the provider once per configuration, not in every file. Filenames organize the code; they do not isolate it. Child modules declare their own provider requirements and normally inherit provider configuration from the root project.

## 4. Declaring EC2 and our first error

We initially wrote:

```hcl
resource "aws_instance" "example" {
}
```

Terraform reported missing arguments because the block did not provide launch settings. Our basic exercise needs an AMI (the operating system image) and an instance type (CPU and memory configuration).

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0055977a6e828a4f4"
  instance_type = "t3.micro"

  tags = {
    Name = "practice"
  }
}
```

The AMI ID was supplied during practice; its region, availability, and compatibility have not been independently confirmed.

- `aws_instance` is the resource type.
- `example` is Terraform's local resource label.
- `Name = "practice"` is an AWS tag, separate from that label.

The error mentioned `launch_template` because a launch template can supply launch settings instead. We do not need one for this exercise.

## 5. Main commands

| Command | Purpose |
| --- | --- |
| `terraform init` | Initialize the directory and install required providers |
| `terraform validate` | Check configuration syntax and internal consistency |
| `terraform plan` | Preview proposed infrastructure changes |
| `terraform apply` | Carry out changes |
| `terraform destroy` | Remove resources managed by the configuration |

Validation does not check whether an AMI exists in AWS. A plan does not create infrastructure. Applying can create billable resources.

## 6. Our discovery: a dummy AMI can pass planning

We entered a dummy AMI and still saw:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

This proposes one creation, zero updates, and zero deletions. It does not guarantee that AWS will accept every setting. Planning can contact AWS, but does not check every launch condition. An invalid AMI can therefore fail during apply.

Lesson: a successful plan is a preview, not a guarantee of successful creation.

## 7. Checking an AMI using a data source

A data source reads information; a resource manages something. We added a lookup to check the AMI before using it:

```hcl
data "aws_ami" "selected" {
  filter {
    name   = "image-id"
    values = ["ami-0055977a6e828a4f4"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "example" {
  ami           = data.aws_ami.selected.id
  instance_type = "t3.micro"

  tags = {
    Name = "practice"
  }
}
```

`data.aws_ami.selected.id` references the ID returned by the lookup named `selected`. With these fixed filters, the lookup normally runs during planning. It uses the configured region and requires permission to describe images.

## 8. Our lookup error: no results

```text
Error: Your query returned no results.
```

The initial copied example contained a placeholder instead of a real AMI ID. Other causes can include a different region, lack of access, an unavailable image, or filters that do not match.

Lesson: the lookup stopped the plan before creating an instance. A successful lookup still does not guarantee compatibility, capacity, or every other launch requirement.

## 9. Displaying the image name and ID

```hcl
output "selected_image" {
  value = {
    name = data.aws_ami.selected.name
    id   = data.aws_ami.selected.id
  }
}
```

The name helps us recognize the image. The ID is what EC2 uses to launch it. Add this output to the existing configuration; do not duplicate the resource block.

Outputs can appear in the plan when known. After a successful apply, view saved outputs with:

```bash
terraform output
```

For only the name:

```hcl
output "image_name" {
  value = data.aws_ami.selected.name
}
```

An output exposes a chosen value; Terraform does not automatically print every AWS attribute.

## 10. Optional: look up by image name

As an alternative to the ID lookup, this example searches Amazon-owned Amazon Linux 2023 images:

```hcl
data "aws_ami" "selected" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
```

Use this instead of the earlier `selected` data block, not alongside it. `most_recent` selects the newest match; `owners` restricts the publisher. The EC2 resource still references `data.aws_ami.selected.id`. The selected image can change as newer images are published.

## 11. Security groups: introduction only

A security group controls allowed inbound and outbound traffic for associated resources such as EC2 instances. Creating an instance and allowing access are separate tasks. If we omit security groups, AWS may use the VPC's default group; this does not automatically allow us to connect. Ports, IP ranges, VPCs, and routing are for a later networking lesson.

## 12. How we maintain these notes

For each exercise, record the goal, configuration, command, result or error, reason, and correction. Prefer daws-92s examples when available and label additional examples clearly. The AMI lookup and output examples here were written for our discussion, not verified as daws-92s examples.

## References

- Training repository: https://github.com/daws-92s/learn-terraform
- Provider requirements: https://developer.hashicorp.com/terraform/language/providers/requirements
- Configuration structure: https://developer.hashicorp.com/terraform/language/files
- Providers in modules: https://developer.hashicorp.com/terraform/language/modules/develop/providers
- Terraform workflow: https://developer.hashicorp.com/terraform/cli/run
- AWS AMI data source: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami.html
