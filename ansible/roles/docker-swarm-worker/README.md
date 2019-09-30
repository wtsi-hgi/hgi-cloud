Role Name
=========

This role provision a docker swarm worker.

Dependencies
------------

Refer to the [metadata](meta/main.yml).

Example Playbook
----------------

```yaml
    - hosts: localhost
      roles:
         - { role: docker-swarm-worker }
```

License
-------

BSD

Author Information
------------------

Refer to [AUTHORS.md](../../../AUTHORS.md) and [CREDITS.md](../../../CREDITS.md) files.
