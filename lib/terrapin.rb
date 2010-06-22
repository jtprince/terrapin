require 'rubygame'

require 'ffi-opengl'

include GL
include GLU

include Rubygame
include Rubygame::Events

class Terrapin
  # basic template off of http://rubygame.org/forums/viewtopic.php?f=5&t=104

  include EventHandler::HasEventHandler

  def self.run
    Terrapin.new.go
    Rubygame.quit
  end

  def initialize
    init_screen
    init_clock
    init_queue
    init_hooks
    init_gl
  end

  def init_screen
    @screen = Screen.new [800, 600], 0, [HWSURFACE, DOUBLEBUF, OPENGL]
    @screen.title = 'Particles!'
  end

  def init_clock
    @clock = Clock.new
    @clock.target_framerate = 30
  end

  def init_queue
    @queue = EventQueue.new
    @queue.enable_new_style_events
  end

  def init_hooks
    make_magic_hooks :escape => :quit
  end

  def init_gl
    glClearColor 0.0, 0.0, 0.0, 0.0
    resize 800, 600
  end

  def go
    catch :quit do
      loop do
        handle_events
        draw
      end
    end
  end

  def handle_events
    @queue.each do |e|
      handle e
    end
  end

  def resize(w, h)
    h = 1 if h == 0
    glViewport 0, 0, w, h
    glMatrixMode GL_PROJECTION
    glLoadIdentity
    gluPerspective 45.0, w.to_f / h.to_f, 1.0, 1000.0
    glMatrixMode GL_MODELVIEW
  end

  def draw
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glMatrixMode GL_MODELVIEW
    glLoadIdentity

    glTranslated 0.0, 0.0, -20.0
    glBegin GL_QUADS
    glVertex2i  5,  5
    glVertex2i -5,  5
    glVertex2i -5, -5
    glVertex2i  5, -5
    glEnd

    Rubygame::GL.swap_buffers()
  end

  def quit
    puts 'Quitting!'
    throw :quit
  end

end

