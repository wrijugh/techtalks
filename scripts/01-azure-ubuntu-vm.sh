
rnd=$RANDOM
n=wg-vm-ubuntu$rnd
g=rg-ubuntu$rnd

az group create -n $g -l southeastasia

az vm create -n $n -g $g --image=ubuntults --generate-ssh-keys

az vm create -n $n -g $g --image=ubuntults --generate-ssh-keys --use-unmanaged-disk --storage-sku=Standard_LRS --size Standard 
    --authentication-mode=all