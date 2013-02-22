require "ncurses"
require "./editor"

include Ncurses

editor = Editor.new "public_code.rb"#ARGV[0]

main_loop do
  scr = editor.scr
  #Ncurses::start_color
  #Ncurses::init_pair(2, COLOR_WHITE, COLOR_BLACK)
  editor.redraw

  while (ch = scr.getch)
    case ch
    when KEY_RIGHT
      if editor.cx < [editor.cur_llen, Ncurses.getmaxx(scr)-1].min
        editor.cx += 1
      else
        editor.move_down true
      end
    when KEY_LEFT
      if editor.cx > 0
        editor.cx -= 1
      else
        editor.move_up true
      end
    when KEY_DOWN
      editor.move_down
    when KEY_UP
      editor.move_up
    when 32..126
      editor.file[editor.cy].insert(editor.cx, ch.chr)
      editor.cx += 1
    when KEY_BACKSPACE
      editor.file[editor.cy] = editor.file[editor.cy][0..-2]
      editor.cx = [0, editor.cx-1].max
      awfawgh
    when 27 # escape
      editor.insert_mode = ! editor.insert_mode
    end
    editor.update

    if !editor.insert_mode
      case textBox(Ncurses.getmaxy(scr)-1, 1, scr, true)
        when "q"
          break
        else
          editor.insert_mode = true
      end
    end
    editor.redraw

    scr.attron(A_REVERSE)
    scr.mvprintw(Ncurses.getmaxy(scr)-1, 0, "INSERT") if editor.insert_mode
    scr.attroff(A_REVERSE)
  end
end
