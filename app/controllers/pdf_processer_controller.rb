class PdfProcesserController < ApplicationController

	def index
	end

	def send_pdf
		uploaded_file = params["pdf"].tempfile.path
		directory_name = params["pdf"].original_filename.split(".pdf")[0].gsub!(/[^0-9A-Za-z]/, '')
		FileUtils.mkdir_p(directory_name)
		reader = PDF::Reader.new(uploaded_file)
		i = 0
		CombinePDF.load(uploaded_file).pages.each do |joint_file|
			i+=1
			read_page = reader.page(i)
			file_name = read_page.text.scan(/^.+/)[0].gsub!(/[^0-9A-Za-z]/, '')
			file_name = "#{file_name}.pdf"
			file_path = Rails.root.join(directory_name,file_name)
			pdf = CombinePDF.new
			pdf << joint_file
			pdf.save(file_path)
		end
		folder_path = Rails.root.join(directory_name)
		system("zip -r #{directory_name} '#{folder_path}'")
		send_file(File.join("#{directory_name}.zip"))
	end


end
