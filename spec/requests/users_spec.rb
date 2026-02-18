require "rails_helper"

RSpec.describe "Users", type: :request do
  def user_payload(overrides = {})
    {
      name: "Jane Doe",
      email: "jane@example.com",
      user_type: "visitor",
      address: {
        street: "Rua das Flores",
        number: "100",
        neighborhood: "Centro",
        city: "Sao Paulo",
        state: "SP",
        zip_code: "01000-000",
        country: "BR"
      },
      cpf: "12345678901",
      cnpj: nil,
      fantasy_name: nil,
      site: nil,
      responsible: nil,
      password: "Password123!",
      password_confirmation: "Password123!"
    }.merge(overrides)
  end

  describe "POST /users" do
    let(:valid_params) { { user: user_payload } }

    it "creates a user" do
      expect do
        post "/users", params: valid_params, as: :json
      end.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body["email"]).to eq("jane@example.com")
      expect(body["user_type"]).to eq("visitor")
      expect(body["address"]["city"]).to eq("Sao Paulo")
    end

    it "returns unprocessable_content when cpf and cnpj are missing" do
      post "/users", params: { user: user_payload(cpf: nil, cnpj: nil) }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(JSON.parse(response.body)["errors"]).to include("cpf or cnpj must be provided")
    end
  end

  describe "GET /users" do
    let!(:authenticated_user) do
      User.create!(
        user_payload(email: "auth@example.com", cpf: "11111111111", user_type: "admin")
      )
    end

    let!(:other_user) do
      User.create!(
        user_payload(email: "john@example.com", cpf: nil, cnpj: "12345678000199", user_type: "ong", fantasy_name: "ONG Salva")
      )
    end

    it "returns unauthorized when token is missing" do
      get "/users"

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns users with valid token" do
      token = JsonWebToken.encode(user_id: authenticated_user.id)

      get "/users", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.map { |u| u["id"] }).to include(authenticated_user.id, other_user.id)
    end
  end

  describe "GET /users/:id" do
    let!(:authenticated_user) { User.create!(user_payload(email: "auth-show@example.com", cpf: "22222222222")) }
    let!(:target_user) { User.create!(user_payload(email: "target@example.com", cpf: "33333333333")) }

    it "returns unauthorized when token is invalid" do
      get "/users/#{target_user.id}", headers: { "Authorization" => "Bearer invalid.token" }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns the user with valid token" do
      token = JsonWebToken.encode(user_id: authenticated_user.id)

      get "/users/#{target_user.id}", headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(target_user.id)
    end
  end

  describe "PATCH /users/:id" do
    let!(:user) { User.create!(user_payload(email: "before@example.com", cpf: "44444444444")) }

    it "updates user" do
      patch "/users/#{user.id}", params: { user: { user_type: "ong", fantasy_name: "Amigos dos Animais" } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(user.reload.user_type).to eq("ong")
      expect(user.fantasy_name).to eq("Amigos dos Animais")
    end
  end

  describe "DELETE /users/:id" do
    let!(:user) { User.create!(user_payload(email: "delete@example.com", cpf: "55555555555")) }

    it "deletes user" do
      expect do
        delete "/users/#{user.id}"
      end.to change(User, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
