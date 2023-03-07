# Packer-ProxMox

Project to study and test creating ProxMox VM Images using Hashicorp Packer.

# Approach 1 - Create a template from scratch based on an ISO file:

- Download the ISO installation file and upload it to ProxMox
- Create the file credentials.pkr.hcl and configure the parameters
- Run packer command referencing the credentials file and the Packer's image definition file:
```
packer build -var-file=credentials.pkr.hcl  ubuntu-server-docker.pkr.hcl
```

# Approach 2 - Create a template from another template created via cloud-image running a bash script:

- Connect to the ProxMox server via ssh and run the script, as in the following command:
``` ssh root@proxmox.server < proxmox-create-cloud-template.sh ```
- Create the file credentials.pkr.hcl and configure the parameters
- Run packer command referencing the credentials file and the Packer's image definition file:
```
packer build -var-file=credentials.pkr.hcl  base.pkr.hcl