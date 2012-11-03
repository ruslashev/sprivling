def main_loop
  Ncurses.raw
  Ncurses.nonl
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
  attr_accessor :file, :cx, :cy, :scr

  def initialize(file_to_open)
    @file = File.read(file_to_open).split("\n")
    @cx = 0
    @cy = 0
    @scr = Ncurses.initscr
    @has_colors = Ncurses.has_colors?
  end

  def redraw
    @scr.clear
    
    @file.each do |line|
      @scr.mvprintw(@file.index(line), 0, line)
    end
    
    @scr.mvaddstr(@cy, @cx, "@")
    @scr.move(@cy, @cx)

    @scr.refresh
  end
end
