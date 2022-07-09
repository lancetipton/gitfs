#!/usr/bin/env bash

export PYTHON_VERSION=python3.8

function python {
    $PYTHON_VERSION "$@"
}

echo "I am provisioning..."
sudo sh -c 'date > /etc/vagrant_provisioned_at'

echo "Installing dependencies"
sudo add-apt-repository ppa:presslabs/gitfs
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-virtualenv python-dev libffi-dev build-essential git-core "$PYTHON_VERSION-dev" libgit2-dev "$PYTHON_VERSION-venv" libfuse-dev libfuse2

echo "Configuring fuse"
sudo groupadd fuse
sudo adduser "$USER" fuse
sudo sh -c "echo 'user_allow_other' >> /etc/fuse.conf"

echo "Configure virtualenv"
python -m venv /home/vagrant/gitfs
echo "source $HOME/gitfs/bin/activate" >> "$HOME/.bashrc"

echo Installing cffi
/home/vagrant/gitfs/bin/pip install -q 'cffi'

echo Installing requirements
/home/vagrant/gitfs/bin/pip install -q -r /vagrant/test_requirements.txt

echo Configuring git
git config --global user.email "vagrant@localhost"
git config --global user.name "Vagrant"

echo Installing gitfs
"$HOME/gitfs/bin/pip" install -q -e /vagrant
