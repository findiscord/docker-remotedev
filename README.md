# Docker Remote Development Environment

This Docker image is a full Debian Linux environment running [GoTTY](https://github.com/yudai/gotty), which allows you to access a TTY inside the container from your web browser.

# Usage
```bash
docker run richardcarls/remotedev
```
A GoTTY instance is available on port 8080 running `/bin/login` by default. Check the container log for the generated root password to login.

### Run as user
```bash
docker run -e LOGIN_USER=myuser -e LOGIN_UID=`id myuser -u` richardcarls/remotedev
```
By specifying either `LOGIN_NAME` or `LOGIN_UID`, the init script creates a user to run GoTTY. The `sudo` command is available inside the container and the user is automatically added to the `sudo` group. If no login name is specified, it defaults to `dev`. A uid of `500` is used unless specified.

### Mounting home directory
```bash
docker run --user hostuser -v /some/host/directory:/userdata richardcarls/remotedev
```
`/userdata` is symlinked to the container user's `$HOME` (or `/root` if running as root). Note that permissions of the mounted directory are not modified during init, so use an appropriate login uid or modify the permissions on the host directory and files. Also note that only login uid needs to match for folder and file permissions.

### Configure GoTTY
By default, `gotty` runs with `--permit-write` and `--reconnect` options. See [the GoTTY README](https://github.com/yudai/gotty) for all the configuration options, which can be specified on the docker command, a `.gotty.conf` file in a mounted volume to the user home, or through environment variables.

### Included packages
- `emacs-nox`
- `git`
- `openssh-client`
- `tmux`
- `wget`
