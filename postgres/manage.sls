{%- from "postgres/map.jinja" import postgres with context -%}
{%- from "postgres/macros.jinja" import format_state with context -%}

{%- if salt['postgres.user_create']|default(none) is not callable %}

# Salt states for managing PostgreSQL is not available,
# need to provision client binaries first

include:
  - postgres.client
  {%- if 'server_bins' in postgres and grains['saltversion'] == '2016.11.0' %}
  # FIXME: Salt v2016.11.0 bug https://github.com/saltstack/salt/issues/37935
  - postgres.server
  {%- endif %}

{%- endif %}

# Ensure that Salt is able to use postgres modules

postgres-reload-modules:
  test.nop:
    - reload_modules: True

# User states

{%- for key, user in postgres.users|dictsort() %}

{{ format_state(user.name or key, 'postgres_user', user) }}
    - require:
      - test: postgres-reload-modules

{%- endfor %}

# Tablespace states

{%- for key, tblspace in postgres.tablespaces|dictsort() %}

{{ format_state(tblspace.name or key, 'postgres_tablespace', tblspace) }}
    - require:
      - test: postgres-reload-modules
  {%- if 'owner' in tblspace %}
      - postgres_user: postgres_user-{{ tblspace.owner }}
  {%- endif %}

{%- endfor %}

# Database states

{%- for key, db in postgres.databases|dictsort() %}

{{ format_state(db.name or key, 'postgres_database', db) }}
    - require:
      - test: postgres-reload-modules
  {%- if 'owner' in db %}
      - postgres_user: postgres_user-{{ db.owner }}
  {%- endif %}
  {%- if 'tablespace' in db %}
      - postgres_tablespace: postgres_tablespace-{{ db.tablespace }}
  {%- endif %}

{%- endfor %}

# Schema states

{%- for key, schema in postgres.schemas|dictsort() %}

{{ format_state(schema.name or key, 'postgres_schema', schema) }}
    - require:
      - test: postgres-reload-modules
  {%- if 'owner' in schema %}
      - postgres_user: postgres_user-{{ schema.owner }}
  {%- endif %}

{%- endfor %}

# Extension states

{%- for key, extension in postgres.extensions|dictsort() %}

{{ format_state(extension.name or key, 'postgres_extension', extension) }}
    - require:
      - test: postgres-reload-modules
  {%- if 'maintenance_db' in extension %}
      - postgres_database: postgres_database-{{ extension.maintenance_db }}
  {%- endif %}
  {%- if 'schema' in extension %}
      - postgres_schema: postgres_schema-{{ extension.schema }}
  {%- endif %}

{%- endfor %}
