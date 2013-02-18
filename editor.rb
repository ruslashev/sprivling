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

def textBox y, x, scr
  command = ""
  cx = 0
  scr.move(y, x)
  scr.refresh

  loop do
    case ch = scr.getch
      when 32..126
        command.insert(cx, ch.chr)
        scr.mvprintw(y, x, command)
        cx += 1 if cx < [command.length, Ncurses.getmaxx(scr)].min
      when KEY_RIGHT
        cx += 1 if cx < [command.length, Ncurses.getmaxx(scr)].min
      when KEY_LEFT
        cx = [x, cx-1].max
      when KEY_ENTER
        return command
        break

    end
      scr.move(y, x+cx)
      scr.refresh
  end
end

class Editor
  attr_accessor :file, :cx, :cy, :scr, :cur_llen, :insert_mode
  # :cur_llen -> current line length

  def initialize(file_to_open)
    @file = File.read(file_to_open).split("\n")
    @cx = 0
    @cy = 0
    @scr = Ncurses.initscr
    @has_colors = Ncurses.has_colors?
    @insert_mode = true # oh geezus please forgive my soul
  end

  def redraw
    @cur_llen = @file[cy].length

    @cx = [@cx, @cur_llen].min

    @scr.clear
    
    @file.each do |line|
      @scr.mvprintw(@file.index(line), 0, line)
    end
    
    #@scr.attron(A_REVERSE)
    @scr.mvaddstr(@cy, @cx, "@")
    #@scr.mvprintw(Ncurses.getmaxy(scr)-1, 0, "-"*(Ncurses.getmaxx(scr)))
    @scr.mvprintw(Ncurses.getmaxy(scr)-1, 0, "INSERT") if @insert_mode
    #@scr.attroff(A_REVERSE)

    @scr.refresh
  end

  def move_down move_cx = false
    if @cy < Ncurses.getmaxy(@scr)-1 and @cy < @file.length-1
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
