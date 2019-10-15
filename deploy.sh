
function error() {
    echo $1
    exit 1
}

/usr/bin/dotnet publish "src/HelloWorld" -o "obj/sites/HelloWorld" || {
    error "Build failed"
}

mkdir -p obj/plans

terraform init deploy/dev || {
    error "Terraform init failed"
}

terraform validate deploy/dev || {
    error "Terraform validate failed"
}

terraform plan -out obj/plans/dev deploy/dev || {
    error "Terraform plan failed"
}

terraform apply obj/plans/dev || {
    error "Terraform apply failed"
}

az storage file upload-batch --account-key "$(terraform output storage_account_key)" --account-name "$(terraform output storage_account_name)" --destination "files" --destination-path "app" --source "obj/sites/HelloWorld" || {
    error "Uploading web application failed"
}

echo "Open browser to http://$(terraform output fqdn)"
