class MyPiece < Piece
  # The constant All_My_Pieces should be declared here
 All_My_Pieces = All_Pieces + [[[[0,0],[-1,0],[1,0],[2,0],[-2,0]],#long 5
                  [[0,0],[0,-1],[0,1],[0,2],[0,-2]]],
                rotations([[0,0],[0,1],[1,0]]),# triangle
                rotations([[0,0],[-1,0],[1,0],[0,-1],[-1,-1]])]# 5 blocks not long

  def self.next_piece (board)
    MyPiece.new(All_My_Pieces.sample, board)
  end
end

class MyBoard < Board
 def initialize (game)
    @grid = Array.new(num_rows) {Array.new(num_columns)}
    @current_block =MyPiece.next_piece(self)
    @score = 0
    @game = game
    @delay = 500
    @cheat_pressed = false
 end
 
  def rotate_180
    if !game_over? and @game.is_running?
      @current_block.move(0, 0, 2)
    end
    draw
  end
  
  def cheat_pressed
    @cheat_pressed
  end
  
  def cheat
    if !game_over? and @game.is_running? and @score >= 100 and !cheat_pressed
      @score -= 100
      @cheat_pressed = true 
    end
  end

  def next_piece
    if  @cheat_pressed 
      @current_block = MyPiece.new([[[0,0]]],self)
      @cheat_pressed = false
    else
      @current_block = MyPiece.next_piece(self)
    end
    @current_pos = nil
  end
end
  
class MyTetris < Tetris
  
   def set_board
    @canvas = TetrisCanvas.new
    @board =MyBoard.new(self)
    @canvas.place(@board.block_size * @board.num_rows + 3,
                  @board.block_size * @board.num_columns + 6, 24, 80)
    @board.draw
  end
 def key_bindings  
   super
    @root.bind('u', proc {@board.rotate_180})
    @root.bind('c', proc {@board.cheat})

 end
 
 
end

