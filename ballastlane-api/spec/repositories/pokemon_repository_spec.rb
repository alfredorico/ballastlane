require "rails_helper"

RSpec.describe PokemonRepository do
  let(:adapter) { instance_double(PokemonApiAdapter) }
  subject(:repository) { described_class.new(adapter: adapter) }

  describe "#initialize" do
    it "accepts a custom adapter" do
      custom_adapter = instance_double(PokemonApiAdapter)
      repo = described_class.new(adapter: custom_adapter)

      expect(repo).to be_a(described_class)
    end

    it "uses PokemonApiAdapter by default" do
      repo = described_class.new
      expect(repo).to be_a(described_class)
    end
  end

  describe "#find" do
    let(:pokemon_entity) do
      PokemonEntity.new(
        id: 25,
        name: "pikachu",
        weight: 6.0,
        height: 0.4,
        types: [ "electric" ],
        abilities: [ "static" ],
        photo: "https://example.com/pikachu.png"
      )
    end

    it "delegates to the adapter" do
      expect(adapter).to receive(:find).with(25).and_return(pokemon_entity)

      result = repository.find(25)

      expect(result).to eq(pokemon_entity)
    end

    it "returns nil when adapter returns nil" do
      expect(adapter).to receive(:find).with(999).and_return(nil)

      result = repository.find(999)

      expect(result).to be_nil
    end

    it "accepts string identifiers" do
      expect(adapter).to receive(:find).with("pikachu").and_return(pokemon_entity)

      result = repository.find("pikachu")

      expect(result).to eq(pokemon_entity)
    end
  end

  describe "#all" do
    let(:pokemon_list) do
      {
        results: [
          { id: 1, name: "bulbasaur", photo: "https://example.com/1.png" },
          { id: 2, name: "ivysaur", photo: "https://example.com/2.png" }
        ],
        count: 1302
      }
    end

    it "delegates to the adapter with default parameters" do
      expect(adapter).to receive(:all).with(limit: 20, offset: 0).and_return(pokemon_list)

      result = repository.all

      expect(result).to eq(pokemon_list)
    end

    it "passes custom limit and offset to adapter" do
      expect(adapter).to receive(:all).with(limit: 10, offset: 20).and_return(pokemon_list)

      result = repository.all(limit: 10, offset: 20)

      expect(result).to eq(pokemon_list)
    end

    it "returns nil when adapter returns nil" do
      expect(adapter).to receive(:all).with(limit: 20, offset: 0).and_return(nil)

      result = repository.all

      expect(result).to be_nil
    end
  end
end
