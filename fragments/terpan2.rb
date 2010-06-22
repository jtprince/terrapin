#!/usr/bin/env ruby

# This demonstrates the use of ffi-opengl alongside rubygame to produce
# hardware-accelerated three-dimensional graphics. 
#
# Please note that rubygame itself does not perform any OpenGL functions,
# it only allows ffi-opengl to use the Screen as its viewport. You MUST
# have ffi-opengl installed to run this demo!

require 'rubygame'

begin
  require 'ffi-opengl'
rescue LoadError
  puts "You need ffi-opengl to run this demo:  gem install ffi-opengl"
  raise
end

begin
  require 'ffi-inliner'
rescue LoadError
  puts "You need ffi-inliner to run this demo:  gem install ffi-inliner"
  raise
end


include GL
include GLU

WIDE = 640
HIGH = 480

Rubygame.init

Rubygame::GL.set_attrib(Rubygame::GL::RED_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::GREEN_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::BLUE_SIZE, 5)
Rubygame::GL.set_attrib(Rubygame::GL::DEPTH_SIZE, 16)
Rubygame::GL.set_attrib(Rubygame::GL::DOUBLEBUFFER, 1)

Rubygame::Screen.open([WIDE,HIGH], 16, [Rubygame::OPENGL])
queue = Rubygame::EventQueue.new()
clock = Rubygame::Clock.new { |c| c.target_framerate = 60 }

ObjectSpace.garbage_collect

glViewport( 0, 0, WIDE, HIGH )

glMatrixMode( GL_PROJECTION )
glLoadIdentity( )
gluPerspective( 35, WIDE/(HIGH.to_f), 3, 10)

glMatrixMode( GL_MODELVIEW )
glLoadIdentity( )

glEnable(GL_DEPTH_TEST)
glDepthFunc(GL_LESS)

glShadeModel(GL_FLAT)

color =
  [[ 1.0,  1.0,  0.0], 
  [ 1.0,  0.0,  0.0],
  [ 0.0,  0.0,  0.0],
  [ 0.0,  1.0,  0.0],
  [ 0.0,  1.0,  1.0],
  [ 1.0,  1.0,  1.0],
  [ 1.0,  0.0,  1.0],
  [ 0.0,  0.0,  1.0]]

cube_list = 1

module InlineStuff

cube =
  [[ 0.5,  0.5, -0.5], 
  [ 0.5, -0.5, -0.5],
  [-0.5, -0.5, -0.5],
  [-0.5,  0.5, -0.5],
  [-0.5,  0.5,  0.5],
  [ 0.5,  0.5,  0.5],
  [ 0.5, -0.5,  0.5],
  [-0.5, -0.5,  0.5]]


  extend Inliner
  vals = [0,1,2,3,3,4,7,2,0,5,6,1,5,4,7,6,5,0,3,4,6,1,2,7]
  inline do |builder|
    builder.include "GL/gl.h"
    builder.include "GL/glu.h"
  text_to_inline = <<INLINE 
  void ffi_the_coords() {
  
		glBegin(GL_QUADS)
			glColor3f(1.0f, 0.0f, 0.0f)
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			
			glColor3f(0.0f, 1.0f, 0.0f)
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			
			glColor3f(0.0f, 0.0f, 1.0f)
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			
			glColor3f(0.0f, 1.0f, 1.0f)
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			
			glColor3f(1.0f, 1.0f, 0.0f)
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			
			glColor3f(1.0f, 0.0f, 1.0f)
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
			glVertex3f(#{cube[vals.shift].map {|v| (v.to_s + 'f')}.join(", ")})
    glEnd()
    }
INLINE
  text_to_inline = text_to_inline.split("\n").map do |v| 
    if v =~ /\)\s*$/ 
      v + ";" 
    else ;  v 
    end
  end.join("\n")
  builder.c text_to_inline
  end
end


glNewList(cube_list,GL_COMPILE_AND_EXECUTE)
glPushMatrix()
InlineStuff.ffi_the_coords
glPopMatrix()
glEndList()

angle = 0

catch(:rubygame_quit) do
	loop do
		queue.each do |event|
			case event
			when Rubygame::KeyDownEvent
				case event.key
				when Rubygame::K_ESCAPE
					throw :rubygame_quit 
				when Rubygame::K_Q
					throw :rubygame_quit 
        end
      when Rubygame::QuitEvent
        throw :rubygame_quit
      end
		end

    glClearColor(0.0, 0.0, 0.0, 1.0);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

		glMatrixMode(GL_MODELVIEW);
    glLoadIdentity( )
    glTranslatef(0, 0, -4)
    glRotatef(45, 0, 1, 0)
    glRotatef(45, 1, 0, 0)
    glRotatef(angle, 0.0, 0.0, 1.0)
    glRotatef(angle*2, 0.0, 1.0, 0.0)

    glCallList(cube_list)

		Rubygame::GL.swap_buffers()
		ObjectSpace.garbage_collect

    angle += clock.tick()/50.0
    angle -= 360 if angle >= 360

	end
end

Rubygame.quit
