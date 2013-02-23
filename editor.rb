def main_loop editor
  Ncurses.cbreak
  Ncurses.noecho
  Ncurses.keypad(Ncurses.stdscr, true)

  begin
    yield editor
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
  attr_accessor :file, :cx, :cy, :scr, :cur_llen, :insert_mode, :mx, :my
  # :file -> array of lines of current file
  # :cx -> cursor position x
  # :scr -> editor's screen to draw to
  # :cur_llen -> current line length
  # :mx -> terminal x size (columns)

  def initialize(file_to_open)
    @file = File.read(file_to_open).split("\n")
    @cx = 0
    @cy = 0
    @scr = Ncurses.initscr
    @has_colors = Ncurses.has_colors?
    @insert_mode = true # oh geezus please forgive my soul
    @mx = Ncurses.getmaxx(@scr)
    @my = Ncurses.getmaxy(@scr)
  end

  def update
    @cur_llen = @file[cy].length

    @cx = [@cx, @cur_llen].min
  end

  def redraw
    @scr.clear
    @scr.attron(A_BOLD)
    @my.times do |y|
      @scr.mvprintw y, 0, '~'
    end
    @scr.attroff(A_BOLD)

    @file.each_with_index do |line, i|
      line += ' ' if line.length == 0
      @scr.mvprintw(i, 0, line)
    end
    
    @scr.attron(A_REVERSE)
    #@scr.mvaddstr(@cy, @cx, "@")
    @scr.mvprintw(@my-1, 0, "-"*(@mx))
    @scr.attron(A_BOLD)
    @scr.mvprintw(@my-1, 0, "INSERT") if @insert_mode
    @scr.attroff(A_BOLD)
    @scr.mvprintw(@my-1, @mx-5, "%i,%i", @cy+1, @cx+1) if @insert_mode
    @scr.attroff(A_REVERSE)
    @scr.move(@cy, @cx)
    @scr.refresh
  end

  def move_down move_cx = false
    if @cy < @my-1 and @cy < @file.length-1
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
