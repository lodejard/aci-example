
function error() {
    echo $1
    exit 1
}

which dotnet >/dev/null     || error ".NET CLI 'dotnet' must be available on the path"
which az >/dev/null         || error "Azure CLI 'az' must be available on the path"
which terraform >/dev/null  || error "Terraform CLI 'terraform' must be available on the path"

echo "Compile web app publish files"

dotnet publish "src/HelloWorld" --output "bin/sites/HelloWorld" --configuration "Release" || {
    error "Build failed"
}

mkdir -p bin/plans

echo "Create Azure resources"

terraform init azure-deployment                                 || error "Terraform init failed"
terraform validate azure-deployment                             || error "Terraform validate failed"
terraform plan -out bin/plans/azure-deployment azure-deployment || error "Terraform plan failed"
terraform apply bin/plans/azure-deployment                      || error "Terraform apply failed"

echo "Upload web app publish files to storage account file share"

az storage file upload-batch --account-key "$(terraform output storage_account_key)" --account-name "$(terraform output storage_account_name)" --destination "files" --destination-path "app" --source "bin/sites/HelloWorld" || {
    error "Uploading web application failed"
}

echo "Restart container to use published files"

az container restart --resource-group "$(terraform output resource_group_name)" --name "$(terraform output container_group_name)" || {
    error "Container restart failed"
}

echo "ContainerGroup url: http://$(terraform output aci_fqdn)"

echo "FrontDoor urls: http://$(terraform output afd_fqdn) https://$(terraform output afd_fqdn)"
