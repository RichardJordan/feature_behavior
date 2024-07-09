require 'rspec'

require 'rspec/core/formatters/base_text_formatter'
require 'rspec/core/formatters/console_codes'
require 'rspec/core/formatters/documentation_formatter'

module FeatureBehavior
  class Formatter < RSpec::Core::Formatters::DocumentationFormatter
    RSpec::Core::Formatters.register self,
      :example_failed,
      :example_passed,
      :example_started,
      :behavior_terminated,
      :behavior_passed,
      :behavior_skipped,
      :behavior_started,
      :dump_pending,
      :dump_summary


    attr_reader :current_behavior,
      :current_behavior_step,
      :current_description,
      :multi_step_example,
      :skipped_behaviors,
      :total_behaviors


    def initialize(output)
      super
      @current_behavior = ""
      @current_behavior_step = 0
      @current_description = ""
      @multi_step_example = false
      @skipped_behaviors = []
      @total_behaviors = 0
    end

    def behavior_passed(_notification)
      msg = "#{step}#{current_behavior}"

      if current_behavior_step == 1
        output.puts "#{step_indent}#{"-" * msg.length}"
      end

      @last_msg = msg
      output.puts colorized("#{step_indent}#{msg}", :success)
    end

    def behavior_skipped(notification)
      @skipped_behaviors << notification
      msg = "#{step}SKIPPED: #{current_behavior}"

      if current_behavior_step == 1
        output.puts "#{step_indent}#{"-" * msg.length}"
      end

      @last_msg = msg
      output.puts colorized("#{step_indent}#{msg}", :blue)
    end

    def behavior_started(notification)
      @total_behaviors += 1
      @current_behavior = notification
      @current_behavior_step += 1

      if current_behavior_step == 1
        @multi_step_example = true
        msg = "#{current_description}, multiple steps:"
        output.puts "#{current_indentation}#{msg}"
      end
    end

    def behavior_terminated(_notification)
    end

    def dump_pending(notification)
      super

      if @skipped_behaviors.length > 0
        msg = "\nBehaviors Pending: " \
          "(Behaviors listed here have been intentionally skipped pending attention)"
        @output << msg

        results = []

        @skipped_behaviors.each_with_index do |behavior, index|
          results << skipped_behavior_dump_string(behavior, index)
        end

        @output << colorized("\n#{results.join("\n")}\n", :blue)
      end
    end

    def dump_summary(notification)
      behavior_summary if @total_behaviors > 0
      super
    end

    def example_failed(_notification)
      if multi_step_example
        msg = "#{step}#{current_behavior} (Failed)"
        output.puts colorized("#{step_indent}#{msg}", :failure)
        output.puts "#{step_indent}#{"-" * msg.length}"
        reset_behavior
      end
      super
    end

    def example_passed(_notification)
      if multi_step_example
        output.puts "#{step_indent}#{"-" * @last_msg.length}"
        reset_behavior
      end
      super
    end

    def example_started(notification)
      @current_behavior = ""
      @current_behavior_step = 0
      @current_description = notification.example.description
      super
    end


    private

    def behavior_summary
      @output << "\n\nBehaviors:\n"

      @output << colorized(
        "\nTotal Behaviors Tested: #{total_behaviors}, Skipped: #{skipped_behaviors.length}\n",
        behavior_summary_color,
      )

      @output << "\nExamples:\n"
    end

    def behavior_summary_color
      skipped_behaviors.length > 0 ? :blue : :green
    end

    def colorized(text_string, color_scheme)
      console_color_wrapper.wrap(text_string, color_scheme)
    end

    def console_color_wrapper
      RSpec::Core::Formatters::ConsoleCodes
    end

    def reset_behavior
      @current_behavior = nil
      @multi_step_example = false
    end

    def skip_description_indent(idx)
      " " * (skip_indent_length + 1 - Math.log10(idx + 1).to_i)
    end

    def skip_indent
      " " * skip_indent_length
    end

    def skip_indent_length
      Math.log10(skipped_behaviors.length).to_i
    end

    def skipped_behavior_dump_string(bh, idx)
      colorized(
        "\n  #{idx + 1})#{skip_description_indent(idx)}#{bh[:example_group_description]}" \
        "\n     #{skip_indent}- Scenario: #{bh[:behavior_description_args].first}" \
        "\n     #{skip_indent}- Behavior: #{bh[:current_behavior]}",
        :blue
      ) + colorized(
        "\n     #{skip_indent}# Temporarily skipped with xbehavior" \
        "\n     #{skip_indent}# #{bh[:location]}",
        :cyan
      )
    end

    def step
      "Step#{step_number_indent}#{current_behavior_step}. "
    end

    def step_indent
      "#{current_indentation}#{' ' * step_indent_extra_space_count}"
    end

    def step_indent_extra_space_count
      2
    end

    def step_number_indent
      current_behavior_step > 9 ? " " : "  "
    end
  end
end
