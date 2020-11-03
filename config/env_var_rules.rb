# frozen_string_literal: true

# List of all required environment variables with descriptions.
class EnvVarRules # rubocop:disable Metrics/ClassLength
  OPTIONAL = [
    { DONOTLOGSQL: 'Dev mode: do not log SQL calls' },
    { LOGSQLTOFILE: 'Dev mode: separate SQL calls out of logs and write to file "log/sql.log"' },
    { LOGFULLMESSERVERCALLS: 'Dev mode: Log full payload of HTTP calls to MesServer. Only do this if debugging.' },
    { RUN_FOR_RMD: 'Dev mode: Force the server to act as if it is being called from a Registered Mobile Device' },
    { NO_ERR_HANDLE: 'Dev mode: Do not use the error handling built into the framework. Can be useful to debug without mail sending in the output.' },
    { EMAIL_REQUIRES_REPLY_TO: 'Set to Y if user cannot send email directly. i.e. FROM must be system email, and REPLY-TO will be set to user email.' },
    { DEFAULT_LABEL_DIMENSION: 'User`s preferred label dimension in mm (width then height) e.g. 100x100' },
    { LABEL_SIZES: 'Possible label sizes for designing in format "w,h;w,h;w,h...". e.g. 100,100;100,150;84,64' },
    { FROM_DEPOT: 'Sending Depot for PO out EDIs. Defaults to the value of DEFAULT_DEPOT.' },
    { BASE_PACK_EQUALS_STD_PACK: 'If true, creating a std pack will automatically create a basic pack.' },
    { RPT_INDUSTRY: 'Industry specific reporting folder' },
    { E_CERT_ENVIRONMENT: 'optional. eCert API Environment' },
    { E_CERT_API_CLIENT_ID: 'optional. eCert API  Client ID' },
    { E_CERT_API_CLIENT_SECRET: 'optional. eCert API Secret' },
    { E_CERT_BUSINESS_ID: 'optional. eCert API Business ID' },
    { E_CERT_BUSINESS_NAME: 'optional. eCert API Business Name' },
    { E_CERT_INDUSTRY: 'optional. eCert API Industry' },
    { PHYT_CLEAN_API_USERNAME: 'optional. PhytClean API User Name' },
    { PHYT_CLEAN_API_PASSWORD: 'optional. PhytClean API Password' },
    { PHYT_CLEAN_SEASON_ID: 'optional. PhytClean Standard Data season id' },
    { VAT_FACTOR: 'To calculate vat amounts for the delivery cost invoice report' },
    { MAX_PASSENGER_INSTANCES: 'Number of passenger instance as set in /etc/nginx/conf.d/mod-http-passenger.conf' },
    { ALLOW_OVERFULL_REWORKS_PALLETIZING: 'Reworks Palletizing - If FALSE auto complete pallet if pallets cartons_per_pallet is reached in reworks.' }
  ].freeze

  NO_OVERRIDE = [
    { RACK_ENV: 'This is set to "development" in the .env file and set to "production" by deployment settings.' },
    { APP_CAPTION: 'The application name to display in web pages.' },
    { DATABASE_NAME: 'The name of the database. This is mostly used to derive the test database name.' },
    { QUEUE_NAME: 'The name of the job Que.' }
  ].freeze

  CAN_OVERRIDE = [
    { DATABASE_URL: 'Database connection string in the format "postgres://USER:PASSS@HOST:PORT/DATABASE_NAME".' },
    { IMPLEMENTATION_OWNER: 'The name of the implementation client.' },
    { SHARED_CONFIG_HOST_PORT: 'IP address of shared_config in the format HOST:PORT' },
    { JRUBY_JASPER_HOST_PORT: 'IP address of jruby jasper reporting engine in the format HOST:PORT' },
    { CHRUBY_STRING: 'The version of chruby used in development. Used in Rake tasks.' },
    { PREVIEW_PRINTER_TYPE: 'Which printer type is the default choice for label image previews' }
  ].freeze

  MUST_OVERRIDE = [
    { LABEL_SERVER_URI: 'HTTP address of MesServer in the format http://IP:2080/ NOTE: the trailing "/" is required.' },
    { LABEL_PUBLISH_NOTIFY_URLS: 'HTTP address of the publish notify urls separated by ",". e.g. http://localhost:9296/masterfiles/config/label_templates/published' },
    { JASPER_REPORTING_ENGINE_PATH: 'Full path to dir containing JasperReportPrinter.jar' },
    { JASPER_REPORTS_PATH: "Full path to client's Jasper report definitions." },
    { SYSTEM_MAIL_SENDER: 'Email address for "FROM" address in the format NAME<email>' },
    { ERROR_MAIL_PREFIX: 'Prefix to be placed in subject of emails sent from exceptions.' },
    { ERROR_MAIL_RECIPIENTS: 'Comma-separated list of recipients of exception emails.' },
    { CLIENT_CODE: 'Short, lowercase code to identify the implementation client. Used e.g. in defining per-client behaviour.' },
    { INSTALL_LOCATION: 'A maximum 7-character name for the location - required by EDI transformers' },
    { EDI_NETWORK_ADDRESS: 'Network address for sending EDI documents' },
    { URL_BASE: 'Base URL for this website - in the format http://xxxx' }
  ].freeze

  def print
    puts <<~STR
      -----------------------------
      --- ENVIRONMENT VARIABLES ---
      -----------------------------
      - Certain environment variables are fixed in the .env file.
      - Some of them can be overridden in the .env.local file. These are effectively the client settings.
      - Others are just available to set temporarily when running in development.

      No need to change these variable settings:
      ==========================================
      #{format(NO_OVERRIDE)}

      These variable settings can be changed in .env.local:
      =====================================================
      #{format(CAN_OVERRIDE)}

      These variable settings MUST be changed in .env.local:
      ======================================================
      #{format(MUST_OVERRIDE)}

      These variable settings can be set on the fly in development mode:
      e.g. "NO_ERR_HANDLE=y rackup"
      ==================================================================
      #{format(OPTIONAL)}
    STR
  end

  def list_keys # rubocop:disable Metrics/AbcSize
    (NO_OVERRIDE.map { |a| a.keys.first } + CAN_OVERRIDE.map { |a| a.keys.first } + MUST_OVERRIDE.map { |a| a.keys.first } + OPTIONAL.map { |a| a.keys.first }).sort.join("\n")
  end

  def client_settings # rubocop:disable Metrics/AbcSize
    one_hash = {}
    NO_OVERRIDE.each { |h| one_hash[h.keys.first] = h.values.first }
    CAN_OVERRIDE.each { |h| one_hash[h.keys.first] = h.values.first }
    MUST_OVERRIDE.each { |h| one_hash[h.keys.first] = h.values.first }
    OPTIONAL.each { |h| one_hash[h.keys.first] = h.values.first }
    keys = (NO_OVERRIDE.map { |a| a.keys.first } + CAN_OVERRIDE.map { |a| a.keys.first } + MUST_OVERRIDE.map { |a| a.keys.first } + OPTIONAL.map { |a| a.keys.first }).sort
    ar = []
    keys.each do |key|
      hs = { key: key, env_val: (ENV[key.to_s] || '').gsub(',', ', ') } # rubocop:disable Lint/Env
      description = one_hash[key]
      hs[:key] = %(<span class="fw5 near-black">#{key}</span><br><span class="f6">#{description}</span>)
      hs[:const_val] = AppConst.const_defined?(key) ? AppConst.const_get(key).to_s.gsub(',', ', ') : nil
      ar << hs
    end
    ar
  end

  def root_path
    @root_path ||= File.expand_path('..', __dir__)
  end

  def env_keys
    envs = File.readlines(File.join(root_path, '.env'))
    ar = []
    envs.each { |e| ar << e.split('=').first unless e.strip.start_with?('#') }
    ar
  end

  def local_keys
    envs = File.readlines(File.join(root_path, '.env.local'))
    ar = []
    envs.each { |e| ar << e.split('=').first unless e.strip.start_with?('#') }
    ar
  end

  def existing
    @existing ||= (env_keys + local_keys).uniq
  end

  def format(array)
    array.map { |var| "#{var.keys.first.to_s.ljust(48)} : #{var.values.first}" }.join("\n")
  end

  def validate
    validation_check(NO_OVERRIDE, 'Must be present in ".env"')
    validation_check(CAN_OVERRIDE, 'Must be present in ".env" or ".env.local"')
    validation_check(MUST_OVERRIDE, 'Must be present in ".env.local"')
    puts "\nValidation complete"
  end

  def missing_check(array)
    msg = []
    array.each do |env|
      msg << "- Missing: #{env.keys.first} (#{env.values.first})" unless existing.include?(env.keys.first.to_s)
    end
    msg
  end

  def validation_check(array, desc)
    msg = missing_check(array)
    puts msg.empty? ? "#{desc} - OK" : desc
    puts msg.join("\n") unless msg.empty?
  end

  def add_missing_to_local
    to_add = []
    MUST_OVERRIDE.each do |env|
      k = env.keys.first.to_s
      v = env.values.first
      unless local_keys.include?(k)
        to_add << "# #{k}=#{v}\n"
        puts "Adding: #{k} (#{v})"
      end
    end

    update_local_file(to_add) unless to_add.empty?
  end

  def update_local_file(to_add)
    File.open(File.join(root_path, '.env.local'), 'a') { |f| to_add.each { |a| f << a } }
    puts "\nUpdated \".env.local\" - please modify (current contents are shown here):\n\n"
    puts File.read(File.join(root_path, '.env.local'))
  end
end
