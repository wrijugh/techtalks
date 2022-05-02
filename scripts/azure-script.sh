# Global Azure May 2022
rnd=$RANDOM
g=rg-demo$rnd

az group create -n $g -l eastus

# Azure Container Registry (ACR)
acr=wgacr$rnd
az acr create -g $g -n $acr --admin-enabled=true --sku=basic

echo "Please copy the ACR password and paste here:"
# -----------
acrpwd=XjUfuyeuBF8L4r8DDRleYbdh/Gi3Vd1y

docker login -u $acr -p $acrpwd $acr.azurecr.io

az acr login -n $acr

## Download the nginx image to local machine 

docker pull nginx

image=$acr.azurecr.io/nginx:latest

docker images
image_id=fa5269854a5e

docker tag $image_id $image

docker push $image

# ---------------
# Azure Container Instance (ACI)
aci=nginx$rnd
az container create -g $g -n $aci --image=$image --ip-address=Public --registry-password=$acrpwd --registry-username=$acr 

## Azure App Service (Container)
plan=asPlan$rnd
webapp=wgwebapp$rnd
az appservice plan create -g $g -n $plan --is-linux --sku B2

az webapp create -g $g -n $webapp -p $plan -i=$image -s wgacr -w $acrpwd

# Azure Kubernetes Service (AKS)
