# frozen_string_literal: true

# What this script does:
# ----------------------
# Truncates transactional tables in preparation for a new season.
# NOTE: This script must only be run after a backup and all the end-of-season extracts have been run.
#
# Reason for this script:
# -----------------------
# Each new season for a packhouse needs to start with a clean set of transaction tables.
#
# To run:
# -------
# Debug : DEBUG=y RACK_ENV=production ruby scripts/base_script.rb EndOfSeasonTruncate
# Live  : RACK_ENV=production ruby scripts/base_script.rb EndOfSeasonTruncate
# Dev   : ruby scripts/base_script.rb EndOfSeasonTruncate
#
class EndOfSeasonTruncate < BaseScript
  # TODO: add missing tables
  ORDERED_TABLES = %i[
    pallet_sequences
    pallets
  ].freeze

  def run # rubocop:disable Metrics/AbcSize
    if debug_mode
      puts 'Tables to be truncated:'
      ORDERED_TABLES.each { |tbl| puts "Truncate: #{tbl}" }
    else
      DB.transaction do
        DB[:palletizing_bay_states].update(current_state: 'empty',
                                           pallet_sequence_id: nil,
                                           determining_carton_id: nil,
                                           last_carton_id: nil)

        ORDERED_TABLES.each do |tbl|
          DB[tbl].truncate(cascade: true, restart: true)
          puts "Truncated #{tbl}"
        end

        puts 'DELETING audit trail rows (could take a while)...'
        # Clear audit tables
        # But clear ALL logged action details (no table_name column and the data from previous season is not important)
        puts 'Deleting logged_action_details...'
        DB[Sequel[:audit][:logged_action_details]].delete
        puts 'Deleting logged_actions...'
        DB[Sequel[:audit][:logged_actions]].where(table_name: ORDERED_TABLES.map(&:to_s)).delete
        puts 'Deleting current_statuses...'
        DB[Sequel[:audit][:current_statuses]].where(table_name: ORDERED_TABLES.map(&:to_s)).delete
        puts 'Deleting status_logs...'
        DB[Sequel[:audit][:status_logs]].where(table_name: ORDERED_TABLES.map(&:to_s)).delete
        puts '...DONE'
      end
    end

    infodump = <<~STR
      Script: EndOfSeasonTruncate

      What this script does:
      ----------------------
      Truncates transactional tables in preparation for a new season.
      NOTE: This script must only be run after a backup and all the end-of-season extracts have been run.

      Reason for this script:
      -----------------------
      Each new season for a packhouse needs to start with a clean set of transaction tables.

      Results:
      --------

      1. Cleared foreign keys on palletizing bay states table.

      2. Truncated the following tables:

      #{ORDERED_TABLES.join("\n")}

      3. Cleared related data from audit tables.
    STR

    unless debug_mode
      log_infodump(:end_of_season,
                   :tables,
                   :truncated,
                   infodump)
    end

    if debug_mode
      success_response('Dry run complete')
    else
      success_response('Tables were truncated')
    end
  end
end
