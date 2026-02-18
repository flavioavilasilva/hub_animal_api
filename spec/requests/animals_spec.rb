require "rails_helper"

RSpec.describe "Animals", type: :request do
  def user_payload(overrides = {})
    {
      name: "User",
      email: "user@example.com",
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
      cpf: "12345678901",
      password: "Password123!",
      password_confirmation: "Password123!"
    }.merge(overrides)
  end

  def uploaded_avatar
    Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/avatar.jpg"), "image/jpeg")
  end

  def animal_payload(overrides = {})
    {
      name: "Thor",
      tags: ["friendly", "vaccinated", "good with kids"],
      size: "medium",
      birth_date: "2022-04-10"
    }.merge(overrides)
  end

  describe "GET /animals" do
    let!(:responsible) { User.create!(user_payload(email: "ong@example.com", cpf: nil, cnpj: "12345678000199", user_type: "ong")) }
    let!(:animal) do
      Animal.create!(animal_payload.merge(responsible: responsible)).tap do |record|
        record.avatar.attach(uploaded_avatar)
      end
    end

    it "returns animals without authentication" do
      get "/animals"

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.first["id"]).to eq(animal.id)
      expect(body.first["avatar_url"]).to be_present
    end
  end

  describe "POST /animals" do
    let!(:ong_user) { User.create!(user_payload(email: "ong-create@example.com", cpf: nil, cnpj: "22345678000199", user_type: "ong")) }
    let!(:visitor_user) { User.create!(user_payload(email: "visitor@example.com", cpf: "22345678901", user_type: "visitor")) }

    it "returns unauthorized without token" do
      post "/animals", params: { animal: animal_payload }

      expect(response).to have_http_status(:unauthorized)
    end

    it "returns forbidden for non-ong token" do
      token = JsonWebToken.encode(user_id: visitor_user.id)

      post "/animals", params: { animal: animal_payload }, headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["error"]).to eq("Only ONG users can manage animals")
    end

    it "creates animal for ong token with uploaded avatar and sets responsible automatically" do
      token = JsonWebToken.encode(user_id: ong_user.id)

      expect do
        post "/animals", params: { animal: animal_payload(avatar: uploaded_avatar) }, headers: { "Authorization" => "Bearer #{token}" }
      end.to change(Animal, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(Animal.last.responsible_id).to eq(ong_user.id)
      expect(Animal.last.avatar).to be_attached
      expect(JSON.parse(response.body)["avatar_url"]).to be_present
    end
  end

  describe "PATCH /animals/:id" do
    let!(:responsible_ong) { User.create!(user_payload(email: "ong-owner@example.com", cpf: nil, cnpj: "32345678000199", user_type: "ong")) }
    let!(:other_ong) { User.create!(user_payload(email: "ong-other@example.com", cpf: nil, cnpj: "42345678000199", user_type: "ong")) }
    let!(:animal) { Animal.create!(animal_payload.merge(responsible: responsible_ong)) }

    it "allows update by responsible ong" do
      token = JsonWebToken.encode(user_id: responsible_ong.id)

      patch "/animals/#{animal.id}", params: { animal: { size: "large", avatar: uploaded_avatar } }, headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      expect(animal.reload.size).to eq("large")
      expect(animal.avatar).to be_attached
    end

    it "returns forbidden for another ong" do
      token = JsonWebToken.encode(user_id: other_ong.id)

      patch "/animals/#{animal.id}", params: { animal: { size: "small" } }, as: :json, headers: { "Authorization" => "Bearer #{token}" }

      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["error"]).to eq("Only the responsible ONG can update or delete this animal")
    end
  end

  describe "DELETE /animals/:id" do
    let!(:responsible_ong) { User.create!(user_payload(email: "ong-delete@example.com", cpf: nil, cnpj: "52345678000199", user_type: "ong")) }
    let!(:animal) { Animal.create!(animal_payload.merge(responsible: responsible_ong)) }

    it "deletes animal by responsible ong" do
      token = JsonWebToken.encode(user_id: responsible_ong.id)

      expect do
        delete "/animals/#{animal.id}", headers: { "Authorization" => "Bearer #{token}" }
      end.to change(Animal, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
