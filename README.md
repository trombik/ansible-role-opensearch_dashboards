# `trombik.opensearch_dashboards`

Manages `opensearch-dashboards`.

Note that the latest `opensearch-dashboards` (1.1.0 as of this writing) has
`nodejs` version 10.x and several outdated, vulnerable `nodejs` modules.
See [Issue 835](https://github.com/opensearch-project/OpenSearch-Dashboards/issues/835)
for more details. Generally, you should not use `openseach-dashboards` in
production until the upstream releases a newer, fixed version. If this is your
concern, use `elasticsearch` and `kibana` instead.

## For FreeBSD users

The package in the official FreeBSD ports tree (1.1.0 as of this writing) is
broken. See
[bug 259330](https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=259330) for
more details. The role requires my own port, which can be found at
[trombik/freebsd-ports-opensearch](https://github.com/trombik/freebsd-ports-opensearch).
The port depends on old, deprecated `node10`. `node10` has been removed from
the ports tree. As a result, my repository includes changes to `node` ports,
reviving `node10`. In short, do not use it unless you know what you are doing.

## For Debian users

The role installs `opensearch-dashboards` from the official tar archive. This
is a huge hack until when Amazon or distributions release packages.

Changes from the default includes:

* the configuration directory is `/etc/opensearch-dashboards`
* log file is under `/var/log/opensearch-dashboards`
* `path.data` is `/var/lib/opensearch-dashboards`
* the application is installed under `/var/www/opensearch-dashboards`
* the user to run the application is `www-data`

The changes will be updated when an official package is available.

The role downloads the official tar archive under
`opensearch_dashboards_src_dir`. The default is `/var/dist` The directory is
not just a cache directory. In addition to the tar file, it has a PGP key, a
signature file , and files to control `ansible` tasks.

The role installs a `systemd` unit file for `opensearch-dashboards`. The
author is not an expert of `systemd` in any way.

# Requirements

None

# Role Variables

| variable | description | default |
|----------|-------------|---------|


# Dependencies

None

# Example Playbook

```yaml
---
- hosts: localhost
  roles:
    - ansible-role-opensearch_dashboards
  vars:
    opensearch_dashboards_config:
      server.host: "{{ opensearch_dashboards_bind_address }}"
      server.port: "{{ opensearch_dashboards_bind_port }}"
      path.data: "{{ opensearch_dashboards_data_dir }}"
      opensearch.hosts: ["http://localhost:9200"]
      opensearch.ssl.verificationMode: none
      opensearch.username: "kibanaserver"
      opensearch.password: "kibanaserver"
      opensearch.requestHeadersWhitelist:
        - authorization,securitytenant
      opensearch_security.multitenancy.enabled: true
      opensearch_security.multitenancy.tenants.preferred: ["Private", "Global"]
      opensearch_security.readonly_mode.roles: ["kibana_read_only"]
      # Use this setting if you are running kibana without https
      opensearch_security.cookie.secure: false
```

# License

```
Copyright (c) 2021 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
