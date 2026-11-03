# Despliegue Juice Shop seguro (fix IDOR)

Desde la raiz del repo, en la rama fix/idor-basket-ownership (PowerShell):

```
cd deploy/gcp-secure
terraform init
terraform apply -target="google_artifact_registry_repository.repo"
gcloud auth configure-docker us-central1-docker.pkg.dev
cd ../..
docker build -t us-central1-docker.pkg.dev/juice-shop-lab-2026/juice-shop/juice-shop-secure:latest .
docker push us-central1-docker.pkg.dev/juice-shop-lab-2026/juice-shop/juice-shop-secure:latest
cd deploy/gcp-secure
terraform apply
```

Prueba: con el token del atacante, /rest/basket/1 -> 403 y /rest/basket/<su id> -> 200.
