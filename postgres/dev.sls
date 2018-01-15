{% from "postgres/map.jinja" import postgres with context %}

{% if grains.os not in ('Windows', 'MacOS',) %}

  {% if postgres.pkg_dev %}
install-postgres-dev-package:
  pkg.installed:
    - name: {{ postgres.pkg_dev }}
  {% endif %}

  {% if postgres.pkg_libpq_dev %}
install-postgres-libpq-dev:
  pkg.installed:
    - name: {{ postgres.pkg_libpq_dev }}
  {% endif %}

{% endif %}


{% if grains.os == 'MacOS' %}

  # Darwin maxfiles limits
  {% if postgres.limits.soft or postgres.limits.hard %}

postgres_maxfiles_limits_conf:
  file.managed:
    - name: /Library/LaunchDaemons/limit.maxfiles.plist
    - source: salt://postgres/templates/limit.maxfiles.plist
    - context:
      soft_limit: {{ postgres.limits.soft or postgres.limits.hard }}
      hard_limit: {{ postgres.limits.hard or postgres.limits.soft }}
    - group: wheel
  {% endif %}

  # MacOS Shortcut for system user
  {% if postgres.systemuser|lower not in (None, '',) %}

postgres-desktop-shortcut-clean:
  file.absent:
    - name: '{{ postgres.userhomes }}/{{ postgres.systemuser }}/Desktop/postgres'
    - require_in:
      - file: postgres-desktop-shortcut-add

  {% endif %}

postgres-desktop-shortcut-add:
  file.managed:
    - name: /tmp/mac_shortcut.sh
    - source: salt://postgres/templates/mac_shortcut.sh
    - mode: 755
    - template: jinja
    - context:
      user: {{ postgres.systemuser }}
      homes: {{ postgres.userhomes }}
  cmd.run:
    - name: /tmp/mac_shortcut.sh {{ postgres.use_upstream_repo }}
    - runas: {{ postgres.systemuser }}
    - require:
      - file: postgres-desktop-shortcut-add

{% endif %}
