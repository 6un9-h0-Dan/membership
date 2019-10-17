# frozen_string_literal: true

class PlanChangesController < ApplicationController
  before_action :set_current_user_plan, only: %i[index create]

  # GET /users/:user_id/plan_change
  def index
    redirect_to root_path unless current_user&.active_subscription
    @user = current_user
    @plans = Plan.all
  end

  # GET /users/:user_id/plan_change/new
  # GET /users/:user_id/plan_change/new.json
  def new
    @plan_change = UserPlanChange.new
  end

  # POST /users/:user_id/plan_change
  # POST /users/:user_id/plan_change.json
  def create
    head :not_authorized unless current_user

    @plan = UserPlanChange.new(user_id: plan_change_params[:user_id], old_plan_id: plan_change_params[:old_plan_id], new_plan_id: plan_change_params[:new_plan_id])

    respond_to do |format|
      if @plan.save
        format.json { render json: @plan, status: :ok }
      else
        format.html { render :index }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_current_user_plan
    @current_plan = current_user&.active_subscription
  end

  def plan_change_params
    params.require(:plan_change).permit(:user_id, :old_plan_id, :new_plan_id)
  end
end
