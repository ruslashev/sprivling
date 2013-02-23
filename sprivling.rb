require "ncurses"
require "./editor"

include Ncurses

editor = Editor.new "public_code.rb"#ARGV[0]

main_loop editor do |ed|
  scr = ed.scr
  #Ncurses::start_color
  #Ncurses::init_pair(2, COLOR_WHITE, COLOR_BLACK)
  ed.update
  ed.redraw

  while (ch = scr.getch)
    case ch
    when KEY_RIGHT
      if ed.cx < [ed.cur_llen, Ncurses.getmaxx(scr)-1].min
        ed.cx += 1
      else
        ed.move_down true
      end
    when KEY_LEFT
      if ed.cx > 0
        ed.cx -= 1
      else
        ed.move_up true
      end
    when KEY_DOWN
      ed.move_down
    when KEY_UP
      ed.move_up
    when 32..126
      ed.file[ed.cy].insert(ed.cx, ch.chr)
      ed.cx += 1
    when KEY_BACKSPACE
      ed.file[ed.cy] = ed.file[ed.cy][0..-2]
      ed.cx = [0, ed.cx-1].max
      awfawgh
    when 27 # escape
      ed.insert_mode = ! ed.insert_mode
    when KEY_ENTER, KEY_EOL, KEY_EOS, ?\r, ?\n, 10
      if ed.cx > 0
        to_copy = ed.file[ed.cy][ed.cx..-1]
        ed.file[ed.cy] = ed.file[ed.cy][0..ed.cx-1]
        ed.file.insert(ed.cy+1, to_copy)
      else
        ed.file.insert(ed.cy, '')
      end
      ed.move_down
      ed.cx = 0
    end
    ed.update

    if !ed.insert_mode
      case textBox(Ncurses.getmaxy(scr)-1, 1, scr, true)
        when "q"
          break
        else
          ed.insert_mode = true
      end
    end
    ed.redraw
  end
end
