# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'dummy truthy test' do
  it 'is truthy' do
    expect(true).to be_truthy
  end
end