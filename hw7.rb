# University of Washington, Programming Languages, Homework 7, hw7.rb 
# (See also ML code)

# a little language for 2D geometry objects

# each subclass of GeometryExpression, including subclasses of GeometryValue,
#  needs to respond to messages preprocess_prog and eval_prog
#
# each subclass of GeometryValue additionally needs:
#   * shift
#   * intersect, which uses the double-dispatch pattern
#   * intersectPoint, intersectLine, and intersectVerticalLine for 
#       for being called by intersect of appropriate clases and doing
#       the correct intersection calculuation
#   * (We would need intersectNoPoints and intersectLineSegment, but these
#      are provided by GeometryValue and should not be overridden.)
#   *  intersectWithSegmentAsLineResult, which is used by 
#      intersectLineSegment as described in the assignment
#
# you can define other helper methods, but will not find much need to

# Note: geometry objects should be immutable: assign to fields only during
#       object construction

# Note: For eval_prog, represent environments as arrays of 2-element arrays
# as described in the assignment

class GeometryExpression  
  # do *not* change this class definition
  Epsilon = 0.00001

end
class GeometryValue 
  # do *not* change methods in this class definition
  # you can add methods if you wish

  private
  # some helper methods that may be generally useful
  def real_close(r1,r2) 
    (r1 - r2).abs < GeometryExpression::Epsilon
  end

  def real_close_point(x1,y1,x2,y2) 
    real_close(x1,x2) && real_close(y1,y2)
  end
  
  # two_points_to_line could return a Line or a VerticalLine
  def two_points_to_line(x1,y1,x2,y2) 
    if real_close(x1,x2)
      VerticalLine.new x1
    else
      m = (y2 - y1).to_f / (x2 - x1)
      b = y1 - m * x1
      Line.new(m,b)
    end
  end

  public
  # we put this in this class so all subclasses can inherit it:
  # the intersection of self with a NoPoints is a NoPoints object
  def intersectNoPoints np
    np # could also have NoPoints.new here instead
  end

  # we put this in this class so all subclasses can inhert it:
  # the intersection of self with a LineSegment is computed by
  # first intersecting with the line containing the segment and then
  # calling the result's intersectWithSegmentAsLineResult with the segment
  def intersectLineSegment seg
    line_result = intersect(two_points_to_line(seg.x1,seg.y1,seg.x2,seg.y2))
    line_result.intersectWithSegmentAsLineResult seg
  end
end

class NoPoints < GeometryValue
  # do *not* change this class definition: everything is done for you
  # (although this is the easiest class, it shows what methods every subclass
  # of geometry values needs)
  # However, you *may* move methods from here to a superclass if you wish to

  # Note: no initialize method only because there is nothing it needs to do
  def eval_prog env 
    self # all values evaluate to self
  end
  def preprocess_prog
    self # no pre-processing to do here
  end
  def shift(dx,dy)
    self # shifting no-points is no-points
  end
  def intersect other
    other.intersectNoPoints self # will be NoPoints but follow double-dispatch
  end
  def intersectPoint p
    self # intersection with point and no-points is no-points
  end
  def intersectLine line
    self # intersection with line and no-points is no-points
  end
  def intersectVerticalLine vline
    self # intersection with line and no-points is no-points
  end
  # if self is the intersection of (1) some shape s and (2) 
  # the line containing seg, then we return the intersection of the 
  # shape s and the seg.  seg is an instance of LineSegment
  def intersectWithSegmentAsLineResult seg
    self
  end
end


class Point < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods

  # Note: You may want a private helper method like the local
  # helper function inbetween in the ML code
  
  def preprocess_prog
    self
  end
  
  def eval_prog env
    self
  end

  def shift (dx,dy)
    Point.new(x + dx ,y + dy)
  end
  
  def intersect v
    v.intersectPoint self
  end
  
  def intersectPoint p
    if real_close_point(x,y,p.x,p.y)
      Point.new(x,y)
    else
      NoPoints.new
    end
  end
def intersectLine l
      if real_close(y,(l.m*x)+l.b)
	  Point.new(x,y)
      else
        NoPoints.new
      end
end
def intersectVerticalLine v
    if real_close(x,v.x)
     self
    else NoPoints.new
    end
end
 def intersectWithSegmentAsLineResult seg
   	if inbetween(x,seg.x1,seg.x2) and inbetween(y,seg.y1,seg.y2)
          Point.new(x,y)
	else
          NoPoints.new
        end
 end
          
  attr_reader :x, :y
  def initialize(x,y)
    @x = x
    @y = y
    @Epsilon = 0.00001
  end
  private
  def inbetween (v,end1,end2)
    (end1 - @Epsilon <= v and v <= end2 + @Epsilon)or (end2 - @Epsilon <= v and v <= end1 + @Epsilon)
  end

end

class Line < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
   def preprocess_prog
    self
   end
  
  def eval_prog env
    self
  end

  def shift (dx,dy)
    Line.new(m , (b + dy) - (m * dx)) 
  end
  def intersect v
    v.intersectLine self
  end
  def intersectLine l
    	if real_close(m,l.m) 
	   if real_close(b,l.b)
	      l 
	   else
           NoPoints.new
           end
	else 
		x = (l.b - b) / (m - l.m)
		y = m * x + b
		Point.new(x,y)
	end
  end
  def intersectPoint p
    p.intersectLine self
  end
  def intersectVerticalLine v
    Point.new( v.x, (m*v.x) + b)
  end

   def intersectWithSegmentAsLineResult seg
     seg
  end
  attr_reader :m, :b 
  def initialize(m,b)
    @m = m
    @b = b
  end
end

class VerticalLine < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
   def preprocess_prog
    self
   end
   
  def eval_prog env
    self
  end

  def shift (dx,dy)
    VerticalLine.new(x + dx)
  end
  
  def intersect v
     v.intersectVerticalLine self
  end
  
  def intersectVerticalLine v
    	if real_close(x,v.x)
	 v
	else
          NoPoints.new
        end
  end
  
  def intersectPoint p
    p.intersectVerticalLine self
  end
  
  def intersectLine l
    l.intersectVerticalLine self
  end

  def intersectWithSegmentAsLineResult seg
      seg
  end
  attr_reader :x
  def initialize x
    @x = x
  end
end
class LineSegment < GeometryValue
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  # Note: This is the most difficult class.  In the sample solution,
  #  preprocess_prog is about 15 lines long and 
  # intersectWithSegmentAsLineResult is about 40 lines long
  def preprocess_prog
    if real_close_point(x1,y1,x2,y2)
      Point.new(x1,y1)
    elsif (x1 < x2)
      self
    elsif (real_close(x1,2) and y1 < y2)
       self
    else
      LineSegment.new(x2,y2,x1,y1)
     end
  end

 
  def eval_prog env
    self
  end

  def shift (dx,dy)
    LineSegment.new(x1+dx,y1+dy,x2+dx,y2+dy)
  end
  
  def intersect v
    v.intersectLineSegment self
  end
  
 def intersectPoint p
 p.intersectLineSegment self
 end
 
 def intersectLine l
    l.intersectLineSegment self
 end
 
 def intersectVerticalLine v
    v.intersectLineSegment self
 end
 def intersectWithSegmentAsLineResult seg2
     if real_close(x1,x2)
       aXstart,aYstart,aXend,aYend,bXstart,bYstart,bXend,bYend =
                                                         if y1 < seg2.y1
                                                           [x1,y1,x2,y2,seg2.x1,seg2.y1,seg2.x2,seg2.y2]
                                                         else
                                                           [seg2.x1,seg2.y1,seg2.x2,seg2.y2,x1,y1,x2,y2]
                                                         end
                              
	            if real_close(aYend,bYstart)
	        	Point.new(aXend,aYend) 
                	elsif aYend < bYstart
	                NoPoints.new
	         	elsif aYend > bYend
			 LineSegment.new(bXstart,bYstart,bXend,bYend) 
	                else
                          LineSegment.new(bXstart,bYstart,aXend,aYend)
                    end
     
     else
        aXstart,aYstart,aXend,aYend,bXstart,bYstart,bXend,bYend =
                                                         if x1 <seg2.x1
                                                           [x1,y1,x2,y2,seg2.x1,seg2.y1,seg2.x2,seg2.y2]
                                                         else
                                                           [seg2.x1,seg2.y1,seg2.x2,seg2.y2,x1,y1,x2,y2]
                                                         end
        
 			if real_close(aXend,bXstart)
			 Point.new(aXend,aYend) 
			elsif aXend < bXstart
			 NoPoints.new
			elsif aXend > bXend
			 LineSegment.new(bXstart,bYstart,bXend,bYend) 
			else
                          LineSegment.new(bXstart,bYstart,aXend,aYend) 
		        end
     end
 end

    
  attr_reader :x1, :y1, :x2, :y2
  def initialize (x1,y1,x2,y2)
    @x1 = x1
    @y1 = y1
    @x2 = x2
    @y2 = y2
  end
  
end


class Intersect < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
   def preprocess_prog
     Intersect.new(@e1.preprocess_prog,@e2.preprocess_prog)
   end
  
  def eval_prog env
   @e1.eval_prog(env).intersect(@e2.eval_prog(env))
  end

  
  def initialize(e1,e2)
    @e1 = e1
    @e2 = e2
  end
end

class Let < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  # Note: Look at Var to guide how you implement Let
  def preprocess_prog
    Let.new(@s,@e1.preprocess_prog,@e2.preprocess_prog)
   end
  
   def eval_prog env
    @e2.eval_prog([[@s,@e1.eval_prog(env)]]+env)
   
  end

 
  def initialize(s,e1,e2)
    @s = s
    @e1 = e1
    @e2 = e2
  end
end

class Var < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
  def preprocess_prog
   self
  end

  def initialize s
    @s = s
  end
  def eval_prog env # remember: do not change this method
    pr = env.assoc @s
    raise "undefined variable" if pr.nil?
    pr[1]
  end
end

class Shift < GeometryExpression
  # *add* methods to this class -- do *not* change given code and do not
  # override any methods
   def preprocess_prog
    Shift.new(@dx,@dy,@e.preprocess_prog)
  end
  
  def eval_prog env
    @e.eval_prog(env).shift(@dx,@dy)
  end

  def initialize(dx,dy,e)
    @dx = dx
    @dy = dy
    @e = e
   
  end

end



