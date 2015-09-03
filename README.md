# Apache (`apache`)

[![Build Status](https://semaphoreci.com/api/v1/projects/9fd776a8-8f74-4e82-a2e0-bce17fcacdf3/526947/badge.svg)](https://semaphoreci.com/antarctica/ansible-apache)

**Part of the BAS Ansible Role Collection (BARC)**

Installs the Apache web-sever and optionally setup a default virtual host

## Overview

TODO: Rewrite/Update

* Installs Apache server and enables the rewrite module
* Configures default virtual host for HTTP connections
* Optionally configures virtual host for HTTPS connections, this is disabled by default
* Where HTTPS connections are supported, additional configuration is applied to improve security (including HTST)
* Supports the use of a custom DH parameters file for use in SSL connections, this is disabled by default
* If a non-default document root is used, virtual hosts for HTTP and, if enabled, HTTPS, will be configured to point to this location
* The app user is made a member of the `www-data` group and ownership of the default document root is assigned to the 'app' user
* Content is removed from the default document root, if enabled, this is performed regardless of whether the default document root is used or not
* Optionally allows non-default ports and IP bindings to be set (i.e. listening for local connections only or using port 8080 for HTTP connections)
* Includes additional Apache configuration directives from files in a location such as 'conf-enabled'

## Availability

This role is designed for internal use but if useful can be shared publicly.

## Quality Assurance

This role uses manual and automated testing to ensure the features offered by this role work as advertised. See the *testing* section for more information.

## Usage

### Deprecated features

The following features are deprecated within this role. They will be removed in the next major version.

* Support for 'allow overrides' (i.e. `.htaccess` files) will be permanently removed, currently support is only disabled. Set `apache_enable_feature_disable_document_root_allow_overrides` to "true" to re-enable support. This is mainly for compatibility with other web-servers which do not support this concept but also for performance reasons. 
* Support for a stand-alone HTTP virtual host will be removed as we move to a HTTPS by default approach. Instead the `apache_enable_feature_upgrade_http_to_https` feature should be used to redirect non-secure requests to a suitably secure virtual host, this is now enabled by default.

### Limitations

* This role assumes you will be using, at most, a single virtual host.

This role will not prevent multiple virtual hosts from being used, but you will need to create additional virtual host configuration files and enable them yourself. You may find the virtual host template [1] and additional configuration files, such as the improvements to SSL configurations, useful for this.

* This role assumes the SSL certificate chain will be contained in the same file as the SSL certificate.

Whilst this role supports specifying a different path and file for the chain, this role will not upload this file. Therefore you are responsible for ensuring the chain file is available at the path you specify (i.e. by uploading it using the *copy* module).

* This role will allow you to enable two virtual hosts that listen on port 80.

Both the deprecated non-secure virtual host and the non-secure to secure redirect virtual host can be enabled independently of each other, and both listen on port 80. This will lead to the non-secure to secure redirect virtual host being ignored.

To prevent or resolve this issue ensure `apache_enable_feature_upgrade_http_to_https` is set to "false" whenever `apache_enable_feature_default_http_virtualhost` is set to "true" and vice versa. See the *Virtual hosts* section for more details.

[1] See the *Virtual host template* sub-section of the *virtual hosts* section.

### Requirements

#### BAS Ansible Role Collection (BARC)

* `core`

#### Other

* If using SSL, which is assumed, the certificate and private key used must be accessible on the server. Use the `apache_default_var_www_ssl_cert` and `apache_default_var_www_ssl_key` variables to point to their respective locations.
* If using a non-default document root (i.e. not `/var/www`) you **MUST** ensure the Apache user can be granted ownership of this location.

### Variables

TODO: Rewrite/Update

* `apache_app_user_username`
	* Username of the 'app' user, used for day to day tasks
	* This variable **MUST** be the username of a valid UNIX user.
    * This user **SHOULD NOT** have elevated permissions (i.e. Sudo)
	* Default: "app"
* `apache_server_use_canonical_name`
    * Whether Apache should use the "server name" value when constructing self-referential links
    * If "on", you **MUST** ensure the `apache_default_var_www_server_name` variable is set correctly. 
    * See [the Apache documentation](http://httpd.apache.org/docs/current/mod/core.html#usecanonicalname) for more information.
    * This is a binary variable and **MUST** be set to either "on" or "off" (with quotes).
    * The value for this variable **MUST** be quoted or Ansible will evaluate it to "True" or "False" which are not valid values.
    * Default: "off"
* `apache_enable_feature_disable_default_configs`
    * If "true", the configuration files that ship with Apache and enabled by default are disabled
    * See the `apache_default_enabled_configs` variable for the files that will be disabled where this feature is enabled
    * Files are disabled by removing the sym-link between *conf-available* and *conf-enabled*, the actual configuration file is untouched.
    * This is a binary variable and MUST be set to either "true" or "false" (without quotes).
    * This feature is enabled by default as the default `security.conf` file triggers an invalid configuration error within Apache.
    * Default: "true"
* `apache_enable_feature_remove_default_document_root_content`
    * If "true", the default Apache document root content will be removed, this will result in a "403 - Forbidden" error where other defaults are used
    * This is a binary variable and MUST be set to either "true" or "false" (without quotes).
    * Default: "true"
* `apache_available_configs_dir`
    * Path to the directory for additional configuration files, typically used for settings that apply to all virtual hosts
    * Importantly files can be stored in this location without necessarily being enabled. Where a configuration file should be enabled, it will be sym-linked from this directory to that set by the `apache_enabled_configs_dir` variable.
    * This variable **MUST** point to a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "/etc/apache2/conf-available"
* `apache_enabled_configs_dir`
    * Path to the directory for additional configuration files that are currently enabled, typically used for settings that apply to all virtual hosts
    * This variable **MUST** point to a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "/etc/apache2/conf-enabled"
* `apache_enabled_configs_file_selector`
    * Within virtual hosts an [Include](http://httpd.apache.org/docs/2.2/mod/core.html#include) directive is used to load all configuration files within the directory set by `apache_enabled_configs_dir` variable, this variable controls the pattern that a file within this directory must match to be included
    * For example, the default value is "*.conf" meaning "some-file.conf" would be included, but "some-file.txt" would not.
    * A directory separator (`/`) will be inserted between the `apache_enabled_configs_dir` variable and this variable, and therefore **MUST NOT** be included within this variable.
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "*.conf"
* `apache_default_enabled_configs`
    * Where `apache_enable_feature_disable_default_configs` is true, defines the configuration files to be disabled
    * By default this variable is set to all configuration files that ship with Apache by default, you **SHOULD NOT** need to change its value.
    * If overriding this variable you **MUST** ensure you include any configuration files you wish to disable, as the entire list if overridden.
    * Structured as an array of file names located in the directory set by `apache_enabled_configs_dir` (i.e. configuration files that are already enabled)
    * Default: (array)
        * "charset.conf"
        * "localized-error-pages.conf"
        * "other-vhosts-access-log.conf"
        * "security.conf"
        *"serve-cgi-bin.conf"
* `apache_default_var_www_server_binding`
    * Networking interface on which Apache will listen for HTTP and HTTPS connections
    * By default, this variable listens on any IPv4 interface.
    * Default: "0.0.0.0"
* `apache_default_var_www_server_http_port`
    * Port on which Apache will listen for HTTP connections
    * By default, this variable uses port 80, this is a convention and **SHOULD NOT** be changed.
    * Default: "80"
* `apache_default_var_www_server_https_port`
    * Port on which Apache will listen for HTTPS connections
    * By default, this variable uses port 443, this is a convention and **SHOULD NOT** be changed.
    * Default: "443"
* `apache_default_var_www_server_name`
    * Name of the virtual server, typically this will match the address of the server
    * When using SSL, this variable **MUST** match the one of the subjects or the common name of the SSL certificate.
    * By default this variable will use the Fully Qualified Domain Name of the server.
    * Default: "{{ ansible_fqdn }}"
* `apache_default_var_www_server_admin`
	* E-mail address shown to users in error pages (404, 500, etc.)
	* By default, this variable uses a BAS specific contact, if external this default **MUST NOT** be used.
    * Default: "basweb@bas.ac.uk"
* `apache_default_var_www_document_root`
	* Path to the physical directory on the server containing site files.
    * This variable **MUST** be a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
	* If a non-default root is used, you **MUST** ensure the `www-data` group has access.
    * Default: "/var/www"
* `apache_default_var_www_options`
    * Array of options, each will be added as a separate `option: {{ item }}`
    * Each option **MUST** be valid options as defined by Apache.
	* Default: [array]
        * "-Indexes"
        * "+FollowSymLinks"
        * "-MultiViews
* `apache_default_var_www_allowoverride`
	* To disable `.htaccess` support set this to `None`.
	* Default: "All"`
* `apache_available_configs_dir`
    * Path to the location additional configuration files should be kept, regardless of whether they are active
    * This variable **MUST** be a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "/etc/apache2/conf-available"
* `apache_enabled_configs_dir`
    * Path to the location, active, additional configuration files should be kept
    * This variable **MUST** be a valid UNIX directory and **MUST** end with "/*.conf".
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "/etc/apache2/conf-enabled/*.conf"
* `apache_default_var_www_ssl_enabled`
    * If "true" support for secure connections will be enabled within Apache
    * This is a binary variable and MUST be set to either "true" or "false" (without quotes).
    * Default: "false"
* `apache_default_var_www_ssl_cert_path`
    * Path to the directory containing the SSL certificate for secure connections
    * This variable **MUST** be a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
    * By default this variable will use the `core_ssl_private_key_destination_path` variable if available. If not, a fall back value will be used.
    * The `core_ssl_private_key_destination_path` variable **SHOULD** be set within a project, either in a playbook or group/host vars file.
    * Default:  "{{ core_ssl_private_key_destination_path }}" if defined otherwise, "/app/provisioning/certificates/domain"
* `apache_default_var_www_ssl_cert_file`
    * File name and extension of the SSL certificate for secure connections
    * By convention, this file **SHOULD** use a `.crt` extension.
    * By default this variable will use the `core_ssl_private_key_destination_file` variable if available. If not, a fall back value will be used.
    * The `core_ssl_private_key_destination_file` variable **SHOULD** be set within a project, either in a playbook or group/host vars file.
    * Default:  "{{ core_ssl_private_key_destination_file }}" if defined otherwise, "certificate-including-trust-chain.crt"
* `apache_default_var_www_ssl_cert_chain_path`
    * Path to the directory containing the SSL certificate trust chain, this file is usually the same as the SSL certificate
    * This variable **MUST** be a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
    * By default, this variable uses the value of the `apache_default_var_www_ssl_cert_path` variable as the certificate and certificate trust chain are usually the same file and so would be in the same directory.
    * Default: "{{ apache_default_var_www_ssl_cert_path }}"
* `apache_default_var_www_ssl_cert_chain_file`
    * The file name and extension of the SSL certificate trust chain, this file is usually the same as the SSL certificate
    * The certificate file **SHOULD** contain a complete trust chain, except for the root/anchor which **SHOULD** be omitted.
    * By convention, this file **SHOULD** use a `.crt` extension.
    * By default, this variable uses the value of the `apache_default_var_www_ssl_cert_file` variable as the certificate and certificate trust chain are usually the same file.
    * Default: "{{ apache_default_var_www_ssl_cert_file }}"
* `apache_default_var_www_ssl_key_path`
    * Path to the directory holding the private key for the SSL certificate
    * This variable **MUST** be a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
    * By default, this variable uses the Debian convention for SSL private keys, this **SHOULD NOT** be changed.
    * Default: "/etc/ssl/private"
* `apache_default_var_www_ssl_key_file`
    * The file name and extension of the the private key for the SSL certificate
    * Naturally the correct private key **MUST** be used for the certificate specified by `apache_default_var_www_ssl_cert_file`.
    * The private key **MUST NOT** require a pass-phrase to unlock.
    * Private keys **MUST** be stored and distributed securely.
    * By convention this file **SHOULD** use a `.key` extension
    * Default: "certificate.key"
* `apache_ssl_config_path`
    * Path to the location where additional Apache configurations should be kept, but specifically where the configuration for additional SSL configuration files should be kept
    * This variable **MUST** be a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * By default this variable will use the value of the `apache_available_configs_dir` variable.
    * Default: "{{ apache_available_configs_dir }}"
* `apache_enable_feature_ssl_custom_dh_parameters`
    * If "true", support for a custom DH parameters file will be enabled
    * See the *DH parameters* section for more information on what this does.
    * This is a binary variable and MUST be set to either "true" or "false" (without quotes).
    * Default: "false"
* `apache_ssl_dhparam_cert_path`
    * path to the directory holding the custom DH parameters file, if enabled
    * See the *DH parameters* section for more information on what this does.
    * This variable **MUST** be a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
    * By default, this variable uses the Debian convention for SSL private keys, this **SHOULD NOT** be changed.
    * Default: "/etc/ssl/certs"
* `apache_ssl_dhparam_cert_file`
    * The file name and extension of the custom DH parameters file, if enabled
    * See the *DH parameters* section for more information on what this does.
    * This file **MUST** be located in the directory set by the `apache_ssl_dhparam_cert_path` variable
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "dhparam.pem"
* `apache_enable_feature_ssl_hsts`
    * If "true", support for [HTTP Strict Transport Security](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) will be enabled, this is recommended wherever HTTPS is supported
    * This is a binary variable and MUST be set to either "true" or "false" (without quotes).
    * Default: "true"

### Virtual hosts

This role supports creating three virtual hosts:

* A non-secure (HTTP) default virtual host
* A secure (HTTPS) default virtual host
* A non-secure to secure redirect virtual host

If you need to additional virtual hosts, or to significantly change the virtual hosts provided by this role, you **SHOULD**:

* Prevent this role creating default virtual host files by setting the `apache_enable_feature_default_http_virtualhost`, `apache_enable_feature_default_https_virtualhost`  and `apache_enable_feature_upgrade_http_to_https` variables to "false"
* Create required virtual host files yourself, optionally using the template provided in this role

The secure and non-secure virtual hosts are based on the default Apache virtual host files but with the following major differences:

* Support for running CGI scripts is disabled via the removal of `ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/` and associated directives
* Support for accessing system documentation is disabled via the removal of the `/usr/share/doc` alias and associated directives
* For security reasons the `ServerTokens` directive is set to least informative setting
* The `ServerName` directive is always set
* Access to the document root is granted to all (i.e. `Allow from all`)
* Support for `.htaccess` files is enabled within the document root [1]

The non-secure to secure redirect virtual host is based on the Apache example [2].

These virtual hosts are enabled or disabled, independently, using their respective variables (see the *Variables* section).

The table below shows, for different scenarios, how to set these variables:

| Variable                                          | Non-secure only | Secure only | Non-secure redirecting to secure |
|---------------------------------------------------|-----------------|-------------|----------------------------------|
| `apache_enable_feature_default_http_virtualhost`  | True            | False       | False                            |
| `apache_enable_feature_default_https_virtualhost` | False           | True        | True                             |
| `apache_enable_feature_upgrade_http_to_https`     | False           | False       | True                             |

By default this role will use the *Non-secure redirecting to secure* scenario.

**Note**: As the non-secure and non-secure to secure redirect virtual host both listen on port 80 it is possible to cause to a conflict between these virtual host. See the *Limitations* section for how to resolve this.

[1] Support for `.htaccess` files is deprecated. See the *deprecated features* section for more information.

[2] https://wiki.apache.org/httpd/RedirectSSL

#### Virtual host template

This role uses Jinja's templating features to create virtual host files with a block to include additional configuration.

The base template is `_virtualhost.conf.template.j2` (the `_` prefix donates this is a template file) and contains an opinionated virtual host definition based on the default Apache virtual host.

A block `additional_configuration` is provided to inject any additional configuration (e.g. enabling SSL ) within a virtual host. This block is deliberately placed before additional configuration files are included, see the *additional configuration* section for details.

The default virtual host files created by this role use this template and can be used as implementation examples if needed. The default HTTPS virtual host uses the template block feature to include a partial which enables SSL within that virtual host. 

##### `additional_configuration` block or *additional configuration* feature

Both the `additional_configuration` block defined in this template, and the *additional configuration* feature support including additional configuration directives into a virtual host. This is deliberate and each **SHOULD** be used to load a different type of configuration.

* The `additional_configuration` block **SHOULD** be used where the additional configuration applies specifically to a single virtual host
* The *additional configuration* feature **SHOULD** be used where the additional configuration applies to one or more virtual hosts

For example:

* Enabling SSL is specific to each virtual host and so **SHOULD** use the `additional_configuration` block
* SSL hardening rules however apply equally to all virtual hosts [1] and so **SHOULD** use the *additional configuration* feature

[1] These hardening rules would only be used by virtual hosts that have enabled SSL so is safe to load globally.

### Additional configuration

Where a module, or an application, requires additional configuration that does not depend on a particular virtual host, isolated configuration files **SHOULD** be used.

These files can be templated, assembled or copied as needed, using a `.conf` file extension. They **SHOULD** be stored in the directory set by the `apache_available_configs_dir` variable (by convention this is `/etc/apache2/config-available`).

To enable these additional configuration files create a (soft) symbolic link to the directory set by the `apache_enabled_configs_dir` variable, (by convention this is `/etc/apache2/config-enabled/*.conf`). Virtual host files created by this role are configured to include all configuration files (using the `.conf` file extension) inside the `apache_enabled_configs_dir` directory.

[1] See the *additional_configuration block or additional configuration feature* sub-section of the *Virtual host template* section for more details on when to use this feature.

### DH Parameters

Where secure connections are supported (i.e. `apache_default_var_www_ssl_enabled` is set to *true*) it is possible to use a custom Diffie Hellman Ephemeral Parameters file. More information is available [here](http://security.stackexchange.com/questions/43355/what-are-the-implications-of-using-the-same-dh-parameters-in-a-tls-server) (and other places).

This is recommended as the default shipped with OpenSSL (the library Apache uses for SSL related functions) uses, by default, a 1024-bit key. To use a custom key enable the `apache_enable_feature_ssl_custom_dh_parameters` variable and set the `apache_ssl_dhparam_cert_path` and `apache_ssl_dhparam_cert_file` variables accordingly.

This role includes a 4096 bit key for this purpose, though you can of course replace it with your own. The included key was generated on the 21st August 2015 (at about 10:00 AM) on a machine running MAC OS X 10.10.4 and OpenSSL 1.0.2d 9 Jul 2015. The command ran was:

```shell
$ mkdir -p files/etc/ssl/certs
$ cd files/etc/ssl/certs
$ openssl dhparam -out dhparam.pem 4096
```

Note: Using a custom DH parameters file requires OpenSSL version 1.0.2 or higher. This version is not available in Ubuntu 14.04 and so this feature is disabled by default. When this changes this role will be updated to enable this feature by default (requiring a new major version). This change can be tracked in the issue [BARC-35](https://jira.ceh.ac.uk/browse/BARC-35).

### Compatibility with Uncomplicated Firewall

This role assumes Ubuntu's Uncomplicated FireWall (UFW) is used [1]. This role will create application definitions for non-secure and secure connections to Apache [2] and rules will to allow incoming connections to these services.

See the [Security role](https://github.com/antarctica/ansible-security) within the BARC for more details on using UFW.

See the *variables* section for details on the variables this role offers to control the application definitions and rules this role will make.

For reference the application definitions this role creates [3] are:

| Name                 | Title                          | Ports                                                                 | Notes                        |
| -------------------- | ------------------------------ | --------------------------------------------------------------------- | ---------------------------- |
| `Apache-Non-Section` | Apache Web Server (HTTP)       | TCP `{{ apache_server_http_port }}`                                   | Port is based on variable    |
| `Apache-Section`     | Apache Web Server (HTTPS)      | TCP `{{ apache_server_https_port }}`                                  | Port is based on variable    |
| `Apache-Full`        | Apache Web Server (HTTP/HTTPS) | TCP `{{ apache_server_http_port }}`, `{{ apache_server_https_port }}` | Ports are based on variables |

For reference the rules this role creates (using application definitions) are:

| From     | Action   | To (`Application Definition`)         | Notes |
|----------|----------|---------------------------------------| ----- |
| Anywhere | Allow In | Apache Non-Secure `Apache-Non-Secure` |       |
| Anywhere | Allow In | Apache Secure `Apache-Secure`         |       |

[1] Unless the UFW is enabled the rules this role creates will not be enforced, therefore you do not necessarily need to its support within this role. By doing so it would be harder to enable the UFW later without reapplying this role with UFW support enabled.

[2] Apache includes an application definitions file, but the ports for secure and non-secure connections are hard-coded. To support custom ports (though you **SHOULD NOT** do so), a similar definition file is created by this role.

[3] In `/etc/ufw/applications.d/BARC-apache.ufw.profile`.

## Developing

### Apache modules

This role **MUST NOT** contain any additional Apache modules or module configuration, except for modules available in Apache by default.

Separate roles **MUST** be used for these modules, each module **SHOULD** have a separate role with this `apache` role as a dependency (plus any other roles as needed). By convention they should be named `ansible-*` where `*` is the name of the role, e.g. `apache-some-module`.

Roles **SHOULD NOT** duplicate virtual host file templates. Doing so introduces brittleness and fragmentation between the 'upstream' `apache` role and module roles (which will typically update at much slower frequencies).

### Testing

Note: Role testing is currently a proof-of-concept and may change significantly.

To ensure this role works correctly tests **MUST** be written for any role changes, and tested before new versions are released. Both manual and automated methods are used to test this role.

Three aspects of this role are tested:

1. **Valid role syntax** - as determined by `ansible-playbook --syntax-check`
2. **Functionality** - i.e. does this role do what it claims to 
3. **Idempotency** - i.e. do any changes occur if this role is applied a second time

Tests for these aspects can be split into:

* **Test tasks** - tests each task to ensure it functions correctly, act like unit tests
* **Test playbooks** - combine test tasks for various scenarios, act like integration tests

Test tasks are kept in the `test-takes` directory, mirroring the structure of the `tasks` directory.

A test playbook is used to run these test tasks. This playbook is applied to a number of test VMs, with host variables used to control which features each VM tests.

These tests, and their different configurations aim to cover the most frequent ways a role is used, in an environment designed to replicate that in which this role will be used. They also try to cover all the features of a role, wherever practical. Playbooks, host variables and other support files are kept in the `tests` directory. Both manual and automated test methods use these playbooks and test tasks, reducing the need for duplication and ensuring both types of test are as similar as possible.

The following configurations are tested:

* An Apache server with no virtual hosts
* An Apache server with a non-secure (HTTP) virtual host only
* An Apache server with a secure (HTTPS) virtual host only [1]

[1] This configuration is also used in automated tests, as discussed in the *automated tests* section.

#### Automated tests

Currently [Semaphore CI](https://semaphoreci.com/) is used for automated testing of this role. It is linked to this role's repository and will trigger on each commit to configured branches, which are currently:

* [Develop](https://semaphoreci.com/antarctica/ansible-apache/branches/develop)

When triggered a single test configuration [1] will be run [2].

Current automated test status:

[![Build Status](https://semaphoreci.com/api/v1/projects/9fd776a8-8f74-4e82-a2e0-bce17fcacdf3/526947/badge.svg)](https://semaphoreci.com/antarctica/ansible-apache)

See the [automated testing environment](https://semaphoreci.com/antarctica/ansible-apache) for test history, configuration and documentation.

[1] It is currently only possible to test a single configuration, as we cannot wipe the test VM during the test process.
[2] This configuration is indicated and described in the main *testing* section.

#### Manual tests

Manual tests are more complete than the automated tests, testing all the test configurations [1]. Consequently, these tests are slower and more time consuming to run than automated tests. The use of Ansible and simple shell scripts aims to reduce this effort/complexity as far as is practical.

Two environments, local and remote, are available for manual testing. Some types of test, for example testing SSL with tools such as SSL Labs, can only be performed using the remote environment.

[1] These configurations are described in the main *testing* section.

##### Requirements

###### All environments

* [Mac OS X](https://www.apple.com/uk/osx/)
* [NMap](http://nmap.org/) `brew cask install nmap` [1]
* [Git](http://git-scm.com/) `brew install git`
* [Ansible](http://www.ansible.com) `brew install ansible`
* You have a [private key](https://help.github.com/articles/generating-ssh-keys/) `id_rsa`
and [public key](https://help.github.com/articles/generating-ssh-keys/) `id_rsa.pub` in `~/.ssh/`

[1] `nmap` is needed to determine if you access internal resources (such as Stash).

###### Manual testing - local

* [VMware Fusion](http://vmware.com/fusion) `brew cask install vmware-fusion`
* [Vagrant](http://vagrantup.com) `brew cask install vagrant`
* Vagrant plugins:
    * [Vagrant VMware](http://www.vagrantup.com/vmware) `vagrant plugin install vagrant-vmware-fusion`
    * [Host manager](https://github.com/smdahlen/vagrant-hostmanager) `vagrant plugin install vagrant-hostmanager`
    * [Vagrant triggers](https://github.com/emyl/vagrant-triggers) `vagrant plugin install vagrant-triggers`
* You have an entry like [1] in your `~/.ssh/config`
* You have a [self signed SSL certificate for local use](https://gist.github.com/felnne/25c220a03f8f39663a5d), with the
certificate assumed at, `tests/provisioning/certificates/v.m/v.m.tls.crt`, and private key at `tests/provisioning/certificates/v.m/v.m.tls.key`

[1] SSH config entry

```shell
Host *.v.m
    ForwardAgent yes
    User app
    IdentityFile ~/.ssh/id_rsa
    Port 22
```

###### Manual testing - remote

* [Terraform](terraform.io) `brew cask install terraform` (minimum version: 6.0)
* [Rsync](https://rsync.samba.org/) `brew install rsync`
* You have an entry like [1] in your `~/.ssh/config`
* An environment variable: `TF_VAR_digital_ocean_token=XXX` set,
where `XXX` is your DigitalOcean personal access token - used by Terraform
* An environment variable: `TF_VAR_ssh_fingerprint=XXX` set,
 where `XXX` is [your public key fingerprint](https://gist.github.com/felnne/596d2bf11842a0cf64d6) - used by Terraform
* You have the `*.web.nerc-bas.ac.uk` wildcard SSL certificate, with the
certificate assumed at, `tests/provisioning/certificates/star.web.nerc-bas.ac.uk/star.web.nerc-bas.ac.uk-certificate-including-trust-chain.crt`, and private key at `tests/provisioning/certificates/star.web.nerc-bas.ac.uk/star.web.nerc-bas.ac.uk.key`

[1] SSH config entry

```shell
Host *.web.nerc-bas.ac.uk
    ForwardAgent yes
    User app
    IdentityFile ~/.ssh/id_rsa
    Port 22
```

##### Setup

###### All environments

It is assumed you are in the root of this role.

```shell
cd tests
```

###### Manual testing - local

VMs are powered by VMware, managed using Vagrant and configured by Ansible.

```shell
$ vagrant up
```

Vagrant will automatically configure the localhost hosts file for infrastructure it creates on your behalf:

| Name                      | Points To                                     | FQDN                        | Notes                             |
| ------------------------- | --------------------------------------------- | --------------------------- | --------------------------------- |
| barc-apache-test-web1.v.m | *computed value*                              | `barc-apache-test-web1.v.m` | The VM's private IP address       |

Note: Vagrant managed VMs also have a second, host-guest only, network for management purposes not documented here.

###### Manual testing - remote

VMs are powered by DigitalOcean, managed using Terraform and configured by Ansible.

```shell
$ terraform get
$ terraform apply
```

Terraform will automatically configure DNS records for infrastructure it creates on your behalf:

| Kind      | Name                           | Points To                                           | FQDN                                                | Notes                                             |
| --------- | ------------------------------ | --------------------------------------------------- | --------------------------------------------------- | ------------------------------------------------- |
| **A**     | barc-apache-test-web2.internal | *computed value*                                    | `barc-apache-test-web2.internal.web.nerc-bas.ac.uk` | The VM's private IP address                       |
| **A**     | barc-apache-test-web2.external | *computed value*                                    | `barc-apache-test-web2.external.web.nerc-bas.ac.uk` | The VM's public IP address                        |
| **CNAME** | barc-apache-test-web2          | `barc-apache-test-web2.external.web.nerc-bas.ac.uk` | `barc-apache-test-web2.web.nerc-bas.ac.uk`          | A pointer for the default address                 |

Note: Terraform cannot provision VMs itself due to [this issue](https://github.com/hashicorp/terraform/issues/1178),
therefore these tasks need to be performed manually:

```shell
$ ansible-galaxy install https://github.com/antarctica/ansible-prelude,v0.1.2 --roles-path=provisioning/roles_bootstrap  --no-deps --force
$ ansible-playbook -i provisioning/local provisioning/prelude.yml
$ ansible-playbook -i provisioning/testing-remote provisioning/bootstrap-digitalocean.yml
```

##### Usage

###### Manual testing - local

Use this shell script to run all test phases automatically:

```shell
$ ./tests/run-local-tests.sh
```

Alternatively run each phase separately:

```shell
# Check syntax:
$ ansible-playbook -i provisioning/testing-local provisioning/site-test.yml --syntax-check

# Apply playbook:
$ ansible-playbook -i provisioning/testing-local provisioning/site-test.yml

# Apply again to check idempotency:
$ ansible-playbook -i provisioning/testing-local provisioning/site-test.yml
```

Note: The use of `#` in the above indicates a comment, not a root shell.

###### Manual testing - remote

Use this shell script to run all test phases automatically:

```shell
$ ./tests/run-remote-tests.sh
```

Alternatively run each phase separately:

```shell
# Check syntax:
$ ansible-playbook -i provisioning/testing-remote provisioning/site-test.yml --syntax-check

# Apply playbook:
$ ansible-playbook -i provisioning/testing-remote provisioning/site-test.yml

# Apply again to check idempotency:
$ ansible-playbook -i provisioning/testing-remote provisioning/site-test.yml
```

Note: The use of `#` in the above indicates a comment, not a root shell.

##### Clean up

###### Manual testing - local

```shell
$ vagrant destroy
```

###### Manual testing - remote

```shell
$ terraform destroy
```

### Issue tracking

Issues, bugs, improvements, questions, suggestions and other tasks related to this package are managed through the BAS Web & Applications Team Jira project ([BASWEB](https://jira.ceh.ac.uk/browse/BASWEB)).

### Committing changes

The [Git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow/) workflow is used to manage development of this package.

Discrete changes should be made within *feature* branches, created from and merged back into *develop* (where small one-line changes may be made directly).

When ready to release a set of features/changes create a *release* branch from *develop*, update documentation as required and merge into *master* with a tagged, [semantic version](http://semver.org/) (e.g. `v1.2.3`).

After releases the *master* branch should be merged with *develop* to restart the process. High impact bugs can be addressed in *hotfix* branches, created from and merged into *master* directly (and then into *develop*).

## Contributing

This project welcomes contributions, see `CONTRIBUTING` for our general policy.

## License

Copyright 2015 NERC BAS. Licensed under the MIT license, see `LICENSE` for details.
