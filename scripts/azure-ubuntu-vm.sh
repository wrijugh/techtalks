
rnd=$RANDOM
n=wg-vm-ubuntu$rnd
g=rg-ubuntu$rnd

az group create -n $g -l southeastasia

az vm create -n $n -g $g --image=ubuntults --generate-ssh-keys