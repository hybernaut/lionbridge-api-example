require 'OpenSSL'
require 'time'
require 'httparty'

# http://developers.lionbridge.com/content/docs
# https://support.liondemand.com/hc/en-us/articles/201095990-Writing-your-first-API-Call

class LionBridge
  include HTTParty

  LOD_BASE_URI = ENV['LOD_BASE_URI'] || 'developer-sandbox.liondemand.com'
  LOD_PREFIX = 'LOD1-BASE64-SHA256'
  LOD_VERSION = '2015-02-23'
  LOD_ACCEPT = 'text/xml'
  LOD_CLIENT_ID = ENV['LOD_CLIENT_ID']
  LOD_CLIENT_SECRET = ENV['LOD_CLIENT_SECRET']

  base_uri LOD_BASE_URI

  def request request_path
    headers = http_headers(request_path)
    puts "GET #{request_path}"
    # puts headers
    self.class.get request_path, headers: headers
  end

  protected

  def http_headers resource
    {
      "Authorization"   => lod_auth_header(resource),
      "X-LOD-VERSION"   => LOD_VERSION,
      "X-LOD-TIMESTAMP" => timestamp,
      "Accept"          => LOD_ACCEPT,
    }
  end

  def lod_digest resource
    method = 'GET'
    text = [method, resource, LOD_CLIENT_SECRET, lod_headers].join(':')
    # puts "Digest input: #{text}"
    OpenSSL::Digest::SHA256.new(text).base64digest
  end

  def lod_headers
    [timestamp, LOD_VERSION, LOD_ACCEPT].join(':')
  end

  def lod_auth_header resource
    headers = 'x-lod-timestamp;x-lod-version;accept'
    text = ["KeyID=#{LOD_CLIENT_ID}", "Signature=#{lod_digest(resource)}", "SignedHeaders=#{headers}"].join(',')
    LOD_PREFIX + ' ' + text
  end

  def timestamp
    @_current_timestamp ||= Time.now.iso8601(4)
  end

end

puts LionBridge.new.request( $1 || '/api/account/info' )
