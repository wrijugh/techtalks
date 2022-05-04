
rnd=$RANDOM
vm=wg-vm-ubuntu$rnd
g=rg-ubuntu$rnd
loc=southeastasia

adminuser='wriju'
pwd='P@ssw0rd1234'

echo 'VM=$vm will be created inside Resource Group:$g'

az group create -n $g -l $loc

# Economic VM
az vm create -n $vm -g $g --image=ubuntults --generate-ssh-keys \
    --admin-username $adminuser --admin-password @pwd --storage-sku=Standard_LRS

az vm auto-shutdown -g $g -n $vm --time 1430


az vm create -g $g -n $vm --image=ubuntults --generate-ssh-keys 