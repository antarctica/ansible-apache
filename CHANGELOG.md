# Apache (`apache`) - Change log

All notable changes to this role will be documented in this file.
This role adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased][unreleased]

## [1.0.0] - 2015-09-07

### Changed - BREAKING!

* Removing support for un-deprecated feature - markers for including module and custom virtual host configuration details, use new virtual host templates instead
* Removing support for un-deprecated feature - use of Allow Overrides is disabled by default - re-enable to use `.htaccess` files
* Removing support for un-deprecated feature - running CGI scripts is removed in default virtual host files
* Removing support for un-deprecated feature - Alias for system documentation is removed in default virtual host files
* Support for secure connections (i.e. HTTPS) is now assumed
* It is assumed the certificate and associated private key for secure connections will be stored as single files inside a base directory (i.e. '/etc/ssl/private/certificate.key' not '/etc/ssl/private/certificate/certificate.key')
* Refactoring all variables relating to secure connections
* Removing support for deprecated feature - aliases within virtual hosts
* Removing support for deprecated feature - Ubuntu versions before 14.04

### Deprecated

* Support for non-secure virtual hosts (i.e. HTTP), is now disabled by default and will be removed entirely - use the non-secure to secure virtual host instead
* Support for Allow Overrides, is now disabled by default and will be removed entirely

### Added

* Added testing support for automated testing using Semaphore
* Added testing support for manual testing, using local and remote environments
* Added support for UFW by creating application definitions and rules
* Added support for upgrading non-secure to secure requests using a specialist, minimal, virtual host
* Adding support for uploading a certificate required for secure connections

### Fixed

* Default variable values, which were previously defined within the core role, now use generic variables and fall-back defaults
* Support for uploading a certificate private key has been moved from core role to here
* Spelling virtual host properly, i.e. virtual host not 'virtualhost'

### Changed

* Updated change log to follow 'keep a changelog' format
* Significantly improving the configuration of secure connections, through the choice of supported cipher sets and protocols
* Removing content from the default document root is now optional, but still enabled by default
* Using Jinja template for virtual host files to reduce duplication
* Providing future support for custom DH parameters for secure connections, for when this is available with operating systems
* Refactoring configuration needed for secure connections and configuring the default HTTPS virtual host
* Refactoring tasks to be clearer and better structured

## [0.5.1] - 2015-05-01

### Deprecated

* Support for aliases
* Support for Ubuntu versions before 14.04

### Fixed

* Names of virtual host template files

### Changed

* The Apache 'Server Name' property now uses the FQDN by default, rather than the hostname 

## [0.5.0] - 2015-03-01

### Added

* Adding markers for including module and custom configuration within virtual host configuration files

## [0.4.2] - 2015-03-01

### Fixed

* Default document root variable value which incorrectly contained a trailing slash

## [0.4.1] - 2015-03-01

### Added

* Support for configuring ports file to support non-default ports

## [0.4.0] - 2015-03-01

### Added

* Certificate chain file support
* Server name support
* Canonical name support
* Support for setting the network interface and secure/non-secure port bindings

## [0.3.0] - 2015-01-01

### Added

* Adds single alias support

## [0.2.4] - 2014-12-01

### Changed

* Preparing role for public release

## [0.2.3] - 2014-10-01

### Fixed

* The app user's username is now configurable

### Changed

* Updating role dependencies
* Spelling
* Preparing role for public release

## [0.2.2] - 2014-10-01

### Changed

* Adjusting role for inclusion in BARC
* Tasks clean-up

## [0.2.1] - 2014-09-01

### Changed

* Disabling reporting of Apache version

## [0.2.0] - 2014-09-01

### Added

* Secure virtual host support

## [0.1.4] - 2014-09-01

### Fixed

* 'Could not reliably determine the server's fully qualified domain name' error
* Incorrect server administrator address error

## [0.1.3] - 2014-09-01

### Fixed

* Hard-coded non-standard document root

### Changed

* Minor template refactoring

## [0.1.2] - 2014-07-01

### Added

* Compatibility with Apache 2.4

### Fixed

* If a non-standard document root is used Apache is configured to allow access to this directory automatically

## [0.1.1] - 2014-07-01

### Added

* Compatibility with Ubuntu 14.04
* New variables for document root and server administrator

## [0.2.1] - 2014-06-01

### Added

* Initial version
