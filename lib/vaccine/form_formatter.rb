require 'trenni/formatters'
require 'trenni/formatters/html/label_form'
require 'trenni/formatters/html/option_select'
require 'trenni/formatters/html/radio_select'
require 'trenni/formatters/html/accept_checkbox'

module Vaccine
	class FormFormatter < Trenni::Formatters::Formatter
		include Trenni::Formatters::HTML::LabelForm
	end
end
