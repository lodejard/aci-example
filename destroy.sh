
function error() {
    echo $1
    exit 1
}

which az >/dev/null         || error "Azure CLI 'az' must be available on the path"
which terraform >/dev/null  || error "Terraform CLI 'terraform' must be available on the path"

echo "Destroy Azure resources"

terraform init azure-deployment     || error "Terraform init failed"
terraform validate azure-deployment || error "Terraform validate failed"
terraform destroy azure-deployment  || error "Terraform destroy failed"
