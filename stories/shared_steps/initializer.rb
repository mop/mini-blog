require 'spec/story/step_group'

# Monkeypatches the given module into RSpec
# The module must have the name ModuleNameHelper and have two submodules:
# ModuleNameGroupMethods and ModuleNameMethods. The methods in 
# the GroupMethods module are available in the steps_for-block and the methods
# in the Methods module are available in the Given, When and Then blocks
def include_shared_steps(mod)
  base_name = mod.to_s.gsub(/Helper$/, "")
  class_module    = mod.const_get("#{base_name}GroupMethods")
  instance_module = mod.const_get("#{base_name}Methods")

  Spec::Story::StepGroup.send(:include, class_module)
  Spec::Story::World.send(:include, instance_module)
end

