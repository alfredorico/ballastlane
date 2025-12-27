require "rails_helper"

RSpec.describe "Api::V1::Pokemons", type: :request do
  describe "when user it's not authenticated" do
    describe "GET /api/v1/pokemons" do
      context "without authorization header" do
        it "returns unauthorized error" do
          get "/api/v1/pokemons"

          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Missing authorization token")
        end
      end

      context "with invalid token" do
        it "returns unauthorized error" do
          get "/api/v1/pokemons", headers: { "Authorization" => "Bearer invalid_token" }

          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json["error"]).to include("Invalid token")
        end
      end

      context "with expired token" do
        let(:user) { create(:user) }

        it "returns unauthorized error" do
          access_token = JwtService.encode_access_token(user)

          travel_to 16.minutes.from_now do
            get "/api/v1/pokemons", headers: { "Authorization" => "Bearer #{access_token}" }

            expect(response).to have_http_status(:unauthorized)
            json = JSON.parse(response.body)
            expect(json["error"]).to eq("Token has expired")
          end
        end
      end

      context "with revoked token" do
        let(:user) { create(:user) }

        it "returns unauthorized error" do
          access_token = JwtService.encode_access_token(user)
          user.regenerate_jti!

          get "/api/v1/pokemons", headers: { "Authorization" => "Bearer #{access_token}" }

          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Token has been revoked")
        end
      end
    end

    describe "GET /api/v1/pokemons/:id" do
      context "without authorization header" do
        it "returns unauthorized error" do
          get "/api/v1/pokemons/25"

          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Missing authorization token")
        end
      end

      context "with invalid token" do
        it "returns unauthorized error" do
          get "/api/v1/pokemons/25", headers: { "Authorization" => "Bearer invalid_token" }

          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json["error"]).to include("Invalid token")
        end
      end

      context "with expired token" do
        let(:user) { create(:user) }

        it "returns unauthorized error" do
          access_token = JwtService.encode_access_token(user)

          travel_to 16.minutes.from_now do
            get "/api/v1/pokemons/25", headers: { "Authorization" => "Bearer #{access_token}" }

            expect(response).to have_http_status(:unauthorized)
            json = JSON.parse(response.body)
            expect(json["error"]).to eq("Token has expired")
          end
        end
      end

      context "with revoked token" do
        let(:user) { create(:user) }

        it "returns unauthorized error" do
          access_token = JwtService.encode_access_token(user)
          user.regenerate_jti!

          get "/api/v1/pokemons/25", headers: { "Authorization" => "Bearer #{access_token}" }

          expect(response).to have_http_status(:unauthorized)
          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Token has been revoked")
        end
      end
    end
  end

  describe "when user is authenticated" do
    let(:user) { create(:user) }
    let(:access_token) { JwtService.encode_access_token(user) }
    let(:auth_headers) { { "Authorization" => "Bearer #{access_token}" } }

    describe "GET /api/v1/pokemons" do
      context "successful request", vcr: { cassette_name: "pokemon_api_adapter/list_default" } do
        it "returns 200 OK" do
          get "/api/v1/pokemons", headers: auth_headers

          expect(response).to have_http_status(:ok)
        end

        it "returns pokemons array" do
          get "/api/v1/pokemons", headers: auth_headers

          json = JSON.parse(response.body)
          expect(json["pokemons"]).to be_an(Array)
          expect(json["pokemons"].length).to eq(20)
        end

        it "returns Pokemon with basic info" do
          get "/api/v1/pokemons", headers: auth_headers

          json = JSON.parse(response.body)
          first_pokemon = json["pokemons"].first

          expect(first_pokemon).to have_key("id")
          expect(first_pokemon).to have_key("name")
          expect(first_pokemon).to have_key("photo")
        end

        it "returns pagination metadata" do
          get "/api/v1/pokemons", headers: auth_headers

          json = JSON.parse(response.body)
          pagination = json["pagination"]

          expect(pagination["page"]).to eq(1)
          expect(pagination["per_page"]).to eq(20)
          expect(pagination["total"]).to be > 0
          expect(pagination["total_pages"]).to be > 0
          expect(pagination).to have_key("next_page")
          expect(pagination).to have_key("previous_page")
        end
      end

      context "with pagination params", vcr: { cassette_name: "pokemon_api_adapter/list_limit_5" } do
        it "respects per_page parameter" do
          get "/api/v1/pokemons", params: { per_page: 5 }, headers: auth_headers

          json = JSON.parse(response.body)
          expect(json["pokemons"].length).to eq(5)
          expect(json["pagination"]["per_page"]).to eq(5)
        end
      end
    end

    describe "GET /api/v1/pokemons/:id" do
      context "with valid Pokemon ID", vcr: { cassette_name: "pokemon_api_adapter/find_pikachu" } do
        it "returns 200 OK" do
          get "/api/v1/pokemons/25", headers: auth_headers

          expect(response).to have_http_status(:ok)
        end

        it "returns Pokemon details" do
          get "/api/v1/pokemons/25", headers: auth_headers

          json = JSON.parse(response.body)

          expect(json["id"]).to eq(25)
          expect(json["name"]).to eq("pikachu")
          expect(json["weight"]).to be_a(Float)
          expect(json["height"]).to be_a(Float)
          expect(json["types"]).to be_an(Array)
          expect(json["types"]).to include("electric")
          expect(json["abilities"]).to be_an(Array)
          expect(json["photo"]).to be_a(String)
        end
      end

      context "with valid Pokemon name", vcr: { cassette_name: "pokemon_api_adapter/find_charmander" } do
        it "returns 200 OK" do
          get "/api/v1/pokemons/charmander", headers: auth_headers

          expect(response).to have_http_status(:ok)
        end

        it "returns Pokemon details" do
          get "/api/v1/pokemons/charmander", headers: auth_headers

          json = JSON.parse(response.body)

          expect(json["name"]).to eq("charmander")
          expect(json["types"]).to include("fire")
        end
      end

      context "with invalid Pokemon ID", vcr: { cassette_name: "pokemon_api_adapter/find_not_found" } do
        it "returns 404 Not Found" do
          get "/api/v1/pokemons/999999", headers: auth_headers

          expect(response).to have_http_status(:not_found)
        end

        it "returns error message" do
          get "/api/v1/pokemons/999999", headers: auth_headers

          json = JSON.parse(response.body)
          expect(json["error"]).to eq("Pokemon not found")
        end
      end
    end
  end
end
