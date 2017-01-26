require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      alias_method :old_exec_cache, :exec_cache
      alias_method :old_exec_no_cache, :exec_no_cache
      alias_method :old_execute, :execute
      alias_method :old_reconnect!, :reconnect!
      alias_method :old_connect, :connect
      alias_method :old_transaction, :transaction

      PG_SLEEP_RETRY = ENV['PG_SLEEP_RETRY'].to_f || 0.33
      PG_QUERY_RETRY = ENV['PG_QUERY_RETRY'].to_i || 0

      def exec_no_cache(sql, name, binds)
        with_retry { old_exec_no_cache(sql, name, binds) }
      end

      def exec_cache(sql, name, binds)
        with_retry { old_exec_cache(sql, name, binds) }
      end

      def execute(sql, name = nil)
        with_retry { old_execute(sql, name) }
      end

      def reconnect!
        with_retry { old_reconnect! }
      end

      def connect
        with_retry { old_connect }
      end

      def transaction(options = {}, &block)
        with_retry { old_transaction(options = {}, &block) }
      end

      def with_retry
        retry_count = 0

        begin
          yield
        rescue PG::ConnectionBad, PG::UnableToSend, ActiveRecord::StatementInvalid => ex
          raise if open_transactions != 0
          raise if retry_count >= PG_QUERY_RETRY
          raise if ex.is_a?(ActiveRecord::StatementInvalid) unless (
            ex.original_exception.is_a?(PG::ConnectionBad) ||
            ex.original_exception.is_a?(PG::UnableToSend)
          )

          sleep PG_SLEEP_RETRY
          retry_count += 1
          $log.warn "PostgreSQL retry ##{retry_count} '#{defined?(sql) ? sql : ''}' because #{ex}"
          reconnect!
          retry
        end

      end

    end
  end
end
