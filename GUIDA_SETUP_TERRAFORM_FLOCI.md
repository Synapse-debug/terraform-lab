# Guida Completa: Setup Ambiente di Studio Terraform con Floci (Emulatore AWS Locale) su Windows

Questa guida è pensata per spiegare passo-passo, partendo da zero assoluto, come allestire un ambiente per studiare ed esercitarsi con **Terraform per AWS** direttamente sul proprio PC Windows, **senza avere un account AWS reale e senza spendere un centesimo**.

---

## Indice

1. [Concetti Base: Perché questa architettura?](#1-concetti-base-perché-questa-architettura)
2. [Software Necessari e Installazione da Zero](#2-software-necessari-e-installazione-da-zero)
3. [Dove si trova la roba nel computer](#3-dove-si-trova-la-roba-nel-computer)
4. [Struttura della Cartella di Lavoro](#4-struttura-della-cartella-di-lavoro)
5. [Spiegazione dei File e del Codice](#5-spiegazione-dei-file-e-del-codice)
   - [docker-compose.yml](#file-docker-composeyml)
   - [provider.tf](#file-providertf)
   - [main.tf](#file-maintf)
6. [Guida Operativa: Il Ciclo di Lavoro](#6-guida-operativa-il-ciclo-di-lavoro)
7. [Comandi Essenziali di Riferimento (Cheat Sheet)](#7-comandi-essenziali-di-riferimento-cheat-sheet)
   - [Comandi Docker](#comandi-docker-più-utilizzati)
   - [Comandi Terraform](#comandi-terraform-più-utilizzati)
   - [Comandi AWS CLI per Test e Verifica](#comandi-aws-cli-per-test-e-verifica)
8. [Verifica Visiva: Web Console](#8-verifica-visiva-web-console)

---

## 1. Concetti Base: Perché questa architettura?

Per imparare **Terraform per AWS** di solito servirebbe un account AWS con carta di credito, rischiando costi imprevisti se ci si dimentica di distruggere le risorse create.

Per evitare questo rischio usiamo una combinazione di 3 strumenti:
- **Terraform**: Lo strumento di Infrastructure as Code (IaC). Legge file scritti in linguaggio HCL (`.tf`) e descrive a un provider le risorse da creare/modificare/distruggere.
- **Floci**: Un emulatore locale di AWS gratuito e open-source (drop-in replacement moderno per LocalStack). Si comporta esattamente come i server di AWS, rispondendo agli standard API di Amazon sulla porta `4566`, ma gira sul tuo computer.
- **Docker Desktop**: Il gestore di container che ospita ed esegue il container di Floci su Windows.

```text
[Tuo Codice Terraform (.tf)] ---> (porta 4566) ---> [Container Floci (Docker)]
                                                            |
[AWS CLI (per verifiche)]   ---> (porta 4566) ------------> |
                                                            v
                                                   [Risorse AWS Emulate]
                                                   (S3, SQS, DynamoDB...)
```

---

## 2. Software Necessari e Installazione da Zero

Se un utente parte da un computer pulito, ecco cosa deve installare e come:

### A. Docker Desktop
1. Scaricare l'installer ufficiale dal sito: [https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)
2. Avviare l'eseguibile e seguire la procedura guidata assicurandosi che sia selezionata l'opzione **WSL 2** (consigliata).
3. Al termine dell'installazione, riavviare il computer se richiesto.
4. Avviare l'applicazione **Docker Desktop** dal menu Start e verificare che l'icona nell'angolo in basso a sinistra diventi verde con la scritta **"Engine running"**.

### B. Terraform CLI
Aprire il terminale **PowerShell** ed eseguire:
```powershell
winget install Hashicorp.Terraform --accept-package-agreements --accept-source-agreements
```
*Chiudere e riaprire PowerShell per rendere attivo il comando nel PATH.*

### C. AWS CLI (v2)
Sempre dal terminale **PowerShell**:
```powershell
winget install Amazon.AWSCLI --accept-package-agreements --accept-source-agreements
```
*Chiudere e riaprire PowerShell per rendere attivo il comando nel PATH.*

---

## 3. Dove si trova la roba nel computer

Nel sistema Windows i percorsi effettivi dei componenti installati sono:

| Componente | Percorso nel File System | Note |
| :--- | :--- | :--- |
| **Docker Desktop (Eseguibile CLI)** | `C:\Users\<TUO_UTENTE>\AppData\Local\Programs\DockerDesktop\resources\bin\docker.exe` | Aggiunto al PATH utente |
| **Terraform** | `C:\Users\<TUO_UTENTE>\AppData\Local\Microsoft\WinGet\Packages\Hashicorp.Terraform_...\terraform.exe` | Aggiunto al PATH utente |
| **AWS CLI** | `C:\Program Files\Amazon\AWSCLIV2\aws.exe` | Aggiunto al PATH di sistema |
| **Cartella di Lavoro dei Lab** | `C:\Users\<TUO_UTENTE>\Documents\GitHub\terraform-lab` | Contiene manifest `.tf` e `docker-compose.yml` |

---

## 4. Struttura della Cartella di Lavoro

All'interno di `C:\Users\X\Documents\GitHub\terraform-lab` sono presenti i seguenti file:

```text
terraform-lab/
│
├── docker-compose.yml      # Istruzioni per far partire l'emulatore Floci
├── provider.tf            # Configurazione provider AWS che punta a Floci
├── main.tf                # Risorse AWS di esempio da creare
│
├── .terraform/            # (Generata da terraform init) Plugin AWS scaricati
├── .terraform.lock.hcl    # (Generata da terraform init) Blocco versioni dei provider
├── terraform.tfstate      # (Generata dopo terraform apply) Mappa delle risorse attive
└── data/                  # Cartella per la persistenza dei dati del container
```

---

## 5. Spiegazione dei File e del Codice

### File: `docker-compose.yml`

Questo file serve a Docker per sapere quale container avviare, quali porte aprire e quali volumi mappare.

```yaml
services:
  floci:
    image: floci/floci:latest
    ports:
      - "4566:4566"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data:/app/data
```

**Cosa fa e perché è fatto così:**
- `image: floci/floci:latest`: dice a Docker di scaricare da Docker Hub l'immagine ufficiale dell'emulatore AWS Floci.
- `ports: - "4566:4566"`: la porta `4566` è la porta standard su cui Floci riceve tutte le chiamate API AWS. Mappando `"4566:4566"` rendiamo l'emulatore raggiungibile dal nostro PC su `http://localhost:4566`.
- `volumes:`
  - `/var/run/docker.sock:/var/run/docker.sock`: consente a Floci di dialogare con il motore Docker locale per servizi che richiedono container reali (come AWS Lambda o database RDS).
  - `./data:/app/data`: salva i dati dell'emulatore in una cartella locale `data`, in modo che se spegni il container non perdi le risorse create.

---

### File: `provider.tf`

Terraform per sua natura parla con il vero cloud AWS. Questo file dice a Terraform: *"Non andare su internet a cercare i server di Amazon, usa il mio emulatore su `localhost:4566`"*.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  # Disabilita i controlli che fallirebbero senza un vero account AWS
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  # Reindirizza ogni servizio verso la porta locale di Floci
  endpoints {
    dynamodb       = "http://localhost:4566"
    s3             = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    iam            = "http://localhost:4566"
    sts            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    ec2            = "http://localhost:4566"
  }
}
```

**Punti chiave:**
- `access_key` e `secret_key`: impostati arbitrariamente su `"test"`. Floci non richiede credenziali reali.
- I parametri `skip_*`: bloccano le chiamate agli endpoint di validazione proprietari di AWS (ad esempio il controllo dell'account ID reale).
- Il blocco `endpoints`: è il cuore dell'integrazione. Ogni volta che Terraform gestisce un bucket S3 o una tabella DynamoDB, non contatta AWS ma chiama `http://localhost:4566`.

---

### File: `main.tf`

Questo file contiene l'infrastruttura di esempio da creare:

```hcl
# =============================================
# Primo test: risorse AWS locali via Floci
# =============================================

# 1. Bucket S3 (Object Storage)
resource "aws_s3_bucket" "test" {
  bucket = "mio-primo-bucket-terraform"
}

# 2. Coda SQS (Messaggistica asincrona)
resource "aws_sqs_queue" "test" {
  name = "mia-prima-coda"
}

# 3. Tabella DynamoDB (Database NoSQL)
resource "aws_dynamodb_table" "test" {
  name         = "mia-prima-tabella"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# 4. Parametro SSM (Archiviazione configurazioni)
resource "aws_ssm_parameter" "test" {
  name  = "/terraform-lab/ambiente"
  type  = "String"
  value = "locale"
}
```

---

## 6. Guida Operativa: Il Ciclo di Lavoro

Ecco la sequenza esatta di comandi da seguire per una sessione di studio.

### Passo 1: Aprire PowerShell ed entrare nella cartella
```powershell
cd C:\Users\X\Documents\GitHub\terraform-lab
```

### Passo 2: Avviare l'emulatore Floci
Assicurati che **Docker Desktop** sia aperto. Poi esegui:
```powershell
docker compose up -d
```
*(Il parametro `-d` fa girare il container in background liberando il terminale).*

### Passo 3: Inizializzare Terraform (solo la prima volta o se cambi provider)
```powershell
terraform init
```
*Scarica i plugin necessari in `.terraform/`.*

### Passo 4: Anteprima delle modifiche
```powershell
terraform plan
```
*Terraform calcola cosa c'è scritto nei file `.tf` rispetto allo stato attuale e mostra un riassunto con i simboli `+` (creazione), `~` (modifica) o `-` (eliminazione).*

### Passo 5: Creare le risorse
```powershell
terraform apply
```
*Terraform chiede conferma. Digita `yes` e premi Invio. Per saltare la richiesta di conferma interattiva puoi usare `terraform apply -auto-approve`.*

### Passo 6: Spegnere tutto a fine sessione
Quando hai finito di studiare:
```powershell
# Distrugge le risorse create da Terraform
terraform destroy -auto-approve

# Spegne e rimuove il container Docker di Floci
docker compose down
```

---

## 7. Comandi Essenziali di Riferimento (Cheat Sheet)

### Comandi DOCKER più utilizzati

| Comando | Descrizione / A cosa serve |
| :--- | :--- |
| `docker ps` | Mostra i container attualmente in esecuzione. |
| `docker ps -a` | Mostra tutti i container, inclusi quelli spenti o fermati. |
| `docker compose up -d` | Avvia i servizi definiti nel `docker-compose.yml` in background. |
| `docker compose stop` | Ferma i container senza rimuoverli. |
| `docker compose start` | Riavvia i container precedentemente fermati. |
| `docker compose down` | Ferma e distrugge i container e la rete creata da Compose. |
| `docker logs -f <nome_container>` | Visualizza i log del container in tempo reale (utile per debug). |
| `docker images` | Mostra tutte le immagini scaricate sul PC. |
| `docker rmi <image_id>` | Elimina un'immagine Docker dal disco per liberare spazio. |
| `docker system prune -a` | Pulisce tutti i container fermi, reti inutilizzate e immagini orfane. |

---

### Comandi TERRAFORM più utilizzati

| Comando | Descrizione / A cosa serve |
| :--- | :--- |
| `terraform init` | Inizializza la cartella, scarica provider e configura il backend. |
| `terraform fmt` | Riformatta automaticamente il codice HCL con le indentazioni corrette. |
| `terraform validate` | Controlla la validità sintattica del codice senza contattare il provider. |
| `terraform plan` | Genera ed espone a video il piano di esecuzione. |
| `terraform apply` | Applica le modifiche all'infrastruttura (richiede digitazione di `yes`). |
| `terraform show` | Ispeziona il file di stato corrente (`terraform.tfstate`) mostrando le risorse attive. |
| `terraform state list` | Elenca in modo sintetico tutte le risorse attualmente tracciate dallo stato. |
| `terraform output` | Mostra a schermo i valori delle variabili di output definite nel codice. |
| `terraform destroy` | Elimina tutte le risorse create da Terraform tracciate nel file di stato. |

---

### Comandi AWS CLI per Test e Verifica

Per interrogare l'emulatore locale con la CLI AWS senza dover inserire credenziali vere, imposta prima queste 3 variabili d'ambiente in PowerShell:
```powershell
$env:AWS_ACCESS_KEY_ID="test"
$env:AWS_SECRET_ACCESS_KEY="test"
$env:AWS_DEFAULT_REGION="us-east-1"
```

Poi usa sempre il flag `--endpoint-url http://localhost:4566`:

```powershell
# S3: Elencare tutti i bucket creati
aws --endpoint-url http://localhost:4566 s3 ls

# S3: Controllare l'interno di un bucket
aws --endpoint-url http://localhost:4566 s3 ls s3://mio-primo-bucket-terraform

# SQS: Elencare tutte le code create
aws --endpoint-url http://localhost:4566 sqs list-queues

# DynamoDB: Elencare tutte le tabelle NoSQL
aws --endpoint-url http://localhost:4566 dynamodb list-tables

# SSM Parameter Store: Leggere il valore di un parametro
aws --endpoint-url http://localhost:4566 ssm get-parameter --name "/terraform-lab/ambiente"
```

---

## 8. Verifica Visiva: Web Console

Floci mette a disposizione una dashboard grafica visualizzabile comodamente da browser.

1. Con il container Floci avviato (`docker compose up -d`), apri Google Chrome o Edge.
2. Digita nella barra degli indirizzi:
   👉 **`http://localhost:4566/_floci/ui`**
3. Al primo caricamento, Floci avvierà in automatico un sidecar container leggero per la dashboard.
4. Dalla barra di navigazione potrai navigare tra i servizi (es. **S3**, **SQS**, **DynamoDB**) e vedere con i tuoi occhi le risorse create da Terraform via interfaccia grafica, esattamente come sulla console AWS reale.
