

n=wg-ubuntu-vm
g=rg-ubuntu-2

az group create -n $g -l eastus

az vm create -n $n -g $g --image=ubuntults --generate-ssh-keys