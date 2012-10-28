require "ncurses"
require "./editor"

include Ncurses

editor = Editor.new "public_code.rb"#ARGV[0]

main_loop do
  scr = editor.text_scr

  scr.clear
  editor.file.each do |l|
    scr.mvaddstr(editor.file.index(l), 0, l)
  end
  scr.mvprintw(editor.cy, editor.cy, "@")
  scr.move(editor.cy, editor.cy)
  scr.refresh

  while (ch = scr.getch) != KEY_BACKSPACE
    case ch
    when KEY_RIGHT
      editor.cx += 1 if editor.cx < Ncurses.getmaxx(scr)-1
    when KEY_LEFT
      editor.cx -= 1 if editor.cx > 0
    when KEY_DOWN
      editor.cy += 1 if editor.cy < Ncurses.getmaxy(scr)-1
    when KEY_UP
      editor.cy -= 1 if editor.cy > 0
    end
  end
end
