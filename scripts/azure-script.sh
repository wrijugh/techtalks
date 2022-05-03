# Global Azure May 2022
az account set "MSDN WG 2021"

rnd=$RANDOM
g=rg-demo$rnd

loc=southeastasia
az group create -n $g -l $loc

# Azure Container Registry (ACR)
acr=wgacr$rnd
az acr create -g $g -n $acr --admin-enabled=true --sku=basic

# -----------Manually Copy the Password from Portal------------
acrpwd=2oMaYhOn4j5m1EVRS=xBZXiYC5GUYXay

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
ip=$(az container show -g $g -n $aci --query 'ipAddress.ip' -o tsv)

curl http://$ip

# Azure App Service (Container)
plan=asPlan$rnd
webapp=wgwebapp$rnd

az appservice plan create -g $g -n $plan --is-linux --sku B2

az webapp create -g $g -n $webapp -p $plan -i=$image -s $acr -w $acrpwd

curl http://$webapp.azurewebsites.net 

# Azure Kubernetes Service (AKS)
