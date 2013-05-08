# CHANGELOG for check_mk

This file is used to list changes made in each version of check_mk.

## 1.0.0:

  * Added kitchen test
  * Removed the fewbytes-common cookbook dependency
  * Removed the cluster_service_discovery cookbook dependency
  * Cookbook now handles server/agent discovery on its own using libraries/discovery.rb (backward inc. change)
  * Agent recipe now downloads packages configured in attributes

## 0.4.0:

  * Added support for check_parameters

## 0.3.0:

  * Added attribute to make recipe ignore nodes (node['check_mk']['ignore'])

## 0.2.1:

  * Mismatch in tag 0.2.0, bumped patch version

## 0.2.0:
  
  * Added a dependency on sudo cookbook
  * Added node level extra_service_conf
  * Added external agents feature
  * Removed inventorizing pseudo agents

## 0.1.1:

* Changed the way pseudo agents are used, see README.

## 0.1.0:

* Initial release of check_mk
