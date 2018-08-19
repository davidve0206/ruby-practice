require "csv"
require "google/apis/civicinfo_v2"
require "erb"
require "date"

@hour_hash = Hash.new(0)
@day_hash = Hash.new(0)

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

# Practice, not used in the excercise output
def clean_phone_number(phone_number)
  phone_number = phone_number.to_s.delete('^0-9')
  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11 && phone_number[0] == "1"
    phone_number[1..10]
  else
    "Invalid phone number"
  end
end

def clean_date(date_registered)
  DateTime.strptime(date_registered, '%m/%d/%y %k:%M')
end

def collect_registration_data(date_registered)
  hour_registered = date_registered.hour
  day_registered = date_registered.strftime('%A')

  @hour_hash[hour_registered] += 1
  @day_hash[day_registered] += 1
end


def legislators_by_zipcode(zipcode)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    civic_info.representative_info_by_address(
               address: zipcode,
               levels: 'country',
               roles: ['legislatorUpperBody', 'legislatorLowerBody'])
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "Event Manager Initialized"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  date_registered = clean_date(row[:regdate])
  collect_registration_data(date_registered)

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)

end

puts "Most common hour of registration was #{@hour_hash.sort_by{|key,value| value}[-1][0]} hours"
puts "Most common day of registration was #{@day_hash.sort_by{|key,value| value}[-1][0]}"
