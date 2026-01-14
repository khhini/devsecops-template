
# CICD Templates

## Branching Strategy

Branching strategy mendefinisikan roles spesifik setiap branch dalam proses deployment dari Development hingga Production.

| Branch Name | Purpose | Stability | Deployment Trigger |
| --- | --- | --- | --- |
| `main` | Memuat `production-ready` source code. Semua deployments ke Production enviroment berasal dari branch ini. | Highest | `Production` (Manual / Scheduled Approval) |
| `staging` | Mengintrasikan semua fitur & bug fix, di serving sebagai branch integrasi | High | `Staging/Pre-production`(Automatic on merge) |
| `feature/*` | digunanakan untuk mendevelop fitur baru. dibuat dari branch `staging` | Low | N/A |
| `bugfix/*` | digunakan untuk memperbaiki **non-critical bugs** dalam branch `staging`. dibuat dari branch `staging` | Medium | N/A |
| `hotfix/*` | Untuk memperbaiki **critical production bugs**. dibuat dari branch `main` | Medium / High | N/A |

### Workflow

1. **Development**: Developers membuat branch `feature/` atau `bugfix/` dari branch `staging`
2. **Integrasi:** Setelah selesai, developer membuka **Pull Request** ke branch `staging`. Merge ke `staging`untuk mentrigger CI pipelines.
3. **CI/CD Trigger:** CI pipelines akan menjalankan proses builds. Jika langkah - langkah CI berhasil (lulus test), CI akan mentrigger **CD Pipeline.**
4. **Deployment Staging**: CD pipeline akan melakukan proses deployment ke environment `Staging`
5. **Promosi ke Production**: Setelah fitur/perbaikan bug di `Staging` disetujui untuk naik ke `Production`, branch `staging` di-merge ke `main`.
6. **Rilis Production**: buat release tag dengan format `vX.Y.Z` ( misal, `v1.0.0` ) dari commit branch `main` yang akan di release. Pembuatan tag ini akan mentrigger deployment ke environment `Production`.

## CI/CD Pipelines

### Pipeline Architecture

### Environment Mapping

| environment | Branch Source | CI/CD Pipeline Trigger | Testing Level |
| --- | --- | --- | --- |
| Development | `feature/*`, `bugfix/*` | N/A | Unit, Linting, Basic Integration |
| Staging (UAT/QA) | `staging`(on merge) | Full CI -> Container Build -> Deploy | End-to-End, User Acceptance |
| Production | `main` (on tag release) | Full CI -> Container Build -> Deploy | Smoke, Post-deployment Health Checks |

### CI/CD pipelines Configurations

### Config File Structure

```
root-project/
|-- ...
|-- deployments/
    |-- overlays/
        |-- development/
            |-- cloudbuild.ci.yaml  -> Mendefinisikan langkah-langkah **CI Pipeline**
            |-- cloudbuild.cd.yaml -> Mendefinisikan langkah-langkah **CD Pipeline**
            |-- cloudbuild.cicd.yaml -> Mendifiniskan langkah-langkah **CI & CD Pipeline**
            |-- service.yaml -> Mendefinisikan konfigurasi deployment **Cloud Run Service**
        |-- production/
            |-- ..
        |-- ..
|-- ...

```

Notes:

- **Variabel Lingkungan *Build Time***: Didefinisikan dalam file **`deployments/overlays/DEPLOYMENT_ENV/cloudbuild.yaml`**.
- **Substitutions Cloud Build**: Untuk CI dan CD Pipeline dikonfigurasi dalam **`deployments/overlays/DEPLOYMENT_ENV/cloudbuild.yaml`**.
- **Variabel Lingkungan *Runtime***: Didefinisikan dalam konfigurasi *service* **`deployments/overlays/DEPLOYMENT_ENV/service.yaml`**.

### Continuous Integration (CI) Steps - ditrigger pada setiap push

CI Pipeline dipicu pada **setiap *push* ke *remote repository*** (sesuai dengan Environment Mapping).

1. Checkout Code -> clone code dari source code
2. Build Step Env generations -> jika perlukan ( untuk frontend ), menghasilkan environment variable untuk proses compiling dan/atau build artifact.
3. Build Artifact -> mengompilasi aplikasi dan/atau build Docker image. Image akan diberikan tag dengan **Git commit SHA** dan **nama branch**.
4. Artifact Push -> Push Docker image yang telah di-build ke **Google Artifact Registry**

### Continuous Deployment (CD) Steps - ditrigger oleh CI Pipeline

CD Pipeline dipicu **setelah CI Pipeline berhasil** (seperti yang didefinisikan dalam `cloudbuild.cd.yaml`).

1. **Update Konfigurasi**: Memperbarui file  `cloudrun/service.yaml` dengan image tag yang baru.
2. **Execute Deployment:** Menjalankan deployment script ( menggunakan `gcloud run replace` ) untuk melakukan deployment ke **Cloud Run** berdasarkan konfigurasi `cloudrun/service.yaml`

## Cloud Run Service Configurations

Konfigurasi cloud run services diatur pada file `cloudrun/service.yaml`, file ini berperan sebagai single source of truth untuk deployment cloud run service. Pengaturan environment variabel, secrets, networking, volume, dan konfigurasi lain yang terkait dengan cloud run diatur pada file ini.

### Copy Existing Cloud Run service Configurations

Konfigurasi cloud run service dapat di copy dari existing running service dengan menjalankan perintah berikut:

```bash
gcloud run services describe $CLOUD_RUN_SERIVCE_NAME --project $CLOUD_RUN_SERVICE_PROJECT --region $CLOUD_RUN_SERVICE_LOCATION --format export > deployments/overlays/$_DEPLOYMENT_ENV/service.yaml

```
