puts "1..6"

a = [  0,  1, 2, 3, 4, 5, 6 ]
b = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

c = a & b
if c.size == 6
	c.each() do |i|
	    puts 'ok ', i
	end
end
puts "1..6"

a = [  0,  1, 2, 3, 4, 5, 6 ]
b = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]

c = a & b
if c.size == 6
	c.each() do |i|
	    puts 'ok ', i
	end
end
