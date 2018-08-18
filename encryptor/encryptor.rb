class Encryptor

  @@password = "5f4dcc3b5aa765d61d8327deb882cf99"

  def characters
    (' '..'z').to_a
  end

  def cipher(rotation)
    Hash[characters.zip(characters.rotate(rotation))]
  end

  def encrypt(string, rotation)
    cipher_hash = cipher(rotation)
    string.chars.map { |letter| cipher_hash[letter] }
    .join
  end

  def encrypt_multiple(string, rot1, rot2, rot3)
    letters = string.chars
    rotation = [rot1, rot2, rot3]
    letters.each_with_index
           .map { |letter, i| encrypt(letter, rotation[i % rotation.size]) }
           .join
  end

  def decrypt(string, rotation)
    encrypt(string, -rotation)
  end

  def encrypt_file(filename, rotation)
    text = File.open(filename, "r").read
    encrypted = encrypt(text, rotation)

    encrypted_file = File.open("#{filename}.encrypted", "w")
    encrypted_file.write(encrypted)
    encrypted_file.close
  end

  def decrypt_file(filename, rotation)
    encrypted = File.open(filename, "r").read
    decrypted = decrypt(encrypted, rotation)

    decrypted_file = File.open(filename.gsub("encrypted", "decrypted"), "w")
    decrypted_file.write(decrypted)
    decrypted_file.close
  end

  def crack(message)
    possibilities = characters.count.times.collect do |attempt|
      decrypt(message, attempt)
    end
    print possibilities
  end

  def live_encrypt(rotation)
    puts 'Password?'
    password = gets.chomp
    require 'digest'
    password_md5 =  Digest::MD5.hexdigest password
    if password_md5 == @@password
      puts 'Write your message and hit enter to encrypt; type exit to finish'
      loop do
        text = gets.chomp
        if text == 'exit'
          break
        else
          puts encrypt(text,rotation)
        end
      end
    else
      puts 'Wrong password, encrypter will not run'
    end
  end

  def live_decrypt(rotation)
    puts 'Password?'
    password = gets.chomp
    require 'digest'
    password_md5 =  Digest::MD5.hexdigest password
    if password_md5 == @@password
      puts 'Write encrypted message and hit enter to decrypt; type exit to finish'
      loop do
        code = gets.chomp
        if code == 'exit'
          break
        else
          puts decrypt(code,rotation)
        end
      end
    else
      puts 'Wrong password, decrypter will not run'
    end
  end

end
