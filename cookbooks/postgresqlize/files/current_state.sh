#!/usr/bin/env bash

query=$(cat <<EOF
select
  case
    when pg_is_in_recovery() then 'replica'
    when not pg_is_in_recovery() then 'master'
  end;
EOF
)

psql -c "${query}"
