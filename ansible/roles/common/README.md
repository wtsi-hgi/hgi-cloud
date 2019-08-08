Role Name
=========

This role performs common, pre-configuration of instances, including the
creation of `swap` and `tmpfs` filesystems.

Role Variables
--------------

* **collectd\_interval**  
  Polling interval configuration for `collectd`
* **collectd\_load\_plugins**  
  List of collectd plugins to activate
* **authorized\_keys\_path**  
  Path to the admin user `authorized_keys` files
* **authorized\_keys**  
  List of extra authorized keys for the admin user.

Dependencies
------------

Refer to the [metadata](meta/main.yml).

Example Playbook
----------------

```yaml
    - hosts: localhost
      roles:
         - { role: common }
```

License
-------

BSD

Author Information
------------------

Refer to [AUTHORS.md](../../../AUTHORS.md) and [CREDITS.md](../../../CREDITS.md) files.
