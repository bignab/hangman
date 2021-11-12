# frozen_string_literal: true

class Game
  attr_reader :phrase

  def initialize
    @phrase = set_phrase
  end

  def game_loop
    puts user_input
    @phrase.update_output(user_input)
    puts @phrase.generate_output
  end

  def user_input
    valid_input = false
    until valid_input
      puts 'Enter a letter to guess!'
      response = gets.chomp
      puts response.length
      if /[a-zA-Z]/.match?(response) && response.length == 1
        valid_input = true
        return response.downcase
      end
    end
  end

  def set_phrase
    Phrase.new(random_dictionary_word)
  end

  def random_dictionary_word
    lines = File.foreach('dictionary/dictionary.txt').count
    valid_word = false
    selected_word = ''
    until valid_word
      lineno = rand(lines)
      File.open('dictionary/dictionary.txt', 'r') do |f|
        f.gets until f.lineno == lineno - 1
        selected_word = f.gets.chomp
        valid_word = true if selected_word.length.between?(5, 12)
      end
    end
    selected_word
  end
end

class Phrase
  attr_reader :phrase

  def initialize(phrase)
    @phrase = phrase
    @correct_letters_guessed = []
    @incorrect_letters_guessed = []
    @output = []
    initialize_output
  end

  def add_letter(letter)
    @letters_guessed.push(letter)
  end

  def letters_match(phrase_letter, guess)
    if phrase_letter == guess
      guess
    else
      '_'
    end
  end

  def at_least_one_correct?(guess)
    chars = @phrase.split('')
    count = 0
    chars.each do |char|
      count += 1 if char == guess
    end
    if count > 0
      true
    else
      false
    end
  end

  def initialize_output
    @phrase.length.times { @output.push('_') }
  end

  def update_output(guess)
    @output.each_with_index do |letter, index|
      @output[index] = letters_match(@phrase[index], guess) if letter == '_'
    end
    if at_least_one_correct?(guess)
      @correct_letters_guessed.push(guess)
    else
      @incorrect_letters_guessed.push(guess)
    end
  end

  def generate_output
    output_string = ''
    @output.each do |letter|
      output_string += "#{letter} "
    end
    output_string
  end
end

test_game = Game.new
puts test_game.phrase.phrase
puts test_game.phrase.generate_output
test_game.game_loop
