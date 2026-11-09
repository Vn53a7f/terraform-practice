<h1 align="center">Terraform + EC2 Practice Log</h1>

## 1. EC2 with an AMI lookup

**Context.** I started with a basic EC2 example that used a fixed AMI ID. The revision notes record that a dummy ID got through `terraform plan`. In my current exercise, Terraform looks up the image first and passes the result to EC2. The AMI lookup is **extra practice**. [Quick revision notes](01-terraform-ec2.md)

| File | What it does |
| --- | --- |
| `provider.tf` | Pins the AWS provider to `6.71.0`. The provider block has no region set, so check the AWS environment or profile for the region Terraform will use. |
| `ec2.tf` | Looks up `ami-0055977a6e828a4f4` with state `available`, then uses the returned ID for a `t3.micro` instance. |

```hcl
resource "aws_instance" "example" {
  ami           = data.aws_ami.selected.id
  instance_type = "t3.micro"

  tags = {
    Name = "practice123"
  }
}
```

**What I learned.** `data.aws_ami.selected.id` is the image ID Terraform reads from AWS. `aws_instance.example` is Terraform's address for the server it manages. `practice123` is the server's Name tag in AWS.

| What I tried | What happened | What to check next |
| --- | --- | --- |
| Looked up an AMI ID | `Your query returned no results` | Check the ID and the AWS region first. Then check whether the image is available and visible to my account. |

**Where I left off.** The saved local state contains one managed EC2 instance. That file records Terraform's last saved view of the resource. Its current AWS status is unverified.

- [Exercise files](../01-ec2/)
- [HashiCorp AWS provider configuration](https://registry.terraform.io/providers/hashicorp/aws/6.71.0/docs)
- [DAWS 92S course repository](https://github.com/daws-92s/learn-terraform). I could open the repository listing. The lesson files were unavailable for comparison.
