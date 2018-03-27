# frozen_string_literal: true

require 'active_support/time'

module TimeDistance
  class Calculator
    MULTIPLES = {
      seconds: 1,
      minutes: 1.minute,
      hours: 1.hour,
      days: 1.day,
      weeks: 1.week,
      months: 1.month,
      years: 1.year
    }.freeze

    DEFAULTS = {
      format: [:months, :days, :hours, :minutes],
      translation_scope: 'datetime.time_distance'
    }.freeze

    attr_reader :options

    def initialize(time_from, time_to, options = {})
      @time_from = time_from
      @time_to = time_to
      @options = DEFAULTS.merge(options)

      @seconds = @time_from - @time_to
    end

    def to_s
      array = to_a.compact
      array << I18n.t(:ago, scope: options[:translation_scope]) if negative?

      array.join(' ')
    end

    def units
      @units ||= calculate
    end

    private

    def to_a
      options[:format].map do |unit|
        value = units[unit].to_i
        next unless value.positive?

        I18n.t(unit, scope: [options[:translation_scope], :units], count: value)
      end
    end

    def negative?
      @seconds.to_i < 0
    end

    def desc_sorted_unit_format
      options[:format].sort { |p, n| MULTIPLES[n] <=> MULTIPLES[p] }
    end

    def calculate
      values = {}

      desc_sorted_unit_format.inject(@seconds.abs.to_f.round) do |remainder, unit|
        multiple = MULTIPLES[unit]

        values[unit] = remainder / multiple
        remainder % multiple
      end

      values
    end
  end
end
