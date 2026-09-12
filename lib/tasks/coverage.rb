require 'rexml/document'

module Coverage
  class << self
    def report(full: false)
      doc = REXML::Document.new(File.read('coverage/coverage.xml'))
      rows = extract_rows(doc)
      rows = rows.reject { |_, _, rate| rate == 1.0 } unless full
      rows.sort_by { |_, rate, _| rate }.each do |filename, percent, _|
        puts "#{filename}\t#{percent}%"
      end
      print_total(doc)
    end

    private

    def extract_rows(doc)
      doc.elements.to_a('//class').map do |el|
        rate = el.attributes['branch-rate'].to_f
        [el.attributes['filename'], (rate * 100).round(2), rate]
      end
    end

    def print_total(doc)
      total = doc.elements['//coverage']
      covered = total.attributes['branches-covered']
      valid = total.attributes['branches-valid']
      rate = (total.attributes['branch-rate'].to_f * 100).round(2)
      puts "\nBranch: #{covered}/#{valid} (#{rate}%)"
    end
  end
end
