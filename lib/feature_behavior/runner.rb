module FeatureBehavior
  class Runner

    def self.run(description, example = nil, no_skip = true, &block)
      new(description, example, no_skip, &block).run
    end

    attr_reader :description, :example, :example_block, :skipped

    def initialize(description, example = nil, no_skip = true, &block)
      @description = description
      @example = example
      @example_block = block
      @skipped = !no_skip
    end

    def run
      before_behavior
      notify :behavior_started

      if skipped
        reporter.notify :behavior_skipped, skipped_behavior_args
      else
        run_example!
        notify :behavior_passed
      end

      notify :behavior_terminated
      after_behavior
    end


    private

    def after_behavior
      metadata[:description_args].pop
      refresh_description
    end

    def before_behavior
      metadata[:description_args].push(description)
      refresh_description
    end

    def current_example
      @current_example ||= example || RSpec.current_example
    end

    def metadata
      current_example.metadata
    end

    def notify(event)
      reporter.notify event, description
    end

    def refresh_description
      metadata[:description] = metadata[:description_args].join(', ')

      metadata[:full_description] = [
        metadata[:example_group][:full_description],
      ].concat(metadata[:description_args]).join(', ')
    end

    def reporter
      current_example.reporter
    end

    def run_example!
      example_block.call
    end

    def skipped_behavior_args
      {
        current_behavior: description,
        example_group_description: metadata[:example_group][:full_description],
        behavior_description_args: metadata[:description_args],
        location: metadata[:location],
      }
    end

  end
end
