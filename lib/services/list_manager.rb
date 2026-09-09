require_relative '../api/cloudflare_api'
require_relative '../utils/logger'
require_relative '../utils/terminate'

module Services
  class ListManager
    def self.account_id
      id = ENV.fetch('CF_ACCOUNT_ID', nil)
      ::Utils::Log.logger.info("DEBUG: CF_ACCOUNT_ID value is '#{id}' (length: #{id&.length})")
      ::Utils::Terminate.exit_with_error('CRITICAL: CF_ACCOUNT_ID is missing or invalid!') if id.nil? || id.strip.empty? || id.length != 32
      id.strip
    end

    def self.fetch_existing_lists
      ::Utils::Log.logger.info('Retrieving existing lists...')
      result = API::CloudflareAPI.api_call(:get, "https://api.cloudflare.com/client/v4/accounts/#{account_id}/gateway/rules/lists")
      return [] if result.nil?

      ::Utils::Log.logger.debug("Retrieved #{result.size} existing lists")
      result
    end

    def self.create_list(name, description, domains)
      ::Utils::Log.logger.info("Creating list '#{name}'...")
      items = domains.map { |domain| { 'value' => domain } }
      body = { name: name, description: description, type: 'DOMAIN', items: items }
      API::CloudflareAPI.api_call(:post, "https://api.cloudflare.com/client/v4/accounts/#{account_id}/gateway/rules/lists", body)
    end

    def self.delete_list(list_id)
      ::Utils::Log.logger.info("Deleting list with ID #{list_id}...")
      API::CloudflareAPI.api_call(:delete, "https://api.cloudflare.com/client/v4/accounts/#{account_id}/gateway/rules/lists/#{list_id}")
    end
  end
end
