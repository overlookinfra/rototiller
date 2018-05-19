module Rototiller
  module ColorText

    # Colors a string of text
    # @param text [String] the text to color
    # @param color [Integer] ASCII-code 30-37 http://ascii-table.com/ansi-escape-sequences.php
    # @return [String] formatted text with color
    # @api public
    # @example colorize("i am some yellow text", 33)
    def colorize(text, color)
      "\e[#{color}m#{text}\e[0m"
    end

    # Adds yellow color to a string of text
    # @param text [String] The text to color
    # @return [String] Text formatted in yellow color
    # @api public
    # @example yellow_text("i am some color text")
    def yellow_text(text)
      colorize(text, 33)
    end

    # Adds green color to a string of text
    # @param text [String] The text to color
    # @return [String] Text formatted in green color
    # @api public
    # @example green_text("i am some color text")
    def green_text(text)
      colorize(text, 32)
    end

    # Adds red color to a string of text
    # @param text [String] The text to color
    # @return [String] Text formatted in red color
    # @api public
    # @example red_text("i am some color text")
    def red_text(text)
      colorize(text, 31)
    end

  end
end
