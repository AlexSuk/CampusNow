require 'nokogiri'

module EventsHelper

	def top_image_text
		s=""
		if params[:date]

			s<< "#{params[:date]}'s Events'"
				end
		s.html_safe
	end
	def list_event(event, col_length)
		string = ''
		string << "<div class='#{col_length} portfolio-item'>"
		string <<  event_image(event)
		string << "<h4> <a href='#{event_path(event.id)}'> #{event.name}</a></h4>"
		string << "<p>#{truncate event.description, :length => 100}</p>"
		string << start_time(event) + location(event)
		string << '</div>'
		string.html_safe
	end

	def event_image(event)
		s = ""
		s<<"<a href='#{event_path(event.id)}'>"
		if event.event_image_file_name.nil?
			s<< image_tag('missing_thumbnail.png').html_safe
		else
			s<< image_tag(event.event_image(:thumbnail)).html_safe
		end
		s<<"</a>"
	end

	def start_time(event)
		<<-eos
		<div class="row">
		<div class="col-xs-4">
		<span class="glyphicon glyphicon-time" id="icon-home" class="col-md-2"></span>#{event.start.strftime('%m/%d')}
		</div>
		eos
	end

	def location(event)
		string = "<div class='col-xs-8 text-right'>"
		string << "<span class='glyphicon glyphicon-map-marker' id='icon-location'></span>"
		string << "#{event.location}"
		string << "</div>"
		string << "</div>"
	end

	def sidebar(locations)
		return_string = '<h4>Locations</h4>'
		return_string << sidebar_locations(locations)
		return_string.html_safe
	end

	def sidebar_locations(locations)
		string = ""
		string << "<div id='column_results'>"
		string <<  "<p>" + link_to("All Locations", events_path) + "</p>"
		locations.sort.each do |l|
			string <<  "<p>" + link_to(l, events_path(l)) + "</p>"
		end

		string << "</div>"

	end

	def sidebar_date
		string = ""
		string << '<h4>Dates</h4>'
		string << "<p>" + link_to("All Dates", events_path) + "</p>"
		string << "<p>" + link_to("Today", events_path(:date => "today")) + "</p>"
		string << "<p>" + link_to("Tomorrow", events_path(:date => "tomorrow")) + "</p>"
		string << "<p>" + link_to("This Week", events_path(:date => "this week")) + "</p>"
		string << "<p>" + link_to("This Weekend", events_path(:date => "this weekend")) + "</p>"
		string << "<p>" + link_to("Next Week", events_path(:date => "next week")) + "</p>"
		string << "<p>" + link_to("This Month", events_path(:date => "this month")) + "</p>"
		string << "<hr>"
		string.html_safe
	end

	def search_bar
		search_bar_string = <<-eos
		<div class="row">
		<div class="col-lg-8 col-lg-offset-2">
		<div class="search_bar_events">
		<input type="text" class="form-control" placeholder="Search for...">

		</div>
		<!-- /input-group -->
		</div>
		<!-- /.col-lg-6 -->
		</div>
		eos
		search_bar_string.html_safe
	end

	def is_host
		current_user && @event.host == current_user
	end

end
