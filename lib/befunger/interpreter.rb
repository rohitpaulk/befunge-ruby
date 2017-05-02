module Befunger
  # {Befunger::Interpreter} is responsible for running Befunge code.
  #
  # The only input to the Interpreter is the code to be executed,
  # passed in as a string. Lines are to be separated with the `\n`
  # character.
  #
  # Example usage:
  #
  # ```
  # output = Befunger::Interpreter.new(code_string).run
  # ```
  class Interpreter
    # The Befunge code to be run, stored as a 2D array of characters.
    #
    # For a program like this:
    #
    # ```
    # >987v>.v
    # v456<  :
    # >321 ^ _@
    # ```
    #
    # `code_array` will look like:
    #
    # ```
    # [
    #   [">", "9", "8", "7", "v", ">", ".", "v"],
    #   ["v", "4", "5", "6", "<", " ", " ", ":"],
    #   [">", "3", "2", "1", " ", "^", " ", "_", "@"]
    # ]
    # ```
    #
    attr_reader :code_array

    # Human friendly constants for the direction to move a code_pointer in.
    DIRECTIONS = {
      right: { x: 1, y: 0 },
      down:  { x: 0, y: 1 },
      left:  { x: -1, y: 0 },
      up:    { x: 0, y: -1 }
    }

    # Default interpreter state.
    #
    # This gets copied and then modified and passed from instruction to instruction
    # in the interpreter loop.
    #
    # - ## `code_pointer`
    #
    # Denotes what the position of the current instruction is.
    #
    # `x` and `y` are positive values starting at 0, calculated like this:
    #
    # ```
    # .----------------------------------------------> x
    # |
    # |
    # |
    # |  (code_array)                  --------> {x: 5, y: 0}
    # |                               |
    # |  [                            |
    # |
    # |    [">", "9", "8", "7", "v", ">", ".", "v"],
    # |
    # |    ["v", "4", "5", "6", "<", " ", " ", ":"],
    # |
    # |    [">", "3", "2", "1", " ", "^", " ", "_", "@"]
    # |
    # |  ]                                           |
    # |                                              |
    # |                                               ------> {x: 8, y: 2}
    # v
    #
    # y
    #
    # ```
    #
    # ## `code_direction`
    #
    # The next direction to move `code_pointer` in.
    #
    # `x` and `y` are either 0, 1, or -1.
    #
    # - (x: 1, y: 0) means the next move is towards the right
    # - (x: 0, y: 1) means the next move is downwards
    # - ... so on and so forth.
    #
    # Human-friendly constants available in {Interpreter::DIRECTIONS}.
    #
    # ## `stack`
    #
    # A stack to store values, manipulated by the befunge code being run.
    #
    # ## `output`
    #
    # Output returned from program, represented as an array of characters.
    INITIAL_STATE = {
      code_pointer: {x: 0, y: 0}, # Instructions are evaluated from the top-left
      code_direction: Interpreter::DIRECTIONS[:right],
      stack: [],
      output: []
    }

    # @param code [String] the befunge code to be run. Lines must be separated with newline characters
    def initialize(code)
      @code_array = code.split("\n").map { |line| line.chars }
    end

    # @return [String] output of program execution
    def run
      state = Interpreter::INITIAL_STATE # TODO: `deep_dup`?

      loop do
        instruction = get_instruction(state[:code_pointer])

        break if instruction == '@'

        state = handle_instruction(instruction, state)
      end

      state[:output].join('')
    end

    private

    # Returns the next instruction to be processed
    #
    # @param code_pointer [Hash] the current +code_pointer+, in the form: `{x: 0, y: 3}`
    # @return [String] the next instruction to be processed
    def get_instruction(code_pointer)
      @code_array[code_pointer[:y]][code_pointer[:x]]
    end

    # Moves the `code_pointer` in the specified `code_direction`, and returns the modified
    # `code_pointer`
    #
    # @param code_pointer [Hash] the current +code_pointer+, in the form: `{x: 0, y: 3}`
    # @param code_direction [Hash] the current +code_direction+, in the form: `{x: 0, y: 1}`
    # @return [Hash] the modified `code_pointer`
    def move_pointer(code_pointer, code_direction)
      code_pointer[:x] += code_direction[:x]
      code_pointer[:y] += code_direction[:y]

      code_pointer
    end

    # Given an `instruction` and `state` - processes the instruction and returns
    # the modified `state`.
    #
    # @param instruction [String] the instruction to be executed
    # @param state [Hash] the current interpreter state
    # @return [Hash] the modified `state`
    def handle_instruction(instruction, state)
      output         = state[:output].dup
      stack          = state[:stack].dup
      code_pointer   = state[:code_pointer].dup
      code_direction = state[:code_direction].dup

      # Numbers
      if ('0'..'9').include? instruction
        stack.push(instruction.to_i)

      # Binary Stack Operations
      elsif ['+', '-', '*', '/', '%', '`'].include? instruction
        a = stack.pop
        b = stack.pop

        value = case instruction
          when '+' then b + a
          when '*' then b * a
          when '-' then b - a
          when '/' then b / a
          when '%' then b % a
          when '`' then b > a ? 1 : 0
        end

        stack.push(value)

      # Setter, Getter
      elsif ['p', 'g'].include? instruction
        y = stack.pop
        x = stack.pop
        case instruction
        when 'p' then @code_array[y][x] = stack.pop.chr
        when 'g' then stack.push @code_array[y][x].ord
        end

      # Operations with one stack value
      elsif ['!', '$', '.', ','].include? instruction
        a = stack.pop

        case instruction
        when '!' then stack.push(a == 0 ? 1 : 0)
        when '.' then output.push(a)
        when ',' then output.push(a.chr)
        end

      # Direction changes
      elsif ['>', '<', 'v', '^', '?', '_', '|'].include? instruction
        code_direction = case instruction
        when '>' then DIRECTIONS[:right]
        when '<' then DIRECTIONS[:left]
        when 'v' then DIRECTIONS[:down]
        when '^' then DIRECTIONS[:up]
        when '?' then DIRECTIONS.values.sample
        when '_' then DIRECTIONS[stack.pop == 0 ? :right : :left]
        when '|' then DIRECTIONS[stack.pop == 0 ? :down : :up]
        end

      # String Mode
      elsif instruction == '"'
        code_pointer = move_pointer(code_pointer, code_direction) # Skip the first quote

        loop do
          instruction = get_instruction(code_pointer)
          break if instruction == '"'
          stack.push(instruction.ord)
          code_pointer = move_pointer(code_pointer, code_direction)
        end

      # Swap
      elsif instruction == '\\'
        if stack.size == 1
          stack.push(0)
        else
          stack[-1], stack[-2] = stack[-2], stack[-1]
        end

      # Duplicate
      elsif instruction == ":"
        stack.push(stack.empty? ? 0 : stack.last)

      # Skip
      elsif instruction == '#'
        code_pointer = move_pointer(code_pointer, code_direction)

      elsif instruction != ' '
        raise "Invalid Instruction '#{instruction}'"
      end

      {
        code_pointer: move_pointer(code_pointer, code_direction),
        code_direction: code_direction,
        stack: stack,
        output: output
      }
    end
  end
end
