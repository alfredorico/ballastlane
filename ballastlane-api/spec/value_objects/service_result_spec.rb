require "rails_helper"

RSpec.describe ServiceResult do
  describe ".success" do
    context "with data" do
      subject(:result) { described_class.success({ id: 1, name: "test" }) }

      it "creates a successful result" do
        expect(result.success?).to be true
        expect(result.failure?).to be false
      end

      it "stores the data" do
        expect(result.data).to eq({ id: 1, name: "test" })
      end

      it "has nil error and code" do
        expect(result.error).to be_nil
        expect(result.code).to be_nil
      end
    end

    context "without data" do
      subject(:result) { described_class.success }

      it "creates a successful result with nil data" do
        expect(result.success?).to be true
        expect(result.data).to be_nil
      end
    end
  end

  describe ".failure" do
    context "with error message only" do
      subject(:result) { described_class.failure("Something went wrong") }

      it "creates a failed result" do
        expect(result.success?).to be false
        expect(result.failure?).to be true
      end

      it "stores the error message" do
        expect(result.error).to eq("Something went wrong")
      end

      it "has nil code and data" do
        expect(result.code).to be_nil
        expect(result.data).to be_nil
      end
    end

    context "with error message and code" do
      subject(:result) { described_class.failure("Not found", code: :not_found) }

      it "stores the error code" do
        expect(result.code).to eq(:not_found)
      end

      it "stores the error message" do
        expect(result.error).to eq("Not found")
      end
    end
  end

  describe "#success?" do
    it "returns true for successful results" do
      result = described_class.success("data")
      expect(result.success?).to be true
    end

    it "returns false for failed results" do
      result = described_class.failure("error")
      expect(result.success?).to be false
    end
  end

  describe "#failure?" do
    it "returns false for successful results" do
      result = described_class.success("data")
      expect(result.failure?).to be false
    end

    it "returns true for failed results" do
      result = described_class.failure("error")
      expect(result.failure?).to be true
    end
  end

  describe "immutability" do
    it "freezes the object after creation" do
      result = described_class.success("data")
      expect(result).to be_frozen
    end

    it "prevents modification of instance variables" do
      result = described_class.success("data")
      expect { result.instance_variable_set(:@success, false) }.to raise_error(FrozenError)
    end
  end
end
