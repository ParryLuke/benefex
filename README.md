You have been given the below list of requirements for the deployment:
- 2 Linux virtual machines hosted in AWS London region.
- All resources must be labelled with `environment: techBlog`
- 1 data drive per VM.
- IAC must be written in Terraform.
- IAC must be reusable to allow deployments to other regions.
- Benefex employees require RDP access from the office IP 80.193.23.74/32
- Port 443 must be open to the internet.

Scenario 

A junior platform engineer with little experience of terraform needs to deploy the
infrastructure from task 1 into a new region. Create a runbook formatted in
Markdown, that they can follow in order to achieve the following.
1. Deploy the infrastructure to the Belgium region.
2. Adding an additional Data drive for logs to the existing deployment.
