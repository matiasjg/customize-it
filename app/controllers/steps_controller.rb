class StepsController < ApplicationController
  before_action :login_again_if_different_shop
  before_action :validate_payment_type
  before_action :set_step, only: [:show, :edit, :update, :destroy]
  around_filter :shopify_session
  layout 'embedded_app'

  # GET /steps
  # GET /steps.json
  def index
    @steps = Step.where shop_id: session[:shopify]
  end

  # GET /steps/1
  # GET /steps/1.json
  def show
  end

  # GET /steps/new
  def new
    @collections = ShopifyAPI::CustomCollection.find(:all, :params => { :published_status => "any" })
    @nextSteps = Step.where shop_id: session[:shopify]

    @step = Step.new
    @step.shop_id = session[:shopify]
  end

  # GET /steps/1/edit
  def edit
    @collections = ShopifyAPI::CustomCollection.find(:all, :params => { :published_status => "any" })
    @nextSteps = Step.where("id != ? AND shop_id = ?", params[:id], session[:shopify])
  end

  def not_allowed
    render :status => :forbidden, :text => "Ups! this action is not allowed, contact us to upgrade your account and customize your steps!"
  end

  # POST /steps
  # POST /steps.json
  def create
    @step = Step.new(step_params)
    @step.shop_id = session[:shopify]

    respond_to do |format|
      if @step.save
        format.html { redirect_to @step, notice: 'Step was successfully created.' }
        format.json { render :show, status: :created, location: @step }
      else
        format.html { render :new }
        format.json { render json: @step.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /steps/1
  # PATCH/PUT /steps/1.json
  def update
    respond_to do |format|
      if @step.update(step_params)
        format.html { redirect_to @step, notice: 'Step was successfully updated.' }
        format.json { render :show, status: :ok, location: @step }
      else
        format.html { render :edit }
        format.json { render json: @step.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /steps/1
  # DELETE /steps/1.json
  def destroy
    @step.destroy
    respond_to do |format|
      format.html { redirect_to steps_url, notice: 'Step was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def validate_payment_type
        logger.debug action_name
        unless action_name == "not_allowed"
            shop = Shop.find session[:shopify]
            logger.debug shop.private?.inspect
            if shop.private?
                redirect_to url_for(:controller => 'steps', :action => 'not_allowed')
            end
        end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_step
      @step = Step.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def step_params
      params.require(:step).permit(:name, :step_url, :html, :collection_id, :next_step_id)
    end
end
