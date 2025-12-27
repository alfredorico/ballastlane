require "rails_helper"

RSpec.describe Pokemon::FetchService do
  let(:repository) { instance_double(PokemonRepository) }
  subject(:service) { described_class.new(repository: repository) }

  describe "#call" do
    context "when Pokemon is found" do
      let(:pokemon_entity) do
        instance_double(
          PokemonEntity,
          to_h: {
            id: 25,
            name: "pikachu",
            weight: 6.0,
            height: 0.4,
            types: [ "electric" ],
            abilities: [ "static", "lightning-rod" ],
            photo: "https://example.com/pikachu.png",
            hq_photo: "https://example.com/pikachu-hq.png",
            description: "A yellow electric mouse Pokemon."
          }
        )
      end

      before do
        allow(repository).to receive(:find).with(25).and_return(pokemon_entity)
      end

      it "returns a successful ServiceResult" do
        result = service.call(25)

        expect(result).to be_a(ServiceResult)
        expect(result.success?).to be true
      end

      it "returns Pokemon data in the result" do
        result = service.call(25)

        expect(result.data[:id]).to eq(25)
        expect(result.data[:name]).to eq("pikachu")
        expect(result.data[:types]).to eq([ "electric" ])
      end

      it "includes all Pokemon attributes" do
        result = service.call(25)

        expect(result.data).to include(
          :id, :name, :weight, :height, :types, :abilities, :photo, :hq_photo, :description
        )
      end
    end

    context "when Pokemon is not found" do
      before do
        allow(repository).to receive(:find).with(999).and_return(nil)
      end

      it "returns a failed ServiceResult" do
        result = service.call(999)

        expect(result).to be_a(ServiceResult)
        expect(result.failure?).to be true
      end

      it "returns 'Pokemon not found' error message" do
        result = service.call(999)

        expect(result.error).to eq("Pokemon not found")
      end

      it "returns :not_found error code" do
        result = service.call(999)

        expect(result.code).to eq(:not_found)
      end
    end

    context "when searching by name" do
      let(:pokemon_entity) do
        instance_double(
          PokemonEntity,
          to_h: { id: 4, name: "charmander", types: [ "fire" ] }
        )
      end

      before do
        allow(repository).to receive(:find).with("charmander").and_return(pokemon_entity)
      end

      it "returns successful result for valid name" do
        result = service.call("charmander")

        expect(result.success?).to be true
        expect(result.data[:name]).to eq("charmander")
      end
    end
  end

  describe "#initialize" do
    it "uses PokemonRepository by default" do
      service = described_class.new
      expect(service).to be_a(described_class)
    end

    it "accepts a custom repository" do
      custom_repo = instance_double(PokemonRepository)
      service = described_class.new(repository: custom_repo)
      expect(service).to be_a(described_class)
    end
  end
end
