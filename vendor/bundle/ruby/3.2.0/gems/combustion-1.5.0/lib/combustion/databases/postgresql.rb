# frozen_string_literal: true

class Combustion::Databases::PostgreSQL < Combustion::Databases::Base
  def reset
    if Combustion::VersionGate.call("activerecord", ">= 7.1.0.alpha")
      base.connection_handler.clear_active_connections!
    else
      base.clear_active_connections!
    end

    establish_connection(postgres_configuration)

    super
  end

  private

  def create
    connection.create_database(
      configuration[:database],
      configuration.merge(:encoding => encoding)
    )
  rescue StandardError => error
    warn error, *error.backtrace
    warn "Couldn't create database for #{configuration.inspect}"
  end

  def drop
    connection.drop_database(configuration[:database])
  end

  def encoding
    configuration[:encoding] || ENV["CHARSET"] || "utf8"
  end

  def postgres_configuration
    configuration.merge(
      :database           => "postgres",
      :schema_search_path => schema_search_path
    )
  end

  def schema_search_path
    configuration[:adapter][/postgis/] ? "public, postgis" : "public"
  end
end
