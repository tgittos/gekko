require 'net/http'

class Downloader
  
  def initialize
    @username = 'gek'
    @password = 'gek'
    @host = "lib.homelinux.org"
    @site_root = "http://lib.homelinux.org/_djvu/_catalog/"
    @url = @site_root + 'index_1.html'
  end

  public

    def fetch_list(output_file)
      list = create_list
      write_list list, output_file
    end
  
  private
    
    def create_list
      content = get_page_with_auth(@url)
      ebook_list = []
      link_list = []
      # Rip out all URLs from this page
      page_regexp = /index_[0-9]+.html/
      content.scan(page_regexp).each do |link|
        puts "Found link #{link}"
        if not link_list.include? link then link_list << link end
      end
      # For every url in the link list, visit the page
      # and store the url
      link_regexp = /<a href="([^"]+)">/
      link_list.each do |link|
        page_content = get_page_with_auth(@site_root + link)
        page_content.scan(link_regexp).flatten.each do |ebook|
          puts "Found ebook #{ebook}"
          if not ebook_list.include? ebook then ebook_list << ebook end
        end
      end
      ebook_list
    end

    def get_page_with_auth(url)
      retries = 2
      content = nil
      begin  
        Net::HTTP.start(@host) { |http|
          puts "Getting url #{url}"
          request = Net::HTTP::Get.new(url)
          request.basic_auth @username, @password
          response = http.request(request)
          content = response.body
        }
      rescue Timeout::Error
        if retries > 0
          retries -= 1
          retry
        else
          puts "Timed out fetching #{url}"
        end
      end
      content
    end
    
    def write_list(list, output_file)
      File.open(output_file, "w") do |f|
        list.each do |i|
          f.write "<a href='#{@site_root + i}'>#{i}</a><br />\r"
        end
      end
      
    end
  
end
