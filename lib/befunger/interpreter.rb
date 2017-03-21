module Befunger
  class Interpreter
    DIRECTIONS = {
      right: { x: 1, y: 0 },
      down:  { x: 0, y: 1 },
      left:  { x: -1, y: 0 },
      up:    { x: 0, y: -1 }
    }

    def initialize(code)
      @code_array     = code.split("\n").map { |line| line.split('') }
      @code_pointer   = { x: 0, y: 0 }
      @code_direction = DIRECTIONS[:right]
      @stack          = []
      @output         = []
    end

    def read_instruction
      @code_array[@code_pointer[:y]][@code_pointer[:x]]
    end

    def move_pointer
      @code_pointer[:x] += @code_direction[:x]
      @code_pointer[:y] += @code_direction[:y]
    end

    def run
      while read_instruction != '@'
        handle_instruction(read_instruction)
      end

      @output.join('')
    end

    def handle_instruction(instruction)

      # Numbers
      if ('0'..'9').include? instruction
        @stack.push(instruction.to_i)

      # Binary Stack Operations
      elsif ['+', '-', '*', '/', '%', '`'].include? instruction
        a = @stack.pop
        b = @stack.pop

        value = case instruction
          when '+' then b + a
          when '*' then b * a
          when '-' then b - a
          when '/' then b / a
          when '%' then b % a
          when '`' then b > a ? 1 : 0
        end

        @stack.push(value)

      # Setter, Getter
      elsif ['p', 'g'].include? instruction
        a = @stack.pop
        b = @stack.pop
        case instruction
        when 'p' then @code_array[a][b] = @stack.pop.chr
        when 'g' then @stack.push @code_array[a][b].ord
        end

      # Operations with one stack value
      elsif ['!', '$', '.', ','].include? instruction
        a = @stack.pop

        case instruction
        when '!' then @stack.push(a == 0 ? 1 : 0)
        when '.' then @output.push(a)
        when ',' then @output.push(a.chr)
        end

      # Direction changes
      elsif ['>', '<', 'v', '^', '?', '_', '|'].include? instruction
        @code_direction = case instruction
        when '>' then DIRECTIONS[:right]
        when '<' then DIRECTIONS[:left]
        when 'v' then DIRECTIONS[:down]
        when '^' then DIRECTIONS[:up]
        when '?' then DIRECTIONS.values.sample
        when '_' then DIRECTIONS[@stack.pop == 0 ? :right : :left]
        when '|' then DIRECTIONS[@stack.pop == 0 ? :down : :up]
        end

      # String Mode
      elsif instruction == '"'
        move_pointer # Skip the first quote

        loop do
          instruction = read_instruction
          break if instruction == '"'
          @stack.push(instruction.ord)
          move_pointer
        end

      # Swap
      elsif instruction == '\\'
        if @stack.size == 1
          @stack.push(0)
        else
          @stack[-1], @stack[-2] = @stack[-2], @stack[-1]
        end

      # Duplicate
      elsif instruction == ":"
        @stack.push(@stack.empty? ? 0 : @stack.last)

      # Skip
      elsif instruction == '#'
        move_pointer

      elsif instruction != ' '
        raise "Invalid Instruction '#{instruction}'"
      end

      move_pointer
    end
  end
end