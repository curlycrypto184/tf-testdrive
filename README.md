# tf-testdrive

Install AWS CLI and configure with API keys. Give EKS and RDS rights to that user.

Configuration is all over the place.. Might want to take a look at node sizes and volume sizes in particular.

```
# Get code
git clone https://github.com/yannhowe/tf-testdrive.git

# Get going
terraform init
terraform plan
terraform apply

# Get details of installation

# when you are done
terraform destroy
```