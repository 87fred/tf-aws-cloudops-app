# 🚀 AWS CloudOps Portal

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-blue.svg?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange.svg?logo=amazon-aws)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Python-3.11-blue.svg?logo=python)](https://www.python.org/)
[![AWS Lambda](https://img.shields.io/badge/AWS-Lambda-orange.svg?logo=awslambda)](https://aws.amazon.com/lambda/)
[![CloudWatch](https://img.shields.io/badge/CloudWatch-Monitoring-green.svg)](https://aws.amazon.com/cloudwatch/)
[![CloudFront](https://img.shields.io/badge/Amazon-CloudFront-orange.svg?logo=amazonaws)](https://aws.amazon.com/cloudfront/)
[![DynamoDB](https://img.shields.io/badge/Amazon-DynamoDB-blue.svg?logo=amazondynamodb)](https://aws.amazon.com/dynamodb/)
[![API Gateway](https://img.shields.io/badge/Amazon-API_Gateway-orange.svg)](https://aws.amazon.com/api-gateway/)

Projeto de **Infrastructure as Code (IaC)** para provisionamento de uma plataforma **CloudOps Serverless**, focada em observabilidade, FinOps e automação operacional utilizando **Terraform**.

---

# 📌 Visão Geral

Infraestrutura **production-like** desenvolvida totalmente como código utilizando **Terraform**, provisionando automaticamente um portal operacional para gerenciamento e visualização de recursos AWS.

O ambiente é composto por:

- Amazon CloudFront
- Amazon S3
- AWS Lambda (Python 3.11)
- Amazon API Gateway HTTP
- Amazon DynamoDB
- Amazon CloudWatch
- AWS Cost Explorer
- IAM Least Privilege


O projeto simula um portal utilizado por equipes de Cloud Engineering para visualizar informações operacionais da infraestrutura AWS, incluindo consumo de recursos, custos e métricas em tempo real.

---

# 🎯 Objetivo do Projeto

Projetar e demonstrar uma arquitetura moderna baseada em serviços **Serverless**, aplicando boas práticas de Engenharia de Cloud e Infraestrutura como Código.

Este projeto faz parte do meu portfólio profissional e demonstra a construção de uma aplicação totalmente automatizada utilizando serviços gerenciados da AWS.

Os principais pilares da solução são:

- **Infrastructure as Code (IaC):** Provisionamento automatizado utilizando Terraform.
- **Arquitetura Serverless:** Eliminação da necessidade de gerenciamento de servidores.
- **Observabilidade Centralizada:** Monitoramento completo através do Amazon CloudWatch.
- **FinOps:** Consulta de custos utilizando a API do AWS Cost Explorer.
- **Segurança por padrão:** Aplicação do princípio de Least Privilege.
- **Alta disponibilidade:** Distribuição global através do Amazon CloudFront.

---

# 🏗️ Arquitetura do Sistema

```mermaid
graph TD

User((Usuário))

User --> CF[Amazon CloudFront]

CF --> S3[Amazon S3]

S3 --> Browser[Frontend]

Browser --> API[Amazon API Gateway]

API --> Lambda[AWS Lambda]

Lambda --> Dynamo[(Amazon DynamoDB)]

Lambda --> Cost[Cost Explorer]

Lambda --> CW[Amazon CloudWatch]

CW --> Dashboard[Dashboards]
```

---

# 🧠 Decisões Arquiteturais

- **Amazon CloudFront:** Distribuição global do frontend utilizando CDN.
- **Origin Access Control (OAC):** Bucket S3 privado sem acesso público.
- **Amazon S3:** Hospedagem estática do frontend.
- **AWS Lambda:** Backend serverless escrito em Python 3.11.
- **Amazon API Gateway HTTP:** Camada de exposição da API.
- **Amazon DynamoDB:** Persistência dos usuários e autenticação.
- **Amazon CloudWatch:** Monitoramento, dashboards e logs.
- **AWS Cost Explorer:** Consulta automática de custos da conta AWS.
- **IAM Least Privilege:** Permissões mínimas necessárias para execução da aplicação.

---

# 📦 Recursos Implementados & Provisionados

### 🌐 Frontend

- Amazon S3
- Amazon CloudFront
- Origin Access Control (OAC)
- Bucket Policy

### ⚙️ Backend

- AWS Lambda
- Amazon API Gateway HTTP
- IAM Role
- IAM Policies

### 🗄 Banco de Dados

- Amazon DynamoDB

### 📈 Observabilidade

- CloudWatch Dashboard
- CloudWatch Log Groups
- CloudWatch Alarms

### 💰 FinOps

- AWS Cost Explorer API

### 🔒 Segurança

- IAM Least Privilege
- Bucket Privado
- CloudFront OAC
- Políticas customizadas

---

# 🔒 Segurança

A arquitetura foi desenvolvida seguindo rigorosamente o princípio de **Least Privilege**, implementando:

- Bucket S3 totalmente privado.
- CloudFront utilizando Origin Access Control.
- IAM Roles específicas para execução da Lambda.
- Políticas customizadas de acesso.
- API Gateway integrado ao backend serverless.
- Controle de acesso através de políticas AWS.

---

# 👁️ Observabilidade

O projeto integra monitoramento completo utilizando o Amazon CloudWatch.

São monitorados:

- Execuções da Lambda
- Erros
- Tempo de resposta
- Invocações
- Logs centralizados
- Dashboards operacionais

Além disso, alarmes são criados automaticamente para identificação de falhas operacionais.

---

# 💰 FinOps

O CloudOps Portal integra-se ao **AWS Cost Explorer**, permitindo visualizar informações financeiras da infraestrutura como:

- Custos diários
- Custos mensais
- Custos acumulados
- Serviços com maior consumo
- Distribuição dos gastos da conta

Demonstrando a integração entre operações Cloud e governança financeira.

---

# 📁 Estrutura do Projeto

```text
.
├── api_gateway.tf
├── backend.tf
├── cloudfront.tf
├── cloudwatch.tf
├── dynamodb.tf
├── frontend.tf
├── iam.tf
├── locals.tf
├── outputs.tf
├── providers.tf
├── variables.tf
├── versions.tf
├── dev.tfvars
├── frontend/
│   ├── css/
│   ├── js/
│   ├── assets/
│   ├── index.html
│   └── config.js
└── README.md
```

---

# ⚙️ Pré-requisitos

Antes da execução, certifique-se de possuir:

- Terraform 1.5+
- AWS CLI configurada
- Permissões para criação dos recursos AWS
- AWS Cost Explorer habilitado na conta

---

# 🚀 Como Executar

## 1. Inicializar o Terraform

```bash
terraform init
```

## 2. Criar Workspace

```bash
terraform workspace select dev || terraform workspace new dev
```

## 3. Validar

```bash
terraform validate
```

## 4. Planejar

```bash
terraform plan -var-file="dev.tfvars"
```

## 5. Provisionar

```bash
terraform apply -var-file="dev.tfvars"
```

## 6. Destruir

```bash
terraform destroy -var-file="dev.tfvars"
```

---

# 🌐 Outputs

Após o término do **terraform apply**, serão disponibilizados automaticamente:

- URL do CloudFront
- Endpoint da API Gateway
- Nome da função Lambda
- Nome da tabela DynamoDB
- Bucket S3
- Dashboard CloudWatch

---

# 🔥 Destaques Técnicos

- Arquitetura totalmente Serverless
- Frontend distribuído globalmente através do CloudFront
- Backend desacoplado utilizando API Gateway + Lambda
- Banco NoSQL utilizando DynamoDB
- Deploy automatizado com Terraform
- Integração nativa com AWS Cost Explorer
- Dashboards operacionais via CloudWatch
- IAM Least Privilege
- Origin Access Control (OAC)
- Geração automática do `config.js`
- Infraestrutura totalmente reproduzível

---

# 🚀 Roadmap

Próximas evoluções previstas:

- Autenticação com Amazon Cognito
- AWS WAF
- AWS X-Ray
- Amazon EventBridge
- Amazon SNS
- Exportação de relatórios PDF
- Suporte Multi-Region
- CI/CD com GitHub Actions
- Testes automatizados
- Integração com AWS Organizations

---

# 👨‍💻 Autor

**Frederico Almeida**

*Cloud Engineer | AWS Certified Solutions Architect – Associate | Terraform | Linux | Serverless | CloudOps*
