require "befunger/interpreter"
require "befunger/version"

module Befunger
  def self.run(code)
    Befunger::Interpreter.new(code).run
  end
end