def main_loop
  Ncurses.cbreak
  Ncurses.noecho
  Ncurses.keypad(Ncurses.stdscr, true)

  begin
    yield
  ensure
    Ncurses.echo
    Ncurses.endwin
  end
end

def textBox y, x, scr, background = false, text = "$ ", max_len = (scr.getmaxx-x-text.length-1)
  string = ""
  cursx = 0

  loop do
    if background
      scr.attron(A_REVERSE)
      scr.mvprintw(Ncurses.getmaxy(scr)-1, 0, "-"*(Ncurses.getmaxx(scr)))
      scr.attroff(A_REVERSE)
    end
    scr.mvaddstr(y, x, text)
    scr.mvaddstr(y, x+text.length, string)
    scr.move(y, x+text.length+cursx)
    ch = scr.getch
    case ch
    when KEY_LEFT
      cursx = [0, cursx-1].max
    when KEY_RIGHT
      cursx = [max_len, cursx+1, string.length].min
    when KEY_ENTER, KEY_EOL, KEY_EOS, ?\r, ?\n, 10
      return string
    when KEY_BACKSPACE, 263
      string = string[0..-2]
      cursx = [0, cursx-1].max
    when KEY_DL, 330
      if cursx < string.length
        unless cursx == 0
          string = string[0..cursx-1]+string[(cursx == 0 ? 0 : cursx+1)..-1]
        else
          string = string[1..-1]
        end
      end
    when 32..126
      if string.length <= max_len
        string.insert(cursx, ch.chr)
        cursx = [max_len, cursx+1].min
      end
    end
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

  def update
    @cur_llen = @file[cy].length

    @cx = [@cx, @cur_llen].min
  end

  def redraw
    @scr.clear
    @file.each do |line|
      @scr.mvprintw(@file.index(line), 0, line)
    end
    
    @scr.attron(A_REVERSE)
    @scr.mvaddstr(@cy, @cx, "@")
    @scr.mvprintw(Ncurses.getmaxy(@scr)-1, 0, "-"*(Ncurses.getmaxx(@scr)))
    @scr.attroff(A_REVERSE)
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
