VARS = -var-file="envs/dev.tfvars"

.PHONY: init plan apply destroy fmt build-lambda

init:
	terraform init

# Novo comando para empacotar o código
build-lambda:
	@echo "Empacotando Lambda..."
	@rm -f modules/lambda/lambda_functions.zip
	@zip -j modules/lambda/lambda_functions.zip modules/lambda/main.py

# O 'apply' agora depende de 'build-lambda'
# Sempre que você rodar 'make apply', ele zipa o código antes
apply: build-lambda
	terraform apply $(VARS)

plan:
	terraform plan $(VARS)

fmt:
	terraform fmt -recursive

destroy:
	terraform destroy $(VARS) -auto-approve