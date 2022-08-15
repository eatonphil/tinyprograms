# frozen_string_literal: true

module Bf
  def self.run(prog)
    data_stack = Hash.new { 0 }
    data_pointer = 0

    instruction_pointer = 0
    instruction_stack = []

    while instruction_pointer < prog.length
      case prog[instruction_pointer]
      when ">"
        data_pointer += 1
      when "<"
        data_pointer -= 1
      when "+"
        data_stack[data_pointer] += 1
      when "-"
        data_stack[data_pointer] -= 1
      when "."
        STDOUT.putc(data_stack[data_pointer].chr)
      when ","
        data_stack[data_pointer] = STDIN.getc.ord
      when "["
        stack = 1
        ending = instruction_pointer + 1

        while stack > 0
          case prog[ending]
          when "["
            stack += 1
          when "]"
            stack -= 1
          end

          ending += 1  
        end

        if data_stack[data_pointer] == 0
          instruction_pointer = ending
        else
          instruction_stack << instruction_pointer
        end
      when "]"
        if data_stack[data_pointer] != 0
          instruction_pointer = instruction_stack.last - 1
        end
        instruction_stack.pop
      end

      instruction_pointer += 1
    end
  end
end

Bf.run(ARGF.read)
