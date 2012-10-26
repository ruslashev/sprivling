require "ncurses"
include Ncurses


Char = { "x" => 0, "y" => 0, "char" => "@", "color" => COLOR_RED }

def charcheck char
  return ["A".."Z", "a".."z", "0".."9", "(", ")"].concat(%w(~ ` ! @ # $ % ^ & * _ - = + { } [ ] " ' | \ / . , )).include?(char)
end

begin
  scr = Ncurses.initscr
  Ncurses.raw
  Ncurses.keypad(scr, true)
  Ncurses.noecho()
  # todo: specify a file to open
  file = File.read "public_code.rb"

  scr.mvaddstr(0, 0, file)
  scr.move(0, 0)

  while (ch = Ncurses.getch) != KEY_BACKSPACE
    case ch
      when KEY_RIGHT
        Char["x"] += 1 if Char["x"] < Ncurses.getmaxx(scr) - 1
      when KEY_LEFT
        Char["x"] -= 1 if Char["x"] > 0
      when KEY_UP
        Char["y"] -= 1 if Char["y"] > 0
      when KEY_DOWN
        Char["y"] += 1 if Char["y"] < Ncurses.getmaxy(scr) - 1
    end

    scr.clear
    scr.mvaddstr(0, 0, file)
    scr.mvaddstr(10, 0, Char["x"].to_s + ", " + Char["y"].to_s)
    #scr.attron(Ncurses.COLOR_PAIR(1))
    scr.mvprintw(Char["y"], Char["x"], Char["char"])
    scr.move(Char["y"], Char["x"])
    #scr.attroff(Ncurses.COLOR_PAIR(1))
    scr.refresh
  end
ensure
  Ncurses.echo
  Ncurses.nocbreak
  Ncurses.nl
  Ncurses.curs_set(1)
  Ncurses.endwin
end