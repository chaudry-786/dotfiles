install_docker(){
    echo "installing docker"

    # uninstall old versions
    sudo apt-get remove docker docker-engine docker.io containerd runc

    # install dependencies
    sudo apt-get install ca-certificates curl gnupg lsb-release

    # Add Docker’s official GPG key:
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # Use the following command to set up the repository:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the package manager index
    sudo apt update

    # Install Docker Engine, containerd, and Docker Compose.
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # Verify that the Docker Engine installation is successful by running the hello-world image:
    sudo docker run hello-world

    echo "Successfully installed"
}

remove_docker(){
    echo "uninstalling docker"

    # Uninstall the Docker Engine, CLI, containerd, and Docker Compose packages:
    sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin

    # delete all images, containers, and volumes
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
}

if [ $1 = "install" ]; then
    echo "Installing docker"
    install_docker
elif [ $1 = "remove" ]; then
    echo "remove docker"
    remove_docker
else
    echo "Either specify install or removal"
fi
