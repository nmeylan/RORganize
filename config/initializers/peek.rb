# Author: Nicolas Meylan
# Date: 20.09.14
# Encoding: UTF-8
# File: peek.rb

if defined?(Peek)
  Peek.into Peek::Views::Mysql2
  Peek.into Peek::Views::Rblineprof
  Peek.into Peek::Views::PerformanceBar
end