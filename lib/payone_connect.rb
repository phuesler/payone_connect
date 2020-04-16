require 'net/http'
require 'net/https'
require 'uri'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/object/blank'

class PayoneConnect
  attr_reader :request_data, :request_header
  def initialize(api_url, data)
    @api_url = URI.parse(api_url)
    @request_data = process_data(data)
    @request_header = {'Content-Type'=> 'application/x-www-form-urlencoded'}
  end

  def request
    http = Net::HTTP.new(@api_url.host, @api_url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    handle_response(http.post(@api_url.path, @request_data,@request_header))
  end

  protected

  def handle_response(http_response)
    return nil if http_response.body.blank?
    response = {}
    http_response.body.split(/\n+/).each do |param|
      key,value = param.scan(/([^=]+)=(.*)/).first
      response[key.to_sym] = value
    end
    response
  end

  def process_data(data)
    data.stringify_keys!
    %w(mid portalid key mode).each do |required_field|
      raise "Payone API Setup Data not complete: #{required_field.upcase} was blank" if data[required_field].blank?
    end
    post_data = []
    data.each do |key,value|
      if value.is_a?(Hash)
        value.each do |nested_key, nested_value|
          post_data << "#{key.to_s}[#{nested_key.to_s}]=#{URI.encode_www_form_component(nested_value.to_s)}"
        end
      else
          post_data << "#{key.to_s}=#{URI.encode_www_form_component(value.to_s)}"
      end
    end
    post_data.join("&")
  end
end
