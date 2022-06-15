# Global Azure May 2022
az account set --subscription "MSDN WG 2021"

rnd=$RANDOM
g=rg-demo$rnd
loc=southeastasia

az group create -n $g -l $loc

# Azure Container Registry (ACR)
acr=wgacr$rnd
az acr create -g $g -n $acr --admin-enabled=true --sku=basic

# -----------Manually Copy the Password from Portal------------
# az acr credential show -n $acr --query 'passwords[0].value' -o tsv

acrpwd=$(az acr credential show -n $acr --query 'passwords[0].value' -o tsv)

docker login -u $acr -p $acrpwd $acr.azurecr.io

az acr login -n $acr

## Download the nginx image to local machine 
img=nginx
docker pull $img

image=$acr.azurecr.io/$img:latest

docker images
#----------------Manually copy the IMAGE ID from console-----------
# Task: Get docker image ID for $img
image_id=$(docker images -f reference="nginx*" -q)

docker tag $image_id $image

docker push $image

# Azure Container Instance (ACI)
aci=nginx$rnd
az container create -g $g -n $aci --image=$image --ip-address=Public --registry-password=$acrpwd --registry-username=$acr 

# Task: Get Public IP
aciIp=$(az container show -g $g -n $aci --query 'ipAddress.ip' -o tsv)
echo $aciIp
curl http://$aciIp

# Azure App Service (Container)
plan=asPlan$rnd
webapp=wgwebapp$rnd

az appservice plan create -g $g -n $plan --is-linux --sku B2 -l eastus

az webapp create -g $g -n $webapp -p $plan -i=$image -s $acr -w $acrpwd

curl http://$webapp.azurewebsites.net 

# Azure Kubernetes Service (AKS)
aks=wgaks$rnd
az aks create -n $aks -g $g --generate-ssh-keys #-c 1 

az aks get-credentials -n $aks -g $g

#attach AKS with ACR
az aks update -n $aks -g $g --attach-acr $acr

alias k=kubectl

# k create secret docker-registry my-secret \
# --docker-server=$acr.azurecr.io --docker-username=$acr \
# --docker-password=$acrpwd --docker-email=a@a.com

dockerhubimage="wrijughosh/nginx:latest"
image=$dockerhubimage #to avoid private reg
k run nginxpod --image=$image 

k create deploy nginxweb --image=$image

k expose deploy nginxweb --port=80 --type=LoadBalancer 

k get svc -w