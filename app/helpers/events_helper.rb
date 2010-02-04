module EventsHelper
	def day(date)
		day = date.strftime('%d')
		day.slice!('0') if (date.day < 10)
		if (date.day == 1 or date.day == 21 or date.day == 31)
			day += 'st'
		elsif (date.day == 2 or date.day == 22)
			day += 'nd'
		elsif (date.day == 3 or date.day == 23)
			day += 'rd'
		else
			day += 'th'
		end
		return day
	end
end
