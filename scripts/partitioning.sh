#!/bin/bash -e
# function install_parted () {
#   PACKAGE="parted"

#   if dpkg -s "${PACKAGE}" &> /dev/null;
#   then
#     echo -e "\n${INFO}\tREQUIRED PACKAGE:\t${PACKAGE}\tis already in installed state.\n"
#   else
#     echo -e "\n${INFO}\tINSTALLING REQUIRED PACKAGE:\t${PACKAGE}\n"
#     sudo DEBIAN_FRONTEND=noninteractive apt-get install "${PACKAGE}" -y
#   fi
# }

# # Function to determine the size of an NVMe volume
# get_nvme_size() {
#     volume=$1
#     lsblk -o SIZE -n $volume | tr -d '[:space:]'
# }

# create_partition_and_format() {
#     device=$1
#     label=$2

#     echo "Creating a partition on device $device, with label $label"

#     # Create partition using parted command
#     sudo parted -s $device mklabel gpt
#     sudo parted -s $device mkpart $label 0% 100%

#     # Format partition as ext4
#     sleep 30
#     sudo mkfs -t ext4 $device"p1"
#     sudo e2label $device"p1" $label

# }

# Make sure parted is installed
# install_parted

# # List all NVMe volumes excluding the root volume
# root_volume=$(blkid | grep cloudimg-rootfs | awk '{print $1}' | cut -d "/" -f 3 | cut -d "p" -f 1)
# #nvme_list=$(lsblk -o NAME,SIZE -d -n | grep "nvme" | grep -v $root_volume| awk '{print $1}')
# nvme_list="nvme1n1 nvme2n1 nvme3n1 nvme4n1 nvme5n1 nvme6n1 nvme7n1"
# label="home var var/log var/log/audit var/tmp tmp appdata"
# for line in $nvme_list; do
#         volume="/dev/$(echo $line | cut -d' ' -f1)"
#         create_partition_and_format $volume $label
#         echo "Created partition, formatted as ext4, and assigned label '$label' to NVMe volume $volume."
#     done


# for x in $(nvme_list label)
#   do
#     echo "setting up partition for $x"
#     sudo mkdir /newtmp-$label
#     sudo mount /dev/$x /newtmp-$labelsleep 10
#     sudo rsync -aXS /$label/. /newtmp-$label/.
#     sudo mv /$label /oldtmp-$label
#     sudo mkdir /$label
#     sudo sed -i '/\/$label.*ext4/d' /etc/fstab
#     echo '/dev/$nvme_list /$label ext4 noatime,nodev,nosuid,nofail 0 2' >> /etc/fstab
#     sudo umount /newtmp-$label
# done

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y &> /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install parted -y

echo "Some troublehsooting output"
sudo lsblk
echo "contents of /etc/fstab"
cat /etc/fstab
echo "contents of df"
df -h

#/home
#nvme1n1
sudo parted -s /dev/nvme1n1 mklabel gpt
sudo parted -s /dev/nvme1n1 mkpart home 0% 100%
# Format partition as ext4
sudo mkfs -t ext4 /dev/nvme1n1
sudo e2label /dev/nvme1n1 home
echo "setting up partition for nvme1n1"
sudo mkdir /new-home
sudo mount /dev/nvme1n1 /new-home
sudo rsync -aXS /home/. /new-home/.
sudo mv /home /old-home
sudo mkdir /home
sudo sed -i '/\/home.*ext4/d' /etc/fstab
echo '/dev/nvme1n1 /home ext4 noatime,nodev,nosuid,nofail 0 2' | sudo  tee -a /etc/fstab
sudo umount /new-home
sudo mount -a

#/var
#nvme2n1
sudo parted -s /dev/nvme2n1 mklabel gpt
sudo parted -s /dev/nvme2n1 mkpart var 0% 100%
# Format partition as ext4
sudo mkfs -t ext4 /dev/nvme2n1
sudo e2label /dev/nvme2n1 var
echo "setting up partition for nvme2n1"
sudo mkdir /newvar
sudo mount /dev/nvme2n1 /newvar
sudo rsync -aXS /var/. /newvar/.
sudo mv /var /oldvar
sudo mkdir /var
sudo sed -i '/\/var.*ext4/d' /etc/fstab
echo '/dev/nvme2n1 /var ext4 noatime,nodev,nosuid,nofail 0 2' | sudo  tee -a /etc/fstab
sudo umount /newvar
sudo mount -a

#/var/log
#nvme3n1
sudo parted -s /dev/nvme3n1 mklabel gpt
sudo parted -s /dev/nvme3n1 mkpart varlog 0% 100%
# Format partition as ext4
sudo mkfs -t ext4 /dev/nvme3n1
sudo e2label /dev/nvme3n1 varlog
echo "setting up partition for nvme3n1"
sudo mkdir -p /var/log
echo '/dev/nvme3n1 /var/log ext4 noatime,nodev,nosuid,nofail 0 2' | sudo  tee -a /etc/fstab
sudo mount -a

#/var/log/audit
#/var/log/audit should be a new directory and therefore is created a bit differently from a directory that already exists
#nvme4n1
sudo parted -s /dev/nvme4n1 mklabel gpt
sudo parted -s /dev/nvme4n1 mkpart varlogaudit 0% 100%
# Format partition as ext4
sudo mkfs -t ext4 /dev/nvme4n1
sudo e2label /dev/nvme4n1 varlogaudit
echo "setting up partition for nvme4n1"
sudo mkdir -p /var/log/audit
sudo mount -a

#/var/tmp
#/var/tmp should be a new directory and therefore is created a bit differently from a directory that already exists
#nvme5n1
sudo parted -s /dev/nvme5n1 mklabel gpt
sudo parted -s /dev/nvme5n1 mkpart vartmp 0% 100%
# Format partition as ext4
sudo mkfs -t ext4 /dev/nvme5n1
sudo e2label /dev/nvme5n1 vartmp
echo "setting up partition for nvme5n1"
sudo mkdir -p /var/tmp
sudo sed -i '/\/var\/tmp.*ext4/d' /etc/fstab
echo '/dev/nvme5n1 /var/tmp ext4 noatime,nodev,nosuid,nofail 0 2' | sudo  tee -a /etc/fstab
sudo mount -a

#/tmp
#nvme6n1
sudo parted -s /dev/nvme6n1 mklabel gpt
sudo parted -s /dev/nvme6n1 mkpart tmp 0% 100%
# Format partition as ext4
sudo mkfs -t ext4 /dev/nvme6n1
sudo e2label /dev/nvme6n1 tmp
echo "setting up partition for nvme6n1"
sudo mkdir /newtmp
sudo mount /dev/nvme6n1 /newtmp
sudo mv /tmp /oldtmp
sudo mkdir /tmp
sudo sed -i '/\/tmp.*ext4/d' /etc/fstab
echo '/dev/nvme6n1 /tmp ext4 noatime,nodev,nosuid,nofail 0 2' | sudo  tee -a /etc/fstab
sudo umount /newtmp
sudo mount -a

#/appdata
#/appdata should be a new directory and therefore is created a bit differently from a directory that already exists
#nvme7n1
sudo parted -s /dev/nvme7n1 mklabel gpt
sudo parted -s /dev/nvme7n1 mkpart appdata 0% 100%
# Format partition as ext4
sudo mkfs -t ext4 /dev/nvme7n1
sudo e2label /dev/nvme7n1 appdata
echo "setting up partition for nvme7n1"
sudo mkdir -p /appdata
sudo sed -i '/\/appdata.*ext4/d' /etc/fstab
echo '/dev/nvme7n1 /appdata ext4 noatime,nodev,nosuid,nofail 0 2' | sudo  tee -a /etc/fstab
sudo mount -a

echo "Finished partitioning"