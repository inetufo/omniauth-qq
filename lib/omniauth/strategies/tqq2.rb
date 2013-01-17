require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Tqq2 < OmniAuth::Strategies::OAuth2
      option :name, 'tqq2'
      options.client_options = {
          :site => 'https://open.t.qq.com',
          :authorize_url => '/cgi-bin/oauth2/authorize',
          :token_url => "/cgi-bin/oauth2/access_token"
      }

      def request_phase
        super
      end
        
      option :token_params, {
        :parse => :json,
      }

      uid do
        raw_info['data']['openid']
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
          client.request(:get, "https://open.t.qq.com/api/user/info (", :params => {
             :format => :json, 
              :openid => uid,
              :oauth_consumer_key => options[:client_id],
              :oauth_version => '2.a',
              :clientip => request.remote_ip,
              :access_token => access_token.token
          }, :parse => :json).parsed
        end
      end
    end
  end
end

OmniAuth.config.add_camelization('tqq2', 'Tqq2')