# Global Azure May 2022
# az account set --subscription "MSDN WG 2021"
# Note: please run this script as $ bash file.sh if you use $ sh file.sh may not work because it does not understand $RANDOM

echo ".....Creating variables....."
rnd=`date +%d%m%Y`
# rnd=$RANDOM
g=rg-demo$rnd
g2=rg-demo-del$rnd
loc=southeastasia

echo ".....Creating Resource Groups....."
az group create -n $g -l $loc
# Create this second rg to keep temp resources like aci and websites which can be deleted when needed
az group create -n $g2 -l $loc

echo ".....Creating ACR....."
# Azure Container Registry (ACR)
acr=wgacr$rnd
az acr create -g $g -n $acr --admin-enabled=true --sku=basic

acrpwd=$(az acr credential show -n $acr --query 'passwords[0].value' -o tsv)

echo "ACR Passowrd "$acrpwd

echo "ACR Login"
docker login -u $acr -p $acrpwd $acr.azurecr.io

az acr login -n $acr

echo "Downloading nginx from docker hub"
## Download the nginx image to local machine 
img=nginx
docker pull $img

image=$acr.azurecr.io/$img:latest

docker images
#----------------Manually copy the IMAGE ID from console-----------
# Get docker image ID for $img
image_id=$(docker images -f reference=$img"*" -q)

docker tag $image_id $image

echo "Push NGINX to ACR"
docker push $image

echo "Creating ACI"
# Azure Container Instance (ACI)
aci=nginx$rnd
# create in different resource group $g2 because it will be easy to clean
az container create -g $g2 -n $aci --image=$image --ip-address=Public --registry-password=$acrpwd --registry-username=$acr 

# Task: Get Public IP
aciIp=$(az container show -g $g2 -n $aci --query 'ipAddress.ip' -o tsv)
echo $aciIp
curl http://$aciIp

echo "Creating App Services (Container)"
# Azure App Service (Container)
plan=asPlan$rnd
webapp=wgwebapp$rnd

az appservice plan create -g $g -n $plan --is-linux --sku B2 -l eastus

# create in different resource group $g2 because it will be easy to clean
az webapp create -g $g2 -n $webapp -p $plan -i=$image -s $acr -w $acrpwd

curl http://$webapp.azurewebsites.net 

echo "Creating AKS"
# Azure Kubernetes Service (AKS)
aks=wgaks$rnd
az aks create -n $aks -g $g --generate-ssh-keys #-c 1 

az aks get-credentials -n $aks -g $g

echo "Attaching AKS and ACR"

#attach AKS with ACR
az aks update -n $aks -g $g --attach-acr $acr

# alias k=kubectl

# k create secret docker-registry my-secret \
# --docker-server=$acr.azurecr.io --docker-username=$acr \
# --docker-password=$acrpwd --docker-email=a@a.com

#---------------------------------------------
# dockerhubimage="wrijughosh/$img:latest"
# image=$dockerhubimage #to avoid private reg
# k run nginxpod --image=$image 

# k create deploy $img'web' --image=$image

# k expose deploy $img'web' --port=80 --type=LoadBalancer 

# k get svc -w
#---------------------------------------------

#=================
# To Cleanup 
# Remove only ACI and Azure WebSites (not the plan)
# Hence only delete the resource group $g2
#=================
# az group delete -n $g2 