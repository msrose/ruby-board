class Board
  attr_accessor :print_char
  attr_accessor :label_with
  attr_accessor :label_locations

  def initialize(row_count, col_count, options = {})
    @board = Array.new(row_count) { Array.new(col_count) }
    @print_char = options[:print_char] || '_'
    @label_with = options[:label_with]
    @label_locations = options[:label_locations] || [:left, :top]
    yield self if block_given?

  end

  def self.print(board)
    board.print_board
  end

  def print_board
    print_column_labels if label_locations.include?(:top)
    @board.each_with_index do |row, i|
      print_label_for_row(i) if label_locations.include?(:left)
      print_row(row)
      if label_locations.include?(:right)
        print ' '
        print_label_for_row(i)
      end
      puts
    end
    print_column_labels if label_locations.include?(:bottom)
  end

  def row_count
    @board.length
  end

  def col_count
    @board.first.length
  end

  def update!(loc = {})
    value = yield
    row_access = lambda do |row|
        @board[row].map! { |cell| cell = value }
    end

    !!access_board(loc, false,
      cell_access: lambda do |row, col|
        @board[row][col] = value
      end,
      row_access: row_access,
      col_access: lambda do |col|
        @board.map { |board_row| board_row[col] = value }
      end,
      board_access: lambda do
        (0...row_count).each do |row_num|
          row_access.call(row_num)
        end
      end
    )
  end

  def update_cell!(row, col, value = nil)
    check_for_cell_access_error(row, col)
    update!(row: row, col: col) { value || yield }
  end

  def value(loc = {})
    access_board(loc, nil,
      cell_access: lambda do |row, col|
        @board[row][col]
      end,
      row_access: lambda do |row|
        Array.new(@board[row])
      end,
      col_access: lambda do |col|
        @board.collect { |board_row| board_row[col] }
      end,
      board_access: lambda do
        @board.collect { |board_row| Array.new(board_row) }
      end
    )
  end

  def value_at(row, col)
    check_for_cell_access_error(row, col)
    value(row: row, col: col)
  end

  ['row', 'col'].each do |item|
    access_error_check = lambda { |index| self.send("check_for_#{item}_access_error", index) }

    self.send(:define_method, "update_#{item}!") do |index, value = nil, &block|
      instance_exec(index, &access_error_check)
      update!(item.to_sym => index) { value || block.call }
    end

    self.send(:define_method, "#{item}_value") do |index|
      instance_exec(index, &access_error_check)
      value!(item.to_sym => index)
    end
  end

  protected

    def valid_row?(row)
      0 <= row && row < row_count
    end

    def valid_col?(col)
      0 <= col && col < col_count
    end

    def valid_location?(row, col)
      valid_row?(row - 1) || valid_col?(col - 1)
    end

  private

    def access_board(loc, error_val, actions)
      row, col = loc[:row], loc[:col]
      if row
        row -= 1
        return error_val unless valid_row?(row)
      end
      if col
        col -= 1
        return error_val unless valid_col?(col)
      end
      if row && col
        actions[:cell_access].call(row, col)
      elsif row
        actions[:row_access].call(row)
      elsif col
        actions[:col_access].call(col)
      else
        actions[:board_access].call
      end
    end

    def print_row(row)
      print row.map { |el| "%#{column_print_width}s" % (el.nil? ? @print_char : el.to_s) }.join
    end

    def print_label_for_row(i)
      label_type = label_type_for(:row)
      if label_type
        case label_type
        when :numbers
          print "%#{row_print_width}d" % (i + 1)
        when :letters
        else
          raise ArgumentError, "Invalid row label type #{label_type}"
        end
      end
    end

    def row_print_width
      row_count.to_s.length
    end

    def print_column_labels
      label_type = label_type_for(:col)
      if label_type
        print ' ' * row_print_width
        case label_type
        when :numbers
          puts (1..col_count).to_a.map { |col| "%#{column_print_width}s" % col }.join
        when :letters
        else
          raise ArgumentError, "Invalid column label type #{label_type}"
        end
      end
    end

    def column_print_width
      col_count.to_s.length + 1
    end

    def label_type_for(type)
      @label_with.is_a?(Array) ? @label_with[type == :row ? 0 : 1] : @label_with
    end

    def check_for_cell_access_error(row, col)
      raise ArgumentError, "Board cell out of range: [#{row}, #{col}]" unless valid_location?(row, col)
    end

    def check_for_row_access_error(row)
      raise ArgumentError, "Board row out of range: #{row}" unless valid_row?(row)
    end

    def check_for_col_access_error(col)
      raise ArgumentError, "Board column out of range: #{col}" unless valid_col?(col)
    end
end
