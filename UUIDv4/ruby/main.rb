File.open("/dev/random") do |file|
  buffer = file.read(16).bytes

  # Set bit 6 to 0
  buffer[8] &= ~(1 << 6);
  # Set bit 7 to 1
  buffer[8] |= (1 << 7);

  # Set version
  buffer[6] &= ~(1 << 4);
  buffer[6] &= ~(1 << 5);
  buffer[6] |= (1 << 6);
  buffer[6] &= ~(1 << 7);

  chars = buffer.map { |byte| "%02x" % byte }
  segments = [chars[0..3], chars[4..5], chars[6..7], chars[8..9], chars[10..15]]

  puts segments.map(&:join).join("-")
end
