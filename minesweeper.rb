class Board
  attr_accessor :steps, :dimension

  def initialize(dimension, number_of_mines)
    @steps = dimension ** 2 - number_of_mines
    @dimension = dimension
    build_field(dimension, number_of_mines)
  end

  def build_field(dimension, number_of_mines)
    @board = Array.new(dimension) { Array.new(dimension)  { {u: 0} }}
    number_of_mines.times do
      set_bomb(dimension)
    end
  end

  def set_bomb(dimension)
    x, y = Array.new(2) { rand(dimension) }
    unless bomb?(x, y)
      @board[x][y] = {u: :b}
      set_around(x, y)
    else
      set_bomb(dimension)
    end
  end

  def set_around(x, y)
    range(x).each do |_x|
      range(y).each do |_y|
        set_counter(_x, _y) unless bomb?(_x, _y)
      end
    end
  end

  def set_counter(x, y)
    @board[x][y][:u] += 1
  end

  def bomb?(x, y)
    @board[x][y] == {u: :b}
  end

  def range(x)
    (x-1 < 0 ? 0 : x-1)..(x+1 > @dimension-1 ? x : x+1)
  end

  def click(x,y)
    if bomb?(x, y)
      decision('lose')
    else
      sqare_open(x, y)
    end
  end

  def sqare_open(x, y)
    if @board[x][y].has_key? :u
      @board[x][y][:c] = @board[x][y].delete :u
      @steps -= 1
    end
    if @board[x][y][:c] == 0
      zero_open(x, y)
    end
  end

  def zero_open(x, y)
    range(x).each do |_x|
      range(y).each do |_y|
        sqare_open(_x, _y) if @board[_x][_y].has_key?(:u) && !bomb?(_x, _y)
      end
    end
  end

  def gui
    @board.each do |line|
      line.each do |el|
        print el.has_key?(:u) ? '*' : el[:c].to_s
      end
      puts
    end
  end

  def lose_game
    system('clear')
    puts 'You lose'
    open_board
    ask_restart
  end

  def decision(key)
    system('clear')
    puts "You #{key}"
    open_board
    ask_restart
  end

  def open_board
    @board.map do |line|
      line.map { |el| el[:c] = el.delete :u if el[:u] }
    end
    gui
  end

  def ask_restart
    print "Do you want to start new game?(y/n)\n> "
    if gets.chomp.downcase == 'y'
      Launcher.restart
    else
      exit
    end
  end
end

class Game
  def initialize
    rules = "'*' - unchecked sqare, 'numbers' - count of bombs arround sqare, 'b' - bomb"
    print "#{rules}\nEnter size, number of mines\n> "
    size, mines = user_input
    input_correct?(size, mines, :numbs) ? @board = Board.new(size, mines) : restart_initialize
    start
  end

  def start
    print "OK! Let's start!\nYour first step:\n"
    step
  end

  def move(x, y)
    @board.click(x, y)
    @board.steps.zero? ? @board.decision('win') : step
  end

  def step
    @board.gui
    print "> "
    x,y = user_input
    input_correct?(x, y) ? move(x, y) : restart_step
  end

  def input_correct?(x, y, type = :step )
    if type == :step
      [x, y].all? { |coord| (0...@board.dimension).cover? coord }
    else
      (y <= x**2-1) && (x < 20) && (y > 0) && (x > 0)
    end if [x,y].all?
  end

  def restart_step
    puts "Wrong coordinates!"
    start
  end

  def restart_initialize
    puts "Wrong numbers!"
    initialize
  end

  def user_input
    gets.chomp.split(' ').map(&:to_i)
  end
end

class Launcher
  class << self
    def start
      system('clear')
      @game = Game.new
    end

    def restart
      start
    end
  end
end
Launcher.start
