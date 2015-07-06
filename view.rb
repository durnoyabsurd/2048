require 'curses'
include Curses

cbreak
noecho
init_screen
stdscr.keypad = true
start_color
init_pair(1, COLOR_WHITE, COLOR_BLACK)
init_pair(2, COLOR_WHITE, COLOR_BLUE)
init_pair(3, COLOR_BLACK, COLOR_RED)
init_pair(4, COLOR_WHITE, COLOR_GREEN)
init_pair(5, COLOR_BLACK, COLOR_YELLOW)
init_pair(6, COLOR_BLACK, COLOR_MAGENTA)
init_pair(7, COLOR_BLACK, COLOR_CYAN)
curs_set(0)
crmode
at_exit { close_screen }
refresh

class View < Struct.new(:field)
  COLORS = {
         0 => color_pair(1) | A_DIM,
         2 => color_pair(2) | A_DIM,
         4 => color_pair(3) | A_DIM,
         8 => color_pair(4) | A_DIM,
        16 => color_pair(5) | A_DIM,
        32 => color_pair(6) | A_DIM,
        64 => color_pair(7) | A_DIM,
       128 => color_pair(1) | A_NORMAL,
       256 => color_pair(2) | A_NORMAL,
       512 => color_pair(3) | A_NORMAL,
      1024 => color_pair(4) | A_NORMAL,
      2048 => color_pair(5) | A_NORMAL }

  S_WIDTH = 5
  S_HEIGHT = 3
  WIDTH = S_WIDTH * Field::SIZE + 2
  HEIGHT = S_HEIGHT * Field::SIZE + 2
  TOP = (lines - HEIGHT) / 2
  LEFT = (cols - WIDTH) / 2
  SPACE_CHAR = 32
  VICTORY_MESSAGE = 'YOU WIN!'
  LOOSE_MESSAGE = 'GAME OVER!'

  def get_command
    command = nil

    while command.nil?
      command = case getch
        when KEY_UP then :up
        when KEY_DOWN then :down
        when KEY_LEFT then :left
        when KEY_RIGHT then :right
        else nil
      end
    end

    command
  end

  def render
    field_win.clear
    field_win.box(?|, ?-)

    field.cells.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        top = i * S_HEIGHT + 1
        left = j * S_WIDTH + 1

        field_win.attron(COLORS[cell]) do
          S_HEIGHT.times.each do |ii|
            S_WIDTH.times.each do |jj|
              field_win.setpos(top + ii, left + jj)
              field_win.addch(SPACE_CHAR | A_REVERSE)
            end
          end

          unless cell.zero?
            field_win.setpos(top + S_HEIGHT / 2, left + S_WIDTH / 2)
            field_win << cell.to_s
          end
        end
      end
    end

    field_win.refresh
  end

  def game_over(victory)
    render

    message = victory ? VICTORY_MESSAGE : LOOSE_MESSAGE
    color = victory ? 4 : 3
    height = 5
    width = message.size + 4
    message_win = Window.new(height, width, (lines - height) / 2, (cols - width) / 2)

    message_win.attron(color_pair(color) | A_NORMAL) do
      x = width / 2 - message.size / 2 - 2
      message_win.setpos(height / 2 - 1, x)
      message_win << ' ' * width
      message_win.setpos(height / 2, x)
      message_win << "  #{message}  "
      message_win.setpos(height / 2 + 1, x)
      message_win << ' ' * width
    end

    message_win.refresh
    getch
    message_win.close
    field_win.close
  end

  private

  def field_win
    @field_win ||= Window.new(HEIGHT, WIDTH, TOP, LEFT)
  end
end
