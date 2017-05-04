require 'faker'
require_relative 'brandeis_event_parser'
require_relative 'tag_dictionary'
require_relative 'twinword'
require "ConnectSdk"
# require_relative 'ghetty'

@user_count = User.count

#trumba data for brandeis events
@data = BrandeisEventParser.new.get_data

#dictionary for creating tags (related words)
@dictionary = TagDictionary.new.dictionary

@keyword_finder = TwinWord.new
@count = 0

def create_events
	@manual = false
	@locations = Location.all.pluck(:name)
	@data.each do |line|
		title = line["title"]
		description, description_text = get_description(line["content"])#get_description(line["content"])
		# description_text = Nokogiri::HTML(line["content"]).text
		location = get_location_info(line["content"])
		date_time = Time.parse(line["published"].to_s)
		e = Event.find_or_create_by(name: title, description: description, description_text: description_text, location: location, start: date_time, user: User.first)

		create_tags(e) if e.save

		split_string = e.name.split()
		if split_string[0]== "Introducing...Lenny"
			e.image_id = imageUrl("Lenny Bruce")
		else
			e.image_id = imageUrl(split_string[0] + " " + split_string[1])
		end

		e.save
		# e.image_id = "http://aarongold.com"

	end


	@manual = true
end

def get_description(html)
	start = html.index "br"
	description = html[start+9, html.length]
	description_text = Nokogiri::HTML(html).text
	start = description_text.index "m. "
	description_text = description_text[start+3, description_text.length]
	# description = ""
	# skip = 3
	# d.xpath("//p").children.each do |line|
	# 	description << line.text if skip <= 0
	# 	skip -= 1
	# end
	return description.html_safe, description_text
end

def get_location_info(html)
	parsed_html = Nokogiri::HTML(html)
	data = parsed_html.xpath("//a")
	location = []
	data.each do |line|
		words = line.text.downcase.gsub!(/[^A-Za-z]/, ' ') || line.text.downcase unless line.text.nil?
		location = @locations.select { |l| l.downcase.include? words }
		return location.first if location.size >= 1
		words.split(" ").each do |word|
			location = @locations.select { |l| l.downcase.include? word }
			return location.first if location.size >= 1
		end
	end

	return "Other"
end

def create_host
	User.find_or_create_by(uid: "calendar", provider: "google", first_name: "BrandeisEvents",   email: "calendar@brandeis.edu", can_host: true, is_admin: false)
end

def create_default_tags
	File.open("db/seeds/tags.txt").each do |tag|

		tag = tag.gsub("\t", "")
		tag = tag.gsub("\n", "")
		Tag.find_or_create_by(name: tag)
	end
	@tags = Tag.all.pluck(:name)
end

def create_tags(event)
	description = event.description
	#without api
	word_list = get_word_list(description)
	keywords = keywords_from_word_list(word_list)
	tag_names = look_up(keywords)
	#with api
	#tag_names = @keyword_finder.find(description)
	tag_names.each do |t|
		tag = Tag.find_or_create_by(name: t.capitalize)
	 	event.tags << tag unless event.tags.include?(tag)
		#event.tags.create(name: t.capitalize)
	end
end

def look_up(keywords)
	if(keywords.empty?)
		return ["Other"]
	end
	keywords.map { |k| @dictionary[k] }.uniq
end

def get_word_list(description)
	wl = (description.gsub(/\W/, ' ').split.map { |w| w.downcase } || event.name.gsub(/\W/, ' ').split.map { |w| w.downcase }).uniq
	wl.map {|word| word.singularize}
end

def keywords_from_word_list(word_list)
	dict_words = @dictionary.keys | @dictionary.values.flatten
	dict_words & word_list
end

def create_locations
	File.open("db/seeds/locations.txt").each do |line|
		line = line.gsub("\t", "")
		line = line.gsub("\n", "")
		Location.find_or_create_by(name: line)
	end
end

def imageUrl(name)
# create instance of the Connect SDK
# all_tags = ""
# tags.each do |tag|
# 	all_tags << " #{tag.name}"
# end
@count+= 1
if @count >42
puts @count
puts name
end
 connectSdk = ConnectSdk.new(ENV["getty_api_key_#{@count%2}"], ENV["getty_api_secret_#{@count%2}"])
	search_results = connectSdk.search.images.with_phrase(name).execute
	if !search_results["images"].empty?
			return "#{search_results["images"][0]["display_sizes"][0]["uri"]}"
	end
end

def debug_events
	Tag.where(name: "Other").first.events.each do |e|

	end
end

create_host
create_locations if !Location.any?
create_default_tags if !Tag.any?
create_events
#debug_events
