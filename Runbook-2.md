# Adding an additional data drive
To add an additional data drive for logs, a new block device mapping is needed:

1. Open _main.tf_ and find _block\_device\_mappings_ under the _aws\_launch\_template_ (_blog\_launch\_template_)
2. Add a new block:
```
  block_device_mappings {
    device_name = "/dev/sdc"

    ebs {
      volume_size           = var.volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }
```
3. Commit changes to version control
4. Run _terraform apply_ to add the new volumes to the EC2 instances. **Note** this will incur downtime, as the launch template will be updated and the instances will be refreshed by the Auto Scaling group

## Benefex notes
- Unsure about wording in task question 'Adding an additional Data drive for logs to the existing deployment.'. I took this to mean solely adding a new block device for logs. I thought this could be interpreted as 'This must store logs for the terraform deployment itself', although this seemed unlikely.
- A potential future improvement: Use a "dynamic" block with for_each to create multiple volumes from a specified "number of volumes" variable. This seemed overkill for the requirement.
