# Plio load testing
This repository is responsible for load testing of Plio environments.

## Installation
1. Create a new EC2 instance
    1. OS: Ubuntu 20.04 amdx64 LTS
    2. Type: t3.large (or based on your preference)
    3. Security group: should only have SSH port open
2. Add the EC2 IP to the DNS provider firewall protocol so that it doesn't get blocked due to request limits.
3. SSH into the EC2 instance and run the following commands
    ```sh
    # ssh into the server
    ssh -i PRIVATE_KEY_FILE.pem ubuntu@EC2_INSTANCE_IP

    # install k6
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
    echo "deb https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
    sudo apt-get update
    sudo apt-get install k6

    # OS fine tuning
    sudo sysctl -w net.ipv4.ip_local_port_range="1024 65535"
    sudo sysctl -w net.ipv4.tcp_tw_reuse=1
    sudo sysctl -w net.ipv4.tcp_timestamps=1
    ulimit -n 250000

    # clone this repo
    git clone https://github.com/avantifellows/plio-load-testing

    # go to the project/tests directory
    cd plio-load-testing/tests

    # run the load testing script
    k6 run script.js
    ```
