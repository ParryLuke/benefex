# Change region for blogs website
The default region for the blogs site is London (eu-west-2). To change the region to (e.g. Frankfurt - eu-central-1):

1. Log into the AWS console and navigate to EC2 > Snapshots
2. Find the snapshot for the EBS volume
3. Select the snapshot
4. Click _Actions_ > _Copy snapshot_
5. Select the target region on the form, and continue
6. Take note of the target snapshot ID once the process has finished
7. Edit _volume\_details_ in _terraform.tfvars_ and enter the snapshot ID from the target region, ensure that the lines aren't commented out (preceded with # symbol)
```
volume_details = [
  {
    device_name          = "/dev/sdb"
    volume_size          = 5
    snapshot_id          = "snap-XXXXXXXXXXXXXXXXX" # restore from snapshot
  }
```
8. Open the _terraform.tfvars_ file
9. Change _region_ value to "eu-central-1", ensure that the line is not commented out (preceded with # symbol)
10. Run _terraform apply_
11. Read the output and ensure that there are no unexpected changes. You should see only new additions with references to _eu-central-1x_ under _availability_zones_ at the top of the output
12. Confirm the apply with _yes_

## Benefex notes
- There is no AWS region in Belgium, instructions reflect an example deploy to Frankfurt (eu-central-1)
