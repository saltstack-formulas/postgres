{% from "postgres/map.jinja" import postgres with context %}

postgresql-python:
  pkg.installed:
    - name: {{ postgres.pkg_python}}
  {% if postgres.fromrepo %}
    - fromrepo: {{ postgres.fromrepo }}
  {% endif %}
  {% if postgres.use_upstream_repo == true %}
    - refresh: True
    - require:
      - pkgrepo: postgresql-repo

include:
  - postgres.upstream
  {% endif %}
