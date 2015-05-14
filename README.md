# Apache ('apache')

**Part of the BAS Ansible Role Collection (BARC)**

Installs Apache web-sever using default virtual host

## Overview

* Installs Apache server and enabled mod_rewrite support.
* Configures default virtual host for HTTP connections, if a non-default document root is used the virtual host will be configured to point to this location.
* Optionally configures virtual host for HTTPS connections, if a non-default document root is used the virtual host will be configured to point to this location.
* The app user is made a member of the `www-data` group and ownership of the default document root is set to the 'app' user.
* Default content is removed (for use with a default document root).
* Optionally adds support for a single alias, for compatibility with production environments.
* Optionally allows non-default ports and IP bindings to be set (i.e. listening for local connections only or setting port 80 to 8080).
* Provides 'markers' for adding additional configuration to default and default-ssl configuration files

## Availability

This role is designed for internal use but if useful can be shared publicly.

## Usage

### Requirements

#### BAS Ansible Role Collection (BARC)

* `core`

#### Other

If using SSL the certificate and private key used must be accessible on the server, then use the `apache_default_var_www_ssl_cert` and `apache_default_var_www_ssl_key` variables to point to this location. It is out of scope to do this in this role (as the certificate may be used in multiple web-servers).

### Variables

Variables used in default virtual host `/etc/apache2/sites-available/default`:

* `apache_app_user_username`
	* The username of the app user, used for day to day tasks, if enabled
	* This variable **MUST** be a valid unix username
	* Default: "app"
* `apache_server_use_canonical_name`
    * Whether Apache should use the server name value when constructing self-referential links or if a dynamic value can be used.
    * If this variable is set to "on", you **MUST** ensure the `apache_default_var_www_server_name` variable is set correctly. 
    * In most cases it is safe to leave this option turned off.
    * See [the Apache documentation](http://httpd.apache.org/docs/current/mod/core.html#usecanonicalname) for more information.
    * You **MUST** quote this value or Ansible will evaluate this value to a "True" or "False" which are not valid.
    * Allowed values: "on" or "off".
    * Default: "off"
* `apache_default_var_www_server_binding`
    * The networking interface Apache will listen for connections on
    * By default this variable listens on any IPv4 interface.
    * Default: "0.0.0.0"
* `apache_default_var_www_server_http_port`
    * The port on which Apache will listen for HTTP connections
    * By default this variable uses port 80, this is a convention and **SHOULD NOT** be changed.
    * Default: "80"
* `apache_default_var_www_server_https_port`
    * The port on which Apache will listen for HTTPS connections
    * By default this variable uses port 80, this is a convention and **SHOULD NOT** be changed.
    * Default: "443"
* `apache_default_var_www_server_name`
    * Name of the virtual server
    * If using an SSL certificate this variable **MUST** match the subject of the certificate
    * By default this variable will use the Fully Qualified Domain Name of the local machine.
    * Default: "{{ ansible_fqdn }}"
* `apache_default_var_www_server_admin`
	* E-mail address shown to users in error pages (404, 500, etc.).
	* External servers **SHOULD** use `basweb@bas.ac.uk`.
    * Default: "basweb@bas.ac.uk"
* `apache_default_var_www_document_root`
	* Path, without a trailing slash, of the physical directory on the server containing site files.
    * This variable **MUST** be a valid UNIX path without a trailing slash (i.e. `/`).
	* If a non-default root is used you **MUST** ensure the `www-data` group has access.
    * Default: "/var/www/"
* `apache_default_var_www_document_root_alias` 
	* Path, without a leading or trailing slash, of the virtual directory (i.e. the value as used in the URL). 
	* The alias will always point to the path set by `apache_default_var_www_document_root`.
	* Default: "" (empty string)
* `apache_default_var_www_options`
    * Array of options, each will be added as a separate `option: {{ item }}`
	* Default: [array]
        * "-Indexes"
        * "+FollowSymLinks"
        * "-MultiViews
* `apache_default_var_www_allowoverride`
	* To disable `.htaccess` support set this to `None`.
	* Default: "All"`
* `apache_default_var_www_ssl_enabled`
    * Boolean value for enabling SSL support
    * Default: "false"
* `apache_default_var_www_ssl_cert_path`
    * Path, without a trailing slash, to the directory holding the SSL certificate
    * This variable **MUST** be a valid UNIX path without a trailing slash (i.e. `/`).
    * Default: "/app/provisioning/certificates/domain"
* `apache_default_var_www_ssl_cert_file`
    * The file name and extension of the SSL certificate file within the directory specified by `apache_default_var_www_ssl_cert_path`
    * The certificate file **SHOULD** contain any required trust chain, but **SHOULD NOT** contain the root of the chain.
    * By convention this file **SHOULD** use a `.crt` extension.
    * Default: "certificate-including-trust-chain.crt"
* `apache_default_var_www_ssl_cert_chain_path`
    * Path, without a trailing slash, to the directory holding the SSL certificate chain
    * This variable **MUST** be a valid UNIX path without a trailing slash (i.e. `/`).
    * Default: "{{ apache_default_var_www_ssl_cert_path }}" (i.e. same directory as `apache_default_var_www_ssl_cert_path`)
* `apache_default_var_www_ssl_cert_chain_file`
    * The file name and extension of the SSL certificate chain file within the directory specified by `apache_default_var_www_ssl_cert_chain_path`
    * This variable is usually the same as `apache_default_var_www_ssl_cert_file` as the trust chain is part of the same file
    * By convention this file **SHOULD** use a `.crt` extension.
    * Default: "{{ apache_default_var_www_ssl_cert_file }}" (i.e. same directory as `apache_default_var_www_ssl_cert_file`)
* `apache_default_var_www_ssl_key_path`
    * Path, without a trailing slash, to the directory holding the SSL private key
    * This variable **MUST** be a valid UNIX path without a trailing slash (i.e. `/`).
    * By default this variable uses the Debian convention for SSL private keys and so this variable **SHOULD NOT** be changed.
    * Default: "/etc/ssl/private"
* `apache_default_var_www_ssl_key_file`
    * The file name and extension of the SSL private key within the directory specified by `apache_default_var_www_ssl_key_path`
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
