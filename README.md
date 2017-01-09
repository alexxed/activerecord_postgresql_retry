# active_record_postgresql_retry
This gem provides a patch that once included will retry the PostgreSQL operation in case the server has gone away

1. add it to your Gemfile
2. declare the following environment variables
- PG_SLEEP_RETRY, default 0.33 seconds
- PG_QUERY_RETRY, default 0
- PG_RECONNECT_RETRY, default 0
- PG_CONNECT_RETRY, default 0

