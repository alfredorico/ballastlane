require "rails_helper"

RSpec.describe PokemonEntity do
  let(:attributes) do
    {
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
  end

  describe "#initialize" do
    context "with all attributes" do
      subject(:entity) { described_class.new(attributes) }

      it "sets all attributes correctly" do
        expect(entity.id).to eq(25)
        expect(entity.name).to eq("pikachu")
        expect(entity.weight).to eq(6.0)
        expect(entity.height).to eq(0.4)
        expect(entity.types).to eq([ "electric" ])
        expect(entity.abilities).to eq([ "static", "lightning-rod" ])
        expect(entity.photo).to eq("https://example.com/pikachu.png")
        expect(entity.hq_photo).to eq("https://example.com/pikachu-hq.png")
        expect(entity.description).to eq("A yellow electric mouse Pokemon.")
      end
    end

    context "with missing optional attributes" do
      subject(:entity) { described_class.new(id: 1, name: "bulbasaur") }

      it "defaults types to empty array" do
        expect(entity.types).to eq([])
      end

      it "defaults abilities to empty array" do
        expect(entity.abilities).to eq([])
      end

      it "allows nil for other attributes" do
        expect(entity.weight).to be_nil
        expect(entity.height).to be_nil
        expect(entity.photo).to be_nil
        expect(entity.hq_photo).to be_nil
        expect(entity.description).to be_nil
      end
    end

    context "with empty attributes" do
      subject(:entity) { described_class.new }

      it "creates entity with nil values and empty arrays" do
        expect(entity.id).to be_nil
        expect(entity.name).to be_nil
        expect(entity.types).to eq([])
        expect(entity.abilities).to eq([])
      end
    end
  end

  describe "#to_h" do
    subject(:entity) { described_class.new(attributes) }

    it "returns a hash with all attributes" do
      result = entity.to_h

      expect(result).to be_a(Hash)
      expect(result[:id]).to eq(25)
      expect(result[:name]).to eq("pikachu")
      expect(result[:weight]).to eq(6.0)
      expect(result[:height]).to eq(0.4)
      expect(result[:types]).to eq([ "electric" ])
      expect(result[:abilities]).to eq([ "static", "lightning-rod" ])
      expect(result[:photo]).to eq("https://example.com/pikachu.png")
      expect(result[:hq_photo]).to eq("https://example.com/pikachu-hq.png")
      expect(result[:description]).to eq("A yellow electric mouse Pokemon.")
    end

    it "includes all expected keys" do
      expected_keys = [ :id, :name, :weight, :height, :types, :abilities, :photo, :hq_photo, :description ]
      expect(entity.to_h.keys).to match_array(expected_keys)
    end
  end
end
