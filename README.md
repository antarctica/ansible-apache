# Apache ('apache')

**Part of the BAS Ansible Role Collection (BARC)**

Installs the Apache web-sever using default virtual hosts

## Overview

* Installs Apache server and enabled mod_rewrite support
* Configures default virtual host for HTTP connections
* Optionally configures virtual host for HTTPS connections, this is disabled by default
* If a non-default document root is used, virtual hosts for HTTP and, if enabled, HTTPS, will be configured to point to this location
* The app user is made a member of the `www-data` group and ownership of the default document root is assigned to the 'app' user
* Content is removed from the default document root, this is performed regardless of whether the default document root is used or not
* Optionally adds support for a single alias, for compatibility with some types of production environments - this is deprecated!
* Optionally allows non-default ports and IP bindings to be set (i.e. listening for local connections only or using port 8080 for HTTP connections)
* Provides 'markers' for including additional Apache configuration directives into default and default-ssl configuration files

## Availability

This role is designed for internal use but if useful can be shared publicly.

## Usage

### Deprecated features

The following features are deprecated within this role. They will be removed in the next major version.

* Support for aliases
* Support for Ubuntu 12.0 or lower

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
* `apache_default_var_www_document_root_alias` 
	* Path, without a leading or trailing slash, of the virtual directory (i.e. the value as used in the URL). 
    * Support for aliases is **deprecated** and as such this feature **SHOULD NOT** be used.
    * The alias will always point to the path set by `apache_default_var_www_document_root`.
	* Default: "" (empty string)
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
* `apache_default_var_www_ssl_enabled`
    * If "true" support for secure connections will be enabled within Apache
    * This is a binary variable and MUST be set to either "true" or "false" (without quotes).
    * Default: "false"
* `apache_default_var_www_ssl_cert_path`
    * Path to the directory containing the SSL certificate for secure connections
    * This variable **MUST** be a valid UNIX directory and **MUST NOT** contain a trailing slash (`/`).
    * Default: "/app/provisioning/certificates/domain"
* `apache_default_var_www_ssl_cert_file`
    * File name and extension of the SSL certificate for secure connections
    * By convention, this file **SHOULD** use a `.crt` extension.
    * Default: "certificate-including-trust-chain.crt"
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

## Contributing

This project welcomes contributions, see `CONTRIBUTING` for our general policy.

## Developing

### Apache modules

This role **MUST NOT** contain any additional Apache modules or module configuration, except for modules available in Apache by default.

Separate roles **MUST** be used for these modules, each module **SHOULD** have a separate role with this `apache` role as a dependency (plus any other roles as needed).

Where a module requires configuration directives within virtualhost files, isolated configuration files **SHOULD** be used. These files can be templated, assembled or copied as needed and **SHOULD** be stored in `/etc/apache2/conf-available`, using a `.conf` file extension. These files can then be included within virtualhost files using an [include directive](http://httpd.apache.org/docs/2.0/mod/core.html#include) using the [lineinfile](http://docs.ansible.com/lineinfile_module.html) Ansible action.

For example:

```yaml
---

- name: create module config file
  template: src=etc/apache2/conf-available/module.conf.j2 dest="{{ apache_module_config_file_path }}"

- name: add module configuration to default apache virtual host
  lineinfile: dest=/etc/apache2/sites-available/default line="    include {{ apache_wsgi_config_file_path }}" insertafter="# Marker - Apache module configuration" state=present
  notify:
    - Restart Apache
  when: ansible_distribution_version == "12.04"

- name: add module configuration to default apache virtual host
  lineinfile: dest=/etc/apache2/sites-available/000-default.conf line="    include {{ apache_wsgi_config_file_path }}" insertafter="# Marker - Apache module configuration" state=present
  notify:
    - Restart Apache
  when: ansible_distribution_version == "14.04"
```

This ensures each *lineinfile* call is unique (as each refers to a unique file) neatly sidestepping issues where common elements, such as `</Directory>`, are ignored as such element will almost certainly already exist elsewhere in the virtualhost file. Using separate files also encourages loose coupling between roles, and makes managing the file itself much easier.

Roles **SHOULD NOT** duplicate virtualhost file templates. Doing so introduces brittleness and fragmentation between the 'upstream' `apache` role and module roles (which will typically update at much slower frequencies).

### Custom configuration

There may be times where a project or role needs to make alterations to virtualhosts files which cannot be catered for using variables (e.g. directory or location directives). A similar approach to modules **SHOULD** be taken whereby isolated configuration files are created and included in the main virtualhosts file.

See the *apache modules* sub-section in the *developing* section for details on how this approach works.

Note: For these sorts of include files use `insertafter="# Marker - Other custom configuration"` instead of `insertafter="# Marker - Apache module configuration"`.

### Committing changes

The [Git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow/) workflow is used to manage development of this package.

Discrete changes should be made within *feature* branches, created from and merged back into *develop* (where small one-line changes may be made directly).

When ready to release a set of features/changes create a *release* branch from *develop*, update documentation as required and merge into *master* with a tagged, [semantic version](http://semver.org/) (e.g. `v1.2.3`).

After releases the *master* branch should be merged with *develop* to restart the process. High impact bugs can be addressed in *hotfix* branches, created from and merged into *master* directly (and then into *develop*).

### Issue tracking

Issues, bugs, improvements, questions, suggestions and other tasks related to this package are managed through the BAS Web & Applications Team Jira project ([BASWEB](https://jira.ceh.ac.uk/browse/BASWEB)).

## License

Copyright 2015 NERC BAS. Licensed under the MIT license, see `LICENSE` for details.
