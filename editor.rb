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
  attr_accessor :file, :cx, :cy, :scr, :last_line_cx, :cur_llen
  # :cur_llen -> current line length
  def initialize(file_to_open)
    @file = File.read(file_to_open).split("\n")
    @cx = 0
    @cy = 0
    @scr = Ncurses.initscr
    @has_colors = Ncurses.has_colors?
  end

  def redraw
    @cur_llen = @file[cy].length

    @cx = [@cx, @cur_llen].min

    @scr.clear
    
    @file.each do |line|
      @scr.mvprintw(@file.index(line), 0, line)
    end
    
    @scr.mvaddstr(@cy, @cx, "@")
    @scr.move(@cy, @cx)

    @scr.refresh
  end

  def move_down move_cx = false
    if @cy < Ncurses.getmaxy(@scr)-1 and @cy < @file.length-2
      @cy += 1
      if move_cx
        @cx = 0
      end
    end
  end
  def move_up move_cx = false
    if @cy > 0
      @cy -= 1
      if move_cx
        @cx = @file[@cy].length
      end
    end
  end
end
