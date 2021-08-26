#!/usr/bin/env ruby

require 'async/http/internet/instance'
require 'async/barrier'

module Vaccine
	class Query
		# This seems to be the same for everyone.
		KEY = "WyJhMVQ0YTAwMDAwMEdiVGdFQUsiXQ=="
		
		SEARCH = "https://skl-api.bookmyvaccine.covid19.health.nz/public/locations/search"
		
		OTAUTAHI = {
			# Put your location here:
			lng: 172.5294065,
			lat: -43.5373362,
		}
		
		def initialize(key: KEY, location: OTAUTAHI, forwarded_for: nil)
			@key = key
			@location = location
			@forwarded_for = forwarded_for
		end
		
		def longitude
			@location[:lng]
		end
		
		def latitude
			@location[:lat]
		end
		
		def internet
			Async::HTTP::Internet.instance
		end
		
		def headers(*fields)
			if @forwarded_for
				Console.logger.info(self, "Adding x-forwarded-for: #{@forwarded_for}")
				fields << ['X-Forwarded-For', @forwarded_for]
			end
			
			return fields
		end
		
		def lookup_locations
			query = {
				vaccineData: KEY,
				fromDate: Date.today,
				location: @location,
				limit: 100,
			}
			
			cursor = ""
			locations = {}
			
			while true
				response = internet.post(SEARCH, headers(['content-type', 'application/json']), JSON.generate(query))
				
				body = JSON.parse(response.read)
				cursor = body['cursor']
				
				query['cursor'] = cursor
				
				break unless body['locations']&.any?
				
				body['locations'].each do |location|
					id = location['extId']
					locations[id] = location
				end
			end
			
			return locations
		end

		def lookup_availabilities(id)
			internet = Async::HTTP::Internet.instance
			
			url = "https://skl-api.bookmyvaccine.covid19.health.nz/public/locations/#{id}/availability"
			query = {
				startDate: Date.today,
				endDate: Date.today + 20,
				vaccineData: KEY,
				doseNumber: 1,
				groupSize: 1,
			}
			
			response = internet.post(url, headers(['content-type', 'application/json']), JSON.generate(query))
			body = JSON.parse(response.read)
			
			return body['availability']&.select{|availability| availability['available']}
		end

		def lookup_slots(id, availability)
			internet = Async::HTTP::Internet.instance
			
			url = "https://skl-api.bookmyvaccine.covid19.health.nz/public/locations/#{id}/date/#{availability['date']}/slots"
			query = {
				vaccineData: KEY,
			}
			
			response = internet.post(url, headers(['content-type', 'application/json']), JSON.generate(query))
			body = JSON.parse(response.read)
			
			return body['slotsWithAvailability']
		end
		
		def each
			return to_enum unless block_given?
			
			Sync do
				locations = lookup_locations
				barrier = Async::Barrier.new
				output_guard = Async::Semaphore.new
				
				locations.each do |id, location|
					barrier.async do
						availabilities = lookup_availabilities(id)
						
						if availabilities&.any?
							availabilities.each do |availability|
								availability['slots'] = lookup_slots(id, availability)
							end
							
							yield location, availabilities
						end
					end
				end
				
				barrier.wait
			end
		end
		
		def each_slot
			return to_enum(:each_slot) unless block_given?
			
			each.sort_by{|(location, _)| location['name']}.each do |(location, availabilities)|
				availabilities.each do |availability|
					availability['slots'].each do |slot|
						yield location, availability, slot
					end
				end
			end
		end
	end
end
