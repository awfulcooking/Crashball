# For advanced users:
# You can put some quick verification tests here, any method
# that starts with the `test_` will be run when you save this file.

# Here is an example test and game

# To run the test: ./dragonruby mygame --eval app/tests.rb --no-tick

def test_maw?
  assert.true! (respond_to? :maw?)
end

puts "Running tests"
$gtk.reset 100
$gtk.log_level = :off
$gtk.tests.start
