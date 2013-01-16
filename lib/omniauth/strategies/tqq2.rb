require 'omniauth/strategies/oauth2'
require 'multi_json'

module OmniAuth
  module Strategies
    class Tqq2 < OmniAuth::Strategies::OAuth2
      option :name, 'tqq2'
      option :sign_in, true

      def initialize(*args)
        super
        # taken from https://github.com/intridea/omniauth/blob/0-3-stable/oa-oauth/lib/omniauth/strategies/oauth/tqq.rb#L15-24
        options.client_options = {
            :site => 'https://open.t.qq.com/cgi-bin',
            :authorize_url => 'https://open.t.qq.com/cgi-bin/oauth2/authorize',
            :token_url => "https://open.t.qq.com/cgi-bin/oauth2/access_token"
        }
      end

      uid do
        @uid ||= begin
          access_token.options[:mode] = :query
          access_token.options[:param_name] = :access_token
          # Response Example: "callback( {\"client_id\":\"11111\",\"openid\":\"000000FFFF\"} );\n"
          response = access_token.get('/oauth2.0/me')
          #TODO handle error case
          matched = response.body.match(/"openid":"(?<openid>\w+)"/)
          matched[:openid]
        end
      end

      info do
        {
            :nickname => raw_info['data']['nick'],
            :email => (raw_info['data']['email'] if raw_info['data']['email'].present?),
            :name => raw_info['data']['name'],
            :location => raw_info['data']['location'],
            :image => (raw_info['data']['head']+'/40' if raw_info['data']['head'].present?),
            :description => raw_info['data']['introduction'],
            :urls => {
                'Tqq' => 't.qq.com/' + raw_info['data']['name']
            }
        }
      end

      extra do
        {
            :raw_info => raw_info
        }
      end

      def raw_info
        @raw_info ||= begin
                        #TODO handle error case
                        #TODO make info request url configurable
          client.request(:get, "https://open.t.qq.com/api/user/infos (", :params => {
              :format => :json,
              :openid => uid,
              :oauth_consumer_key => options[:client_id],
              :access_token => access_token.token
          }, :parse => :json).parsed
        end
      end
    end
  end
end

OmniAuth.config.add_camelization('tqq2', 'Tqq2')