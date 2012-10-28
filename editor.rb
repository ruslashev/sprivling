def main_loop
  Ncurses.raw
  Ncurses.keypad(Ncurses.stdscr, true)
  Ncurses.noecho

  begin
    yield
  ensure
    Ncurses.echo
    Ncurses.nocbreak
    Ncurses.nl
    Ncurses.curs_set(1)
    Ncurses.endwin
  end
end

class Editor
  attr_accessor :file, :cx, :cy, :text_scr

  def initialize(file_to_open)
    @file = File.read(file_to_open).split("\n")
    @cx = 0
    @cy = 0
    @text_scr = Ncurses.initscr
  end
end
