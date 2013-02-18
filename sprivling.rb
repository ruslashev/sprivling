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
    case editor.insert_mode
      when true
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
          when 27 # escape
            editor.insert_mode = ! editor.insert_mode
        end
      editor.redraw

      when false
        textBox(Ncurses.getmaxy(scr)-1, 2, scr)
    end
  end
end