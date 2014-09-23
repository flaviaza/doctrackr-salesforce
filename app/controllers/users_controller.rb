class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @sr = params[:signed_request]

    secret = ENV["CANVAS_CONSUMER_SECRET"]
    srHelper = SignedRequest.new(secret,@sr)

    @canvasRequestJson = srHelper.verifyAndDecode()
    @canvasRequest = JSON.parse(@canvasRequestJson)
    @current_user = nil

    unless @current_user = User.find_by_email(@canvasRequest["context"]["user"]["email"])
      @current_user = User.create(email: @canvasRequest["context"]["user"]["email"],
        sf_reference_username: @canvasRequest["context"]["user"]["userName"],
        first_name: @canvasRequest["context"]["user"]["firstName"],
        last_name: @canvasRequest["context"]["user"]["lastName"],
        sf_reference: @canvasRequest["context"]["user"]["userId"],
        refresh_token: @canvasRequest["client"]["refreshToken"],
        oauth_token: @canvasRequest["client"]["oauthToken"])
    end
    redirect_to new_document_path, current_user: @current_user.try(:id)
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
