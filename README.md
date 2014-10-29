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

## Branches

This project uses three permanent branches with the *Git Flow* branching model managing the interaction between branches.

* **Develop:** unstable, potentially non-working but most current version of roles. Bug fixes and features interact with this branch only.
* **Master:** stable, tested, working version of role with full documentation. Releases and hot fixes mainly interact with this branch. This branch should when consuming roles internally.
* **Public:** equivalent to the *master* branch, but available externally. Some configuration details may be altered or features removed to make available for public release.

## Testing

Manual testing is performed for all roles to ensure roles achieve their aims and this forms a prerequisite task for merging changes into the *master* and *public* branches.
Wherever possible testing is as complete as possible meaning tasks such as downloading dependencies are performed as part of each test.

## Issues

Please log issues to the [BAS Web and Applications Team](https://jira.ceh.ac.uk/browse/BASWEB) project in Jira, within the *Project - Ansible Roles* component.

If outside of NERC please get in touch to report any issues.

## Contributions

We have no formal contribution policy, if you spot any bugs or potential improvements please submit a pull request or get in touch.

These roles are used for internal projects which may dictate whether any contributions can be included.

## License

[Open Government Licence V2](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/)

## Requirements

### BAS Ansible Role Collection (BARC)

* `core`

### Other

If using SSL the certificate and private key used must be accessible on the server, then use the `apache_default_var_www_ssl_cert` and `apache_default_var_www_ssl_key` variables to point to this location. It is out of scope to do this in this role (as the certificate may be used in multiple web-servers).

## Variables

Variables used in default virtual host `/etc/apache2/sites-available/default`:

* `apache_app_user_username`
	* The username of the app user, used for day to day tasks, if enabled
	* This variable **must** be a valid unix username
	* Default: "app"
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
    * File name (including extension) of SSL certificate in `apache_default_var_www_ssl_cert_path`
    * Default: "cert.cer"
* `apache_default_var_www_ssl_key_file`
    * File name (including extension) of SSL private key in `apache_default_var_www_ssl_key_path`
    * Default: "cert.key"

## Changelog

### 0.2.3 - October 2014

* Updating role dependencies
* The app user's username is now configurable
* Spelling

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
