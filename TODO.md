In proposed order
* (v0.1.0) Cleanup the use of metadata and extra data in `user_data`
* (v0.2.0) Attach a persistent volume to jupyter data directory
* (v0.3.0) Attach a volatile volume to Hail `tmp_dir` on the master
  * Investigate usage and performances, explore other options
    (requires proper monitoring)
* (v0.4.0) Auto register hail master to infoblox
* (v0.5.0) Backup / Restore (to S3?) Jupyter data files outside git
* (v0.6.0) Review / improve testing and documentation
* (v0.7.0) Create swap partition by resizing the OS boot volume, and use tmpfs
* (v0.8.0) Update `user_data` from script to `cloud-init`
* Harden spark (random password)
  * (v0.9.0) encryption of connections
  * (v0.10.0) encryption of data at rest
* Harden jupyter (user-provided password)
  * (v0.11.0) HTTPS
  * (v0.12.0) encryption of persistent volume
* (v0.13.0) Review / improve testing and documentation
* (v1.0.0) Review / improve tasks automation
