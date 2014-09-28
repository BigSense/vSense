vSense
======

vSense is a set of Vagrant environments and Ansible playbooks for building full BigSense and LtSense environments. vSense can also be used to replicate the build and repository servers use by the project for local development forks.

Creating an Environment
=======================

A BigSense environment consists of at least three virtual machines: a BigSense server, a database server and a LtSense client. In the Vagrant virtual environment, the LtSense client transmits data from fake virtual sensors (randomly generated data).

TODO - documentation

Using a Microsoft SQL Server
============================

BigSense does support a Microsoft SQL Server backend. Although Microsoft does provide Vagrent boxes for Windows Server 2012, they're only for the Hyper-V provider. For vSense, you will have to manually create a Windows Server 2012 R2 box and name it *Windows2012R2*.

TODO: auto-mount the SQL Server ISO and install via powershell

Creating a Cross-Matrix Environment
===================================

TODO - documentation

Creating a build Environment
============================

A build environment
