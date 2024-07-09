module FeatureBehavior
  module DSL
    def behavior(description, example = nil, &block)
      Runner.run description, example, true, &block
    end

    def xbehavior(description, example = nil, &block)
      Runner.run description, example, false, &block
    end
  end
end
