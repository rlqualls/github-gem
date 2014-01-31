require "ncursesw"

module GitHub
  module UI
    class CursesMenu

      KEY_C = 99
      KEY_Q = 113
      KEY_J = 106
      KEY_K = 107
      KEY_UP = 258
      KEY_DOWN = 259

      def initialize(data)
        @data = data
        @size = data.size
        begin
          Ncurses.initscr
          Ncurses.cbreak
          Ncurses.start_color
          Ncurses.noecho
          Ncurses.nonl
          # Ncurses.keypad(screen, true)
          
          position = 0
          
          menu = Ncurses::WINDOW.new(@size + 2, Ncurses.COLS,1,1)
          menu.border(*([0]*8))
          # menu.box('|', '-')
          draw_menu(menu, position)
          while ch = menu.wgetch
            case ch
            when KEY_K, KEY_UP
              # draw_info menu, 'move up'
              position -= 1
            when KEY_J, KEY_DOWN
              # draw_info menu, 'move down'
              position += 1
            when KEY_C
              clone
              break
            when KEY_Q
              exit
            end
            position = @size - 1 if position < 0
            position = 0 if position > @size - 1
            draw_menu(menu, position)
          end
        ensure
          clean_up
        end

      end

      def draw_menu(menu, active_index=nil)
        @data.size.times do |i|
          menu.move(i + 1, 1)
          menu.attrset(i == active_index ? Ncurses::A_STANDOUT : Ncurses::A_NORMAL)
          menu_item = @data[i][0..Ncurses.COLS - 10]
          if @data[i].length > Ncurses.COLS - 10
            menu_item << "..."
          end
          menu.addstr(menu_item)           
        end
      end

      def clean_up
        Ncurses.echo
        Ncurses.nocbreak
        Ncurses.nl
        Ncurses.endwin
      end

      def clone
        clean_up
        puts "Placeholder: You tried to clone the repository!"
      end
      
    end
  end
end
 
