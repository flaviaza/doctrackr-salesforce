# DocTrackrEnterprise Module to access the API for SPA purposes only
module DocTrackrEnterprise
  require 'oauth2'
  require 'json'
  require 'base64'
  require 'dotenv'

  Dotenv.load

  BASE_URL = 'https://api.doctrackr.com/'
  API_VERSION = 'v1'
  API_URL = BASE_URL + API_VERSION + '/'

  APP_ID = ENV['APP_ID']
  APP_SECRET = ENV['APP_SECRET']

  OAUTH_URL = BASE_URL + 'oauth/authorize'

  def self.initialize
    @client = OAuth2::Client.new(APP_ID, APP_SECRET, site: OAUTH_URL) do |c|
      c.request  :multipart
      c.request  :url_encoded
      c.adapter  :net_http
    end
    @token = @client.client_credentials.get_token

    response = @token.get(API_URL+'/users').parsed
    @user_id = response['users'][0]['id']
    @token.token
  end

  def self.refresh_token
    @token.refresh! if @token.expired?
  rescue
    @token = @client.client_credentials.get_token
  end

  # API test method - remove in production
  def self.get_users_count
    response = @token.get(API_URL+'/users').parsed
    response['total_count'].to_i
  end

  def self.secure_document(file, callback)

    # file is a hash containing :tempfile (a File object) and :type (a MIME type string i.e. 'application/pdf')
    # file can be the params[:file] that Sinatra creates when uploading from a form

    params = {
      # 'policy[expires_at]' => Time.now + (60 * 60 * 24), # use in v.2
      'policy[verify_identity]' => 'false',
      'policy[privileges][can_view]' => 'everyone',
      'callback_url' => callback,
      'fileupload' => Faraday::UploadIO.new(file.path, file.tempfile, file.original_filename)
    }

    # puts params # debug

    begin
      response = @token.post(API_URL+'/'+@user_id+'/documents', body: params).parsed
      response['id'] # returns document ID
    rescue OAuth2::Error => e
      puts e
    end
  end

  def self.get_document_info(document_id)
    begin
      response = @token.get(API_URL+'/'+@user_id+'/documents/'+document_id).parsed
      response['policy'] = self.get_document_policy_info(response['policy_id'])
      response
    rescue Error => e
      puts e
    end
  end

  def self.get_document_policy_info(policy_id)
    begin
      @token.get(API_URL+'/'+@user_id+'/policies/'+policy_id).parsed
    rescue Error => e
      puts e
    end
  end

  # test method - remove in production
  #def self.secured_url(document_id)
  #  response = @token.get(API_URL+'/'+@user_id+'/documents/'+document_id).parsed
  #  response['url']
  #end

  def self.validate_email(email)
    email.match /.+@.+\..+/i
  end

  def self.validate_views(views)
    views.to_i <= 10 # change this to an ENV var?
  end

  def self.validate_file(filename)
    [".pdf", ".PDF"].include? File.extname(filename)
    # validate file size
  end

  def self.validate_params(email, file, views)
    self.validate_email(email) && self.validate_file(file) && self.validate_views(views)
  end

  def self.encode_email(email_address)
    data = {
      email: email_address,
      destination: 'spa'
    }
    # copy-paste from Marco's email
    CGI.escape(Base64.encode64(data.to_json).chomp!)
  end

end
