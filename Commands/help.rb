LEOS_HELP = <<-EOS
rtwix extract         - extracts translation keywords from files
rtwix help            - displays this help message
EOS

module Rtwix extend self
  def help_s
    LEOS_HELP
  end
end
