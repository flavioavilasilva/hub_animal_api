class AnimalsController < ApplicationController
  before_action :authenticate_request!, only: %i[create update destroy]
  before_action :set_animal, only: %i[show update destroy]
  before_action :authorize_create!, only: :create
  before_action :authorize_manage!, only: %i[update destroy]

  def index
    animals = Animal.order(created_at: :desc)
    render json: animals.map { |animal| serialize_animal(animal) }, status: :ok
  end

  def show
    render json: serialize_animal(@animal), status: :ok
  end

  def create
    animal = current_user.animals.new(animal_params)

    if animal.save
      render json: serialize_animal(animal), status: :created
    else
      render json: { errors: animal.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @animal.update(animal_params)
      render json: serialize_animal(@animal), status: :ok
    else
      render json: { errors: @animal.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @animal.destroy
    head :no_content
  end

  private

  def set_animal
    @animal = Animal.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Animal not found" }, status: :not_found
  end

  def animal_params
    source = params[:animal].is_a?(ActionController::Parameters) ? params.require(:animal) : params
    permitted = source.permit(:avatar, :name, :size, :birth_date, :tags, tags: [])
    permitted[:tags] = normalize_tags(permitted[:tags]) if permitted.key?(:tags)
    permitted
  end

  def normalize_tags(raw_tags)
    return raw_tags if raw_tags.is_a?(Array)
    return [] if raw_tags.nil?

    if raw_tags.is_a?(String)
      normalized = raw_tags.strip
      return [] if normalized.empty?

      begin
        parsed = JSON.parse(normalized)
        return parsed if parsed.is_a?(Array)
      rescue JSON::ParserError
        # Not JSON, keep fallback behavior below.
      end

      return normalized.split(",").map(&:strip).reject(&:blank?)
    end

    Array(raw_tags).compact
  end

  def authorize_create!
    authorize! :create, Animal, message: "Only ONG users can manage animals"
  end

  def authorize_manage!
    return if performed?

    authorize! action_name.to_sym, @animal, message: "Only the responsible ONG can update or delete this animal"
  end

  def serialize_animal(animal)
    response = animal.as_json
    response["avatar_url"] = animal.avatar.attached? ? url_for(animal.avatar) : nil
    response
  end
end
