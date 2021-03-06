# frozen_string_literal: true

# A class for defining global constants in a central place.
class AppConst # rubocop:disable Metrics/ClassLength
  def self.development?
    ENV['RACK_ENV'] == 'development'
  end

  # Any value that starts with y, Y, t or T is considered true.
  # All else is false.
  def self.check_true(val)
    val.match?(/^[TtYy]/)
  end

  # Take an environment variable and interpret it
  # as a boolean.
  def self.make_boolean(key, required: false)
    val = if required
            ENV.fetch(key)
          else
            ENV.fetch(key, 'f')
          end
    check_true(val)
  end

  # Helper to create hash of label sizes from a 2D array.
  def self.make_label_size_hash(array)
    Hash[array.map { |w, h| ["#{w}x#{h}", { 'width': w, 'height': h }] }].freeze
  end

  # Client-specific code
  CLIENT_CODE = ENV.fetch('CLIENT_CODE')
  raise 'CLIENT_CODE must be lowercase.' unless CLIENT_CODE == CLIENT_CODE.downcase

  IMPLEMENTATION_OWNER = ENV.fetch('IMPLEMENTATION_OWNER')
  SHOW_DB_NAME = ENV.fetch('DATABASE_URL').rpartition('@').last
  URL_BASE = ENV.fetch('URL_BASE')
  APP_CAPTION = ENV.fetch('APP_CAPTION')

  # labeling cached setup data path
  LABELING_CACHED_DATA_FILEPATH = File.expand_path('../tmp/run_cache', __dir__)

  # Reworks
  ALLOW_OVERFULL_REWORKS_PALLETIZING = make_boolean('ALLOW_OVERFULL_REWORKS_PALLETIZING')

  # General
  DEFAULT_KEY = 'DEFAULT'

  # Production Runs
  ALLOW_CULTIVAR_GROUP_MIXING = make_boolean('ALLOW_CULTIVAR_GROUP_MIXING')

  VAT_FACTOR = ENV['VAT_FACTOR']

  # Constants for pallet statuses:
  PALLETIZED_NEW_PALLET = 'PALLETIZED_NEW_PALLET'
  RW_PALLET_SINGLE_EDIT = 'RW_PALLET_SINGLE_EDIT'
  RW_PALLET_BATCH_EDIT = 'RW_PALLET_BATCH_EDIT'
  PALLETIZED_SEQUENCE_ADDED = 'PALLETIZED_SEQUENCE_ADDED'
  PALLETIZED_SEQUENCE_REPLACED = 'PALLETIZED_SEQUENCE_REPLACED'
  PALLETIZED_SEQUENCE_UPDATED = 'PALLETIZED_SEQUENCE_UPDATED'
  PALLET_WEIGHED = 'PALLET WEIGHED'
  PALLET_MOVED = 'PALLET_MOVED'
  PALLET_SCRAPPED = 'PALLET SCRAPPED'
  PALLET_UNSCRAPPED = 'PALLET UNSCRAPPED'
  PALLETIZING = 'PALLETIZING'
  SEQUENCE_REMOVED_BY_CTN_TRANSFER = 'SEQUENCE_REMOVED_BY_CTN_TRANSFER'
  SCRAPPED_BY_BUILDUP = 'SCRAPPED_BY_BUILDUP'

  # Constants for stock types:
  PALLET_STOCK_TYPE = 'PALLET'
  BIN_STOCK_TYPE = 'BIN'

  # Constants for pallet build statuses:
  PALLET_FULL_BUILD_STATUS = 'FULL'

  PRINT_PALLET_LABEL_AT_PALLET_VERIFICATION = make_boolean('PRINT_PALLET_LABEL_AT_PALLET_VERIFICATION')

  # Constants for pallets exit_ref
  PALLET_EXIT_REF_SCRAPPED = 'SCRAPPED'
  PALLET_EXIT_REF_SCRAPPED_BY_BUILDUP = 'SCRAPPED_BY_BUILDUP'
  PALLET_EXIT_REF_REMOVED = 'REMOVED'
  PALLET_EXIT_REF_REPACKED = 'REPACKED'

  # Constants for roles:
  ROLE_IMPLEMENTATION_OWNER = 'IMPLEMENTATION_OWNER'
  ROLE_CUSTOMER = 'CUSTOMER'
  ROLE_SUPPLIER = 'SUPPLIER'
  ROLE_MARKETER = 'MARKETER'
  ROLE_FARM_OWNER = 'FARM_OWNER'
  ROLE_SHIPPING_LINE = 'SHIPPING_LINE'
  ROLE_SHIPPER = 'SHIPPER'
  ROLE_FINAL_RECEIVER = 'FINAL_RECEIVER'
  ROLE_EXPORTER = 'EXPORTER'
  ROLE_BILLING_CLIENT = 'BILLING_CLIENT'
  ROLE_CONSIGNEE = 'CONSIGNEE'
  ROLE_HAULIER = 'HAULIER'
  ROLE_FARM_MANAGER = 'FARM_MANAGER'

  # Target Market Type: 'PACKED'
  PACKED_TM_GROUP = 'PACKED'

  # Defaults for Packaging
  BASE_PACK_EQUALS_STD_PACK = make_boolean('BASE_PACK_EQUALS_STD_PACK')

  # Default UOM TYPE
  UOM_TYPE = 'INVENTORY'

  # Routes that do not require login:
  BYPASS_LOGIN_ROUTES = [
    '/masterfiles/config/label_templates/published',
    '/messcada/.*',
    '/dashboard/.*'
  ].freeze

  # Menu
  FUNCTIONAL_AREA_RMD = 'RMD'

  # Logging
  FIELDS_TO_EXCLUDE_FROM_DIFF = %w[label_json png_image].freeze

  # MesServer
  LABEL_SERVER_URI = ENV.fetch('LABEL_SERVER_URI')
  POST_FORM_BOUNDARY = 'AaB03x'

  # Labels
  SHARED_CONFIG_HOST_PORT = ENV.fetch('SHARED_CONFIG_HOST_PORT')
  LABEL_VARIABLE_SETS = ENV.fetch('LABEL_VARIABLE_SETS').strip.split(',')
  LABEL_PUBLISH_NOTIFY_URLS = ENV.fetch('LABEL_PUBLISH_NOTIFY_URLS', '').split(',')
  BATCH_PRINT_MAX_LABELS = ENV.fetch('BATCH_PRINT_MAX_LABELS', 20).to_i
  PREVIEW_PRINTER_TYPE = ENV.fetch('PREVIEW_PRINTER_TYPE', 'zebra')

  # Label sizes. The arrays contain width then height.
  DEFAULT_LABEL_DIMENSION = ENV.fetch('DEFAULT_LABEL_DIMENSION', '84x64')
  LABEL_SIZES = if ENV['LABEL_SIZES']
                  AppConst.make_label_size_hash(ENV['LABEL_SIZES'].split(';').map { |s| s.split(',') })
                else
                  AppConst.make_label_size_hash(
                    [
                      [84,   64], [84,  100], [97,   78], [78,   97], [77,  130], [100,  70],
                      [100,  84], [100, 100], [105, 250], [130, 100], [145,  50], [100, 150]
                    ]
                  )
                end

  # Printers
  PRINTER_USE_INDUSTRIAL = 'INDUSTRIAL'
  PRINTER_USE_OFFICE = 'OFFICE'

  PRINT_APP_LOCATION = 'Location'
  PRINT_APP_BIN = 'Bin'
  PRINT_APP_CARTON = 'Carton'
  PRINT_APP_PALLET = 'Pallet'

  PRINTER_APPLICATIONS = [
    PRINT_APP_LOCATION,
    PRINT_APP_BIN,
    PRINT_APP_CARTON,
    PRINT_APP_PALLET
  ].freeze

  # These will need to be configured per installation...
  BARCODE_PRINT_RULES = {
    location: { format: 'LC%d', fields: [:id] },
    # sku: { format: 'SK%d', fields: [:sku_number] },
    # delivery: { format: 'DN%d', fields: [:delivery_number] },
    bin: { format: 'BN%d', fields: [:id] }
  }.freeze

  BARCODE_SCAN_RULES = [
    { regex: '^LC(\\d+)$', type: 'location', field: 'id' },
    # { regex: '^(\\D\\D\\D)$', type: 'location', field: 'location_short_code' },
    # { regex: '^(\\D\\D\\D)$', type: 'dummy', field: 'code' },
    # { regex: '^SK(\\d+)', type: 'sku', field: 'sku_number' },
    { regex: '^DN(\\d+)', type: 'delivery', field: 'delivery_number' },
    { regex: '^BN(\\d+)', type: 'bin', field: 'id' },
    { regex: '^(\\d+)', type: 'pallet_number', field: 'pallet_number' },
    { regex: '^(\\d+)', type: 'carton_label_id', field: 'id' },
    # { regex: '^SK(\\d+)', type: 'bin_asset', field: 'bin_asset_number' }, # asset no should change to string and this should not require SK.
    { regex: '^([A-Z0-9]+)', type: 'bin_asset', field: 'bin_asset_number' }, # asset no should change to string and this should not require SK.
    { regex: '^(\\d+)', type: 'load', field: 'id' },
    { regex: '^(\\d+)', type: 'vehicle_job', field: 'id' }
  ].freeze

  # Per scan type, per field, set attributes for displaying a lookup value below a scan field.
  # The key matches a key in BARCODE_PRINT_RULES. (e.g. :location)
  # The hash for that key is keyed by the value of the BARCODE_SCAN_RULES :field. (e.g. :id)
  # The rules for that field are: the table to read, the field to match the scanned value and the field to display in the form.
  # If a join is required, specify join: table_name and on: Hash of field on source table: field on target table.
  BARCODE_LOOKUP_RULES = {
    location: {
      id: { table: :locations, field: :id, show_field: :location_long_code },
      location_short_code: { table: :locations, field: :location_short_code, show_field: :location_long_code }
    },
    sku: {
      sku_number: { table: :mr_skus,
                    field: :sku_number,
                    show_field: :product_variant_code,
                    join: :material_resource_product_variants,
                    on: { id: :mr_product_variant_id } }
    }
  }.freeze

  # Que
  QUEUE_NAME = ENV.fetch('QUEUE_NAME', 'default')

  # Mail
  ERROR_MAIL_RECIPIENTS = ENV.fetch('ERROR_MAIL_RECIPIENTS')
  ERROR_MAIL_PREFIX = ENV.fetch('ERROR_MAIL_PREFIX')
  SYSTEM_MAIL_SENDER = ENV.fetch('SYSTEM_MAIL_SENDER')
  EMAIL_REQUIRES_REPLY_TO = make_boolean('EMAIL_REQUIRES_REPLY_TO')
  EMAIL_GROUP_LABEL_APPROVERS = 'label_approvers'
  EMAIL_GROUP_LABEL_PUBLISHERS = 'label_publishers'
  EMAIL_GROUP_EDI_NOTIFIERS = 'edi_notifiers'
  USER_EMAIL_GROUPS = [EMAIL_GROUP_LABEL_APPROVERS, EMAIL_GROUP_LABEL_PUBLISHERS, EMAIL_GROUP_EDI_NOTIFIERS].freeze

  # Business Processes
  # PROCESS_DELIVERIES = 'DELIVERIES'
  # PROCESS_VEHICLE_JOBS = 'VEHICLE JOBS'
  # PROCESS_BULK_STOCK_ADJUSTMENTS = 'BULK STOCK ADJUSTMENTS'
  PROCESS_ADHOC_TRANSACTIONS = 'ADHOC_TRANSACTIONS'
  PROCESS_RECEIVE_EMPTY_BINS = 'RECEIVE_EMPTY_BINS'
  PROCESS_ISSUE_EMPTY_BINS = 'ISSUE_EMPTY_BINS'

  # Storage Types
  STORAGE_TYPE_PALLETS = 'PALLETS'

  # Locations: Location Types
  # LOCATION_TYPES_WAREHOUSE = 'WAREHOUSE'
  # LOCATION_TYPES_RECEIVING_BAY = 'RECEIVING BAY'
  # LOCATION_TYPES_COLD_BAY_DECK = ENV.fetch('LOCATION_TYPES_COLD_BAY_DECK', 'DECK')
  # LOCATION_TYPES_EMPTY_BIN = 'EMPTY_BIN'
  INSTALL_LOCATION = ENV.fetch('INSTALL_LOCATION')
  raise "Install location #{INSTALL_LOCATION} cannot be more than 7 characters in length" if INSTALL_LOCATION.length > 7

  # Loads:
  # DEFAULT_EXPORTER = ENV['DEFAULT_EXPORTER']
  # DEFAULT_INSPECTION_BILLING = ENV['DEFAULT_INSPECTION_BILLING']
  # DEFAULT_DEPOT = ENV['DEFAULT_DEPOT']
  FROM_DEPOT = ENV['FROM_DEPOT'] # || DEFAULT_DEPOT
  # IN_TRANSIT_LOCATION = 'IN_TRANSIT_EX_PACKHSE'
  SCRAP_LOCATION = 'SCRAP_PACKHSE'
  UNSCRAP_LOCATION = 'UNSCRAP_PACKHSE'
  UNTIP_LOCATION = 'UNTIPPED_BIN'
  # VGM_REQUIRED = make_boolean('VGM_REQUIRED')
  # MAX_PALLETS_ON_LOAD = ENV['MAX_PALLETS_ON_LOAD'] || 50
  # TEMP_TAIL_REQUIRED_TO_SHIP = make_boolean('TEMP_TAIL_REQUIRED_TO_SHIP')
  # Constants for port types:
  PORT_TYPE_POL = 'POL'
  PORT_TYPE_POD = 'POD'

  # CLM_BUTTON_CAPTION_FORMAT
  #
  # This string provides a format for captions to display on buttons
  # of robots that print carton labels.
  # The string can contain any text and fruitspec tokens that are
  # delimited by $: and $. e.g. 'Count: $:actual_count_for_pack$'
  #
  # The possible fruitspec tokens are:
  # HBL: 'COUNT: $:actual_count_for_pack$'
  # UM : 'SIZE: $:size_reference$'
  # SR : '$:size_ref_or_count$ $:product_chars$ $:target_market_group_name$'
  # * actual_count_for_pack
  # * basic_pack_code
  # * commodity_code
  # * grade_code
  # * mark_code
  # * marketing_variety_code
  # * org_code
  # * product_chars
  # * size_count_value
  # * size_reference
  # * size_ref_or_count
  # * standard_pack_code
  # * target_market_group_name
  # CLM_BUTTON_CAPTION_FORMAT = ENV['CLM_BUTTON_CAPTION_FORMAT']

  # Does this installation require login when printing a label from a robot?
  # INCENTIVISED_LABELING = make_boolean('INCENTIVISED_LABELING')

  # pi Robots can display 6 lines of text, while T2n robots can only display 4.
  # If all robots on site are homogenous, set the value here.
  # Else it will be looked up from the module name.
  ROBOT_DISPLAY_LINES = ENV.fetch('ROBOT_DISPLAY_LINES', 0).to_i
  ROBOT_MSG_SEP = '###'

  # Max number of passenger instances - used for designating high, busy or over usage
  MAX_PASSENGER_INSTANCES = ENV.fetch('MAX_PASSENGER_INSTANCES', 30).to_i
  # Lowest state for passenger usage to send emails. Can be INFO, BUSY or HIGH.
  PASSENGER_USAGE_LEVEL = ENV.fetch('PASSENGER_USAGE_LEVEL', 'INFO')

  # ERP_PURCHASE_INVOICE_URI = ENV.fetch('ERP_PURCHASE_INVOICE_URI', 'default')

  BIG_ZERO = BigDecimal('0')
  # The maximum size of an integer in PostgreSQL
  MAX_DB_INT = 2_147_483_647

  # The maximum weight of a pallet
  MAX_PALLET_WEIGHT = 2000

  # The maximum weight of a bin
  MAX_BIN_WEIGHT = 2000

  # ISO 2-character country codes
  ISO_COUNTRY_CODES = %w[
    AF AL DZ AS AD AO AI AQ AG AR AM AW AU AT AZ BS BH BD BB BY BE BZ BJ
    BM BT BO BQ BA BW BV BR IO BN BG BF BI CV KH CM CA KY CF TD CL CN CX
    CC CO KM CD CG CK CR HR CU CW CY CZ CI DK DJ DM DO EC EG SV GQ ER EE
    SZ ET FK FO FJ FI FR GF PF TF GA GM GE DE GH GI GR GL GD GP GU GT GG
    GN GW GY HT HM VA HN HK HU IS IN ID IR IQ IE IM IL IT JM JP JE JO KZ
    KE KI KP KR KW KG LA LV LB LS LR LY LI LT LU MO MG MW MY MV ML MT MH
    MQ MR MU YT MX FM MD MC MN ME MS MA MZ MM NA NR NP NL NC NZ NI NE NG
    NU NF MP NO OM PK PW PS PA PG PY PE PH PN PL PT PR QA MK RO RU RW RE
    BL SH KN LC MF PM VC WS SM ST SA SN RS SC SL SG SX SK SI SB SO ZA GS
    SS ES LK SD SR SJ SE CH SY TW TJ TZ TH TL TG TK TO TT TN TR TM TC TV
    UG UA AE GB UM US UY UZ VU VE VN VG VI WF EH YE ZM ZW AX
  ].freeze

  DASHBOARD_INTERNAL_PAGES = [
    ['Carton Pallet summary per day', '/production/dashboards/carton_pallet_summary_days?fullpage=y'],
    ['Carton Pallet summary per week', '/production/dashboards/carton_pallet_summary_weeks?fullpage=y'],
    ['Deliveries per day', '/production/dashboards/delivery_days?fullpage=y'],
    ['Deliveries per week', '/production/dashboards/delivery_weeks?fullpage=y'],
    ['Device allocation', '/production/dashboards/device_allocation/$:ROBOT_BUTTON$?fullpage=y'],
    ['Loads per day', '/production/dashboards/load_days?fullpage=y'],
    ['Loads per week', '/production/dashboards/load_weeks?fullpage=y'],
    ['Palletizing bay states', '/production/dashboards/palletizing_bays?fullpage=y'],
    ['Pallets in stock', '/production/dashboards/in_stock?fullpage=y'],
    ['Production runs', '/production/dashboards/production_runs?fullpage=y']
  ].freeze

  DASHBOARD_QUERYSTRING_PARAMS = {
    'Production runs' => [{ key: 'LINE', optional: true }]
  }.freeze

  # Addendum: place of issue for export certificate
  # ADDENDUM_PLACE_OF_ISSUE = ENV.fetch('ADDENDUM_PLACE_OF_ISSUE', 'CPT')
  # raise Crossbeams::FrameworkError, "#{ADDENDUM_PLACE_OF_ISSUE} is not a valid code" unless ADDENDUM_PLACE_OF_ISSUE.match?(/cpt|dbn|plz|mpm|oth/i)

  # Inspection - Signee caption
  # GOVT_INSPECTION_SIGNEE_CAPTION = ENV.fetch('GOVT_INSPECTION_SIGNEE_CAPTION', 'Packhouse manager')

  # EDI Settings
  EDI_NETWORK_ADDRESS = ENV.fetch('EDI_NETWORK_ADDRESS', '999')
  EDI_RECEIVE_DIR = ENV['EDI_RECEIVE_DIR']
  EDI_FLOW_PS = 'PS'
  EDI_FLOW_PO = 'PO'
  EDI_FLOW_UISTK = 'UISTK'
  EDI_FLOW_PALBIN = 'PALBIN'
  EDI_AUTO_CREATE_MF = make_boolean('EDI_AUTO_CREATE_MF')
  # PS_APPLY_SUBSTITUTES = make_boolean('PS_APPLY_SUBSTITUTES')
  DEPOT_DESTINATION_TYPE = 'DEPOT'
  PARTY_ROLE_DESTINATION_TYPE = 'PARTY_ROLE'
  DESTINATION_TYPES = [DEPOT_DESTINATION_TYPE, PARTY_ROLE_DESTINATION_TYPE].freeze
  EDI_OUT_RULES_TEMPLATE = {
    EDI_FLOW_PS => {
      depot: false,
      roles: [ROLE_MARKETER]
    },
    EDI_FLOW_PO => {
      depot: true,
      roles: [ROLE_CUSTOMER, ROLE_SHIPPER, ROLE_EXPORTER]
    },
    EDI_FLOW_UISTK => {
      depot: false,
      roles: [ROLE_MARKETER]
    },
    EDI_FLOW_PALBIN => {
      depot: true,
      roles: [ROLE_CUSTOMER, ROLE_EXPORTER]
    }
  }.freeze

  MF_VARIANT_RULES = { Standard_Pack_Codes: { table_name: 'standard_pack_codes',
                                              column_name: 'standard_pack_code' },
                       PUCs: { table_name: 'pucs',
                               column_name: 'puc_code' },
                       Marketing_Varieties: { table_name: 'marketing_varieties',
                                              column_name: 'marketing_variety_code' },
                       Fruit_Size_References: { table_name: 'fruit_size_references',
                                                column_name: 'size_reference' },
                       Marks: { table_name: 'marks',
                                column_name: 'mark_code' },
                       Inventory_Codes: { table_name: 'inventory_codes',
                                          column_name: 'inventory_code' },
                       Grades: { table_name: 'grades',
                                 column_name: 'grade_code' },
                       Packed_TM_Group: { table_name: 'target_market_groups',
                                          column_name: 'target_market_group_name' },
                       Organizations: { table_name: 'organizations',
                                        column_name: 'medium_description' },
                       Depots: { table_name: 'depots',
                                 column_name: 'depot_code' },
                       Cities: { table_name: 'destination_cities',
                                 column_name: 'city_name' },
                       Ports: { table_name: 'ports',
                                column_name: 'port_code' },
                       Vessels: { table_name: 'vessels',
                                  column_name: 'vessel_code' } }.freeze

  # SOLAS_VERIFICATION_METHOD = ENV['SOLAS_VERIFICATION_METHOD']
  # SAMSA_ACCREDITATION = ENV['SAMSA_ACCREDITATION']

  RPT_INDUSTRY = ENV['RPT_INDUSTRY']
  JASPER_REPORTS_PATH = ENV['JASPER_REPORTS_PATH']
  JRUBY_JASPER_HOST_PORT = ENV.fetch('JRUBY_JASPER_HOST_PORT')
  JASPER_NEW_METHOD = make_boolean('JASPER_NEW_METHOD')
  USE_EXTENDED_PALLET_PICKLIST = make_boolean('USE_EXTENDED_PALLET_PICKLIST')

  # Titan: Govt Inspections
  # TITAN_ENVIRONMENT = { UAT: 'uatapigateway', STAGING: 'stagingapigateway', PRODUCTION: 'apigateway' }[ENV.fetch('TITAN_ENVIRONMENT', 'UAT').to_sym]
  # TITAN_API_USER_ID = ENV['TITAN_API_USER_ID']
  # TITAN_API_SECRET = ENV['TITAN_API_SECRET']

  # QUALITY APP result types
  PASS_FAIL = 'Pass/Fail'
  CLASSIFICATION = 'Classification'
  QUALITY_RESULT_TYPE = [PASS_FAIL, CLASSIFICATION].freeze
  PHYT_CLEAN_STANDARD = 'PhytCleanStandardData'
  QUALITY_API_NAMES = [PHYT_CLEAN_STANDARD].freeze
  # BYPASS_QUALITY_TEST_PRE_RUN_CHECK = make_boolean('BYPASS_QUALITY_TEST_PRE_RUN_CHECK')
  # BYPASS_QUALITY_TEST_LOAD_CHECK = make_boolean('BYPASS_QUALITY_TEST_LOAD_CHECK')

  # PhytClean
  PHYT_CLEAN_ENVIRONMENT = 'https://www.phytclean.co.za'
  PHYT_CLEAN_API_USERNAME = ENV['PHYT_CLEAN_API_USERNAME']
  PHYT_CLEAN_API_PASSWORD = ENV['PHYT_CLEAN_API_PASSWORD']
  PHYT_CLEAN_SEASON_ID = ENV['PHYT_CLEAN_SEASON_ID']

  # eCert
  E_CERT_ENVIRONMENT = { QA: 'http://qa.', PRODUCTION: 'https://' }[ENV.fetch('E_CERT_ENVIRONMENT', 'QA').to_sym]
  E_CERT_API_CLIENT_ID = ENV['E_CERT_API_CLIENT_ID']
  E_CERT_API_CLIENT_SECRET = ENV['E_CERT_API_CLIENT_SECRET']
  E_CERT_BUSINESS_ID = ENV['E_CERT_BUSINESS_ID']
  E_CERT_BUSINESS_NAME = ENV['E_CERT_BUSINESS_NAME']
  E_CERT_INDUSTRY = ENV['E_CERT_INDUSTRY']
  E_CERT_OPEN_TIMEOUT = ENV.fetch('E_CERT_OPEN_TIMEOUT', 5)
  E_CERT_READ_TIMEOUT = ENV.fetch('E_CERT_READ_TIMEOUT', 10)

  ASSET_TRANSACTION_TYPES = { adhoc_move: 'ADHOC_MOVE',
                              adhoc_create: 'ADHOC_CREATE',
                              adhoc_destroy: 'ADHOC_DESTROY',
                              receive: 'RECEIVE_BINS',
                              issue: 'ISSUE_BINS',
                              bin_tip: 'BIN_TIP',
                              rebin: 'REBIN' }.freeze

  # Bin Control
  ONSITE_EMPTY_BIN_LOCATION = ENV['ONSITE_EMPTY_BIN_LOCATION']
  # MAX_BINS_ON_LOAD = ENV['MAX_BINS_ON_LOAD'] || 50

  # Complete Pallet
  PLT_LABEL_QTY_TO_PRINT = 4

  # Refresh pallet data
  REFRESH_PALLET_DATA_TABLES = %w[carton_labels cartons pallet_sequences].freeze
  REFRESH_PALLET_DATA_COLUMNS = %w[fruit_actual_counts_for_pack_id fruit_size_reference_id].freeze
end
