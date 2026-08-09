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

Infraestrutura de nível de produção (*production-like*) desenvolvida totalmente como código utilizando **Terraform**, provisionando automaticamente um portal operacional para gerenciamento e visualização dinâmica de recursos AWS através de um **Motor de Descoberta Automática baseado em Tags** (*Resource Groups Tagging API*).

O ambiente é composto por:

- Amazon CloudFront
- Amazon S3
- AWS Lambda (Python 3.11)
- Amazon API Gateway HTTP
- Amazon DynamoDB
- Amazon CloudWatch
- AWS Cost Explorer
- IAM Least Privilege (Menor Privilégio)

O projeto simula um portal utilizado por equipes de Engenharia de Cloud para visualizar informações operacionais da infraestrutura AWS, incluindo consumo de recursos, custos, inventário dinâmico e métricas em tempo real.

---

# 🎯 Objetivo do Projeto

Projetar e demonstrar uma arquitetura moderna baseada em serviços **Serverless**, aplicando boas práticas de Engenharia de Cloud e Infraestrutura como Código.

Este projeto faz parte do meu portfólio profissional e demonstra a construção de uma aplicação totalmente automatizada utilizando serviços gerenciados da AWS.

Os principais pilares da solução são:

- **Infraestrutura como Código (IaC):** Provisionamento automatizado utilizando Terraform.
- **Arquitetura Serverless:** Eliminação da necessidade de gerenciamento de servidores.
- **Descoberta Dinâmica de Recursos:** Varredura automática da AWS via tags corporativas, sem necessidade de alterações manuais no front-end.
- **Observabilidade Centralizada:** Monitoramento completo através do Amazon CloudWatch.
- **FinOps:** Consulta de custos utilizando a API do AWS Cost Explorer.
- **Segurança por Padrão:** Aplicação do princípio de Menor Privilégio (*Least Privilege*).
- **Alta Disponibilidade:** Distribuição global através do Amazon CloudFront.

---

# 🏗️ Arquitetura do Sistema

```mermaid
graph TD

User((Usuário))

User --> CF[Amazon CloudFront]

CF --> S3[Amazon S3]

S3 --> Browser[Frontend - Painel Dinâmico]

Browser --> API[Amazon API Gateway]

API --> Lambda[AWS Lambda / Motor de Descoberta]

Lambda --> Dynamo[(Amazon DynamoDB)]

Lambda --> Cost[Cost Explorer]

Lambda --> CW[Amazon CloudWatch]

Lambda --> Tags[AWS Resource Groups Tagging API]

CW --> Dashboard[Dashboards]

🧠 Decisões Arquiteturais

    Amazon CloudFront: Distribuição global do frontend utilizando CDN.

    Origin Access Control (OAC): Bucket S3 privado sem acesso público direto.

    Amazon S3: Hospedagem estática do frontend de alta performance.

    AWS Lambda: Backend serverless em Python 3.11 contendo a lógica de autenticação e o Motor de Descoberta de Recursos via API de Tags da AWS.

    Amazon API Gateway HTTP: Camada de exposição da API leve e de baixa latência.

    Amazon DynamoDB: Persistência de usuários e controle de acesso criptografado.

    Amazon CloudWatch: Monitoramento, dashboards e logs centralizados.

    AWS Cost Explorer: Consulta automática de custos e projeções da conta AWS.

    IAM Least Privilege: Permissões mínimas restritas e necessárias para a execução do backend.

📦 Recursos Implementados & Provisionados
🌐 Frontend & Navegação

    Amazon S3

    Amazon CloudFront

    Origin Access Control (OAC)

    Painéis Integrados: Dashboard, Infrastructure, Serverless Observer, Monitoring e Costs (FinOps)

⚙️ Backend & Lógica

    AWS Lambda

    Amazon API Gateway HTTP

    Motor de Varredura por Tags (tag:GetResources)

    IAM Role & Policies restritas

🗄 Banco de Dados

    Amazon DynamoDB

📈 Observabilidade

    CloudWatch Dashboard

    CloudWatch Log Groups

    CloudWatch Alarms

💰 FinOps

    AWS Cost Explorer API

🔒 Segurança

    IAM Least Privilege

    Bucket Privado com OAC

    Políticas customizadas

🔒 Segurança

A arquitetura foi desenvolvida seguindo rigorosamente o princípio de Menor Privilégio (Least Privilege), implementando:

    Bucket S3 totalmente privado.

    CloudFront utilizando Origin Access Control (OAC).

    IAM Roles específicas e escopo restrito para execução da Lambda.

    Políticas customizadas para leitura de tags globais e DynamoDB.

    API Gateway integrado ao backend serverless.

👁️ Observabilidade

O projeto integra monitoramento completo utilizando o Amazon CloudWatch.

São monitorados:

    Execuções e latência da Lambda

    Taxa de erros da aplicação

    Métricas de invocação do API Gateway

    Logs centralizados em Log Groups gerenciados

    Dashboards operacionais customizados

💰 FinOps

O CloudOps Portal integra-se ao AWS Cost Explorer, permitindo visualizar informações financeiras da infraestrutura como:

    Custos diários e mensais da conta

    Projeções de gastos ao final do ciclo

    Distribuição de custos por serviços da nuvem

Demonstrando a integração direta entre operações Cloud e governança financeira.
📁 Estrutura do Projeto & Descrição dos Módulos
Plaintext

.
├── api_gateway.tf          # Configuração do API Gateway HTTP (Rotas e Integrações)
├── backend.tf              # Configuração do backend do Terraform (S3 + DynamoDB State Locking)
├── cloudfront.tf           # Distribuição global via CloudFront e regras de cache
├── cloudwatch.tf           # Criação de Alarms, Log Groups e Dashboards de Monitoramento
├── dynamodb.tf             # Tabela NoSQL para persistência de usuários e autenticação
├── frontend.tf             # Provisionamento do S3, Bucket Policy e OAC
├── iam.tf                  # Perfis de segurança, políticas de Menor Privilégio e IAM Roles
├── locals.tf               # Variáveis locais e tags globais padronizadas do projeto
├── outputs.tf              # Exibição dos endpoints principais (CloudFront, API Gateway, etc.)
├── providers.tf            # Definição dos provedores oficiais da AWS
├── variables.tf            # Declaração das variáveis globais da infraestrutura
├── versions.tf             # Travas de versão do Terraform e provedores
├── dev.tfvars              # Valores reais das variáveis para o ambiente de desenvolvimento
├── frontend/               # Código-fonte da interface web (Serverless Single Page Application)
│   ├── assets/             # Imagens, ícones e mídias estáticas
│   ├── index.html          # 🔐 Tela de Login e autenticação integrada à API
│   ├── register.html       # 📝 Tela de Cadastro de novos usuários (DynamoDB)
│   ├── dashboard.html      # 📊 Painel Principal com status dos serviços e feed de atividades
│   ├── infrastructure.html # 🏗️ Inventário de infraestrutura provisionada
│   ├── serverless-dashboard.html # ⚡ Painel 'Serverless Observer' (Motor de Descoberta por Tags)
│   ├── monitoring.html     # 📈 Central de Observabilidade, latência e métricas
│   ├── costs.html          # 💰 Análise de Custos e governança FinOps (Cost Explorer)
│   └── config.js           # ⚙️ Arquivo dinâmico gerado/configurado com a URL do API Gateway
└── README.md               # Documentação oficial do projeto

💡 O que cada página faz no sistema:

    index.html (Login): Porta de entrada da aplicação. Realiza a autenticação segura do usuário validando as credenciais contra a tabela do DynamoDB através da Lambda.

    register.html (Cadastro): Página dedicada ao registro de novos usuários na plataforma, aplicando criptografia de senha por hash (SHA-256) antes de gravar no banco NoSQL.

    dashboard.html (Visão Geral): O painel de controle principal. Exibe indicadores rápidos de saúde dos serviços, custo atual da conta e um feed de atividades operacionais em tempo real.

    infrastructure.html (Infraestrutura): Inventário estruturado para visualização dos componentes base da nuvem com suporte a pesquisa instantânea.

    serverless-dashboard.html (Serverless Observer): O painel inteligente do projeto. Ele consome a rota /resources da Lambda, que varre dinamicamente a AWS por meio da Resource Groups Tagging API procurando recursos tagueados com CloudOps = "true", desenhando-os na tela automaticamente (como SQS, Lambda, S3, DynamoDB, etc.).

    monitoring.html (Monitoramento): Central de observabilidade focada nas métricas de performance, latência e status operacional da arquitetura serverless.

    costs.html (FinOps): Dashboard financeiro que consome a API do AWS Cost Explorer para detalhar custos diários, mensais e projeções de gastos da conta.

    config.js: Arquivo que desacopla o front-end do back-end, injetando dinamicamente a URL correta do API Gateway em todas as requisições web.

⚙️ Pré-requisitos

Antes da execução, certifique-se de possuir:

    Terraform 1.5+ instalado

    AWS CLI configurada com credenciais válidas

    Permissões para criação de recursos IAM, Lambda, DynamoDB, S3 e CloudFront na conta AWS

    AWS Cost Explorer habilitado na conta

🚀 Como Executar
1. Inicializar o Terraform
Bash

terraform init

2. Criar / Selecionar Workspace
Bash

terraform workspace select dev || terraform workspace new dev

3. Validar Configuração
Bash

terraform validate

4. Planejar Alterações
Bash

terraform plan -var-file="dev.tfvars"

5. Provisionar Infraestrutura
Bash

terraform apply -var-file="dev.tfvars"

6. Destruir Ambiente
Bash

terraform destroy -var-file="dev.tfvars"

🌐 Outputs

Após o término bem-sucedido do terraform apply, serão disponibilizados automaticamente:

    URL de acesso do CloudFront (Frontend)

    Endpoint do API Gateway (Backend)

    Nome da função Lambda

    Nome da tabela DynamoDB

    Nome do Bucket S3 do Front-end

    Link do Dashboard CloudWatch

🔥 Destaques Técnicos

    Arquitetura 100% Serverless e Orientada a Eventos

    Motor de Descoberta Automática: O front-end consulta a Lambda, que utiliza a API de Tags da AWS para listar novos recursos instantaneamente, sem alterações de código front-end.

    Frontend distribuído globalmente através do CloudFront com OAC

    Backend desacoplado utilizando API Gateway + Lambda (Python)

    Banco de dados NoSQL otimizado utilizando DynamoDB

    Deploy e gerenciamento totalmente automatizados com Terraform

    Integração nativa com AWS Cost Explorer (FinOps)

    Dashboards operacionais e logs em tempo real via CloudWatch

    Conformidade rígida com IAM Least Privilege

    Geração automatizada do arquivo de configuração do ambiente (config.js)

🚀 Roadmap

Próximas evoluções planejadas para o projeto:

    Autenticação avançada com Amazon Cognito

    Proteção de borda com AWS WAF

    Rastreamento distribuído com AWS X-Ray

    Orquestração de eventos com Amazon EventBridge e Amazon SNS

    Exportação de relatórios gerenciais em PDF

    Suporte a arquitetura Multi-Region

    Pipeline de CI/CD automatizado com GitHub Actions

    Testes automatizados de infraestrutura

    Integração com AWS Organizations

👨‍💻 Autor

Frederico Almeida

Cloud Engineer | AWS Certified Solutions Architect – Associate | Terraform | Linux | Serverless
