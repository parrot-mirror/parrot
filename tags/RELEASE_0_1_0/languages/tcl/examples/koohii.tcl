# Works with tclsh on OS X if you set your display encoding to UTF-8 

# print out the kana for coffee.
fconfigure stdout -encoding utf-8
puts "\u30b3\u30fc\u30d2\u30fc"
