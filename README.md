# Apache (`apache`)

[![Build Status](https://semaphoreci.com/api/v1/projects/9fd776a8-8f74-4e82-a2e0-bce17fcacdf3/526947/badge.svg)](https://semaphoreci.com/antarctica/ansible-apache)

**Part of the BAS Ansible Role Collection (BARC)**

Installs the Apache web-sever and optionally setup a default virtual host

## Overview

* Installs Apache server and enables the rewrite module
* Makes an 'app' user the owner of the default document root and adds user to the `www-data` group
* Allows non-default ports and IP bindings to be used, with conventional values used by default (i.e. supports local connections only or using port 8080 instead of 80 etc.)
* Optionally, default content is removed from the default document root, if enabled, this is performed regardless of whether the default document root is used or not
* Optionally, creates virtual hosts for non-secure (HTTP - disabled by default) and secure (HTTPS - enabled by default) connections
* For enabled virtual hosts, variables allow common directives (e.g. document root) to be set
* For enabled virtual hosts, allows additional configuration options to be set using additional configuration files (for all virtual hosts) or to override specific templates if needed
* Optionally, enables non-secure requests to be 'upgraded' to secure requests using a specialised, minimal virtual host, this is enabled by default and also enables the rewrite module
* Optionally improves security of secure connections to use recommended cipher/protocols and other methods such as HTST headers and custom DH parameters, enabled by default
* Optionally supports copying a certificate and associated private key for use with the secure virtual host created by this role

## Availability

This role is designed for internal use but if useful can be shared publicly.

## Quality Assurance

This role uses manual and automated testing to ensure the features offered by this role work as advertised. See the `tests/README.md` file for more information.

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

[1] See the *Virtual host template* sub-section of the *Virtual hosts* section.

### Requirements

#### BAS Ansible Role Collection (BARC)

* `core`

#### Other

* If using SSL, which is assumed, the certificate and private key used must be accessible on the server. Use the `apache_default_var_www_ssl_cert` and `apache_default_var_www_ssl_key` variables to point to their respective locations.
* If using a non-default document root (i.e. not `/var/www`) you **MUST** ensure the Apache user can be granted ownership of this location.

### Variables

* `apache_app_user_username`
    * Username of an *app* user, which is used an unprivileged user and suitable for owning things like the document root , but not things like log files or SSL keys.
    * This variable **MUST** be a valid OS username
    * The user specified by this variable **SHOULD NOT** have root permissions, or access to sensitive information outside of the document root. 
    * Default: "app"
* `apache_enable_feature_disable_default_configs`
    * If "true", the set of default additional configuration files will be disabled, by removing the relevant symbolic links.
    * See the `apache_default_enabled_configs` variable for which specific configuration files will be removed.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * Default: "true"
* `apache_enable_feature_disable_default_apache_virtual_host`
    * If "true", the virtual host that ships with Apache by default will be removed.
    * This **SHOULD** be set to "true" if the virtual hosts available from this role are used, or if a custom virtual host(s) will be used.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * Default: "true"
* `apache_enable_feature_default_http_virtualhost`
    * If "true", a minimal virtual host will be created supporting non-secure (HTTP) connections only.
    * See the *Virtual hosts* section of this guide for details of the template used for this virtual host.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * Where this variable is set to "true", the `apache_enable_feature_upgrade_http_to_https` variable **MUST** be set to "false" to avoid a conflict. 
    * See the *Limitations* section of this README for more information.
    * Default: "false"
* `apache_enable_feature_default_https_virtualhost`
    * If "true", a minimal virtual host will be created supporting secure (HTTPS) connections only.
    * See the *Virtual hosts* section of this guide for details of the template used for this virtual host.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * By default this variable will be set to the value of the `apache_enable_feature_ssl` variable.
    * Default: "{{ apache_enable_feature_ssl }}"
* `apache_enable_feature_upgrade_http_to_https`
    * If "true" a virtual host will be created to 'upgrade' (redirect) non-secure (HTTP) connections to secure (HTTPS) connections.
    * See the *Virtual hosts* section of this guide for details of how this feature works.
    * If this feature is used, the `apache_enable_feature_default_https_virtualhost` variable **MUST** be set to "true".
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * Where this variable is set to "true", the `apache_enable_feature_default_http_virtualhost` variable **MUST** be set to "false" to avoid a conflict.
    * See the *Limitations* section of this README for more information.
    * Default: "true"
* `apache_enable_feature_use_canonical_name`
    * If "true', Apache will use the value of the *Server Name* directive when constructing self-referential URIs.
    * The value of the *Server Name* directive can be set using the `apache_server_name` variable.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * Default: "false"
* `apache_enable_feature_remove_default_document_root_content`
    * If "true", the default content in the default document root will be removed, to give an empty document root.
    * The default document root is hard coded to `/var/www/` , all content (including directories) within this path will be removed where this feature is enabled.
    * Assuming the virtual hosts this role creates are used, visiting an empty document root will give a *403 Forbidden* error as the listing of directories (including empty directories) is disabled by directives set by the `apache_document_root_options` variable.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * Default: "true"
* `apache_enable_feature_disable_document_root_allow_overrides`
    * If true, support for using `.htaccess` files will be disabled, providing the virtual hosts created by this role are used.
    * This variable **SHOULD** be set to "true", largely for performance reasons, as it possible to edit the main server configuration (by virtue of using this role). [This approach is also recommended by Apache themselves](http://httpd.apache.org/docs/2.2/howto/htaccess.html#when).
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * Where this variable is set to "true" an *Allow overrides* value of "None" will be used, if set to "false" a value of "All" will be used.
    * Default: "true"
* `apache_server_binding`
    * Network interface Apache should bind to (i.e. accept connections on)
    * This is useful where a server sits behind a load balancer and a private network is used to prevent direct access by clients. Alternatively, in cases where an upstream service sits between the Apache server and the client (e.g. a caching layer) Apache can be set to bind to the local loopback adapter.
    * This variable **MUST** be a valid network interface Apache can bind to
    * By default, this variable will be set to bind to all available interfaces.
    * Default: "0.0.0.0"
* `apache_server_http_port`
    * Port on which Apache will listen for non-secure (HTTP) connections.
    * This variable **MUST** be a valid port and **SHOULD** be set to "80".
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "80"
* `apache_server_https_port`
    * Port on which Apache will listen for secure (HTTPS) connections.
    * More information on this setting is available in the [Apache documentation](http://httpd.apache.org/docs/2.4/mod/core.html#serveradmin).
    * This variable **MUST** be a valid port and **SHOULD** be set to "443".
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "443"
* `apache_server_name`
    * Hostname this server identifies itself as, AKA its domain name.
    * More information on this setting is available in the [Apache documentation](http://httpd.apache.org/docs/2.4/mod/core.html#servername). 
    * This variable **MUST** be a valid, resolvable, hostname.
    * By default, this variable will use the *Fully Qualified Domain Name* (FQDN) of the current machine.
    * Default: "{{ ansible_fqdn }}"
* `apache_server_admin`
    * Email address for an entity responsible for the Apache server (but not usually its content).
    * This address is shown to end-users on error pages (in clear text) and **SHOULD** be set to a system administrator or similar role.
    * More information on this setting is available in the [Apache documentation](http://httpd.apache.org/docs/2.4/mod/core.html#serveradmin).
    * This variable **MUST** be a valid email address as determined by the various relevant IETF RFCs.
    * Default: "webmaster@example.com"
* `apache_document_root`
    * Path from which Apache will serve files.
    * This path acts as the virtual "root" of the server (i.e. it is impossible to access files above this path through the server).
    * This variable **MUST** reference a valid path and **MUST NOT** include a trailing slash (`/`), as recommended by Apache.
    * More information on this setting is available in the [Apache documentation](http://httpd.apache.org/docs/2.4/mod/core.html#documentroot).
    * The path this variable references **MUST** have suitable permissions such that the *www-data* group has, at least, read access to files and, at least, read and execute access to directories. Further permissions may be required for certain use-cases such as uploading files.
    * The path this variable references **SHOULD** be owned by the user set by the `apache_app_user_username` variable.
    * By default, this variable will use the `generic_document_root` variable if available, if not, a conventional default fall-back of "/var/www" will be used.
    * Default: "{{ generic_document_root | default('/var/www') }}"
* `apache_document_root_options`
    * A series of Apache options applied to the document root.
    * The document root is set by the `apache_document_root` variable.
    * This variable **MUST** be structured as a YAML list, each item **MUST NOT** have children.
    * Each item **MUST** be a Apache configuration option permitted inside a *Document* directive within a *Virtual Host* directive, as determined by Apache.
    * Default: *list containing*:
      - "-Indexes"
      - "+FollowSymLinks"
      - "-MultiViews"
* `apache_available_configs_dir`
    * Path to the directory additional Apache configuration files are located.
    * Configurations in this location will not necessarily be used by Apache as they must first be *enabled*. This requires a symbolic link to be made to the directory set by the `apache_enabled_configs_dir` variable.
    * This variable **MUST** reference a valid path and **MUST NOT** include a trailing slash (`/`).
    * The path this variable references **MUST** have *world* read and execute permissions applied.
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "/etc/apache2/conf-available"
* `apache_enabled_configs_dir`
    * Path to the directory *enabled* additional Apache configurations files are located. These configuration files will be used by Apache. 
    * Configuration files **SHOULD** be located in the directory set by the `apache_available_configs_dir` variable and **SHOULD NOT** not stored in this directory directly.
    * To enable a configuration file, a symbolic link **SHOULD** be created between the directory set by the `apache_available_configs_dir` variable and the directory set by this variable.
    * This variable **MUST** reference a valid path and **MUST NOT** include a trailing slash (`/`).
    * The path this variable references **MUST** have *world* read and execute permissions applied.
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "/etc/apache2/conf-enabled"
* `apache_enabled_configs_file_selector`
    * File pattern to specify which files within the directory set by the `apache_enabled_configs_dir` variable will be enabled.
    * Setting this variable to "*.conf" for example will enable all files with an extension of *.conf*. This is the default setting.
    * This variable **MUST** be a valid file pattern, as determined by Apache, and **MUST NOT** include a leading slash (`/`).
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "*.conf"
* `apache_default_enabled_configs`
    * The set of additional Apache configuration files that ship with Apache by default.
    * Most of these files are commented out and so require an *opt-in*, however several files are *opt-out* and will result in an invalid server configuration where the default virtual hosts created by this role are used. For this reason they are set to be disabled by default.
    * This variable **MUST** be structured as a YAML list, each item **MUST NOT** have children.
    * Each item **MUST** be a Apache configuration file located (via a symbolic link) in the directory set by the `apache_enabled_configs_dir` variable.
    * Default: *list containing*:
      - "charset.conf"
      - "localized-error-pages.conf"
      - "other-vhosts-access-log.conf"
      - "security.conf"
      - "serve-cgi-bin.conf"
* `apache_enable_feature_ssl`
    * If true, support for secure connections will be enabled within Apache.
    * Enabling this feature will enable an additional configuration file and default virtual host to be configured automatically (amongst other actions).
    * The term "SSL" is used in a colloquial sense, rather than referring to the specific technology of SSL. Within this role only support for TLS is actually supported.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * In line with general trends, this feature **SHOULD** be enabled by setting this variable to "true".
    * By default, this variable will use the `generic_enable_feature_ssl` variable if available, if not, a conventional default fall-back of "true" will be used.
    * Default: "{{ generic_enable_feature_ssl | default(true) }}"
* `apache_enable_feature_ssl_copy_cert`
    * If "true", the certificate file set by the `apache_ssl_cert_file` variable shall be copied from the path set by the `apache_ssl_cert_src` variable to the path set by the `apache_ssl_cert_base` variable.
    * This feature **SHOULD** be disabled where the certificate file to be used is already present on the server being configured. In these cases this file **MUST** be present in the path set by the `apache_ssl_cert_base` variable.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * By default, this variable will use the `generic_enable_feature_ssl_copy_cert` variable if available, if not, a conventional default fall-back of "true" will be used.
    * Default: "{{ generic_enable_feature_ssl_copy_cert | default(true) }}"
* `apache_enable_feature_ssl_copy_key`
    * If 'true", the certificate private key set by the `apache_ssl_key_file` variable shall be copied from the set by the `apache_ssl_key_src` variable to the path set by the `apache_ssl_key_base` variable.
    * This feature **SHOULD** be disabled where the certificate private key file to be used is already present on the server being configured. In these cases this file **MUST** be present in the path set by the `apache_ssl_cert_base` variable.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * By default, this variable will use the `generic_enable_feature_ssl_copy_key` variable if available, if not, a conventional default fall-back of "true" will be used.
    * Default: "{{ generic_enable_feature_ssl_copy_key | default(true) }}"
* `apache_enable_feature_ssl_hsts`
    * If "true", HTTP Strict Transport Security (HSTS) support will be added to SSL additional Apache configuration file created by this role, and included in the default secure virtual host also created by this role.
    * The headers added by this role will set the *max-age* parameter of the HSTS header with a value of "31536000" (1 year).
    * Additional information on HSTS [is available here](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security).
    * Enabling this feature will enable the Apache headers module in order to set HSTS headers.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * Default: "true"
* `apache_enable_feature_ssl_custom_dh_parameters`
    * If "true", the Diffie-Hellman parameters, (loaded from a file and used in perfect forward security for secure connections, can be set to a custom file.
    * Additional information on custom DH parameters [is available here](https://wiki.openssl.org/index.php/Diffie-Hellman_parameters).
    * The DH parameters file used with Apache and Ubuntu is suitably long (in terms of bit length) to be considered secure, and therefore does not need to be changed. However there may be cases where it is still desired to do, where this feature can be used.
    * Where OpenSSL is used for SSL functions in Apache (the default), OpenSSL version 1.0.2 or higher **MUST** be installed or a config error will prevent Apache from starting.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
    * Default: "false"
* `apache_ssl_additional_config_path`
    * Where secure connections are enabled, path in which the SSL additional Apache configuration file created by this role will be stored.
    * This variable **MUST** reference a valid path and **MUST NOT** include a trailing slash (`/`).
    * The path this variable references **MUST** have *world* read and execute permissions applied.
    * By default this variable will be set to the value of the `apache_available_configs_dir` variable.
    * This default value **SHOULD** not be changed to ensure all additional configuration files are kept in a single location.
    * Default: "{{ apache_available_configs_dir }}"
* `apache_ssl_cert_src`
    * Where secure connections, and copying a SSL certificate file, are enabled, path in which the certificate file is located on the system Ansible will be executed.
    * This variable **MUST** reference a valid path, on the system Ansible will be executed, and **MUST NOT** include a trailing slash (`/`), but **MUST** include any sub directories.
    * E.g. if certificates were located in a directory `example.com` inside a `certificates` directory, this variable would be set to `certificates/example.com`.
    * The path this variable references **MUST** contain the certificate file specified by the `generic_ssl_cert_file` variable.
    * The path this variable references **MUST** be readable by the user executing the Ansible process (usually you).
    * By default, this variable will use the `generic_ssl_cert_src` variable if available, if not, a conventional default fall-back of "certificates" will be used.
    * Default: "{{ generic_ssl_cert_src | default('certificates') }}"
* `apache_ssl_cert_base`
    * Where secure connections are enabled, path in which the certificate file to be used is located, or will be located where the certificate is copied.
    * This variable **MUST** reference a valid path and **MUST NOT** include a trailing slash (`/`).
    * By default, this variable will use the `generic_ssl_cert_base` variable if available, if not, a conventional default fall-back of "/etc/ssl/certs" will be used.
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "{{ generic_ssl_cert_base | default('/etc/ssl/certs') }}"
* `apache_ssl_cert_file`
    * Where secure connections are enabled, name of the certificate file to be used.
    * The certificate file referenced by this variable **MUST** be a valid certificate, as determined by Apache.
    * The *owner* and *group* of the certificate **SHOULD** be set "root* and "ssl-cert" respectively. The permissions **SHOULD** be set to *owner*: 'read-write", *group*: "read" and *world*: "read".
    * By default, this variable will use the `generic_ssl_cert_file` variable if available, if not, a conventional default fall-back of "certificate-including-trust-chain.crt" will be used.
    * Default: "{{ generic_ssl_cert_file | default('certificate-including-trust-chain.crt') }}"
* `apache_ssl_chain_base`
    * Where secure connections are enabled, path in which the certificate chain file to be used is located.
    * This variable **MUST** reference a valid path and **MUST NOT** include a trailing slash (`/`).
    * It is assumed the certificate specified by the `apache_ssl_cert_file` variable requires a certificate chain (i.e the certificate is not a self-signed certificate, or a root CA certificate). If this is not the case the default value for this variable can safely used.
    * It is assumed the certificate chain file will be located in the same path as the final certificate in the chain, where this is not the case this variable **MUST** be set to the path containing the chain file.
    * By default this variable will be set to the value of the `apache_ssl_cert_base` variable.
    * Default: "{{ apache_ssl_cert_base }}"
* `apache_ssl_chain_file`
    * Where secure connections are enabled, name of the certificate chain file to be used.
    * The chain file referenced by this variable **MUST** be a valid chain of certificates, as determined by Apache.
    * It is assumed the certificate specified by the `apache_ssl_cert_file` variable requires a certificate chain (i.e the certificate is not a self-signed certificate, or a root CA certificate). If this is not the case the default value for this variable can safely used.
    * It is assumed certificates within the certificate chain will be specified in the same file as the final certificate in the chain, where this is not the case this variable **MUST** be set to the name of the chain file.
    * The *owner* and *group* of the certificate chain **SHOULD** be set "root* and "ssl-cert" respectively. The permissions **SHOULD** be set to *owner*: 'read-write", *group*: "read" and *world*: "no-access".
    * By default this variable will be set to the value of the `apache_ssl_cert_file` variable.
    * Default: "{{ apache_ssl_cert_file }}"
* `apache_ssl_key_src`
    * Where secure connections, and copying a SSL certificate private key file, are enabled, path in which the private key file is located on the system Ansible will be executed.
    * This variable **MUST** reference a valid path, on the system Ansible will be executed, and **MUST NOT** include a trailing slash (`/`), but **MUST** include any sub directories.
    * E.g. if the private key is located in a directory `example.com` inside a `certificates` directory, this variable would be set to `certificates/example.com`.
    * The path this variable references **MUST** contain the certificate private key file specified by the `generic_ssl_key_file` variable.
    * The path this variable references **MUST** be readable by the user executing the Ansible process (usually you).
    * By default, this variable will use the `generic_ssl_key_src` variable if available, if not, a conventional default fall-back of "certificates" will be used.
    * You **MAY** set this variable to the value of the `generic_ssl_cert_src` variable for convenience.
    * Default: "{{ generic_ssl_key_src | default('certificates') }}"
* `apache_ssl_key_base`
    * Where secure connections are enabled, path in which the certificate private key file to be used is located, or will be located where the private key is copied.
    * By default, this variable will use the `generic_ssl_key_base` variable if available, if not, a conventional default fall-back of "/etc/ssl/private" will be used.
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "{{ generic_ssl_key_base | default('/etc/ssl/private') }}"
* `apache_ssl_key_file`
    * Where secure connections are enabled, name of the certificate private key file to be used.
    * The certificate private key file referenced by this variable **MUST** be a valid certificate private key, as determined by Apache.
    * The *owner* and *group* of the private key **MUST** be set "root* and "ssl-cert" respectively. The permissions **MUST** be set to *owner*: 'read-write", *group*: "read" and *world*: "no-access".
    * By default, this variable will use the `generic_ssl_key_file` variable if available, if not, a conventional default fall-back of "certificate.key" will be used.
    * Default: "{{ generic_ssl_key_file | default('certificate.key') }}"
* `apache_ssl_dhparam_cert_path`
    * Where secure connections, and custom DH parameters, are enabled, path in which the DH parameters file is located.
    * This variable **MUST** reference a valid path and **MUST NOT** include a trailing slash (`/`).
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "/etc/ssl/certs"
* `apache_ssl_dhparam_cert_file`
    * Where secure connections, and custom DH parameters, are enabled, name of the DH parameters file to be used.
    * The parameters file referenced by this variable **MUST** be a valid DH parameters file, as determined by Apache.
    * The *owner* and *group* of the parameters file **SHOULD** be set "root* and "ssl-cert" respectively. The permissions **SHOULD** be set to *owner*: 'read-write", *group*: "read" and *world*: "read".
    * The default value for this variable is a conventional default, therefore you **SHOULD NOT** change this value without good reason.
    * Default: "dhparam.pem"
* `apache_enable_feature_configure_ufw`
    * If "true", rules for allowing non-secure and/or secure connections will be allowed, from anyone, will be enabled in Ubuntu's Uncomplicated FireWall (UFW).
    * See the *Compatibility with Uncomplicated Firewall* section of this README for more information.
    * This is a binary variable and **MUST** be set to either "true" or "false" (without quotes).
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

[1] Support for `.htaccess` files is deprecated. See the *Deprecated features* section for more information.

[2] https://wiki.apache.org/httpd/RedirectSSL

#### Virtual host template

This role uses Jinja's templating features to create virtual host files with a block to include additional configuration.

The base template is `_virtualhost.conf.template.j2` (the `_` prefix donates this is a template file) and contains an opinionated virtual host definition based on the default Apache virtual host.

A block `additional_configuration` is provided to inject any additional configuration (e.g. enabling SSL ) within a virtual host. This block is deliberately placed before additional configuration files are included, see the *Additional configuration* section for details.

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

[1] See the *Additional_configuration block or additional configuration feature* sub-section of the *Virtual host template* section for more details on when to use this feature.

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

See the *Variables* section for details on the variables this role offers to control the application definitions and rules this role will make.

For reference the application definitions this role creates [3] are:

| Name                 | Title                          | Ports                                                                 | Notes                        |
| -------------------- | ------------------------------ | --------------------------------------------------------------------- | ---------------------------- |
| `Apache-Non-Secure`  | Apache Web Server (HTTP)       | TCP `{{ apache_server_http_port }}`                                   | Port is based on variable    |
| `Apache-Secure`      | Apache Web Server (HTTPS)      | TCP `{{ apache_server_https_port }}`                                  | Port is based on variable    |
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

### Issue tracking

Issues, bugs, improvements, questions, suggestions and other tasks related to this package are managed through the BAS Web & Applications Team Jira project ([BASWEB](https://jira.ceh.ac.uk/browse/BASWEB)).

### Committing changes

The [Git flow](sian.com/git/tutorials/comparing-workflows/gitflow-workflow) workflow is used to manage the development 
of this package.

* Discrete changes should be made within feature branches, created from and merged back into develop (where small 
changes may be made directly)
* When ready to release a set of features/changes, create a release branch from develop, update documentation as 
required and merge into master with a tagged, semantic version (e.g. v1.2.3)
* After each release, the master branch should be merged with develop to restart the process
* High impact bugs can be addressed in hotfix branches, created from and merged into master (then develop) directly

## Contributing

This project welcomes contributions, see `CONTRIBUTING` for our general policy.

## License

Copyright 2015 NERC BAS.

Unless stated otherwise, all documentation is licensed under the Open Government License version 3 and all code licensed under the MIT License.

Copies of all licenses are included in this role's root directory.
