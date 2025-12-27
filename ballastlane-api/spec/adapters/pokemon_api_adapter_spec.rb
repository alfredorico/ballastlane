require "rails_helper"

RSpec.describe PokemonApiAdapter do
  subject(:adapter) { described_class.new }

  describe "#find" do
    context "with valid Pokemon ID", vcr: { cassette_name: "pokemon_api_adapter/find_pikachu" } do
      it "returns a PokemonEntity" do
        result = adapter.find(25)

        expect(result).to be_a(PokemonEntity)
      end

      it "returns correct Pokemon data" do
        result = adapter.find(25)

        expect(result.id).to eq(25)
        expect(result.name).to eq("pikachu")
        expect(result.weight).to be_a(Float)
        expect(result.height).to be_a(Float)
        expect(result.types).to include("electric")
        expect(result.abilities).to be_an(Array)
        expect(result.photo).to be_a(String)
      end
    end

    context "with valid Pokemon name", vcr: { cassette_name: "pokemon_api_adapter/find_charmander" } do
      it "returns a PokemonEntity" do
        result = adapter.find("charmander")

        expect(result).to be_a(PokemonEntity)
        expect(result.name).to eq("charmander")
        expect(result.types).to include("fire")
      end
    end

    context "with invalid Pokemon ID", vcr: { cassette_name: "pokemon_api_adapter/find_not_found" } do
      it "returns nil" do
        result = adapter.find(999999)

        expect(result).to be_nil
      end
    end

    context "when API raises an error" do
      before do
        allow(PokeApi).to receive(:get).and_raise(StandardError.new("API Error"))
      end

      it "returns nil" do
        result = adapter.find(25)

        expect(result).to be_nil
      end
    end
  end

  describe "#all" do
    context "with default parameters", vcr: { cassette_name: "pokemon_api_adapter/list_default" } do
      it "returns a hash with results and count" do
        result = adapter.all

        expect(result).to be_a(Hash)
        expect(result).to have_key(:results)
        expect(result).to have_key(:count)
      end

      it "returns 20 Pokemon by default" do
        result = adapter.all

        expect(result[:results].length).to eq(20)
      end

      it "returns Pokemon with id, name, and photo" do
        result = adapter.all
        first_pokemon = result[:results].first

        expect(first_pokemon).to have_key(:id)
        expect(first_pokemon).to have_key(:name)
        expect(first_pokemon).to have_key(:photo)
      end

      it "returns total count" do
        result = adapter.all

        expect(result[:count]).to be > 0
      end
    end

    context "with custom limit", vcr: { cassette_name: "pokemon_api_adapter/list_limit_5" } do
      it "respects the limit parameter" do
        result = adapter.all(limit: 5, offset: 0)

        expect(result[:results].length).to eq(5)
      end
    end

    context "with custom offset", vcr: { cassette_name: "pokemon_api_adapter/list_offset_5" } do
      it "respects the offset parameter" do
        result = adapter.all(limit: 5, offset: 5)
        first_pokemon = result[:results].first

        expect(first_pokemon[:id]).to eq(6)
        expect(first_pokemon[:name]).to eq("charizard")
      end
    end

    context "when API raises an error" do
      before do
        allow(PokeApi).to receive(:get).and_raise(StandardError.new("API Error"))
      end

      it "returns nil" do
        result = adapter.all

        expect(result).to be_nil
      end
    end
  end
end
