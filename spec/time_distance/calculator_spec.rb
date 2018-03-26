# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TimeDistance::Calculator do
  let(:calculator) { described_class.new(743.minutes.from_now, Time.zone.now) }

  before(:all) do
    Time.zone = ActiveSupport::TimeZone.new('EST')
    I18n.load_path = Dir[File.join('config', 'locales', '*.yml')]
  end

  it 'should calculate time distance' do
    units = calculator.units

    expect(units[:days]).to eq 0
    expect(units[:hours]).to eq 12
    expect(units[:minutes]).to eq 23
  end

  it 'should correctly reorder format keys' do
    format_keys = [:minutes, :hours, :months, :days]

    units = described_class.new(743.minutes.from_now, Time.zone.now, format: format_keys).units

    expect(units[:months]).to eq 0
    expect(units[:days]).to eq 0
    expect(units[:hours]).to eq 12
    expect(units[:minutes]).to eq 23
  end

  it 'should translate distance to string' do
    expect(calculator.to_s).to eq '12 hours 23 minutes'
  end

  it 'should detect negative distance' do
    calculator = described_class.new(7743.minutes.ago, Time.zone.now)

    expect(calculator.to_s).to eq '5 days 9 hours 3 minutes ago'
  end

  it 'should skip zero units' do
    calculator = described_class.new(2.weeks.ago, Time.zone.now, format: [:weeks, :days, :hours, :minutes])

    expect(calculator.to_s).to eq '2 weeks ago'
  end
end
