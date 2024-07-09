# frozen_string_literal: true

require_relative "feature_behavior/version"

require 'feature_behavior/dsl'
require 'feature_behavior/formatter'
require 'feature_behavior/runner'

module FeatureBehavior
  class Error < StandardError; end

end
