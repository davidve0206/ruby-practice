class Encryptor

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

end
