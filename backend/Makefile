# Variáveis
VARS = -var-file="envs/dev.tfvars"

.PHONY: init plan apply destroy

init:
	terraform init

plan:
	terraform plan $(VARS)

apply:
	terraform apply $(VARS)

destroy:
	terraform destroy $(VARS) -auto-approve