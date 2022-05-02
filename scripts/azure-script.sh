# Global Azure May 2022

rnd=$RANDOM
g=rg-demo$rnd

az group create -n $g -l eastus

# Azure Container Registry (ACR)
acr=wgacr$rnd
az acr create -g $g -n $acr --admin-enabled=true --sku=basic

# -----------Manually Copy the Password from Portal------------
acrpwd=BieaKhEMFHBrDougN9tl8xAh3Z9XV/iR

docker login -u $acr -p $acrpwd $acr.azurecr.io

az acr login -n $acr

## Download the nginx image to local machine 
img=nginx
docker pull $img

image=$acr.azurecr.io/$img:latest

docker images
#----------------Manually copy the IMAGE ID from console-----------
# Task: Get docker image ID for $img
image_id=fa5269854a5e

docker tag $image_id $image

docker push $image

# Azure Container Instance (ACI)
aci=nginx$rnd
az container create -g $g -n $aci --image=$image --ip-address=Public --registry-password=$acrpwd --registry-username=$acr 

# Task: Get Public IP


# Azure App Service (Container)
plan=asPlan$rnd
webapp=wgwebapp$rnd

az appservice plan create -g $g -n $plan --is-linux --sku B2

az webapp create -g $g -n $webapp -p $plan -i=$image -s $acr -w $acrpwd

curl http://$webapp.azurewebsites.net 

# Azure Kubernetes Service (AKS)
