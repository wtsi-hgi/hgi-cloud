Role Name
=========

This role installs Anaconda's python distribution and configures users' shell
environment.

Role Variables
--------------

* **anaconda\_python\_version**  
  The python version of the Anaconda distribution
* **anaconda\_distribution**  
  The version of the Anaconda distribution
* **anaconda\_mirror**  
  The URL of the mirror from which to download the Anaconda distribution
* **anaconda\_download\_dir**  
  The directory to download the Anaconda distribution to
* **anaconda\_install\_dir**  
  The directory in which to install the Anaconda distribution
* **anaconda\_install\_owner**  
  The user owning the Anaconda distribution files
* **anaconda\_install\_group**  
  The group owning the Anaconda distribution files
* **anaconda\_install\_mode**  
  The Anaconda distribution files' mode

Dependencies
------------

Refer to the [metadata](meta/main.yml).

Example Playbook
----------------

```yaml
    - hosts: localhost
      roles:
         - { role: anaconda-base }
```

License
-------

BSD

Author Information
------------------

Refer to [AUTHORS.md](../../../AUTHORS.md) and [CREDITS.md](../../../CREDITS.md) files.
