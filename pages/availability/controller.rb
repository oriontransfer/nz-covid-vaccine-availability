
prepend Rewrite

def Float?(value)
	if value
		Float(value)
	end
end

# Extracts an Integer
rewrite.extract_prefix longitude: Float, latitude: Float do |request|
	longitude = Float?(@longitude)
	latitude = Float?(@latitude)
	
	if longitude && latitude
		@query = Vaccine::Query.new(location: {lng: longitude, lat: latitude}, forwarded_for: request.ip)
	end
end
