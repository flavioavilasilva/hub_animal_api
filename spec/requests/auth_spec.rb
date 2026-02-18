require "rails_helper"

RSpec.describe "Auth", type: :request do
  def user_payload(overrides = {})
    {
      name: "Login User",
      email: "login@example.com",
      user_type: "visitor",
      address: {
        street: "Rua A",
        number: "10",
        neighborhood: "Centro",
        city: "Sao Paulo",
        state: "SP",
        zip_code: "01000-000",
        country: "BR"
      },
      cpf: "98765432100",
      password: "Password123!",
      password_confirmation: "Password123!"
    }.merge(overrides)
  end

  describe "POST /auth/login" do
    let!(:user) { User.create!(user_payload) }

    it "returns token for valid credentials" do
      post "/auth/login", params: { email: user.email, password: "Password123!" }, as: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["token"]).to be_present
      expect(body.dig("user", "id")).to eq(user.id)
    end

    it "returns unauthorized for invalid credentials" do
      post "/auth/login", params: { email: user.email, password: "wrong-pass" }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["error"]).to eq("Invalid email or password")
    end
  end
end
