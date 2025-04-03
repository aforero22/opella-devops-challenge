# Repositorio del Proyecto

<details> <summary><strong>README.md</strong></summary>

# Opella DevOps Challenge

Este repositorio contiene un ejemplo de configuración de infraestructura en Azure usando Terraform. Incluye:

- Un módulo reutilizable para desplegar una Azure Virtual Network (VNET).
- Configuraciones separadas para múltiples entornos (dev y prod).
- Ejemplo de recursos adicionales (máquina virtual y storage account).
- Pipeline básico en GitHub Actions para validación y plan de Terraform.

## Estructura de Carpetas

```text
.
├── .github/
│   └── workflows/
│       └── terraform.yml      # Pipeline de GitHub Actions
├── env/
│   ├── dev/
│   │   ├── main.tf            # Invoca el módulo de VNET + recursos dev
│   │   ├── variables.tf       # Variables para dev
│   │   └── terraform.tfvars   # Valores concretos para dev
│   └── prod/
│       ├── main.tf            # Invoca el módulo de VNET + recursos prod
│       ├── variables.tf       # Variables para prod
│       └── terraform.tfvars   # Valores concretos para prod
├── modules/
│   └── vnet/
│       ├── main.tf            # Lógica principal del módulo de VNET
│       ├── variables.tf       # Variables del módulo
│       ├── outputs.tf         # Salidas del módulo
│       └── README.md          # Documentación del módulo
└── README.md                  # Este archivo


Cómo Usar
1. Clona este repositorio.

2. Dirígete a la carpeta env/dev (o env/prod) para probar la infraestructura.

3. Ejecuta:

terraform init
terraform plan
terraform apply

4. Revisa el pipeline de GitHub Actions en .github/workflows/terraform.yml para la integración continua (formateo, validación y plan).


Requisitos
Terraform CLI

Azure CLI o variables de entorno para autenticación con Azure

Una suscripción de Azure válida (puedes usar la free tier)

Contribuir
¡Siéntete libre de hacer un fork y proponer mejoras!



---

## 2. Pipeline de GitHub Actions: `.github/workflows/terraform.yml`

```yaml
name: 'Terraform CI'

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Format (dev)
        run: terraform fmt -check
        working-directory: ./env/dev

      - name: Terraform Init (dev)
        run: terraform init
        working-directory: ./env/dev

      - name: Terraform Validate (dev)
        run: terraform validate
        working-directory: ./env/dev

      - name: Terraform Plan (dev)
        run: terraform plan -out=tfplan.out
        working-directory: ./env/dev

      - name: Terraform Show Plan (dev)
        run: terraform show -no-color tfplan.out
        working-directory: ./env/dev

      # (Opcional) Repetir para 'prod' si se desea CI en ambos entornos
      - name: Terraform Format (prod)
        run: terraform fmt -check
        working-directory: ./env/prod

      - name: Terraform Init (prod)
        run: terraform init
        working-directory: ./env/prod

      - name: Terraform Validate (prod)
        run: terraform validate
        working-directory: ./env/prod

      - name: Terraform Plan (prod)
        run: terraform plan -out=tfplan.out
        working-directory: ./env/prod

      - name: Terraform Show Plan (prod)
        run: terraform show -no-color tfplan.out
        working-directory: ./env/prod
