Role Name
=========

This role installs and configure the base image. This role is at the base of
any image built within this system.

Role Variables
--------------

* **base\_user\_name**  
  The username for the base user. This should be an unprivileged,
  application-user.
* **base\_user\_uid**  
  The `UID` of the base user.
* **base\_user\_home**  
  The path to the base user's home directory.
* **base\_user\_groups**  
  A list of groups the user sould be part of. This list should be made of
  dictionaries with the following keys:
  * **name**  
    The name of the group
  * **gid**
    The `GID` of the group (in case it has to be created)
* **base\_user\_shell**  
  The shell of the base user.
* **base\_group\_name**  
  The primary group of the base user.
* **base\_group\_gid**  
  The `GID` of the promary group of the base user.
* **base\_source\_dir**  
  The path to the main source directory.
* **base\_download\_dir**  
  The path to the main download directory.
* **base\_bin\_dir**  
  The path to the base user `bin` directory.

Dependencies
------------

Refer to the [metadata](meta/main.yml).

Example Playbook
----------------

```yaml
    - hosts: localhost
      roles:
         - { role: base }
```

License
-------

BSD

Author Information
------------------

Refer to [AUTHORS.md](../../../AUTHORS.md) and [CREDITS.md](../../../CREDITS.md) files.
