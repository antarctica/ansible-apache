# Apache (`apache`) - Changelog

## 0.5.2 - May 2015

* Changing the Apache serverName property to use the FQDN by default, rather than the hostname 

## 0.5.1 - March 2015

* Fixing names of virtualhost template files

## 0.5.0 - March 2015

* Adding markers for including module and custom configuration within virtualhost configuration files

## 0.4.2 - March 2015

* Fixing default document root which incorrectly contained a trailing slash

## 0.4.1 - March 2015

* Adds support for configuring ports file to support non-default ports

## 0.4.0 - March 2015

* Adds SSL chain file support
* Adds server name support
* Adds canonical name support
* Adds support for setting the network interface and secure/non-secure port bindings

## 0.3.0 - January 2015

* Adds single alias support

## 0.2.4 - December 2014

* Preparing role for public release

## 0.2.3 - October 2014

* Updating role dependencies
* The app user's username is now configurable
* Spelling
* Preparing role for public release

## 0.2.2 - October 2014

* Adjusting role for inclusion in BARC
* Tasks cleanup

## 0.2.1 - September 2014

* Disabling reporting of apache version

## 0.2.0 - September 2014

* Adding SSL virtual host support

## 0.1.4 - September 2014

* Fixing 'Could not reliably determine the server's fully qualified domain name' error
* Fixing incorrect server admin address

## 0.1.3 - September 2014

* Fixing hardcoded non-standard document root
* Minor template refactoring

## 0.1.2 - July 2014

* Making compatible with apache 2.4
* If a non-standard document root is used apache file configured to allow access to this directory automatically

## 0.1.1 - July 2014

* Making compatible with ubuntu 14.04
* Adding new variables for document root and server admin

## 0.1.0 - June 2014

* Initial version
