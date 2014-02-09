{subbmp} = require '../index'
{assert_data_equal, assert_raises} = require './helpers'
assert = require 'assert'
_ = require 'underscore'

describe "subbmp", () ->
    rect = {x: 0, y: 0, width: 1, height: 1}

    xit 'TODO: test coverage for the result'

    it 'does not error for a valid BMP', () ->
      subbmp make_bmp(), rect

    it "errors if x < 0", () ->
      assert_raises 'rect out of bounds', () -> subbmp make_bmp(), {x: -1, y: 0, width: 1, height: 1}

    it "errors if y < 0", () ->
      assert_raises 'rect out of bounds', () -> subbmp make_bmp(), {x: 0, y: -1, width: 1, height: 1}

    it "errors if (x + width) to big", () ->
      assert_raises 'rect out of bounds', () -> subbmp make_bmp(), {x: 1, y: 0, width: 4, height: 1}

    it "errors if (y + height) to big", () ->
      assert_raises 'rect out of bounds', () -> subbmp make_bmp(), {x: 0, y: 1, width: 1, height: 2}

    it "raises 'Expected at least 54 bytes'", () ->
      bmp = new Buffer 53
      assert_raises 'Expected at least 54 bytes', () -> subbmp bmp, rect

    it "raises 'Expected data to start with 'BM'", () ->
      bmp = make_bmp()
      bmp[0] = 'X'
      assert_raises "Expected data to start with 'BM'", () -> subbmp bmp, rect

    it "raises 'Only 24-bit BMPs supported so far'", () ->
      bmp = make_bmp()
      bmp[28] = 8
      assert_raises 'Only 24-bit BMPs supported so far', () -> subbmp bmp, rect

    it "raises 'Only single-plane BMPs supported so far'", () ->
      bmp = make_bmp()
      bmp[26] = 3
      assert_raises 'Only single-plane BMPs supported so far', () -> subbmp bmp, rect

    it "raises 'Header error: pixels_size != (height * pad4(3 * width))'", () ->
      bmp = make_bmp()
      bmp[34] = 123
      assert_raises 'Header error: pixels_size != (height * pad4(3 * width))', () -> subbmp bmp, rect

    it "raises 'Header error: file_size != (pixels_size + 54)'", () ->
      bmp = make_bmp()
      bmp[2] = 123
      assert_raises 'Header error: file_size != (pixels_size + 54)', () -> subbmp bmp, rect

    it "errors if the compression field is not zero", () ->
      bmp = make_bmp()
      bmp[30] = 2
      assert_raises 'The header is not of a supported form', () -> subbmp bmp, rect

    it "raises 'The file size is incompatible with the header'", () ->
      bmp = make_bmp()
      bmp = bmp.slice(0, bmp.length - 1)
      assert_raises 'The file size is incompatible with the header', () -> subbmp bmp, rect


make_bmp = (width = 4, height = 2) ->
  pixels_size = (width * height * 3)
  file_size = (pixels_size + 54)
  bmp = new Buffer 54 + pixels_size
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
