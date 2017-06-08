#!/bin/bash -e

apt-get update

###
echo "Dev tools..."
apt-get install build-essential

###
echo "Setting up Anaconda..."
cd /mnt
wget 'https://repo.continuum.io/archive/Anaconda2-4.4.0-Linux-x86_64.sh'
bash Anaconda2-4.4.0-Linux-x86_64.sh -b -p /mnt/anaconda2
rm -f Anaconda2-4.4.0-Linux-x86_64.sh
echo 'export PATH=/mnt/anaconda2/bin:$PATH' >> /etc/profile
export PATH=/mnt/anaconda2/bin:$PATH

###
echo "Intalling nvidia-cuda..."
cd /mnt
wget 'https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-ubuntu1604-8-0-local-ga2_8.0.61-1_amd64-deb'
dpkg -i cuda*deb
apt-get update
apt-get install -y cuda
rm -f cuda*deb
apt-get clean
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> /etc/profile
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> /etc/profile
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

###
echo "Installing Elektronn..."
conda config --add channels conda-forge && conda install -y elektronn
cp -r /mnt/anaconda2/lib/python2.7/site-packages/elektronn/examples /mnt/
chmod -R a+w /mnt/examples