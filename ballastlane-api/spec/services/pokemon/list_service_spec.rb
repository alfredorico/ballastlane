require "rails_helper"

RSpec.describe Pokemon::ListService do
  let(:repository) { instance_double(PokemonRepository) }
  subject(:service) { described_class.new(repository: repository) }

  describe "#call" do
    let(:pokemon_list) do
      {
        results: [
          { id: 1, name: "bulbasaur", photo: "https://example.com/1.png" },
          { id: 2, name: "ivysaur", photo: "https://example.com/2.png" },
          { id: 3, name: "venusaur", photo: "https://example.com/3.png" }
        ],
        count: 100
      }
    end

    context "when repository returns data" do
      before do
        allow(repository).to receive(:all).and_return(pokemon_list)
      end

      it "returns a successful ServiceResult" do
        result = service.call

        expect(result).to be_a(ServiceResult)
        expect(result.success?).to be true
      end

      it "returns pokemons array" do
        result = service.call

        expect(result.data[:pokemons]).to be_an(Array)
        expect(result.data[:pokemons].length).to eq(3)
      end

      it "returns pagination metadata" do
        result = service.call

        expect(result.data[:pagination]).to include(
          :page, :per_page, :total, :total_pages, :next_page, :previous_page
        )
      end
    end

    context "pagination calculations" do
      before do
        allow(repository).to receive(:all).and_return(pokemon_list)
      end

      it "calculates total_pages correctly" do
        result = service.call(page: 1, per_page: 20)

        expect(result.data[:pagination][:total_pages]).to eq(5)
      end

      it "returns next_page when not on last page" do
        result = service.call(page: 1, per_page: 20)

        expect(result.data[:pagination][:next_page]).to eq(2)
      end

      it "returns nil next_page on last page" do
        result = service.call(page: 5, per_page: 20)

        expect(result.data[:pagination][:next_page]).to be_nil
      end

      it "returns nil previous_page on first page" do
        result = service.call(page: 1, per_page: 20)

        expect(result.data[:pagination][:previous_page]).to be_nil
      end

      it "returns previous_page when not on first page" do
        result = service.call(page: 3, per_page: 20)

        expect(result.data[:pagination][:previous_page]).to eq(2)
      end
    end

    context "parameter handling" do
      it "passes correct limit and offset to repository" do
        expect(repository).to receive(:all).with(limit: 10, offset: 20).and_return(pokemon_list)

        service.call(page: 3, per_page: 10)
      end

      it "uses default per_page of 20" do
        expect(repository).to receive(:all).with(limit: 20, offset: 0).and_return(pokemon_list)

        service.call
      end

      it "defaults page to 1" do
        expect(repository).to receive(:all).with(limit: 20, offset: 0).and_return(pokemon_list)

        service.call(per_page: 20)
      end

      it "handles page as string" do
        expect(repository).to receive(:all).with(limit: 20, offset: 40).and_return(pokemon_list)

        service.call(page: "3", per_page: 20)
      end

      it "treats negative page as 1" do
        expect(repository).to receive(:all).with(limit: 20, offset: 0).and_return(pokemon_list)

        service.call(page: -5, per_page: 20)
      end

      it "treats zero page as 1" do
        expect(repository).to receive(:all).with(limit: 20, offset: 0).and_return(pokemon_list)

        service.call(page: 0, per_page: 20)
      end

      it "treats negative per_page as 1" do
        expect(repository).to receive(:all).with(limit: 1, offset: 0).and_return(pokemon_list)

        service.call(page: 1, per_page: -5)
      end
    end

    context "when repository returns nil" do
      before do
        allow(repository).to receive(:all).and_return(nil)
      end

      it "returns a failed ServiceResult" do
        result = service.call

        expect(result.failure?).to be true
      end

      it "returns appropriate error message" do
        result = service.call

        expect(result.error).to eq("Unable to fetch Pokemon list")
      end

      it "returns :api_error code" do
        result = service.call

        expect(result.code).to eq(:api_error)
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

  describe "DEFAULT_PER_PAGE" do
    it "is set to 20" do
      expect(described_class::DEFAULT_PER_PAGE).to eq(20)
    end
  end
end
