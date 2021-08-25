
prepend Rewrite

def Float?(value)
	if value
		Float(value)
	end
end

# Extracts an Integer
rewrite.extract_prefix longitude: Float, latitude: Float do
	longitude = Float?(@longitude)
	latitude = Float?(@latitude)
	
	if longitude && latitude
		@query = Vaccine::Query.new(location: {lng: longitude, lat: latitude})
	end
end
