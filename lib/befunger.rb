require "befunger/interpreter"
require "befunger/version"

# Example usage:
#
# ```
# code = ">987v>.v\nv456<  :\n>321 ^ _@\n"
# output = Befunger.run(code)
# ```
module Befunger
  # Runs befunge code and returns the output
  #
  # @param code [String] the code to be run, lines separated with newline characters.
  # @return [String] output of the program
  def self.run(code)
    Befunger::Interpreter.new(code).run
  end
end
