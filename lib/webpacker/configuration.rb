require "yaml"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/hash/indifferent_access"

class Webpacker::Configuration
  attr_reader :root_path, :config_path, :env

  def initialize(root_path:, config_path:, env:)
    @root_path = root_path
    @config_path = config_path
    @env = env
  end

  def dev_server
    fetch(:dev_server)
  end

  def compile?
    fetch(:compile)
  end

  def source_path
    root_path.join(fetch(:source_path))
  end

  def resolved_paths
    fetch(:resolved_paths)
  end

  def resolved_paths_globbed
    resolved_paths.map { |p| "#{p}/**/*" }
  end

  def source_entry_path
    source_path.join(fetch(:source_entry_path))
  end

  def public_path
    root_path.join(fetch(:public_root_path))
  end

  def public_output_path
    public_path.join(fetch(:public_output_path))
  end

  def public_manifest_path
    public_output_path.join("manifest.json")
  end

  def cache_manifest?
    fetch(:cache_manifest)
  end

  def cache_path
    root_path.join(fetch(:cache_path))
  end

  def extensions
    fetch(:extensions)
  end

  def check_yarn_integrity=(value)
    data[:check_yarn_integrity] = value
  end

  def check_yarn_integrity?
    fetch(:check_yarn_integrity)
  end

  def webpack_compile_output?
    fetch(:webpack_compile_output)
  end

  def extract_css?
    fetch(:extract_css)
  end

  private
    def fetch(key)
      data.fetch(key, defaults[key])
    end

    def data
      @data ||= load
    end

    def load
      config = begin
        YAML.load_file(config_path.to_s, aliases: true)
      rescue ArgumentError
        YAML.load_file(config_path.to_s)
      end
      config[env].deep_symbolize_keys
    rescue Errno::ENOENT => e
      raise "Webpacker configuration file not found #{config_path}. " \
            "Please run rails webpacker:install " \
            "Error: #{e.message}"

    rescue Psych::SyntaxError => e
      raise "YAML syntax error occurred while parsing #{config_path}. " \
            "Please note that YAML must be consistently indented using spaces. Tabs are not allowed. " \
            "Error: #{e.message}"
    end

    def defaults
      @defaults ||= begin
        path = File.expand_path("../../install/config/webpacker.yml", __FILE__)
        config = begin
          YAML.load_file(path, aliases: true)
        rescue ArgumentError
          YAML.load_file(path)
        end
        HashWithIndifferentAccess.new(config[env])
      end
    end
end
