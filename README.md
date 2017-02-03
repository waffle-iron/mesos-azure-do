# Setup DCOS Cluster in Azure

1. Create A personal ssh key pair.

```bash
$ mkdir .ssh && cd .ssh
$ ssh-keygen -t rsa -b 4096 -C "azureuser@dfwtalent.com" -f id_rsa
```

2. Using the .env_sample file create an .env file with the proper values set.

3. Using the ./templates/example.params.json create the file ./templates/params.json and ensure proper values are set.
  >Note: DNS_PREFIX=dfwtalent in templates should be appended with a '-'  "value": "dfwtalent-"

4. npm install  (** Installs Azure-CLI and setups up the DCOS Cluster)

5. npm run update (** Updates Master Node)

6. npm start (** Connects to Master)

7. Update your cluster to the latest OS patch level

```bash
{master}$ cd tools
{master}$ upgrade.sh
```

8. Access DCOS/Marathon/Mesos  
    * While connected via ssh (Above)
        * DCOS: http://localhost:8080/
        * Marathon: http://localhost:8080/marathon/
        * Mesos: http://localhost:8080/mesos/

## Configure the Cluster
>Note: The instructions below require the `dcos` tool to be installed and you to be connected to your Master0 via ssh (see above).

### Install `dcos` command line utility on the master node
```
curl -fLsS --retry 20 -Y 100000 -y 60 https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.8/dcos -o dcos && 
 sudo mv dcos /usr/local/bin && 
 sudo chmod +x /usr/local/bin/dcos && 
 dcos config set core.dcos_url http://localhost && 
 dcos
```

### Install `dcos` command line utility on your mac laptop
```
curl -fLsS --retry 20 -Y 100000 -y 60 https://downloads.dcos.io/binaries/cli/darwin/x86-64/dcos-1.8/dcos -o dcos && 
 sudo mv dcos /usr/local/bin && 
 sudo chmod +x /usr/local/bin/dcos && 
 dcos config set core.dcos_url http://localhost:8080 && 
 dcos
```

To find these instructions:
* ssh to the cluster
* In a browser, go to http://localhost:8080
* In the lower left corner of the page click the "Install CLI" button: ->  ![Install CLI Button](images/commandline.png)
* Follow the instructions that appear in the modal.



