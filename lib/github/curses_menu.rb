require "curses"

module GitHub
  module UI
    class CursesMenu
      def initialize(data)
        @data = data
        @size = data.size
        Curses.init_screen
        Curses.start_color
        Curses.init_pair(1, Curses::COLOR_RED, Curses::COLOR_BLACK)
        Curses.noecho
        
        position = 0
        
        menu = Curses::Window.new(@size + 2,0,1,2)
        menu.box('|', '-')
        draw_menu(menu, position)
        while ch = menu.getch
          case ch
          when 'k', Curses::KEY_UP
            # draw_info menu, 'move up'
            position -= 1
          when 'j', Curses::KEY_DOWN
            # draw_info menu, 'move down'
            position += 1
          when 'q'
            exit
          end
          position = @size - 1 if position < 0
          position = 0 if position > @size - 1
          draw_menu(menu, position)
        end

      end

      def draw_menu(menu, active_index=nil)
        @data.size.times do |i|
          menu.setpos(i + 1, 1)
          menu.attrset(i == active_index ? Curses::A_STANDOUT : Curses::A_NORMAL)
          menu.addstr @data[i]
        end
      end
      
      def draw_info(menu, text)
        menu.setpos(1, 1)
        menu.attrset(Curses::A_NORMAL)
        menu.addstr text
      end
    end
  end
end
 
