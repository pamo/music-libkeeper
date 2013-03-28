#!/usr/bin/env ruby

require "taglib"
require "term/ansicolor"
require "highline/import"

require "pry"

include Term::ANSIColor

def ask_if_necessary field, file
  value_id3v1 = file.id3v1_tag.send(field)
  value_id3v2 = file.id3v2_tag.send(field)
  
  if value_id3v1 != value_id3v2 or value_id3v1.nil? or value_id3v2.nil? then
    print red, bold, field, reset, " inconsistent in file", "\n"
    print bold, "\tid3v1", reset, " :: ", value_id3v1, "\n"
    print bold, "\tid3v2", reset, " :: ", value_id3v2, "\n"
    ask("which one is better?") { |q| q.default = value_id3v2 }
  else
    value_id3v2
  end
end

Dir.glob(File.join(ARGV[0], "**")).each do |folder|
  next unless File.directory? folder

  Dir.glob(File.join(folder, "*.mp3")).each do |song_file|

    TagLib::MPEG::File.open(song_file) do |file|
      print bold, song_file, reset, "\n"

      artist = ask_if_necessary(:artist, file).downcase
      print bold, blue, 'artist', reset, " :: ", artist, "\n"
      album = ask_if_necessary(:album, file).downcase
      print bold, blue, 'album', reset, " :: ", album, "\n"
      title = ask_if_necessary(:title, file).downcase
      print bold, blue, 'title', reset, " :: ", title, "\n"
      track = ask_if_necessary(:track, file)
      print bold, blue, 'track', reset, " :: ", track.to_s, "\n"
      year = ask_if_necessary(:year, file)
      print bold, blue, 'year', reset, " :: ", year.to_s, "\n"

      file.strip

      id3v1_tag = file.id3v1_tag(create=true)
      id3v1_tag.artist = artist
      id3v1_tag.album = album
      id3v1_tag.title = title
      id3v1_tag.track = track
      id3v1_tag.year = year

      id3v2_tag = file.id3v2_tag(create=true)
      id3v2_tag.artist = artist
      id3v2_tag.album = album
      id3v2_tag.title = title
      id3v2_tag.track = track
      id3v2_tag.year = year

      file.save
    end

  end

end
