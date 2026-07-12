VARS = -var-file="envs/dev.tfvars"

.PHONY: init plan apply destroy fmt

init:
	terraform init

plan:
	terraform plan $(VARS)

fmt:
	terraform fmt -recursive

apply:
	terraform apply $(VARS)

destroy:
	terraform destroy $(VARS) -auto-approve