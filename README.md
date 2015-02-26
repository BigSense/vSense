vSense
======

vSense is a set of Vagrant environments and Ansible playbooks for building full BigSense and LtSense environments. vSense can also be used to replicate the build and repository servers use by the project for local development forks.

Installation
============

vSense depends on Vagrant 1.6+, Ansible 1.8+ and VirtualBox, as well as some additional vagrant plugins. Check your Linux distribution's package repository for installing Vagrant, Ansible and VirtualBox. Then run the following:

```
git clone https://github.com/sumdog/vSense
vagrant plugin install vagrant-hostmanager
```

Dependencies
============

Ubuntu 14.04 LTS doesn't have current versions of most of the dependencies we need.

```
# Install Vagrant 1.7

wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2_x86_64.deb
sudo dpkg -i vagrant_1.7.2_x86_64.deb

# Install packages

sudo apt-get install ansible virtualbox

# Install packages needed for security (optional)

sudo apt-get install whois pwgen
```

On Gentoo, you will need additional overlays:

```
# Install Vagrant 1.6+

sudo layman -a andy
sudo echo ">=app-emulation/vagrant-bin-1.6.1 ~amd64" >> /etc/portage/package.accept_keywords

# Install packages

emerge -av vagrant-bin ansible virtualbox

# Install packages needed for security (optional)

emerge -av whois pwgen

```

Creating a Runtime Environment
==============================

A BigSense environment consists of at least three virtual machines: a BigSense server, a database server and a LtSense client. In the Vagrant virtual environment, the LtSense client transmits data from fake virtual sensors (randomly generated data). vSense can be used to automate the process of building such an environment.

The `vsense create` command can be used to build an environment. In the following example, we'll create an environment called staging which uses a PostgreSQL database for storage, Ubuntu as the operating system and nightly builds of bigsense and ltsense:

```
cd vSense
./vsense create -d postgres -o ubuntu -s nightly staging
```

This will create the appropriate Vagrant files in *virtual-env/staging*. You can edit `virtual-env/staging/environment.yml` to fine tune your settings. If you have multiple environments, you must edit this file to ensure each environment gets unique IP addresses.

Next you can start the environment:

`
./vsense start staging
`

The Vagrant VMs start and the Ansible provisioning scripts will run. You may be prompted for your password as the vagrant-hostmanager plugin will need root privileges to update your */etc/hosts* file. When finished, you'll have three VMs. The *ltsense-staging* VM will start transmitting randomly generated temperatures to the *bigsense-staging* VM. Assuming you're using the default *environment.yml*, you should be able to view the take sensor data by going to the following web address:

`http://bigsense-staging.internal:8080/api/Query/Latest/100.txt`

Congratulations. You now have a BigSense virtual environment. You can also setup a virtual environment with different operating systems and databases. vSense currently supports Ubuntu 14.04, Debian 7 and CentOS 7 (OS flags only affect the BigSense and LtSense VMs. The database VM will always be Ubuntu.)


```
# create a mysql environment that uses CentOS and nightly builds:

./vsense create -d mysql -o centos -s nightly centos-nightly-mysql

# create a postgres environment that uses debian and stable builds:

./vsense create -d postgres -o debian -s stable debian-stable-postgres

```

In a real deployment, LtSense would most likely be running on an embedded Linux system with actual sensors attached to it. Packages for BigSense and LtSense are available for many distributions. For full installation and configuration instructions, visit http://bigsense.io


Using a Microsoft SQL Server (Experimental)
===========================================

BigSense does support a Microsoft SQL Server backend. Although Microsoft does provide Vagrant boxes for Windows Server 2012, they're only for the Hyper-V provider. For vSense using VirtualBox, you will have to manually create a Windows Server 2012 R2 box and name it *Windows2012R2*. Currently this functionality is missing from vSense and the `-d mssql` doesn't currently work. I hope to add this functionality in the future.

TODO: figure out how to auto-mount the SQL Server ISO and install via powershell and document it


Creating a Build Environment (advanced)
=======================================

A build environment can be useful for developers who wish to fork the project and have their own build servers and local package repositories. Most end-users won't need to do this, but this may be useful for developers.

To start, lets' create a build environment using the following:

`
./vsense create -e build builder
`

The default configuration files generated point to the source code located on Github. You can adjust the `environment.yml`, prior to Vagrant provisioning, to change these locations to local repositories or github forks.

You can also fine tune various other settings in the `environment.yml`, including those for PGP key generation (used to sign packages). Prior to starting your build environment, you must generate PGP keys:

`
./vsense genkeys builder
`

Next, you can start the build environment:

`
./vsense start builder
`

You should now have two virtual machines: build and repo. By default, build runs a Jenkins instance that will poll the git repository every 15 minutes to determine if it needs to build new packages. You can start these jobs manually by going to `http://build.internal:8080` and executing the BigSense and LtSense jobs.

TODO: insert screen shot

Finally, you can create a local runtime environment that pulls packages from the local build environment:

`
./vsense create -e run -d postgres -b builder staging
`

Keep in mind that Jenkins builds packages and publishes them to the appropriate repository tree based on their version numbers. If the current commit has a tag associated it which is a version number, the package will get published in *stable*. If the tag is a version number followed by characters (e.g. 0.5beta), it will be published in *testing*. If the current commit is past the latest tag, the package version will end in the short commit hash (e.g. 0.5beta-4-as4g3a) and will be published in *nightly*.

If the runtime environment is configured for a branch that doesn't have any packages published yet, it will fail to provision.


Infrastructure (advanced)
=========================

The Infrastructure environment is a special case for building an haproxy and wiki. It's used for the internal systems that host http://bigsense.io. You probably don't need to build this unless you plan on hosting an entire BigSense organization of your own, or need your various environments accessible from the outside world.


Security
========

By default, vagrant VMs are insecure. Their vagrant/root passwords are set to vagrant and they use a common, non-passphrase protected SSH key. The secure action can ensure vsense will automatically generate passwords, store those passwords in ~/.password-store and encrypt them with a pgp key (so they can be retrieved using the `pass` command).

*Note* that this will only protect new VMs or VMs that are re-provisioned via Ansible.

The secure action requires the following dependencies:

* pwgen
* whois (for mkpasswd)
* pass (optional)

To automatically generate passwords and encrypt them, you must specify a PGP key ID that exists in your keystore.

`
./vsense secure -p 6D0D93B1
`

To use a custom SSH key for the vagrant user:

`
./vsense secure -s [path to ssh key]
`


Creating a Cross-Matrix Environment (advanced)
==============================================

vSense comes with fixtures designed for integration tests. The most common of these tests would be to build environments for each supported database and ensure they all return the same results.

TODO - Implement fixtures and cross-environment tests / add documentation
