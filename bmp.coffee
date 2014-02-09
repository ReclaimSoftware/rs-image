subbmp = (src_bmp, {x, y, width, height}) ->

  # Note: BMP pixels rows start from the bottom of the image
  # Note: BMP pixel rows are padded so their byte size is divisible by four

  [src_width, src_height] = validate_bmp src_bmp

  throw new Error "rect out of bounds" if (\
    (x < 0) or
    (y < 0) or
    ((x + width) > src_width) or
    ((y + height) > src_height))

  src_bytes_per_row = pad4 (3 * src_width)
  dest_bytes_per_row_naive = (3 * width)
  dest_bytes_per_row = pad4 dest_bytes_per_row_naive

  dest_bmp = new Buffer (54 + (height * dest_bytes_per_row))
  make_bmp_header(width, height).copy dest_bmp

  src_pos = 54 + ((src_height - y - height) * src_bytes_per_row) + (x * 3)
  dest_pos = 54

  for i in [0...height]
    src_bmp.copy dest_bmp, dest_pos, src_pos, (src_pos + dest_bytes_per_row_naive)
    src_pos += src_bytes_per_row
    dest_pos += dest_bytes_per_row

  dest_bmp


pad4 = (n) ->
  mod4 = n % 4
  if mod4 then (n + 4 - mod4) else n


validate_bmp = (bmp) ->
  throw new Error "Expected at least 54 bytes" if bmp.length < 54
  throw new Error "Expected data to start with 'BM'" if (bmp[0] != 0x42) or (bmp[1] != 0x4D)
  throw new Error "Only single-plane BMPs supported so far" if bmp.readUInt16LE(26) != 1
  throw new Error "Only 24-bit BMPs supported so far" if bmp.readUInt16LE(28) != 24
  file_size = bmp.readUInt32LE 2
  pixels_size = bmp.readUInt32LE 34
  width = bmp.readUInt32LE 18
  height = bmp.readUInt32LE 22
  throw new Error "Header error: pixels_size != (height * pad4(3 * width))" if pixels_size != (height * pad4(3 * width))
  throw new Error "Header error: file_size != (pixels_size + 54)" if file_size != (pixels_size + 54)
  throw new Error "The header is not of a supported form" if bmp.slice(0, 54).toString('hex') != make_bmp_header(width, height).toString('hex')
  throw new Error "The file size is incompatible with the header" if bmp.length != file_size
  [width, height]


make_bmp_header = (width, height) ->
  pixels_size = (width * height * 3)
  file_size = (pixels_size + 54)
  bmp = new Buffer 54
  bmp[0] = 0x42 # 'B'
  bmp[1] = 0x4D # 'M'
  bmp.writeUInt32LE file_size,    2
  bmp.writeUInt32LE 0,            6  # (reserved)
  bmp.writeUInt32LE 54,           10 # file offset of pixels
  bmp.writeUInt32LE 40,           14 # number of header bytes remaining (including this)
  bmp.writeUInt32LE width,        18
  bmp.writeUInt32LE height,       22
  bmp.writeUInt16LE 1,            26 # num planes
  bmp.writeUInt16LE 24,           28 # bits per pixel
  bmp.writeUInt32LE 0,            30 # compression
  bmp.writeUInt32LE pixels_size,  34
  bmp.writeUInt32LE 0,            38 # X pixels per meter
  bmp.writeUInt32LE 0,            42 # Y pixels per meter
  bmp.writeUInt32LE 0,            46 # num colors in color table
  bmp.writeUInt32LE 0,            50 # important color count
  bmp


module.exports = {subbmp}
