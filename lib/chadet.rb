require "chadet/version"
require "csv"

module Chadet
  class Play
    def initialize secret_chars_object
      @chars_set = secret_chars_object.chars_set
      @num_of_chars = secret_chars_object.num_of_chars
      @secret_chars = secret_chars_object.secret_chars
      @loaded = false
      @used_true = ""
      @used_false = ""
      @max_hint = (@chars_set.length/@num_of_chars).to_i
      @hint_used = 0
      @moves = []
    end

    def header
      puts "Type: " + "chadet --help".code + " in the terminal to see more options.\n"\
           + "To quit this game at any time, type: " + "quit".code + "\n"
      puts ",¸¸,ø¤º°``°º¤ø,¸¸,ø¤°``°º¤ø,¸¸,ø¤º°``°º¤ø,¸¸,ø¤º°``°º¤ø,¸¸"
    end

    def chars_to_use
      @chars_set.length >= 17 ? box_width = @chars_set.length + 2 : box_width = 19
      end_pos = 58
      start_pos = end_pos - box_width
      puts " "*start_pos + "+" + "-"*(box_width-2) + "+" + "\n"\
           + " "*start_pos + "|Set of characters" + " "*(box_width - 19) + "|\n" \
           + " "*start_pos + "|to guess with:" + " "*(box_width - 16) + "|\n" \
           + " "*start_pos + "+" + "-"*(box_width-2) + "+" + "\n" \
           + " "*start_pos + "|" + @chars_set.yellow + " "*(box_width - @chars_set.length - 2) + "|\n" \
           + " "*start_pos + "+" + "-"*(box_width-2) + "+"
      print "\r\e[6A"
    end

    def table_header
      chars_pos = (5 + @num_of_chars - "chars".length)/2
      cc_pos = 10 + @num_of_chars
      cp_pos = 12 + @num_of_chars + 2*@num_of_chars.to_s.length
      table_width = cp_pos + 2
      puts " " + "-"*table_width + "\n"\
           + " no.|" + " "*chars_pos + "chars" + " "*(cc_pos - chars_pos - "chars".length - " no.|".length) \
           + "cc." + " "*(cp_pos - cc_pos - "cc.".length)\
           + "cp." + "\n"\
           + " " + "-"*table_width
    end
    
    def end_game
      # table bottom horizontal line
      cp_pos = 12 + @num_of_chars + 2*@num_of_chars.to_s.length
      table_width = cp_pos + 2
      puts " " + "-"*table_width
    end

    def answer guess, guess_num
      # Display number of correct characters and number of correct positions
      _G_ = guess_num.abs.to_s
      _g_ = _G_.length
      _N_ = @num_of_chars.to_s
      _n_ = _N_.length
      _B_ = checkCC(guess).to_s
      _b_ = _B_.length
      _U_ = checkCP(guess).to_s
      _u_ = _U_.length
      output = (guess_num == -1 ? ' ANS' : " "*(4-_g_) + _G_) + "|  #{guess.yellow}" \
               + "   ["  + ("0"*(_n_-_b_) + _B_).green + "] [" \
               + ("0"*(_n_-_u_) + _U_).green + "]"
      @moves << [guess, "0"*(_n_-_b_) + _B_, "0"*(_n_-_u_) + _U_]
      return output
    end  

    # Method to check how many characters are correctly guessed
    def checkCC guess
      cc = 0
      guess.each_char do |x|
        if @secret_chars.include? x.to_s
          cc += 1
        end
      end
      return cc
    end

    # Method to check how many correct characters are presented in correct positions
    def checkCP guess
      cp = 0
      for i in 0...@num_of_chars
        if @secret_chars[i] == guess[i]
          cp += 1
        end
      end
      return cp
    end

    # Method to display hint
    def hint
      picked_number = 0
      clue = ""
      chance = rand 1..100
      if chance < (@num_of_chars.to_f/@chars_set.length.to_f*100) \
        && chance > (@num_of_chars.to_f/@chars_set.length.to_f*20) #display one correct number
        picked_number = rand 0...(@num_of_chars-@used_true.length) || 0
        true_characters = @secret_chars.tr(@used_true, '')
        picked_true = true_characters[picked_number] || ""
        @used_true += picked_true
        if picked_true == ""
          clue = "You already knew #{@num_of_chars == 1 ? 'the' : 'all'} true "\
                 + "character#{'s' unless @num_of_chars == 1}."
        else
          clue = "'#{picked_true}' is#{@num_of_chars == 1 ? '' : ' among'} the true "\
                 + "character#{'s' unless @num_of_chars == 1}."
        end
      else
        picked_number = rand 0...(@chars_set.length - @num_of_chars - @used_false.length) || 0
        false_characters = @chars_set.tr(@secret_chars, '').tr(@used_false, '') || ""
        picked_false = false_characters[picked_number] || ""
        @used_false += picked_false
        if picked_false == ""
          clue = "You've already known #{(@chars_set.length - @num_of_chars) == 1 ? 'the' : 'all'} "\
                 + "false character#{'s' unless (@chars_set.length - @num_of_chars) == 1}."
        else
          clue = "One can simply omit '#{picked_false}'."
        end
      end
      return clue.yellow
    end

    def do_hint
      if @hint_used != @max_hint 
        hint.flash
        @hint_used += 1
      else
        ("Sorry, you've used #{@max_hint == 1 ? 'the' : 'up all'} #{@max_hint.to_s + " " unless @max_hint == 1}"\
         + "hint#{'s' unless @max_hint == 1}.").red.flash 1.2
      end
    end
    
    def save_game guess_num
      end_game if guess_num > 0
      # create directory if not exists
      dir_name = Chadet::DIR_NAME
      Dir.chdir(Chadet::HOME_DIR)
      Dir.mkdir(dir_name) unless File.exists?(dir_name)
      # generate filename
      time = Time.now
      filename = time.strftime("%y%m%d%H%M%S").to_i.to_s(36)
      # save file
      CSV.open(Chadet::WORK_DIR + "/" + filename + ".csv", "wb") do |f|
        f << [@chars_set.to_i(18).to_s(36), @secret_chars.to_i(18).to_s(36), @hint_used.to_s]
        @moves.each do |move|
          f << move
        end
      end
      guess_num = -2
      return guess_num
    end

    def do_save guess_num
      if guess_num > 0 
        guess_num = save_game guess_num
      else
        "No game to save.".red.flash 1
      end
      return guess_num
    end

    def quit_game guess_num
      print "\r"
      "¯\\(°_o)/¯ I give up.".yellow.flash 1
      guess_num = -1
      puts answer @secret_chars, guess_num
      end_game
      return guess_num
    end

    def do_quit guess_num
       if guess_num > 0
          yes_commands = %w{yes yse ys ye y save saev seav sav sev s}
          print "\r                              "
          print "\r " + "Save game? (yes/no): ".yellow
          save = gets.chomp
          print "\r\e[1A" + " "*25
          print "\r"
          if yes_commands.include? save.downcase
             guess_num = do_save guess_num
          else
             guess_num = quit_game guess_num
          end
       else
          guess_num = quit_game guess_num
       end
       return guess_num
    end

    def load_game guess_object, secret_object
      filename = ".filename"
      work_dir = File.dirname(__FILE__)
      if File.exists?(work_dir + "/" + filename + ".4dig")
        @loaded = true
        table_width = 15 + @num_of_chars + 2*@num_of_chars.to_s.length
        print "\r\e[#{guess_object.guess_num+3}A"
        print (" "*table_width + "\n")*(guess_object.guess_num+3)
        print "\r\e[#{guess_object.guess_num+3}A"
        saved_game = File.read(work_dir + "/" + filename + ".4dig")
        saved_game_arr = saved_game.split("\n")
        @chars_set = saved_game_arr[1]
        @secret_chars = saved_game_arr[4]
        secret_object.secret_chars = @secret_chars
        @num_of_chars = @secret_chars.length
        @hint_used = saved_game_arr[7].to_i
        @max_hint = (@chars_set.length/@num_of_chars).to_i
        @moves = saved_game_arr[10..-1]
        guess_object.guess_num = @moves.length
        chars_to_use
        table_header
        @moves = @moves.inject("") {|result, line| result + line + "\n"}
        puts @moves
      else
        "No saved game found.".yellow.flash 1.5
      end
      return guess_object.guess_num
    end
  end

  class SecretCharacters
    attr_reader :num_of_chars, :chars_set, :max_hint
    attr_accessor :secret_chars

    # default chars = "0123456789" and default num = 4, see option parser.
    def initialize chars_set, num_of_chars
      @num_of_chars = num_of_chars
      @chars_set = chars_set
      @secret_chars = do_shuffle
    end

    # Shuffle a set of number from 0-9
    def do_shuffle
      prep_chars = @chars_set.chars.to_a.shuffle
      secret_chars = prep_chars[0, @num_of_chars].join.to_s
      return secret_chars
    end
  end

  class Guess
     # check if guess has redundant characters
    attr_accessor :guess, :guess_num, :chars_set
    def initialize chars_set
      @guess = ""
      @guess_num = 0
      @chars_set = chars_set
    end

    def is_redundant?
      redundant = false
      a = @guess.split("").to_set.length
      b = @guess.length
      redundant = true if a < b
      return redundant
    end
    
    def handle_redundancy
      char_freq = {}
      @guess.each_char do |char|
        char_freq[char] ? char_freq[char] += 1 : char_freq[char] = 1
      end
      redundant_char = char_freq.select {|k, v| v > 1}
      sorted_red_char = redundant_char.sort_by {|k, v| v}
      sorted_red_char.reverse! unless sorted_red_char[1].nil? || sorted_red_char[0][1] == sorted_red_char[1][1]
      redundant = sorted_red_char[0][0]
      frequency = sorted_red_char[0][1]
      if frequency == 2
        freq_string = "twice"
      else
        freq_string = "#{frequency} times"
      end
      "Redundant: you typed \"#{redundant}\" #{freq_string}.".yellow.flash
    end
    
    # Check if wrong character is input
    def wrong_input?
      wrong_char = false
      error_num = 0
      @guess.each_char do |char|
        error_num += 1 unless chars_set.include? char
      end
      wrong_char = true if error_num > 0
      return wrong_char
    end
  end
end