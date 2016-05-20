module Check_position
  def check_position(x, y)
    if @board[x][y] == 'b'
      return 'b'
    else
      counter(x, y)
    end
  end

  def counter(x, y, counter = 0)
    around_position(x, y).each do |line|
      line.each do |position|
        counter += 1 if position == 'b'
      end
    end
    counter
  end

  def around_position(x, y)
    @board[(x-1 < 0 ? 0 : x-1)..(x+1)].map do |line|
      line[(y-1 < 0 ? 0 : y-1)..(y+1)]
    end
  end
end


class Board
  include Check_position

  attr_accessor :board, :user_board

  def initialize(dimension, number_of_mines)
      @board = Array.new(dimension) { Array.new(dimension) }
      @user_board = Array.new(dimension) { Array.new(dimension, "*") }
      @dimension = dimension
      number_of_mines.times do
          set_bomb(dimension)
      end
      set_other
  end

  private
  def set_bomb(dimension)
      x = rand(dimension)
      y = rand(dimension)
      if @board[x][y] != 'b'
        @board[x][y] = 'b'
      else
        set_bomb(dimension)
      end
  end

  def set_other
    @board.each_with_index do |line, x|
      line.map! do |position|
        position = check_position(x, line.index(position))
      end
    end
  end


end

class User
  attr_accessor :steps, :board
  include Check_position

  def start_game(dimension, mines)
    board = Board.new(dimension, mines)
    @steps = dimension ** 2 - mines
    @board = board.board
    @user_board = board.user_board
    @dimension = dimension
    table(@user_board)
  end

  def step(x, y, key)
    if key == 'mu'
      @user_board[x][y] = 'm'
    else
      if check_position(x, y) == 'b'
        lose_game
      elsif @steps == 0
        win_game
      else
        click(x, y)
      end
    end
    table(@user_board)
  end

  def click(x, y)
    move(x, y, check_position(x, y))
    @steps -= 1
  end

  def move(x, y, check)
    @user_board[x][y] = check
    if check == 0
      range(x).each do |el_x|
        range(y).each do |el_y|
          if el_x <= @dimension-1 && el_y <= @dimension-1 && @user_board[el_x][el_y] == "*"
            click(el_x, el_y)
          end
        end
      end
    end
  end

  def table(table)
    puts "   #{(0..table.size-1).to_a.join(' ')}"
    table.each_with_index { |line, i| puts "#{i} |#{line.join('|')}|" }
  end

  def range(x)
    ((x-1 < 0 ? 0 : x-1)..(x+1)).to_a
  end

  def lose_game
    system('clear')
    puts "Game Over"
    table(@board)
    puts "New game? Y/n"
    if gets.chomp.downcase == 'y'
      system('clear')
      Game.new
    else
      exit
    end
  end
end

class Game
  attr_accessor :board

  def initialize
    game
  end

  def move(range)
    x, y, key = gets.chomp.split.map { |e| e }
    keys = %w(mo mu)
    if range.include?(x) && range.include?(y) && key && (keys.include? key.downcase)
      system('clear')
      @user.step(x.to_i, y.to_i, key)
    else
      puts "wrong coordinates or key"
      move(range)
    end
  end

  def game
    puts "Please, enter field size and number of mines, like: '5 2'.", "Size must be less than 20, and number of mines must be smaller than size"
    dimension, mines = gets.chomp.split.map { |e| e.to_i }
    if mines > (dimension ** 2 - 1)
      puts "Number of mines must be smaller then field size"
      game
    elsif dimension > 20
      puts "Size should be less than 20"
      game
    else
      @user = User.new
      @user.start_game(dimension, mines)
      @board = @user.board
      puts "Please make your moves with keys(mo = move or mu = murk), like: '5 2 mo'"
      range = (0..dimension-1).to_a.map { |e| e.to_s }
      while @user.steps > 0
        move(range)
      end
      win_game
    end
  end

  def win_game
    system('clear')
    puts "You win"
    @user.table(@board)
    puts "New game? Y/n"
    if gets.chomp.downcase == 'y'
      system('clear')
      Game.new
    else
      exit
    end
  end
end

Game.new
