# azure

### create blob for backend

```
az group create --resource-group test-rg --location eastus

az storage account create --name tfbackendaktest --resource-group test-rg --sku Standard_LRS --location eastus

az storage container create --name tfstate --account-name tfbackendaktest

az storage container create --account-name mystorageaccount --name mystoragecontainer
        --account-key "enter-your-storage_account-key" --blob-endpoint
        "https://mystorageaccount.z3.blob.storage.azure.net/"
```
