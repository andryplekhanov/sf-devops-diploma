#!/bin/bash
echo 'hello, we are starting to install software'

# Перечитываем пакеты и обновляем ОС
apt-get update && apt-get upgrade -y

# Устнавливаем terraform и terragrunt с учетом яндекс-зеркала для работы в условиях блокировок - делаем исполняемыми бинарные файлы'
chmod +x /home/ubuntu/terraform
chmod +x /home/ubuntu/terragrunt
mv /home/ubuntu/terraform /bin/terraform
mv /home/ubuntu/terragrunt /bin/terragrunt
cp /home/ubuntu/.terraformrc /root/.terraformrc
chown -R ubuntu:ubuntu /home/ubuntu/.terraformrc

# Ставим предварительные пакеты и зависимости для дальнейших установок утилит, ставим git и синхронизируем время на сервисной ноде'
apt-get install -y git curl ca-certificates gnupg lsb-release gnome-terminal apt-transport-https gnupg-agent software-properties-common chrony tzdata
timedatectl set-timezone Europe/Moscow && systemctl start chrony && systemctl enable chrony

# Ставим docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo usermod -aG docker root
systemctl enable docker.service && systemctl enable containerd.service && systemctl start docker.service && sudo systemctl start containerd.service

# Ставим jq, pip и ansible
add-apt-repository ppa:deadsnakes/ppa -y
apt install python3-pip -y
apt-get install jq ansible -y

# Установка kubeadm kubectl
# Ставим публичный ключ Google Cloud.
# Добавляем Kubernetes репозиторий и перечитываем их:
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update

# Устанавливаем и замораживаем версию утилит при последующих обновлениях через пакетный менеджер:
apt-get install -y kubectl kubeadm
apt-mark hold kubeadm kubectl

# Установка sops и Age
curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64
mv sops-v3.8.1.linux.amd64 /bin/sops
chmod +x /bin/sops
AGE_VERSION=$(curl -s "https://api.github.com/repos/FiloSottile/age/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo age.tar.gz "https://github.com/FiloSottile/age/releases/latest/download/age-v${AGE_VERSION}-linux-amd64.tar.gz"
tar xf age.tar.gz
sudo mv age/age /usr/local/bin
sudo mv age/age-keygen /usr/local/bin
rm -rf age.tar.gz
rm -rf age

# Установка helm
# Ставим ключ и репозиторий:
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

# Перечитываем репозитории и ставим helm и плагин helm-secrets
apt-get update
apt-get install helm -y
helm plugin install https://github.com/jkroepke/helm-secrets --version v4.5.1

# Установка gitlab-runner
# Ставим официальный репозиторий gitlab-runner и перечитываем списки репозиторий
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
apt-get update

# Установка и запуск gitlab-runner
apt-get install gitlab-runner -y
systemctl enable gitlab-runner --now
sudo usermod -aG docker gitlab-runner

echo -e "Сервисная нода готова к управлению кластером k8s. Приступаем к подготовке к развёртывнию кластера."
sleep 5

# Клонируем репозитории для установки k8s кластера с помощью kubespray
cd /opt/
git clone https://github.com/andryplekhanov/kubernetes_setup.git
cd kubernetes_setup/
git clone --branch=release-2.19 https://github.com/kubernetes-sigs/kubespray.git
pip3 install -r ./kubespray/requirements-2.9.txt
sleep 5

# Даём нужные разрешения, подкладываем ключи
chmod +x /opt/kubernetes_setup/cluster_install.sh
chmod +x /opt/kubernetes_setup/cluster_destroy.sh
chmod +x /opt/kubernetes_setup/terraform/generate_credentials_velero.sh
chmod +x /opt/kubernetes_setup/terraform/generate_etc_hosts.sh
chmod +x /opt/kubernetes_setup/terraform/generate_inventory.sh
mv /home/ubuntu/private.variables.tf /opt/kubernetes_setup/terraform/private.variables.tf
cp /home/ubuntu/id_rsa.pub /home/ubuntu/.ssh/id_rsa.pub
cp /home/ubuntu/id_rsa /home/ubuntu/.ssh/id_rsa
cp /home/ubuntu/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub
cp /home/ubuntu/.ssh/id_rsa /root/.ssh/id_rsa
echo "private_key_file = /home/ubuntu/.ssh/id_rsa.pub" >> /etc/ansible/ansible.cfg
echo "private_key_file = /home/ubuntu/.ssh/id_rsa.pub" >> /opt/kubernetes_setup/kubespray/ansible.cfg
chmod 700 /home/ubuntu/.ssh/
chmod 700 /root/.ssh/
chmod 600 /home/ubuntu/.ssh/id_rsa
chown -R ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
chown -R root:root /root/.ssh/id_rsa
chmod 644 /home/ubuntu/.ssh/id_rsa.pub
chown -R ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa.pub
chmod 644 /root/.ssh/id_rsa.pub
chown -R root:root /root/.ssh/id_rsa.pub
apt-get autoremove -y
apt-get autoclean -y

# Поверяем как установились утилиты и их версии: ansible, terraform, terragrunt, jq, docker, docker-compose, git, gitlab-runner, kubeadm, kubectl, helm
echo -e " "
echo -e "Подготовка сервера srv закончена!"
echo -e " "
echo -e "Установились следующие утилиты:"
echo -e " "

echo -e "=========================== Версия ansible =================================="
echo -e " "
ansible --version
echo -e " "

echo -e "=========================== Версия python3 =================================="
echo -e " "
python3 --version
echo -e " "

echo -e "========================== Версия terraform ================================="
terraform --version
echo -e " "

echo -e "========================== Версия terragrunt ================================"
terragrunt --version
echo -e " "

echo -e "============================== Версия jq ===================================="
jq --version
echo -e " "

echo -e "============================ Версия docker =================================="
docker --version
echo -e " "

echo -e "======================== Версия docker-compose =============================="
docker compose version
echo -e " "

echo -e "============================== Версия git ==================================="
git --version
echo -e " "

echo -e "======================== Версия gitlab-runner ==============================="
gitlab-runner --version
echo -e " "

echo -e "========================== Версия kubeadm ==================================="
kubeadm version
echo -e " "
echo -e "=========================== Версия kubectl =================================="
kubectl version
echo -e " "

echo -e "============================= Версия helm ==================================="
helm version
echo -e " "

echo -e "============================= Версия helm secrets ==================================="
helm secrets --version
echo -e " "

echo -e "============================= Версия sops ==================================="
sops --version
echo -e " "

echo -e "============================= Версия age ==================================="
age -version
echo -e " "



echo -e "Подготовка к развёртыванию кластера k8s закончена."
echo -e "Далее необходимо подключиться к сервисной ноде по ssh и запустить скрипт установки k8s кластера в ручную командой ниже:"
echo -e "sudo su"
echo -e "cd /opt/kubernetes_setup"
echo -e "sh cluster_install.sh"
sleep 5