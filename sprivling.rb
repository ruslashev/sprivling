require "ncurses"
require "./editor"

include Ncurses

editor = Editor.new "public_code.rb"#ARGV[0]

main_loop do
  scr = editor.scr
  #Ncurses::start_color
  #Ncurses::init_pair(2, COLOR_WHITE, COLOR_BLACK)
  editor.redraw

  while (ch = scr.getch) != 27
    case ch
    when KEY_RIGHT#, 108
      editor.cx += 1 if editor.cx < Ncurses.getmaxx(scr)-1
    when KEY_LEFT#, 104
      editor.cx -= 1 if editor.cx > 0
    when KEY_DOWN#, 106
      editor.cy += 1 if editor.cy < Ncurses.getmaxy(scr)-1
    when KEY_UP#, 107
      editor.cy -= 1 if editor.cy > 0
    when 32..126
      if editor.cx <= editor.file[editor.cy].length
        editor.file[editor.cy].insert(editor.cx, ch.chr)
        editor.cx += 1
      end
    end

    editor.redraw
  end
end