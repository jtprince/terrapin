#!/usr/bin/env ruby
 
require 'rubygems'
require 'rubygame'
require 'ffi-opengl'
require 'ffi-inliner'
require 'numrb/vec'

class GLEnv
  [GL, GLU].each do |const|
    include const
    extend const
  end

  def initialize(wide, high)


    #glViewport( 0, 0, wide, high)

    glDisable(GL_DEPTH_TEST)

    glClearColor( 0.0, 0.0, 0.0, 0.0 )
    #glClear(GL_COLOR_BUFFER_BIT)
    #glMatrixMode( GL_PROJECTION )
    #glLoadIdentity( )
    #glOrtho(0, wide, high, 0, 0, 1)
    #gluPerspective( 35, wide/(high.to_f), 3, 10)

    #glMatrixMode( GL_MODELVIEW )
    #glLoadIdentity( )

    #glEnable(GL_DEPTH_TEST)
    #glDepthFunc(GL_LESS)

    #glShadeModel(GL_FLAT)  ?? necessary??
  end

  def swap_buffers
    GL.swap_buffers
  end
end

class GLGrid < Numrb::Vec

  # m index
  attr_accessor :nrows
  # n index
  attr_accessor :ncols

  def initialize(array_of_arrays)
    @nrows = array_of_arrays.size
    @ncols = array_of_arrays.first.size
    super(:double, @nrows*@ncols, array_of_arrays.flatten)
  end

  def draw
    GLCommands.gl_quads(self.struct[:ptr], @nrows, @ncols)
  end

  module GLCommands
    extend Inliner
    inline do |build|
      build.include "GL/gl.h"
      build.include "GL/glu.h"

      build.c %q{
      void gl_quads(double * data, int m, int n) {
        glBegin(GL_QUAD_STRIP);
          int i, j;
          for (j=0; j<m; ++j) {
            for (i=0; i<n-1; ++i) {
              glColor3f(1.0f, 0.0f, 1.0f);
              glVertex2f(m, n);
              //glVertex2f(data[(j*m)+i], data[(j*m)+i]);
              //printf("%f %f", data[(j*m)+i], data[(j*m)+i]);
            }
          }
        glEnd();
      }
      }
    end
  end
end

# from tersus (terse) and Greek πᾶν, pan, "all," "of everything,"
class Terpan
  include Rubygame
  include Rubygame::Events

  def initialize(width=800, height=600)
    # init screen
    @screen = Screen.new([width,height], 0, [HWSURFACE, DOUBLEBUF, OPENGL])
    #@screen = Rubygame::Screen.new [width,height], 0, [Rubygame::HWSURFACE | Rubygame::OPENGL, Rubygame::DOUBLEBUF]
    @screen.title = "Terpan - fast, modifiable mass spec viewer"

    # init clock
    @clock = Clock.new
    #@clock.target_framerate = 60
    
    # init queue
    @queue = EventQueue.new
    @queue.enable_new_style_events

    @gl = GLEnv.new(width, height)
    ObjectSpace.garbage_collect
    @grid = GLGrid.new([[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5],[1,2,3,4,5]])
  end


  def go
    loop do
      handle_events
      draw
      @clock.tick
    end
  end

  def handle_events
    @queue.each do |ev|
      case ev
      when QuitEvent
        quit
        exit
      end
    end
  end
  
  def flip
    @screen.flip
    @gl.swap_buffers  # GL.swap_buffers
  end

  def draw
    @grid.draw
    flip
  end

  def quit
    puts 'Quitting!'
    throw :quit
  end
end




vis = Terpan.new

vis.go
Rubygame.quit


=begin
1D texture object
void CContoursDoc::CreateTextureObject()
{
    // Define texture image
    unsigned char Texture8[8][3] =
    {
        { 0x00, 0x00, 0xa0 },   // Dark Blue 
        { 0x00, 0x00, 0xff },   // Blue 
        { 0x00, 0xa0, 0xff },   // Indigo 
        { 0x00, 0xa0, 0x40 },   // Dark Green 
        { 0x00, 0xff, 0x00 },   // Green 
        { 0xff, 0xff, 0x00 },   // Yellow 
        { 0xff, 0xcc, 0x00 },   // Orange 
        { 0xff, 0x00, 0x00 }    // Red 
    };

    // Set pixel storage mode 
    ::glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

    // Generate a texture name
    ::glGenTextures(1, m_nTexName);

    // Create a texture object
    ::glBindTexture(GL_TEXTURE_1D, m_nTexName[0]);
    ::glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MAG_FILTER,
        GL_NEAREST);
    ::glTexParameteri(GL_TEXTURE_1D, GL_TEXTURE_MIN_FILTER,
        GL_NEAREST);
    ::glTexImage1D(GL_TEXTURE_1D, 0, 3, 8, 0, GL_RGB, 
        GL_UNSIGNED_BYTE, Texture8);
}
=end

