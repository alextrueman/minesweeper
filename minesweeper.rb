require 'pry'
class Board
  attr_accessor :dimension

  def initialize(dimension, number_of_mines)
    @steps = dimension ** 2 - number_of_mines
    @dimension = dimension
    @opened = Array.new
    build_field(dimension, number_of_mines)
  end

  def build_field(dimension, number_of_mines)
    @board = Array.new(dimension) { Array.new(dimension, 0) }
    number_of_mines.times do
      set_bomb(dimension)
    end
  end

  def set_bomb(dimension)
    x, y = Array.new(2) { rand(dimension) }
    unless bomb?([x, y])
      @board[x][y] = :b
      increment_around(x, y)
    else
      set_bomb(dimension)
    end
  end

  def increment_around(x, y)
    range(x, y).each do |coords|
      incremet_counter(coords) unless bomb?(coords)
    end
  end

  def incremet_counter(coords)
    x, y = coords
    @board[x][y] += 1
  end

  def bomb?(coords)
    x, y = coords
    @board[x][y] == :b
  end

  def range(x, y)
    [x, y].map do |coord|
      ((coord-1 < 0 ? 0 : coord-1)..(coord+1 > @dimension-1 ? coord : coord+1)).to_a
    end.inject(&:product)
  end

  def click(x,y)
    if bomb? [x,y]
      decision('lose')
    else
      square_open [x, y]
    end
  end

  def square_open(coords)
    unless @opened.include? coords
      @opened.push coords
      @steps -= 1
    end
    x, y = coords
    if @board[x][y] == 0
      zero_open(x, y)
    end
  end

  def zero_open(x, y)
    range(x, y).each do |coords|
      unless @opened.include?(coords) && !bomb?(coords)
        square_open(coords)
      end
    end
  end

  def gui(type: :close)
    @board.each_with_index do |line, x|
      line.each_with_index do |square, y|
        if type == :close
          print @opened.include?([x, y]) ? square.to_s : '*'
        else
          print square.to_s
        end
      end
      puts
    end
  end

  def lose_game
    system('clear')
    puts 'You lose'
    gui(type: :open)
    ask_restart
  end

  def decision(key)
    system('clear')
    puts "You #{key}"
    gui(type: :open)
    ask_restart
  end

  def ask_restart
    print "Do you want to start new game?(y/n)\n> "
    if gets.chomp.downcase == 'y'
      Launcher.restart
    else
      exit
    end
  end

  def all_fields_opened?
    @steps.zero?
  end
end

class Game
  def initialize
    rules = "'*' - unchecked square, 'numbers' - count of bombs arround square, 'b' - bomb"
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
    @board.all_fields_opened? ? @board.decision('win') : step
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
