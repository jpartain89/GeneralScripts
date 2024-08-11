#!/usr/bin/env ruby

supported_types = %w(mov flv wmv avi divx mpg mpeg mp4 mkv)
input_dir = "/media/Porn/"
output_dir = "/media/Porn/"
docker_command = "docker run -itv #{input_dir}:/data ntodd/video-transcoding"

glob = "./*\.{#{supported_types.join(',')}}"

if Dir.glob(glob).length > 0
  # Pull the latest docker image
  system("docker pull ntodd/video-transcoding")
else
  puts "No supported video types in directory. Supported types: #{supported_types.join(', ')}"
end

Dir.glob(glob).each do |input_path|
output_path = "#{output_dir}/#{File.basename(input_path, '.*')}.mp4"
  transcode_command = "transcode-video --crop detect --handbrake-option encoder=x265 --target small --mp4 \"#{input_path}\" -o \"#{output_path}\""
  command = "#{docker_command} #{transcode_command}"

  begin
    IO.popen(command, err: [:child, :out]) do |io|
      Signal.trap 'INT' do
        Process.kill 'INT', io.pid
      end

      io.each_char do |char|
        print char
      end
    end
  rescue SystemCallError => error
    raise "transcoding failed: #{error}"
  end
end
