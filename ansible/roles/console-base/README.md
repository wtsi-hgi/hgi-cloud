Role Name
=========

This is the role that provisions the console server: **cloud.hgi.sanger.ac.uk**

Role Variables
--------------

* **provisioning\_image\_version**  
  The version of the provisioning container
* **provisioning\_image\_basename**  
  The basename of the provisioning container image file
* **provisioning\_image\_url**  
  The base `URL` of provisioning container image file

Dependencies
------------

Refer to the [metadata](meta/main.yml).

Example Playbook
----------------

```yaml
    - hosts: localhost
      roles:
         - { role: console-base }
```

License
-------

BSD

Author Information
------------------

Refer to [AUTHORS.md](../../../AUTHORS.md) and [CREDITS.md](../../../CREDITS.md) files.
