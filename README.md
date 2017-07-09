# Docker Remote Development Environment

This Docker image is a full Debian Linux environment running [GoTTY](https://github.com/yudai/gotty), which allows you to access a TTY inside the container from your web browser.

# Usage
```bash
docker run -p 8080:8080 richardcarls/remotedev
```
A GoTTY instance is available on port 8080 running `/bin/login` by default. Check the container log for the generated root password to login.

### Run as user
```bash
docker run -e LOGIN_UID=`id myuser -u` -p 8080:8080 richardcarls/remotedev
```
By specifying `LOGIN_UID`, the init script creates a user in the container for login. The `sudo` command is available inside the container and the user is automatically added to the `sudo` group. The default user name `dev` can be overriden with `-e LOGIN_NAME`.

### Mounting home directory
```bash
docker run -v /some/host/directory:/userdata -p 8080:8080 richardcarls/remotedev
```
`/userdata` is symlinked to the container user's `$HOME` (or `/root` if running as root). If `LOGIN_UID` is not specified, *the uid of the mounted host directory is used to create the login user*. The init script does not modify permissions on this folder so it should be safe to mount your local home directory.

### Configure GoTTY
By default, gotty runs `/bin/login` and reads default options from a provided `.gotty` configuration file i /userdata. The default config allows browser client write (`--permit-write`) and reconnect (`--reconnect`, `--reconnect-timeout=10`). You may override these and supply other gotty options via docker command, environemnt variables, or a custom `.gotty` config in your mounted /userdata directory.

### Included packages
- `emacs-nox`
- `git`
- `openssh-client`
- `tmux`
- `wget`
