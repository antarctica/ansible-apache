# Apache ('apache')

**Part of the BAS Ansible Role Collection (BARC)**

Installs the Apache web-sever using default virtual hosts

## Overview

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

## Usage

### Deprecated features

The following features are deprecated within this role. They will be removed in the next major version.

* Support for 'allow overrides' (i.e. `.htaccess` files) will be permanently removed, currently support is only disabled. Set `apache_enable_feature_disable_document_root_allow_overrides` to "true" to re-enable support. This is mainly for compatibility with other web-servers which do not support this concept but also for performance reasons. 
* The default HTTP virtual host will be disabled by default as we move to a HTTPS by default approach. Redirections from HTTP to HTTPS connections will be supported in future versions of this role.

### Limitations

* This role assumes you will be using, at most, a single virtual host. This role will not prevent multiple virtual hosts from being used, but you will need to configure this. For example you will need to create additional virtual host configuration files and enable them outside this role. You may wish to use the additional configuration files, such as the improvements to SSL configurations for example, but again, this is not something this role will do for you.
* This role assumes the SSL certificate chain will be contained in the same file as the SSL certificate. Whilst this role supports specifying a different path and file for the chain, this role will not upload this file. Therefore you are responsible for ensuring the chain file is available at the path you specify (i.e. by uploading it using the *copy* module).

### Requirements

#### BAS Ansible Role Collection (BARC)

* `core`

#### Other

* If using SSL, the certificate and private key used must be accessible on the server.
    * Use the `apache_default_var_www_ssl_cert` and `apache_default_var_www_ssl_key` variables to point to there location
    * It is out of scope to do this in this role (as the certificate may be used in multiple web-servers).
* If using a non-default document root (i.e. not `/var/www`) you **MUST** ensure the Apache user has read access to this location.

### Variables

Variables used in default virtual host `/etc/apache2/sites-available/default`:

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

## Contributing

This project welcomes contributions, see `CONTRIBUTING` for our general policy.

## Developing

### Apache modules

This role **MUST NOT** contain any additional Apache modules or module configuration, except for modules available in Apache by default.

Separate roles **MUST** be used for these modules, each module **SHOULD** have a separate role with this `apache` role as a dependency (plus any other roles as needed). By convention they should be named `ansible-*` where `*` is the name of the role, e.g. `apache-some-module`. Roles **SHOULD NOT** duplicate virtual host file templates. Doing so introduces brittleness and fragmentation between the 'upstream' `apache` role and module roles (which will typically update at much slower frequencies).

### Virtual hosts

This role supports creating a default HTTP and HTTPS virtual host only. Where you need to use multiple virtual hosts within a server you should:

* Prevent this role creating default virtual host files by setting the `apache_enable_feature_default_http_virtualhost` and `apache_enable_feature_default_https_virtualhost` variables to "false"
* Create required virtual host files yourself, optionally using the template provided in this role

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

### Committing changes

The [Git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow/) workflow is used to manage development of this package.

Discrete changes should be made within *feature* branches, created from and merged back into *develop* (where small one-line changes may be made directly).

When ready to release a set of features/changes create a *release* branch from *develop*, update documentation as required and merge into *master* with a tagged, [semantic version](http://semver.org/) (e.g. `v1.2.3`).

After releases the *master* branch should be merged with *develop* to restart the process. High impact bugs can be addressed in *hotfix* branches, created from and merged into *master* directly (and then into *develop*).

### Issue tracking

Issues, bugs, improvements, questions, suggestions and other tasks related to this package are managed through the BAS Web & Applications Team Jira project ([BASWEB](https://jira.ceh.ac.uk/browse/BASWEB)).

### Testing

To ensure this role provides its stated functionality tests **MUST** be performed before releasing new versions of this role.

To assist with this a testing environment is provided within this role, through the `tests` directory.

It includes two environments, local and remote for testing changes (a remote environment is provided fro testing SSL configurations with SSL Labs and other similar tools). Ansible is used to configure these environments, the aim being to replicate, as far as possible, the same workflow and environment in which this role will be used.

#### Requirements

##### All environments

* [Mac OS X](https://www.apple.com/uk/osx/)
* [NMap](http://nmap.org/) `brew cask install nmap` [1]
* [Git](http://git-scm.com/) `brew install git`
* [Ansible](http://www.ansible.com) `brew install ansible`
* You have a [private key](https://help.github.com/articles/generating-ssh-keys/) `id_rsa`
and [public key](https://help.github.com/articles/generating-ssh-keys/) `id_rsa.pub` in `~/.ssh/`

[1] `nmap` is needed to determine if you access internal resources (such as Stash).

##### Testing - local

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

##### Testing - remote

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

#### Setup

##### All environments

It is assumed you are in the root of this role.

```shell
cd tests
```

##### Testing - local

VMs are powered by VMware, managed using Vagrant and configured by Ansible.

```shell
$ vagrant up
```

Vagrant will automatically configure the localhost hosts file for infrastructure it creates on your behalf:

| Name                      | Points To                                     | FQDN                        | Notes                             |
| ------------------------- | --------------------------------------------- | --------------------------- | --------------------------------- |
| barc-apache-test-web1.v.m | *computed value*                              | `barc-apache-test-web1.v.m` | The VM's private IP address       |

Note: Vagrant managed VMs also have a second, host-guest only, network for management purposes not documented here.

##### Testing - remote

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
$ ansible-playbook -i provisioning/testing provisioning/bootstrap-digitalocean.yml
```

#### Usage

Currently testing is limited to building a server, installing Apache and configuring it to use SSL.

It is assumed that getting to the to that point indicates this role is working correctly, however manual testing will be needed to confirm this.

In the future these checks will be made automatically, and more scenarios will be tested to more systematically test the different features of this role.

**Note:** Role tests are currently proof-of-concept and may change significantly during development. If practical and useful tests will be added to all BARC roles. Please report all feedback via the issue tracker mentioned previously. 

##### Testing - local

```shell
$ ansible-playbook -i provisioning/testing provisioning/site-test-local.yml
```

##### Testing - remote

```shell
$ ansible-playbook -i provisioning/testing provisioning/site-test-remote.yml
```

## License

Copyright 2015 NERC BAS. Licensed under the MIT license, see `LICENSE` for details.
