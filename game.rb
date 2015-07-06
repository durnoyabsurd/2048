require 'forwardable'
require 'field'
require 'view'

class Game
  extend Forwardable

  def_delegators :view, :render, :game_over, :get_command

  def start
    @field = Field.new.add_random_two

    until @field.empty_cells.none? || @field.has_2048? do
      @field = @field.add_random_two
      render
      @field = @field.public_send("shift_#{get_command}")
    end

    game_over(@field.has_2048?)
  end

  def view
    View.new(@field)
  end
end
