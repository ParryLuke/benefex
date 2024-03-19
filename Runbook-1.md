# Change region for blogs website
The default region for the blogs site is London (eu-west-2). To change the region to (e.g. Frankfurt - eu-central-1):

1. Open the _terraform.tfvars_ file
2. Change _region_ value to "eu-central-1", ensure that the line is not commented out (preceded with # symbol)
3. Run _terraform apply_
4. Read the output and ensure that there are no unexpected changes. You should see _Plan: 3 to add, 0 to change, 0 to destroy._ with references to _eu-central-1x_ under _availability_zones_ at the top of the output
5. Confirm the apply with _yes_

## Benefex notes
- There is no AWS region in Belgium, instructions reflect an example deploy to Frankfurt (eu-central-1)
- Future improvements include:
1. Automated snapshots for existing and new block devices using lifecycle manager. 'snapshot_id' can be used to recover volumes when deploying across region
2. Adding an Application Load balancer, shorter term solution using round robin from Route53 to the instances (although this is not defined in the requirements, this would be required for the website to run as expected for users)
