require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter
      alias_method :old_execute, :execute
      alias_method :old_reconnect!, :reconnect!
      alias_method :old_connect, :connect

      PG_SLEEP_RETRY = ENV['PG_SLEEP_RETRY'].to_f || 0.33
      PG_QUERY_RETRY = ENV['PG_QUERY_RETRY'].to_i || 0
      PG_RECONNECT_RETRY = ENV['PG_RECONNECT_RETRY'].to_i || 0
      PG_CONNECT_RETRY = ENV['PG_CONNECT_RETRY'].to_i || 0

      def execute(sql, name=nil)
        begin
          result = old_execute(sql, name)
          @retry = nil
          result
        rescue PG::ConnectionBad, PG::UnableToSend => ex
          @retry ||= 1
          $log.warn "PostgreSQL statement invalid, retrying #{sql}: #{ex}"
          sleep PG_SLEEP_RETRY
          @retry += 1
          raise if @retry > PG_QUERY_RETRY
        end

        if @retry.nil?
          result
        else
          execute(sql, name)
        end

      end

      def reconnect!
        begin
          result = old_reconnect!
          @retry = nil
          result
        rescue PG::Error => ex
          @retry ||= 1
          $log.warn "PostgreSQL reconnect not possible, retry ##{@retry}: #{ex}"
          sleep PG_SLEEP_RETRY
          @retry += 1
          raise if @retry > PG_RECONNECT_RETRY
        end

        if @retry.nil?
          result
        else
          reconnect!
        end

      end

      def connect

        begin
          result = old_connect
          @retry = nil
          result
        rescue PG::Error => ex
          @retry ||= 1
          $log.warn "PostgreSQL connect not possible, retry ##{@retry}: #{ex}"
          sleep PG_SLEEP_RETRY
          @retry += 1
          raise if @retry > PG_CONNECT_RETRY
        end

        if @retry.nil?
          result
        else
          connect
        end

      end
    end
  end
end