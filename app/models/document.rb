class Document < ActiveRecord::Base
  attr_accessible :dt_reference, :last_event_at, :name, :sf_reference

  attr_accessible :file

  belongs_to :user
  TARGET_ORIGIN = "https://intralinks--poc1.cs8.my.salesforce.com"
  CHATTER_FEED = "/services/data/v31.0/chatter/feeds"

  def post_document_protected
    data = {
      body: {
        messageSegments: [
        {
          type: "Text",
          text: "New document protected with dT "
          }]
        },
      feedElementType: "FeedItem"}
    uri = URI.parse(TARGET_ORIGIN+CHATTER_FEED)
    headers = {"Content-Type" => "application/json", "Authorization" => "Bearer #{user.oauth_token}"}
    http = Net::HTTP.new(uri.host,uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.post(uri.path,data.to_json,headers)
    puts response.inspect
  end

  def file=(attribute)
    @file = attribute
  end

  def file
    @file
  end
end
