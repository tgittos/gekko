#!/usr/bin/env ruby
require 'downloader'
d = Downloader.new
d.fetch_list 'list.html'
