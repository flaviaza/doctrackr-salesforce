class Document < ActiveRecord::Base
  attr_accessible :dt_reference, :last_event_at, :name, :sf_reference

  attr_accessible :file

  belongs_to :user
  TARGET_ORIGIN = "https://intralinks--poc1.cs8.my.salesforce.com"
  CHATTER_FEED = "/services/data/v31.0/chatter/feeds"

  def post_document_protected
    dt_document = DocTrackrEnterprise.get_document_info(dt_reference.to_s)
    puts dt_document.inspect
    data = {
      body: {
        messageSegments: [
        {
          type: "Text",
          text: "#{name} has been protected with docTrackr. download at #{dt_document['url']} "
          }]
        },
      feedElementType: "FeedItem"}
    uri = URI.parse(TARGET_ORIGIN+CHATTER_FEED+"/news/"+user.sf_reference+"/feed-items")
    headers = {"Content-Type" => "application/json", "Authorization" => "Bearer #{user.oauth_token}"}
    http = Net::HTTP.new(uri.host,uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = http.post(uri.path,data.to_json,headers)
  end

  def file=(attribute)
    @file = attribute
  end

  def file
    @file
  end

end
