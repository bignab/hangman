# frozen_string_literal: true

require 'yaml'

# The general game class with contains all methods related to the implementation of the game loop and IO functions.
class Game
  attr_reader :phrase

  def initialize
    @phrase = set_phrase
  end

  def serialize
    YAML.dump(self)
  end

  def save_game
    Dir.mkdir 'saves' unless Dir.exist?('saves')
    filename = 'save_game.yml'
    File.open("saves/#{filename}", 'w') { |file| file.write(serialize) }
  end

  def load_game
    file = YAML.load(File.read('saves/save_game.yml'))
    @phrase = file.phrase
  end

  def game_loop
    until @phrase.incorrect_letters_guessed.count > 9
      game_round
      if @phrase.phrase_solved?
        win_message
        break
      end
    end
    lose_message unless @phrase.phrase_solved?
  end

  def game_initialize
    puts 'Hello, and welcome to the game of Hangman!'
    puts "If you want to start a new game enter '1', or if you want to load a saved game enter '2'"
    valid_input = false
    response = gets.chomp
    until valid_input
      if response == '1'
        game_loop
        valid_input = true
      elsif response == '2'
        load_game
        game_loop
        valid_input = true
      end
    end
  end

  def game_round
    @phrase.update_output(user_input)
    system 'clear'
    puts @phrase.generate_output
    puts "Correct letters: #{@phrase.generate_letter_list('correct')}"
    puts "Incorrect letters: #{@phrase.generate_letter_list('incorrect')}"
  end

  def user_input
    valid_input = false
    until valid_input
      puts "Enter a letter to guess, or enter 'save' to save the game."
      response = gets.chomp
      if response == 'save'
        save_game
        next
      elsif /[a-zA-Z]/.match?(response) && response.length == 1 && @phrase.repeat_letter?(response) == false
        valid_input = true
        return response.downcase
      end
      puts 'Invalid input, try again!'
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

  def win_message
    puts 'Congratulations, you have solved the hidden phrase!'
  end

  def lose_message
    puts 'Sorry, you failed to solve the hidden phrase. You have been hanged.'
  end
end

# Class cotains the hidden phrase used for the game, along with methods
# that check various states and conditions using the phrase.
class Phrase
  attr_reader :phrase, :incorrect_letters_guessed

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
    count.positive?
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

  def repeat_letter?(guess)
    letters_guessed = @correct_letters_guessed + @incorrect_letters_guessed
    letters_guessed.each do |letter|
      return true if letter == guess
    end
    false
  end

  def generate_letter_list(list)
    output_string = ''
    if list == 'correct'
      @correct_letters_guessed.each do |letter|
        output_string += "#{letter}, "
      end
    else
      @incorrect_letters_guessed.each do |letter|
        output_string += "#{letter}, "
      end
    end
    output_string[0..(output_string.length - 3)]
  end

  def phrase_solved?
    @output.each do |letter|
      return false if letter == '_'
    end
    true
  end
end

test_game = Game.new
test_game.game_initialize
