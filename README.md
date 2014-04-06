# board.rb

Used for creating command line game boards in Ruby.

Lots of use/abuse of the Ruby language here:
- Much anonymous functions
- Such meta-programming
- Wow

## Example Usage

```ruby
board = Board.new(11,14) do |b|
  b.label_with = :numbers
  b.label_locations = [:left, :bottom]
end

board.update!(row: 3, col: 5) { 'm' }
board.update!(row: 1) { 'c' }
board.update!(col: 14) { 'h' }
board.update_col!(4, 'f')
board.update_cell!(7,9, 'j')

Board.print(board)
puts "Value at (3,5): #{board.value_at(3, 5)}"
puts "Value of column 4: #{board.col_value(4)}"
```

Prints:

```
 1  c  c  c  f  c  c  c  c  c  c  c  c  c  h
 2  _  _  _  f  _  _  _  _  _  _  _  _  _  h
 3  _  _  _  f  m  _  _  _  _  _  _  _  _  h
 4  _  _  _  f  _  _  _  _  _  _  _  _  _  h
 5  _  _  _  f  _  _  _  _  _  _  _  _  _  h
 6  _  _  _  f  _  _  _  _  _  _  _  _  _  h
 7  _  _  _  f  _  _  _  _  j  _  _  _  _  h
 8  _  _  _  f  _  _  _  _  _  _  _  _  _  h
 9  _  _  _  f  _  _  _  _  _  _  _  _  _  h
10  _  _  _  f  _  _  _  _  _  _  _  _  _  h
11  _  _  _  f  _  _  _  _  _  _  _  _  _  h
    1  2  3  4  5  6  7  8  9 10 11 12 13 14
Value at (3,5): m
Value of column 4: ["f", "f", "f", "f", "f", "f", "f", "f", "f", "f", "f"]
Value of row 1: ["c", "c", "c", "f", "c", "c", "c", "c", "c", "c", "c", "c", "c", "h"]
```
