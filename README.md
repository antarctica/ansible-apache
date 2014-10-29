# Apache ('apache')

**Part of the BAS Ansible Role Collection (BARC)**

Installs Apache web-sever using default virtual host

## Overview

* Installs Apache server and enabled mod_rewrite support.
* Configures default virtual host for HTTP connections, if a non-default document root is used the virtual host will be configured to point to this location.
* Optionally configures virtual host for HTTPS connections, if a non-default document root is used the virtual host will be configured to point to this location.
* The app user is made a member of the `www-data` group and ownership of the default document root is set to the 'app' user.
* Default content is removed (for use with a default document root).

## Author

[British Antarctic Survey](http://www.antarctica.ac.uk) - Web & Applications Team

Contact: [basweb@bas.ac.uk](mailto:basweb@bas.ac.uk).

## Availability

This role is designed for internal use but if useful can be shared publicly.

## License

[Open Government Licence V2](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/)

## Requirements

### BAS Ansible Role Collection (BARC)

* `core`

### Other

If using SSL the certificate and private key used must be accessible on the server, then use the `apache_default_var_www_ssl_cert` and `apache_default_var_www_ssl_key` variables to point to this location. It is out of scope to do this in this role (as the certificate may be used in multiple web-servers).

## Variables

Variables used in default virtual host `/etc/apache2/sites-available/default`:

* `apache_default_var_www_server_admin`
	* E-mail address shown to users in error pages (404, 500, etc.).
	* External servers should use `basweb@bas.ac.uk`.
    * Default: "webteam@bas.ac.uk"
* `apache_default_var_www_document_root`
	* Location on server containing site files.
	* If a non-default root is used ensure the `www-data` group has access.
    * Default: "/var/www/"
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
    * Default: "/vagrant/data/certificates"
* `apache_default_var_www_ssl_key_path`
    * Path, without a trailing slash, to the directory holding the SSL private key
    * Default: "{{ apache_default_var_www_ssl_cert_path }}" (i.e. same directory as `apache_default_var_www_ssl_cert_path`)
* `apache_default_var_www_ssl_cert_file`
    * File name (including extension) of SSL certifcate in `apache_default_var_www_ssl_cert_path`
    * Default: "cert.cer"
* `apache_default_var_www_ssl_key_file`
    * File name (including extension) of SSL private key in `apache_default_var_www_ssl_key_path`
    * Default: "cert.key"

## Changelog

### 0.2.3 - October 2014

* Updating role dependencies

### 0.2.2 - October 2014

* Adjusting role for inclusion in BARC
* Tasks cleanup

### 0.2.1 - September 2014

* Disabling reporting of apache version

### 0.2.0 - September 2014

* Adding SSL virtual host support

### 0.1.4 - September 2014

* Fixing 'Could not reliably determine the server's fully qualified domain name' error
* Fixing incorrect server admin address

### 0.1.3 - September 2014

* Fixing hardcoded non-standard document root
* Minor template refactoring

### 0.1.2 - July 2014

* Making compatible with apache 2.4
* If a non-standard document root is used apache file configured to allow access to this directory automatically

### 0.1.1 - July 2014

* Making compatible with ubuntu 14.04
* Adding new variables for document root and server admin

### 0.1.0 - June 2014

* Initial version
