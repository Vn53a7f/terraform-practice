# Terraform + EC2: quick revision notes

Reference: [DAWS 92S](https://github.com/daws-92s/learn-terraform). Its EC2 files could not be fetched for comparison. These are my practice notes, not an exact copy. Items marked **Extra** came from our discussion.

## 1. Basic words

| Word | What I remember |
| --- | --- |
| AWS | A cloud platform |
| Resource | Something I manage, like a server or security group |
| EC2 instance | A virtual server |
| AMI | The starting image: operating system and possibly software |
| Instance type | Server size: CPU and memory, such as `t3.micro` |
| Region | The AWS location where I create resources |
| Security group | Rules for allowed incoming and outgoing traffic |
| Terraform | Describes the infrastructure I want in code and manages changes |
| Provider | Plugin Terraform uses to talk to AWS or another platform |
| State | Terraform's record linking my resource names to real resources |

Networking details come later. Creating a server does not automatically give me access to it.

## 2. Provider settings

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

- `required_providers`: which plugin I need; like a Maven dependency.
- `source`: the provider's address and publisher.
- `version`: exact AWS provider version, not Terraform's version. This is my practice value.
- `provider`: connection settings, such as region.
- Credentials can come from an AWS profile, environment, or role.

**Folder rule:** all `.tf` files in one folder work together. Declare settings once per project, not in every file. Terraform does not automatically read sibling or parent folders. Child modules can inherit provider settings; learn that later.

## 3. Minimum EC2 example

```hcl
resource "aws_instance" "example" {
  ami           = "ami-0055977a6e828a4f4"
  instance_type = "t3.micro"
}
```

The AMI is the ID I supplied in practice; its region and compatibility have not been verified here.

- `aws_instance`: resource type.
- `example`: local Terraform name; reference it as `aws_instance.example`.
- `ami` + `instance_type`: required for this basic example, unless a launch template supplies them.
- Optional `tags = { Name = "practice" }`: AWS Name tag, separate from Terraform's local name.

**Also needed:** AWS permissions, a region, and a usable subnet. If I omit the subnet, AWS can use a default subnet in the default VPC. Without those defaults, I must supply network settings.

**Usually optional in my code:** Name tag, key pair, startup script (`user_data`), custom disk settings, and custom security group. AWS/AMI defaults supply some settings. Company rules may require more.

Without `count` or `for_each`, this block manages one instance. Direct AWS `RunInstances` calls also need `MinCount` and `MaxCount`; Terraform handles those API values.

## 4. Commands

| Command | Reminder |
| --- | --- |
| `terraform init` | Set up the folder and install providers |
| `terraform fmt` | Format the code |
| `terraform validate` | Check code structure; does not check AMI existence |
| `terraform plan` | Preview changes; creates nothing |
| `terraform apply` | Make the changes in AWS |
| `terraform output` | Show saved outputs after apply |
| `terraform destroy` | Delete resources managed by this configuration |

`1 to add, 0 to change, 0 to destroy` means one planned creation. **A successful plan does not guarantee a successful apply.** AWS can still reject an AMI or another setting. Apply can create billable resources.

## 5. Errors I experienced

| What happened | Meaning / fix |
| --- | --- |
| Empty `aws_instance` block: `Missing required argument` | Give AMI and instance type, or a template that supplies them |
| `one of ami,launch_template must be specified` | Supply the image directly or through a template |
| `one of instance_type,launch_template must be specified` | Supply the size directly or through a template |
| `one of ami,instance_type,launch_template must be specified` | The block has no launch settings; this does not mean just one field is enough |
| Dummy AMI passed plan | Planning did not verify that image exists; apply can fail |
| AMI lookup: `Your query returned no results` | Check placeholder/dummy ID, region, access, availability, and filters |

## 6. Extra: what is a launch template?

A saved set of EC2 settings, such as image and size. It can be reused. **Saving a template does not create a running server.** Missing required settings still need to be supplied at launch.

```hcl
resource "aws_launch_template" "practice" {
  name_prefix   = "practice-"
  image_id      = "ami-0055977a6e828a4f4"
  instance_type = "t3.micro"
}

resource "aws_instance" "example" {
  launch_template {
    id      = aws_launch_template.practice.id
    version = tostring(aws_launch_template.practice.latest_version)
  }
}
```

Alternative to section 3, not another block to paste beside it. This manages a template plus an instance. Notice `image_id` in the template versus `ami` in the instance.

## 7. Extra: AMI lookup and outputs

Added because I asked how to check an AMI before creating EC2. This is extra practice, not a required DAWS EC2 lesson step.

- `resource`: manages something.
- `data`: reads existing information.
- `output`: shows a value I choose.

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

output "selected_image" {
  value = {
    name = data.aws_ami.selected.name
    id   = data.aws_ami.selected.id
  }
}
```

In section 3, replace the fixed `ami` value with `data.aws_ami.selected.id`. With these fixed filters, the lookup normally runs during plan. It needs permission to describe images and checks my provider's region. It does not guarantee every launch condition.

**Search by name instead:** change the first filter to `name = "name"` and use an image-name pattern in `values`. Restrict `owners` to a trusted publisher. `most_recent = true` chooses the newest match, which may change later. EC2 still receives the resulting ID.

## Sources and note-taking rule

Check DAWS 92S first. Label extra examples. Write: **what I tried -> error -> reason -> fix**. Keep networking for later.

- [Terraform EC2 arguments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)
- [AWS launch templates](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-launch-templates.html)
- [AMI lookup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami.html)
- [AWS RunInstances API](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RunInstances.html)
