# Adding an additional data drive
To add an additional data drive for logs, a new block device mapping is needed:

1. Open _variables.tf_ and find _volume\_details_
2. Specify a new block device (e.g. /dev/sdc) as part of the _volume\_details_ variable in _terraform.tfvars_, ensure that the configuration is not commented out, as is by default (preceded with # symbol). **Do not remove the existing volume /dev/sdb**:
```
volume_details = [
  {
    device_name          = "/dev/sdb"
    volume_size          = 5
    snapshot_id          = ""
  },
  {
    device_name          = "/dev/sdc"
    volume_size          = 10
    snapshot_id          = "" # no snapshot, logs only
  }
]
```
3. Commit changes to version control
4. Run _terraform apply_ to add the new volumes to the EC2 instances. **Note** this will incur downtime, as the launch template will be updated and the instances will be refreshed by the Auto Scaling group

## Benefex notes
- Unsure about wording in task question 'Adding an additional Data drive for logs to the existing deployment.'. I took this to mean solely adding a new block device for logs. I thought this could be interpreted as 'This must store logs for the terraform deployment itself', although this seemed unlikely.
