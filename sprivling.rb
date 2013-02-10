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
        if editor.cx < [editor.cur_llen, Ncurses.getmaxx(scr)-1].min
          editor.cx += 1
        else
          editor.move_down true
        end
      when KEY_LEFT#, 104
        if editor.cx > 0
          editor.cx -= 1
        else
          editor.move_up true
        end
      when KEY_DOWN#, 106
        editor.move_down
      when KEY_UP#, 107
        editor.move_up
      when 32..126
        #if editor.cx <= editor.cur_llen
          editor.file[editor.cy].insert(editor.cx, ch.chr)
          editor.cx += 1
        #end
      end

      editor.redraw
  end
end