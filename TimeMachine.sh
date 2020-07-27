#!/bin/bash -e
if [ ! $LINUX_STABLE_SRC ]; then
    echo "You need set \$LINUX_STABLE_SRC."
    exit 1
else if [ ! -d $LINUX_STABLE_SRC/.git ]; then
        git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable $LINUX_STABLE_SRC
    fi
fi

if [ -f ./Vagrantfile ]; then
    echo "Vagrantfile already exists. Do you want to overwrite?[y/N]"
    read $OVERWRITE
    if [ $OVERWRITE != "y" && $OVERWRITE != "Y" ]; then
        exit 1
    fi
fi

echo -e $(cat <<EOF
Vagrant.configure("2") do |config|\n
\tconfig.vm.box = "generic/ubuntu1804"\n
\tconfig.vm.synced_folder ENV["LINUX_STABLE_SRC"], "/home/vagrant/linux-stable", type: "virtualbox", create: true, owner: "vagrant", group: "vagrant"\n
\tconfig.vm.synced_folder ENV["PWD"], "/home/vagrant/work", type: "virtualbox", create: true, owner: "vagrant", group: "vagrant"\n

\tconfig.vm.provision :shell, :path => "kbuild.sh"\n
\tconfig.vm.provider "virtualbox" do |vb|\n
\t\tvb.cpus = 4\n
\t\tvb.memory = 8192\n
\tend\n
end\n
EOF
)> Vagrantfile

echo -e $(cat <<EOF
#!/bin/bash\n
sudo apt-get update
sudo apt-get install -y git bc bison build-essential chrpath cmake diffstat flex gawk gcc gcc-multilib git kmod libelf-dev libssl-dev libncurses5-dev libsdl1.2-d    ev lzop make socat texinfo unar unzip wget xterm
cd /home/vagrant/linux-stable\n
yes ""|make config\n
make -j17\n
sudo make modules_install\n
sudo make install\n
EOF
)> kbuild.sh

USAGE=$(cat <<EOS
Usage: $0 target_commit_hash
EOS
)

if [ ! $1 ]; then
    echo $USAGE;
    rm Vagrantfile
    rm kbuild.sh
    exit 1;
else
    COMMIT_HASH=$1
fi

pushd $PWD

cd $LINUX_STABLE_SRC
git checkout -f $COMMIT_HASH^
if [ $? != 0 ]; then
    echo "checkout error! is $COMMIT_HASH correct?"
    exit 1
fi

popd

vagrant up