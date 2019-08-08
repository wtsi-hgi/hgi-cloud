Role Name
=========

This roles clean up the freshly provisioned instance or image of any downloaded
or unwanted files.

Dependencies
------------

Refer to the [metadata](meta/main.yml).

Example Playbook
----------------

```yaml
    - hosts: localhost
      roles:
         - { role: cleanup-base }
```

License
-------

BSD

Author Information
------------------

Refer to [AUTHORS.md](../../../AUTHORS.md) and [CREDITS.md](../../../CREDITS.md) files.
