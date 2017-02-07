# Setup DCOS Cluster in Azure

### Install `dcos` command line utility on your mac laptop
```
curl -fLsS --retry 20 -Y 100000 -y 60 https://downloads.dcos.io/binaries/cli/darwin/x86-64/dcos-1.8/dcos -o dcos && 
 sudo mv dcos /usr/local/bin && 
 sudo chmod +x /usr/local/bin/dcos && 
 dcos config set core.dcos_url http://localhost:8080 && 
 dcos
```

### Setup Mesos Cluster

1. Create A personal ssh key pair.

```bash
$ mkdir .ssh && cd .ssh
$ ssh-keygen -t rsa -b 4096 -C "azureuser@dfwtalent.com" -f id_rsa
```

2. Using the .env_sample file create an .env file with the proper values set.

3. Using the ./templates/example.params.json create the file ./templates/params.json and ensure proper values are set.
  >Note: DNS_PREFIX=dfwtalent in templates should be appended with a '-'  "value": "dfwtalent-"

4. npm install  (** Installs Azure-CLI and setups up the DCOS Cluster)
  >Note: The azure subscription must ahve the proper Resource Providers registered. (Batch, Compute, ContainerService, KeyValut, Network, Storage)

5. npm start (** Connects to Master)
  >Note: This step should be done in a new terminal window as step 6 requires you be connected.

6. Install `dcos` command line utility on the master node
```
curl -fLsS --retry 20 -Y 100000 -y 60 https://downloads.dcos.io/binaries/cli/linux/x86-64/dcos-1.8/dcos -o dcos && 
 sudo mv dcos /usr/local/bin && 
 sudo chmod +x /usr/local/bin/dcos && 
 dcos config set core.dcos_url http://localhost && 
 dcos
```

>To find these instructions:
>* ssh to the cluster
>* In a browser, go to http://localhost:8080
>* In the lower left corner of the page click the "Install CLI" button: ->  ![Install CLI Button](images/commandline.png)
>* Follow the instructions that appear in the modal.


### Configure the Cluster
>Note: The instructions below require the `dcos` tool to be installed and you to be connected to your Master0 via ssh (see above).

1. npm run update (** Updates Master Node)

2. Update your cluster to the latest OS patch level

```bash
{master}$ cd tools
{master}$ ./upgrade.sh
{master}$ ./agents-do.sh sudo reboot now
```

3. Setup the Storage System

```bash
$ npm run storage
```

4. Optional Keystore Setup

```bash
$ npm run keyvault
```


### Create Applications

Access DCOS/Marathon/Mesos  
  * While connected via ssh (Above)
  * DCOS: http://localhost:8080/
  * Marathon: http://localhost:8080/marathon/
  * Mesos: http://localhost:8080/mesos/

1. Marathon-LB

```bash
{master}$ ./tools/marathon.sh
```

2. Private Registry

_LocalHost Registry_

>Note:  You must add in the values required in the tools/apps/registry.json

```bash
$ npm run registry:start
$ npm run registry:stop
```


_Cluster_

```
$ dcos marathon app add apps/registry.json
```
>Note:  If you remove the registry you must clean up the agents docker engines with the following.
> ```
> {master}$ tools/do-agents.sh sudo docker rm -f registry
> ```


3. Sample Web Site

```
$ dcos marathon app add apps/helloweb.json
``` 

### Install Azure Docker Volume Driver
>Note: If you want to use Docker Files shares for persistent storage, install the Azure Docker Volume Driver.


* Create a new storage account in the same resource group as your mesos cluster.
* In the new storage group, create a new "File" Service.
* In `clusterconfig.sh` update the variables `AZURE_STG_ACCOUNT_NAME=` and `AZURE_STG_ACCOUNT_KEY=` from the data on the "Keys" blade for your storage account in the Azure portal.
* Run `updateMasterConfig.sh` again to refresh the `cluster-tools` directory and configs.
* On the Master, cd to `~/cluster-tools/` and execute `distribInsecReg.sh`