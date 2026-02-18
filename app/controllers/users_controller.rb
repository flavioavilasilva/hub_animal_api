class UsersController < ApplicationController
  before_action :authenticate_request!, only: %i[index show]
  before_action :set_user, only: %i[show update destroy]

  def index
    users = User.order(created_at: :desc)
    render json: users, status: :ok
  end

  def show
    render json: @user, status: :ok
  end

  def create
    user = User.new(user_params)

    if user.save
      render json: user, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :user_type,
      :fantasy_name,
      :site,
      :cpf,
      :cnpj,
      :responsible,
      :password,
      :password_confirmation,
      address: {}
    )
  end
end
