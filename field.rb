class Field
  SIZE = 4

  attr_reader :cells

  def initialize(cells = nil)
    @cells ||= cells || (0..(SIZE - 1)).map { Array.new(SIZE, 0) }
  end

  def shift_right
    new_cells = cells.map do |row|
      (0..(SIZE - 2)).reverse_each do |j|
        if row[j + 1] == row[j] || row[j].zero?
          row[j + 1] += row[j]
          row[j] = 0
        end
      end

      row.reject(&:zero?).tap { |r| r.unshift(0) until r.size == SIZE }
    end

    self.class.new(new_cells)
  end

  def shift_left
    reverse_x.shift_right.reverse_x
  end

  def shift_up
    reverse_y.reverse_x.shift_right.reverse_x.reverse_y
  end

  def shift_down
    reverse_x.reverse_y.shift_right.reverse_y.reverse_x
  end

  def reverse_x
    self.class.new(cells.map(&:reverse))
  end

  def reverse_y
    self.class.new(cells.transpose)
  end

  def empty_cells
    @empty_cells ||= cells.each_with_index.inject([]) do |result, (row, i)|
      empty_in_row = row.each_with_index.inject([]) { |r, (cell, j)| r << [i, j] if cell.zero?; r }
      result + empty_in_row
    end
  end

  def add_random_two
    i, j = empty_cells.sample
    new_cells = cells.map(&:dup)
    new_cells[i][j] = 2
    self.class.new(new_cells)
  end

  def has_2048?
    @has_2048 ||= cells.flatten.any? { |i| i == 2048 }
  end

  def to_s
    @to_s ||= cells.map { |row| row.map { |c| c.zero? ? '-' : c }.join(' ') }.join("\n") + "\n\n"
  end
end
