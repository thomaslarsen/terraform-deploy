# jump box service

This module creates a jump box that can be used as a single ingress point from which users can jump onto other boxes. It can be directly internet facing, or it can be used in conjunction with some other form of access, such as a VPN tunnel.

The jump box will have the following high level characteristics:

* Minimal number of processes and installed software;
* Authentication against external service, such as LDAP;
* Hardened;
* Security Group backed control

The jump box should be placed in the appropriate subnet, which should be either dmz, boundary or public.

The jump box should be associated with an external IP. To ensure this IP will be unlikely to change, it should be implemented as an EIP created at the VPC level.
As EIPs cannot be associated with ELBs, the jump box is implemented as a single EC2 instance.

## Use of module

This module can be used in two ways:

- Directly invoked as a Terraform state, i.e. `terraform apply`
- Called as a module from another Terraform state file

The module will read in the states of the Virtual Data Centre and the Application Zone given the names of those as input variables.
