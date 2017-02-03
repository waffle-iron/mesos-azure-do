# Setup DCOS Cluster in Azure

1. Create A personal ssh key pair.

```bash
$ mkdir ssh && cd ssh
$ ssh-keygen -t rsa -b 4096 -C "azureuser@dfwtalent.com" -f id_rsa
```

2. Using the .env_sample file create an .env file with the proper values set.

3. Using the ./templates/example.params.json create the file ./templates/params.json and ensure proper values are set.
  >Note: DNS_PREFIX=dfwtalent in templates should be appended with a '-'  "value": "dfwtalent-"

4. npm install  (** Installs Azure-CLI and setups up the DCOS Cluster)

5. npm start (** Connects to Master)

6. Access DCOS/Marathon/Mesos  
    * While connected via ssh (Above)
        * DCOS: http://localhost:8080/
        * Marathon: http://localhost:8080/marathon/
        * Mesos: http://localhost:8080/mesos/

## Configure the Cluster
>Note: The instructions below require the `dcos` tool to be installed and you to be connected to your Master0 via ssh (see above).

### Install `dcos` command line utility
```
mkdir -p dcos && cd dcos && 
  curl -O https://downloads.dcos.io/dcos-cli/install-optout.sh && 
  bash ./install-optout.sh . http://localhost:8080 && 
  source ./bin/env-setup
```

To find these instructions:
* ssh to the cluster
* In a browser, go to http://localhost:8080
* In the lower left corner of the page click the "Install CLI" button: ->  ![Install CLI Button](commandline.png)
* Follow the instructions that appear in the modal.

### Update your cluster to the latest OS patch level
* On your local machine run this script: `prepareMaster.sh`.  This will generate a list of IP addresses for the dcos masters and agents in the cluster, copy the `cluster-tools` directory to the Master0 and set up some configs you'll need for later.
* On the **Master0**, `cd` into the `cluster-tools` directory and run `upgradePkgsCluster.sh`.
* You will need to reboot the entire cluster after this, as this will most likely include a kernel upgrade. To accomplish this easily, run these commands on the Master0: 
  * Agents: `agents-do.sh sudo reboot`
  * Masters: `masters-do.sh sudo shutdown -r`.  **NOTE**: This will also reboot the Master0 you're currently connected to, so you'll need to reconnect after the reboot.
  * Best to do this now in case a package update breaks the cluster, at least you're not too far into the configuration.
* Post Reboot, your cluster may have new IP addresses, so make sure to run `updateMasterConfig.sh` (after you reconnect to Master0 over SSH) to update your Agent & Master IP address lists.


### Deploy internal & external marathon-lb
* `cd` to the `system` directory and run `./marathon-lb-install.sh`

### Deploy Docker Registry

#### Deploy registry.json to the cluster _using dcos_  
 * `cd` to the `system` directory and run `dcos marathon app add ./registry.json`

#### Add the insecure registry to all docker daemons in the cluster
* On **Master0** VM `cd` to the `cluster-tools` directory and run `distribInsecReg.sh`
* You can now pull docker images from registry.marathon.mesos:5000.



### Install Azure Docker Volume Driver
If you want to use Docker Files shares for persistent storage, install the Azure Docker Volume Driver.
* Create a new storage account in the same resource group as your mesos cluster.
* In the new storage group, create a new "File" Service.
* In `clusterconfig.sh` update the variables `AZURE_STG_ACCOUNT_NAME=` and `AZURE_STG_ACCOUNT_KEY=` from the data on the "Keys" blade for your storage account in the Azure portal.
* Run `updateMasterConfig.sh` again to refresh the `cluster-tools` directory and configs.
* On the Master, cd to `~/cluster-tools/` and execute `distribInsecReg.sh`


## Deploy Splunk
### Spin the Splunk VM (using Azure Marketplace)
* Update `splunk.params.json` with the following info:  
  * The name of the Virtual Network from your DCOS Resource Group (virtualNetworkName).
  * The name of the Resource Group you created for this DCOS deployment (virtualNetworkExistingRGName).
  * The Domain Name prefix for this splunk install (domainNamePrefix).
  * Make sure that "subnet\*Prefix" and "subnet\*StartAddress" match your subnets on the virtual network.

* We will be deploying Splunk into the same resource group, and onto the same virtual network as the rest of the cluster.
* Once you've updated `splunk.params.json`, execute this command (where <resource_group> is the same resource group you've been using all along):
`azure group deployment create --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/splunk-on-ubuntu/azuredeploy.json --parameters-file splunk.params.json <resource_group> splunkLosantDCOSdeploy`
> Note: This will take a while.

#### Update Splunk to latest Version (if necessary)
1. Edit `./cluster-tools/splunk-config.sh` with your Splunk info.
2. Get the download links for both the Splunk Indexer and the Splunk Universal Forwarder from the Splunk Website and put these values into `splunk-config.sh` (Splunk Linux 64bit tgz).
    a. Be sure to also update the SPLUNK_*_FILENAME configs in `./cluster-tools/splunk-config.sh`.
3. On your Local Computer, run `updateMasterConfig.sh` again to update the `./cluster-tools/` directory on the Master0 VM.
4. Run `./cluster-tools/splunk-indexer-download.sh` on your **local computer** (not on the Mesos Master0).  This will download the latest version of Splunk (if you put the download url in splunk-config.sh), install it, and install our license.
5. Install an ACL on the endpoints for the splunk server.  Use the `azure-add-nsg.sh` script to do this. You will need to Modify the variables at the top of the script for each port you wish to create an ACL on.  Also, you'll have to remove some of the default ACLs in the azure portal.

#### All Agents
##### Install Splunk Universal Forwarder
1. Make sure you have edited `splunk-config.sh` with your Splunk info.
2. If you made any On your Local Computer, run `updateMasterConfig.sh` again to update the `~/cluster-tools/` directory on the Master0 VM.
3. On the Cluster Master0, `cd cluster-tools` and run `./splunk-forwarder-install.sh` to download, copy, install, and configure the splunk forwarder on all the agents and masters in the cluster.

### Splunk Logging Reference
https://docs.mesosphere.com/1.7/administration/logging/splunk/
