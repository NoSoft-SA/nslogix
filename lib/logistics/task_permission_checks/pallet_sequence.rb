# frozen_string_literal: true

module LogisticsApp
  module TaskPermissionCheck
    class PalletSequence < BaseService
      attr_reader :task, :entity, :params, :repo
      def initialize(task, params)
        @task = task
        @repo = PalletRepo.new
        @params = params
        @entity = @repo.find_pallet_sequence(params)
      end

      CHECKS = {
        create: :create_check,
        edit: :edit_check,
        delete: :delete_check
      }.freeze

      def call
        return failed_response 'Pallet Sequence record not found' unless @entity || task == :create

        check = CHECKS[task]
        raise ArgumentError, "Task \"#{task}\" is unknown for #{self.class}" if check.nil?

        send(check)
      end

      private

      def create_check
        # return failed_response 'Not allowed to receive pallets from this depot.' unless receive_edi?

        all_ok
      end

      def edit_check
        all_ok
      end

      def delete_check
        all_ok
      end

      def receive_edi?
        repo.get(:depots, params[:depot_id], :receive_edi) || false
      end

      # def approved?
      #   @entity.approved
      # end
    end
  end
end
