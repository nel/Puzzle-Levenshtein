class LevenshteinOneAscii
  CHARSET = ('a'..'z').to_a

  def initialize(datastore)
    @datastore = datastore
    @known_sibblings = {}
  end
  
  def social_network(word)
    sibblings_word!(word)
    @known_sibblings.keys.sort
  end
  
  def count_social_network(word)
    sibblings_word!(word)
    @known_sibblings.length
  end

private
  
  def sibblings_word!(word)
    reset_known_sibblings!
    new_sibblings = direct_sibblings(word)

    while (new_sibblings.size > 0) do
      new_sibblings = new_sibblings.map! {|sibbling| direct_sibblings(sibbling) }.flatten!
    end
  end
  
  # Return the new direct sibblings of word by studying its different variation
  def direct_sibblings(word)
    sibblings_by_suppression(word) + sibblings_by_substitution(word) + sibblings_by_addition(word)
  end

  def is_new_sibblings?(word)
    @known_sibblings[word] = true if @datastore.key?(word) && !@known_sibblings[word]
  end

  # Generate all variations of a word by removing a char
  def sibblings_by_suppression(word)
    variations = []
    word.length.times do |l| 
      w = ''
      i = 0
      word.each_char do |c|
        w << c if i != l
        i+=1
      end
      variations << w if is_new_sibblings?(w)
    end
    variations
  end  

  # Generate all variations of a word by substituting a char
  def sibblings_by_substitution(word)
    res = []
    l = 0
    word.each_char do |current_char|
      CHARSET.each do |c|
        next if c == current_char
        w = word.dup
        w[l] = c
        res << w
      end
      l+=1
    end
    res
  end

  # Generate all variations of a word by adding a char
  def sibblings_by_addition(word)
    res = []
    (word.length+1).times do |l|
      CHARSET.each do |c|
        res << word.dup.insert(l, c)
      end
    end
    res
  end

  # Generate all yet UNKNOWN variations of a word by substitution
  def sibblings_by_substitution(word)
    variations = []
    word.length.times do |i|
      w = word.dup
      w[i] = '*'
      variations += sibblings_by_wildcard(w, i)
    end
    variations
  end
  
  # Generate all yet UNKNOWN variations of a word by adding
  def sibblings_by_addition(word)
    variations = []
    (word.length + 1).times do |i|
      variations += sibblings_by_wildcard(word.dup.insert(i, '*'), i)
    end
    variations
  end
  
  # Generate all UNKNOWN variations of a word by modifying the character at a certain position
  def sibblings_by_wildcard(word, char_position)
    variations = []
    CHARSET.each do |c|
      word[char_position] = c
      variations << word.dup if is_new_sibblings?(word)
    end
    variations
  end
  
  def reset_known_sibblings!
    @known_sibblings = {} #maintain list valid sibblings in a hash for quick check
  end
end

class DataStore < Hash
  
  def loadfile(filename)
    File.open(filename) do |f|
      f.each_line do |l|
        self[l.chomp!] = true
      end
    end
    self
  rescue
    puts "Failed to open file #{filename}"
  end
end

