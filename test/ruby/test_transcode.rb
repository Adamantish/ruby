# -*- encoding: ASCII-8BIT -*-   # make sure this runs in binary mode
# some of the comments are in UTF-8

require 'test/unit'
class TestTranscode < Test::Unit::TestCase
  def setup_really_needed? # trick to create all the necessary encodings
    all_encodings = [ 'ISO-8859-1', 'ISO-8859-2',
                      'ISO-8859-3', 'ISO-8859-4',
                      'ISO-8859-5', 'ISO-8859-6',
                      'ISO-8859-7', 'ISO-8859-8',
                      'ISO-8859-9', 'ISO-8859-10',
                      'ISO-8859-11', 'ISO-8859-13',
                      'ISO-8859-14', 'ISO-8859-15',
                      'UTF-16BE'
                    ]
    all_encodings.each do |enc|
      'abc'.encode(enc, 'UTF-8')
    end
  end

  def test_errors
    assert_raise(Encoding::ConverterNotFoundError) { 'abc'.encode('foo', 'bar') }
    assert_raise(Encoding::ConverterNotFoundError) { 'abc'.encode!('foo', 'bar') }
    assert_raise(Encoding::ConverterNotFoundError) { 'abc'.force_encoding('utf-8').encode('foo') }
    assert_raise(Encoding::ConverterNotFoundError) { 'abc'.force_encoding('utf-8').encode!('foo') }
    assert_raise(Encoding::UndefinedConversionError) { "\x80".encode('utf-8','ASCII-8BIT') }
    assert_raise(Encoding::InvalidByteSequenceError) { "\x80".encode('utf-8','US-ASCII') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA5".encode('utf-8','iso-8859-3') }
  end

  def test_arguments
    assert_equal('abc', 'abc'.force_encoding('utf-8').encode('iso-8859-1'))
    # check that encoding is kept when no conversion is done
    assert_equal('abc'.force_encoding('Shift_JIS'), 'abc'.force_encoding('Shift_JIS').encode('Shift_JIS'))
    assert_equal('abc'.force_encoding('Shift_JIS'), 'abc'.force_encoding('Shift_JIS').encode!('Shift_JIS'))
    # assert that encoding is correctly set
    assert_equal("D\u00FCrst".encoding, "D\xFCrst".force_encoding('iso-8859-1').encode('utf-8').encoding)
    # check that Encoding can be used as parameter
    assert_equal("D\u00FCrst", "D\xFCrst".encode('utf-8', Encoding.find('ISO-8859-1')))
    assert_equal("D\u00FCrst", "D\xFCrst".encode(Encoding.find('utf-8'), 'ISO-8859-1'))
    assert_equal("D\u00FCrst", "D\xFCrst".encode(Encoding.find('utf-8'), Encoding.find('ISO-8859-1')))
  end

  def test_length
    assert_equal("\u20AC"*20, ("\xA4"*20).encode('utf-8', 'iso-8859-15'))
    assert_equal("\u20AC"*20, ("\xA4"*20).encode!('utf-8', 'iso-8859-15'))
    assert_equal("\u20AC"*2000, ("\xA4"*2000).encode('utf-8', 'iso-8859-15'))
    assert_equal("\u20AC"*2000, ("\xA4"*2000).encode!('utf-8', 'iso-8859-15'))
    assert_equal("\u20AC"*200000, ("\xA4"*200000).encode('utf-8', 'iso-8859-15'))
    assert_equal("\u20AC"*200000, ("\xA4"*200000).encode!('utf-8', 'iso-8859-15'))
  end

  def check_both_ways(utf8, raw, encoding)
    assert_equal(utf8.force_encoding('utf-8'), raw.encode('utf-8', encoding))
    assert_equal(raw.force_encoding(encoding), utf8.encode(encoding, 'utf-8'))
  end

  def check_both_ways2(str1, enc1, str2, enc2)
    assert_equal(str1.force_encoding(enc1), str2.encode(enc1, enc2))
    assert_equal(str2.force_encoding(enc2), str1.encode(enc2, enc1))
  end

  def test_encodings
    check_both_ways("\u307E\u3064\u3082\u3068 \u3086\u304D\u3072\u308D",
        "\x82\xdc\x82\xc2\x82\xe0\x82\xc6 \x82\xe4\x82\xab\x82\xd0\x82\xeb", 'shift_jis') # まつもと ゆきひろ
    check_both_ways("\u307E\u3064\u3082\u3068 \u3086\u304D\u3072\u308D",
        "\xa4\xde\xa4\xc4\xa4\xe2\xa4\xc8 \xa4\xe6\xa4\xad\xa4\xd2\xa4\xed", 'euc-jp')
    check_both_ways("\u677E\u672C\u884C\u5F18", "\x8f\xbc\x96\x7b\x8d\x73\x8d\x4f", 'shift_jis') # 松本行弘
    check_both_ways("\u677E\u672C\u884C\u5F18", "\xbe\xbe\xcb\xdc\xb9\xd4\xb9\xb0", 'euc-jp')
    check_both_ways("D\u00FCrst", "D\xFCrst", 'iso-8859-1') # Dürst
    check_both_ways("D\u00FCrst", "D\xFCrst", 'iso-8859-2')
    check_both_ways("D\u00FCrst", "D\xFCrst", 'iso-8859-3')
    check_both_ways("D\u00FCrst", "D\xFCrst", 'iso-8859-4')
    check_both_ways("D\u00FCrst", "D\xFCrst", 'iso-8859-9')
    check_both_ways("D\u00FCrst", "D\xFCrst", 'iso-8859-10')
    check_both_ways("D\u00FCrst", "D\xFCrst", 'iso-8859-13')
    check_both_ways("D\u00FCrst", "D\xFCrst", 'iso-8859-14')
    check_both_ways("D\u00FCrst", "D\xFCrst", 'iso-8859-15')
    check_both_ways("r\u00E9sum\u00E9", "r\xE9sum\xE9", 'iso-8859-1') # résumé
    check_both_ways("\u0065\u006C\u0151\u00ED\u0072\u00E1\u0073", "el\xF5\xEDr\xE1s", 'iso-8859-2') # előírás
    check_both_ways("\u043F\u0435\u0440\u0435\u0432\u043E\u0434",
         "\xDF\xD5\xE0\xD5\xD2\xDE\xD4", 'iso-8859-5') # перевод
    check_both_ways("\u0643\u062A\u0628", "\xE3\xCA\xC8", 'iso-8859-6') # كتب
    check_both_ways("\u65E5\u8A18", "\x93\xFA\x8BL", 'shift_jis') # 日記
    check_both_ways("\u65E5\u8A18", "\xC6\xFC\xB5\xAD", 'euc-jp')
    check_both_ways("\uC560\uC778\uAD6C\uD568\u0020\u6734\uC9C0\uC778",
         "\xBE\xD6\xC0\xCE\xB1\xB8\xC7\xD4\x20\xDA\xD3\xC1\xF6\xC0\xCE", 'euc-kr') # 애인구함 朴지인
    check_both_ways("\uC544\uD58F\uD58F\u0020\uB620\uBC29\uD6BD\uB2D8\u0020\uC0AC\uB791\uD716",
         "\xBE\xC6\xC1\x64\xC1\x64\x20\x8C\x63\xB9\xE6\xC4\x4F\xB4\xD4\x20\xBB\xE7\xB6\xFB\xC5\x42", 'cp949') # 아햏햏 똠방횽님 사랑휖
  end

  def test_twostep
    assert_equal("D\xFCrst".force_encoding('iso-8859-2'), "D\xFCrst".encode('iso-8859-2', 'iso-8859-1'))
  end

  def test_ascii_range
    encodings = [
      'US-ASCII', 'ASCII-8BIT',
      'ISO-8859-1', 'ISO-8859-2', 'ISO-8859-3',
      'ISO-8859-4', 'ISO-8859-5', 'ISO-8859-6',
      'ISO-8859-7', 'ISO-8859-8', 'ISO-8859-9',
      'ISO-8859-10', 'ISO-8859-11', 'ISO-8859-13',
      'ISO-8859-14', 'ISO-8859-15',
      'EUC-JP', 'SHIFT_JIS', 'EUC-KR'
    ]
    all_ascii = (0..127).to_a.pack 'C*'
    encodings.each do |enc|
      test_start = all_ascii
      assert_equal(test_start, test_start.encode('UTF-8',enc).encode(enc).force_encoding('ASCII-8BIT')) 
    end
  end

  def test_all_bytes
    encodings_8859 = [
      'ISO-8859-1', 'ISO-8859-2',
      #'ISO-8859-3', # not all bytes used
      'ISO-8859-4', 'ISO-8859-5',
      #'ISO-8859-6', # not all bytes used
      #'ISO-8859-7', # not all bytes used
      #'ISO-8859-8', # not all bytes used
      'ISO-8859-9', 'ISO-8859-10',
      #'ISO-8859-11', # not all bytes used
      #'ISO-8859-12', # not available
      'ISO-8859-13','ISO-8859-14','ISO-8859-15',
      #'ISO-8859-16', # not available
    ]
    all_bytes = (0..255).to_a.pack 'C*'
    encodings_8859.each do |enc|
      test_start = all_bytes
      assert_equal(test_start, test_start.encode('UTF-8',enc).encode(enc).force_encoding('ASCII-8BIT')) 
    end
  end

  def test_windows_874
    check_both_ways("\u20AC", "\x80", 'windows-874') # €
    assert_raise(Encoding::UndefinedConversionError) { "\x81".encode("utf-8", 'windows-874') }
    assert_raise(Encoding::UndefinedConversionError) { "\x84".encode("utf-8", 'windows-874') }
    check_both_ways("\u2026", "\x85", 'windows-874') # …
    assert_raise(Encoding::UndefinedConversionError) { "\x86".encode("utf-8", 'windows-874') }
    assert_raise(Encoding::UndefinedConversionError) { "\x8F".encode("utf-8", 'windows-874') }
    assert_raise(Encoding::UndefinedConversionError) { "\x90".encode("utf-8", 'windows-874') }
    check_both_ways("\u2018", "\x91", 'windows-874') # ‘
    check_both_ways("\u2014", "\x97", 'windows-874') # —
    assert_raise(Encoding::UndefinedConversionError) { "\x98".encode("utf-8", 'windows-874') }
    assert_raise(Encoding::UndefinedConversionError) { "\x9F".encode("utf-8", 'windows-874') }
    check_both_ways("\u00A0", "\xA0", 'windows-874') # non-breaking space
    check_both_ways("\u0E0F", "\xAF", 'windows-874') # ฏ
    check_both_ways("\u0E10", "\xB0", 'windows-874') # ฐ
    check_both_ways("\u0E1F", "\xBF", 'windows-874') # ฟ
    check_both_ways("\u0E20", "\xC0", 'windows-874') # ภ
    check_both_ways("\u0E2F", "\xCF", 'windows-874') # ฯ
    check_both_ways("\u0E30", "\xD0", 'windows-874') # ะ
    check_both_ways("\u0E3A", "\xDA", 'windows-874') # ฺ
    assert_raise(Encoding::UndefinedConversionError) { "\xDB".encode("utf-8", 'windows-874') }
    assert_raise(Encoding::UndefinedConversionError) { "\xDE".encode("utf-8", 'windows-874') }
    check_both_ways("\u0E3F", "\xDF", 'windows-874') # ฿
    check_both_ways("\u0E40", "\xE0", 'windows-874') # เ
    check_both_ways("\u0E4F", "\xEF", 'windows-874') # ๏
    check_both_ways("\u0E50", "\xF0", 'windows-874') # ๐
    check_both_ways("\u0E5B", "\xFB", 'windows-874') # ๛
    assert_raise(Encoding::UndefinedConversionError) { "\xFC".encode("utf-8", 'windows-874') }
    assert_raise(Encoding::UndefinedConversionError) { "\xFF".encode("utf-8", 'windows-874') }
  end
  
  def test_windows_1250
    check_both_ways("\u20AC", "\x80", 'windows-1250') # €
    assert_raise(Encoding::UndefinedConversionError) { "\x81".encode("utf-8", 'windows-1250') }
    check_both_ways("\u201A", "\x82", 'windows-1250') # ‚
    assert_raise(Encoding::UndefinedConversionError) { "\x83".encode("utf-8", 'windows-1250') }
    check_both_ways("\u201E", "\x84", 'windows-1250') # „
    check_both_ways("\u2021", "\x87", 'windows-1250') # ‡
    assert_raise(Encoding::UndefinedConversionError) { "\x88".encode("utf-8", 'windows-1250') }
    check_both_ways("\u2030", "\x89", 'windows-1250') # ‰
    check_both_ways("\u0179", "\x8F", 'windows-1250') # Ź
    assert_raise(Encoding::UndefinedConversionError) { "\x90".encode("utf-8", 'windows-1250') }
    check_both_ways("\u2018", "\x91", 'windows-1250') # ‘
    check_both_ways("\u2014", "\x97", 'windows-1250') # —
    assert_raise(Encoding::UndefinedConversionError) { "\x98".encode("utf-8", 'windows-1250') }
    check_both_ways("\u2122", "\x99", 'windows-1250') # ™
    check_both_ways("\u00A0", "\xA0", 'windows-1250') # non-breaking space
    check_both_ways("\u017B", "\xAF", 'windows-1250') # Ż
    check_both_ways("\u00B0", "\xB0", 'windows-1250') # °
    check_both_ways("\u017C", "\xBF", 'windows-1250') # ż
    check_both_ways("\u0154", "\xC0", 'windows-1250') # Ŕ
    check_both_ways("\u010E", "\xCF", 'windows-1250') # Ď
    check_both_ways("\u0110", "\xD0", 'windows-1250') # Đ
    check_both_ways("\u00DF", "\xDF", 'windows-1250') # ß
    check_both_ways("\u0155", "\xE0", 'windows-1250') # ŕ
    check_both_ways("\u010F", "\xEF", 'windows-1250') # ď
    check_both_ways("\u0111", "\xF0", 'windows-1250') # đ
    check_both_ways("\u02D9", "\xFF", 'windows-1250') # ˙
  end
  
  def test_windows_1251
    check_both_ways("\u0402", "\x80", 'windows-1251') # Ђ
    check_both_ways("\u20AC", "\x88", 'windows-1251') # €
    check_both_ways("\u040F", "\x8F", 'windows-1251') # Џ
    check_both_ways("\u0452", "\x90", 'windows-1251') # ђ
    assert_raise(Encoding::UndefinedConversionError) { "\x98".encode("utf-8", 'windows-1251') }
    check_both_ways("\u045F", "\x9F", 'windows-1251') # џ
    check_both_ways("\u00A0", "\xA0", 'windows-1251') # non-breaking space
    check_both_ways("\u0407", "\xAF", 'windows-1251') # Ї
    check_both_ways("\u00B0", "\xB0", 'windows-1251') # °
    check_both_ways("\u0457", "\xBF", 'windows-1251') # ї
    check_both_ways("\u0410", "\xC0", 'windows-1251') # А
    check_both_ways("\u041F", "\xCF", 'windows-1251') # П
    check_both_ways("\u0420", "\xD0", 'windows-1251') # Р
    check_both_ways("\u042F", "\xDF", 'windows-1251') # Я
    check_both_ways("\u0430", "\xE0", 'windows-1251') # а
    check_both_ways("\u043F", "\xEF", 'windows-1251') # п
    check_both_ways("\u0440", "\xF0", 'windows-1251') # р
    check_both_ways("\u044F", "\xFF", 'windows-1251') # я
  end
  
  def test_windows_1252
    check_both_ways("\u20AC", "\x80", 'windows-1252') # €
    assert_raise(Encoding::UndefinedConversionError) { "\x81".encode("utf-8", 'windows-1252') }
    check_both_ways("\u201A", "\x82", 'windows-1252') # ‚
    check_both_ways("\u0152", "\x8C", 'windows-1252') # >Œ
    assert_raise(Encoding::UndefinedConversionError) { "\x8D".encode("utf-8", 'windows-1252') }
    check_both_ways("\u017D", "\x8E", 'windows-1252') # Ž
	assert_raise(Encoding::UndefinedConversionError) { "\x8F".encode("utf-8", 'windows-1252') }
    assert_raise(Encoding::UndefinedConversionError) { "\x90".encode("utf-8", 'windows-1252') }
    check_both_ways("\u2018", "\x91", 'windows-1252') #‘
    check_both_ways("\u0153", "\x9C", 'windows-1252') # œ
    assert_raise(Encoding::UndefinedConversionError) { "\x9D".encode("utf-8", 'windows-1252') }
    check_both_ways("\u017E", "\x9E", 'windows-1252') # ž
    check_both_ways("\u00A0", "\xA0", 'windows-1252') # non-breaking space 
    check_both_ways("\u00AF", "\xAF", 'windows-1252') # ¯
    check_both_ways("\u00B0", "\xB0", 'windows-1252') # °
    check_both_ways("\u00BF", "\xBF", 'windows-1252') # ¿
    check_both_ways("\u00C0", "\xC0", 'windows-1252') # À
    check_both_ways("\u00CF", "\xCF", 'windows-1252') # Ï
    check_both_ways("\u00D0", "\xD0", 'windows-1252') # Ð
    check_both_ways("\u00DF", "\xDF", 'windows-1252') # ß
    check_both_ways("\u00E0", "\xE0", 'windows-1252') # à
    check_both_ways("\u00EF", "\xEF", 'windows-1252') # ï
    check_both_ways("\u00F0", "\xF0", 'windows-1252') # ð
    check_both_ways("\u00FF", "\xFF", 'windows-1252') # ÿ
  end

  def test_windows_1253
    check_both_ways("\u20AC", "\x80", 'windows-1253') # €
    assert_raise(Encoding::UndefinedConversionError) { "\x81".encode("utf-8", 'windows-1253') }
    check_both_ways("\u201A", "\x82", 'windows-1253') # ‚
    check_both_ways("\u2021", "\x87", 'windows-1253') # ‡
    assert_raise(Encoding::UndefinedConversionError) { "\x88".encode("utf-8", 'windows-1253') }
    check_both_ways("\u2030", "\x89", 'windows-1253') # ‰
    assert_raise(Encoding::UndefinedConversionError) { "\x8A".encode("utf-8", 'windows-1253') }
    check_both_ways("\u2039", "\x8B", 'windows-1253') # ‹
    assert_raise(Encoding::UndefinedConversionError) { "\x8C".encode("utf-8", 'windows-1253') }
    assert_raise(Encoding::UndefinedConversionError) { "\x8F".encode("utf-8", 'windows-1253') }
    assert_raise(Encoding::UndefinedConversionError) { "\x90".encode("utf-8", 'windows-1253') }
    check_both_ways("\u2018", "\x91", 'windows-1253') # ‘
    check_both_ways("\u2014", "\x97", 'windows-1253') # —
    assert_raise(Encoding::UndefinedConversionError) { "\x98".encode("utf-8", 'windows-1253') }
    check_both_ways("\u2122", "\x99", 'windows-1253') # ™
    assert_raise(Encoding::UndefinedConversionError) { "\x9A".encode("utf-8", 'windows-1253') }
    check_both_ways("\u203A", "\x9B", 'windows-1253') # ›
    assert_raise(Encoding::UndefinedConversionError) { "\x9C".encode("utf-8", 'windows-1253') }
    assert_raise(Encoding::UndefinedConversionError) { "\x9F".encode("utf-8", 'windows-1253') }
    check_both_ways("\u00A0", "\xA0", 'windows-1253') # non-breaking space
    check_both_ways("\u2015", "\xAF", 'windows-1253') # ―
    check_both_ways("\u00B0", "\xB0", 'windows-1253') # °
    check_both_ways("\u038F", "\xBF", 'windows-1253') # Ώ
    check_both_ways("\u0390", "\xC0", 'windows-1253') # ΐ
    check_both_ways("\u039F", "\xCF", 'windows-1253') # Ο
    check_both_ways("\u03A0", "\xD0", 'windows-1253') # Π
    check_both_ways("\u03A1", "\xD1", 'windows-1253') # Ρ
    assert_raise(Encoding::UndefinedConversionError) { "\xD2".encode("utf-8", 'windows-1253') }
    check_both_ways("\u03A3", "\xD3", 'windows-1253') # Σ
    check_both_ways("\u03AF", "\xDF", 'windows-1253') # ί
    check_both_ways("\u03B0", "\xE0", 'windows-1253') # ΰ
    check_both_ways("\u03BF", "\xEF", 'windows-1253') # ο
    check_both_ways("\u03C0", "\xF0", 'windows-1253') # π
    check_both_ways("\u03CE", "\xFE", 'windows-1253') # ώ
    assert_raise(Encoding::UndefinedConversionError) { "\xFF".encode("utf-8", 'windows-1253') }
  end
  
  def test_windows_1254
    check_both_ways("\u20AC", "\x80", 'windows-1254') # €
    assert_raise(Encoding::UndefinedConversionError) { "\x81".encode("utf-8", 'windows-1254') }
    check_both_ways("\u201A", "\x82", 'windows-1254') # ‚
    check_both_ways("\u0152", "\x8C", 'windows-1254') # Œ
    assert_raise(Encoding::UndefinedConversionError) { "\x8D".encode("utf-8", 'windows-1254') }
    assert_raise(Encoding::UndefinedConversionError) { "\x8F".encode("utf-8", 'windows-1254') }
    assert_raise(Encoding::UndefinedConversionError) { "\x90".encode("utf-8", 'windows-1254') }
    check_both_ways("\u2018", "\x91", 'windows-1254') # ‘
    check_both_ways("\u0153", "\x9C", 'windows-1254') # œ
    assert_raise(Encoding::UndefinedConversionError) { "\x9D".encode("utf-8", 'windows-1254') }
    assert_raise(Encoding::UndefinedConversionError) { "\x9E".encode("utf-8", 'windows-1254') }
    check_both_ways("\u0178", "\x9F", 'windows-1254') # Ÿ
    check_both_ways("\u00A0", "\xA0", 'windows-1254') # non-breaking space
    check_both_ways("\u00AF", "\xAF", 'windows-1254') # ¯
    check_both_ways("\u00B0", "\xB0", 'windows-1254') # °
    check_both_ways("\u00BF", "\xBF", 'windows-1254') # ¿
    check_both_ways("\u00C0", "\xC0", 'windows-1254') # À
    check_both_ways("\u00CF", "\xCF", 'windows-1254') # Ï
    check_both_ways("\u011E", "\xD0", 'windows-1254') # Ğ
    check_both_ways("\u00DF", "\xDF", 'windows-1254') # ß
    check_both_ways("\u00E0", "\xE0", 'windows-1254') # à
    check_both_ways("\u00EF", "\xEF", 'windows-1254') # ï
    check_both_ways("\u011F", "\xF0", 'windows-1254') # ğ
    check_both_ways("\u00FF", "\xFF", 'windows-1254') # ÿ
  end
  
  def test_windows_1255
  	check_both_ways("\u20AC", "\x80", 'windows-1255') # €
	assert_raise(Encoding::UndefinedConversionError) { "\x81".encode("utf-8", 'windows-1255') }
  	check_both_ways("\u201A", "\x82", 'windows-1255') # ‚
 	check_both_ways("\u2030", "\x89", 'windows-1255') # ‰
    assert_raise(Encoding::UndefinedConversionError) { "\x8A".encode("utf-8", 'windows-1255') }
    check_both_ways("\u2039", "\x8B", 'windows-1255') # ‹
    assert_raise(Encoding::UndefinedConversionError) { "\x8C".encode("utf-8", 'windows-1255') }
    assert_raise(Encoding::UndefinedConversionError) { "\x8F".encode("utf-8", 'windows-1255') }
    assert_raise(Encoding::UndefinedConversionError) { "\x90".encode("utf-8", 'windows-1255') }
    check_both_ways("\u2018", "\x91", 'windows-1255') # ‘
    check_both_ways("\u2122", "\x99", 'windows-1255') # ™
    assert_raise(Encoding::UndefinedConversionError) { "\x9A".encode("utf-8", 'windows-1255') }
    check_both_ways("\u203A", "\x9B", 'windows-1255') # ›
    assert_raise(Encoding::UndefinedConversionError) { "\x9C".encode("utf-8", 'windows-1255') }
    assert_raise(Encoding::UndefinedConversionError) { "\x9F".encode("utf-8", 'windows-1255') }
    check_both_ways("\u00A0", "\xA0", 'windows-1255') # non-breaking space
    check_both_ways("\u00A1", "\xA1", 'windows-1255') # ¡
    check_both_ways("\u00D7", "\xAA", 'windows-1255') # ×
    check_both_ways("\u00AF", "\xAF", 'windows-1255') # ¯
    check_both_ways("\u00B0", "\xB0", 'windows-1255') # °
    check_both_ways("\u00B8", "\xB8", 'windows-1255') # ¸
    check_both_ways("\u00F7", "\xBA", 'windows-1255') # ÷
    check_both_ways("\u00BF", "\xBF", 'windows-1255') # ¿
    check_both_ways("\u05B0", "\xC0", 'windows-1255') # ְ
    check_both_ways("\u05B9", "\xC9", 'windows-1255') # ֹ
    assert_raise(Encoding::UndefinedConversionError) { "\xCA".encode("utf-8", 'windows-1255') }
    check_both_ways("\u05BB", "\xCB", 'windows-1255') # ֻ
    check_both_ways("\u05BF", "\xCF", 'windows-1255') # ֿ
    check_both_ways("\u05C0", "\xD0", 'windows-1255') # ׀
    check_both_ways("\u05F3", "\xD7", 'windows-1255') # ׳
    check_both_ways("\u05F4", "\xD8", 'windows-1255') # ״
    assert_raise(Encoding::UndefinedConversionError) { "\xD9".encode("utf-8", 'windows-1255') }
    assert_raise(Encoding::UndefinedConversionError) { "\xDF".encode("utf-8", 'windows-1255') }
    check_both_ways("\u05D0", "\xE0", 'windows-1255') # א
    check_both_ways("\u05DF", "\xEF", 'windows-1255') # ן
    check_both_ways("\u05E0", "\xF0", 'windows-1255') # נ
    check_both_ways("\u05EA", "\xFA", 'windows-1255') # ת
    assert_raise(Encoding::UndefinedConversionError) { "\xFB".encode("utf-8", 'windows-1255') }
    assert_raise(Encoding::UndefinedConversionError) { "\xFC".encode("utf-8", 'windows-1255') }
    check_both_ways("\u200E", "\xFD", 'windows-1255') # left-to-right mark
    check_both_ways("\u200F", "\xFE", 'windows-1255') # right-to-left mark
    assert_raise(Encoding::UndefinedConversionError) { "\xFF".encode("utf-8", 'windows-1255') }
  end
  
  def test_windows_1256
    check_both_ways("\u20AC", "\x80", 'windows-1256') # €
    check_both_ways("\u0679", "\x8A", 'windows-1256') # ٹ
    check_both_ways("\u0688", "\x8F", 'windows-1256') # ڈ
    check_both_ways("\u06AF", "\x90", 'windows-1256') # گ
    check_both_ways("\u06A9", "\x98", 'windows-1256') # ک
    check_both_ways("\u0691", "\x9A", 'windows-1256') # ڑ
    check_both_ways("\u06BA", "\x9F", 'windows-1256') # ں
    check_both_ways("\u00A0", "\xA0", 'windows-1256') # non-breaking space
    check_both_ways("\u06BE", "\xAA", 'windows-1256') # ھ
    check_both_ways("\u00AF", "\xAF", 'windows-1256') # ¯
    check_both_ways("\u00B0", "\xB0", 'windows-1256') # °
    check_both_ways("\u061F", "\xBF", 'windows-1256') # ؟
    check_both_ways("\u06C1", "\xC0", 'windows-1256') # ہ
    check_both_ways("\u062F", "\xCF", 'windows-1256') # د
    check_both_ways("\u0630", "\xD0", 'windows-1256') # ذ
    check_both_ways("\u0643", "\xDF", 'windows-1256') # ك
    check_both_ways("\u00E0", "\xE0", 'windows-1256') # à
    check_both_ways("\u00EF", "\xEF", 'windows-1256') # ï
    check_both_ways("\u064B", "\xF0", 'windows-1256') #  ًً
    check_both_ways("\u06D2", "\xFF", 'windows-1256') # ے
  end
  
  def test_windows_1257
    check_both_ways("\u20AC", "\x80", 'windows-1257') # €
    assert_raise(Encoding::UndefinedConversionError) { "\x81".encode("utf-8", 'windows-1257') }
    check_both_ways("\u201A", "\x82", 'windows-1257') # ‚
    assert_raise(Encoding::UndefinedConversionError) { "\x83".encode("utf-8", 'windows-1257') }
    check_both_ways("\u201E", "\x84", 'windows-1257') # „
    check_both_ways("\u2021", "\x87", 'windows-1257') # ‡
    assert_raise(Encoding::UndefinedConversionError) { "\x88".encode("utf-8", 'windows-1257') }
    check_both_ways("\u2030", "\x89", 'windows-1257') # ‰
    assert_raise(Encoding::UndefinedConversionError) { "\x8A".encode("utf-8", 'windows-1257') }
    check_both_ways("\u2039", "\x8B", 'windows-1257') # ‹
    assert_raise(Encoding::UndefinedConversionError) { "\x8C".encode("utf-8", 'windows-1257') }
    check_both_ways("\u00A8", "\x8D", 'windows-1257') # ¨
    check_both_ways("\u02C7", "\x8E", 'windows-1257') # ˇ
    check_both_ways("\u00B8", "\x8F", 'windows-1257') # ¸
    assert_raise(Encoding::UndefinedConversionError) { "\x90".encode("utf-8", 'windows-1257') }
    check_both_ways("\u2018", "\x91", 'windows-1257') # ‘
    check_both_ways("\u2014", "\x97", 'windows-1257') # —
    assert_raise(Encoding::UndefinedConversionError) { "\x98".encode("utf-8", 'windows-1257') }
    check_both_ways("\u2122", "\x99", 'windows-1257') # ™
    assert_raise(Encoding::UndefinedConversionError) { "\x9A".encode("utf-8", 'windows-1257') }
    check_both_ways("\u203A", "\x9B", 'windows-1257') # ›
    assert_raise(Encoding::UndefinedConversionError) { "\x9C".encode("utf-8", 'windows-1257') }
    check_both_ways("\u00AF", "\x9D", 'windows-1257') # ¯
    check_both_ways("\u02DB", "\x9E", 'windows-1257') # ˛
    assert_raise(Encoding::UndefinedConversionError) { "\x9F".encode("utf-8", 'windows-1257') }
    check_both_ways("\u00A0", "\xA0", 'windows-1257') # non-breaking space
    assert_raise(Encoding::UndefinedConversionError) { "\xA1".encode("utf-8", 'windows-1257') }
    check_both_ways("\u00A2", "\xA2", 'windows-1257') # ¢
    check_both_ways("\u00A4", "\xA4", 'windows-1257') # ¤
    assert_raise(Encoding::UndefinedConversionError) { "\xA5".encode("utf-8", 'windows-1257') }
    check_both_ways("\u00A6", "\xA6", 'windows-1257') # ¦
    check_both_ways("\u00C6", "\xAF", 'windows-1257') # Æ
    check_both_ways("\u00B0", "\xB0", 'windows-1257') # °
    check_both_ways("\u00E6", "\xBF", 'windows-1257') # æ
    check_both_ways("\u0104", "\xC0", 'windows-1257') # Ą
    check_both_ways("\u013B", "\xCF", 'windows-1257') # Ļ
    check_both_ways("\u0160", "\xD0", 'windows-1257') # Š
    check_both_ways("\u00DF", "\xDF", 'windows-1257') # ß
    check_both_ways("\u0105", "\xE0", 'windows-1257') # ą
    check_both_ways("\u013C", "\xEF", 'windows-1257') # ļ
    check_both_ways("\u0161", "\xF0", 'windows-1257') # š
    check_both_ways("\u02D9", "\xFF", 'windows-1257') # ˙
  end

  def test_macCroatian
    check_both_ways("\u00C4", "\x80", 'macCroatian') # Ä
    check_both_ways("\u00E8", "\x8F", 'macCroatian') # è
    check_both_ways("\u00EA", "\x90", 'macCroatian') # ê
    check_both_ways("\u00FC", "\x9F", 'macCroatian') # ü
    check_both_ways("\u2020", "\xA0", 'macCroatian') # †
    check_both_ways("\u00D8", "\xAF", 'macCroatian') # Ø
    check_both_ways("\u221E", "\xB0", 'macCroatian') # ∞
    check_both_ways("\u00F8", "\xBF", 'macCroatian') # ø
    check_both_ways("\u00BF", "\xC0", 'macCroatian') # ¿
    check_both_ways("\u0153", "\xCF", 'macCroatian') # œ
    check_both_ways("\u0110", "\xD0", 'macCroatian') # Đ
    check_both_ways("\u00A9", "\xD9", 'macCroatian') # ©
    check_both_ways("\u2044", "\xDA", 'macCroatian') # ⁄
    check_both_ways("\u203A", "\xDD", 'macCroatian') # ›
    check_both_ways("\u00C6", "\xDE", 'macCroatian') # Æ
    check_both_ways("\u00BB", "\xDF", 'macCroatian') # »
    check_both_ways("\u2013", "\xE0", 'macCroatian') # –
    check_both_ways("\u00B7", "\xE1", 'macCroatian') # ·
    check_both_ways("\u00C2", "\xE5", 'macCroatian') # Â
    check_both_ways("\u0107", "\xE6", 'macCroatian') # ć
    check_both_ways("\u00C1", "\xE7", 'macCroatian') # Á
    check_both_ways("\u010D", "\xE8", 'macCroatian') # č
    check_both_ways("\u00C8", "\xE9", 'macCroatian') # È
    check_both_ways("\u00D4", "\xEF", 'macCroatian') # Ô
    check_both_ways("\u0111", "\xF0", 'macCroatian') # đ
    check_both_ways("\u00D2", "\xF1", 'macCroatian') # Ò
    check_both_ways("\u00AF", "\xF8", 'macCroatian') # ¯
    check_both_ways("\u03C0", "\xF9", 'macCroatian') # π
    check_both_ways("\u00CB", "\xFA", 'macCroatian') # Ë
    check_both_ways("\u00CA", "\xFD", 'macCroatian') # Ê
    check_both_ways("\u00E6", "\xFE", 'macCroatian') # æ
    check_both_ways("\u02C7", "\xFF", 'macCroatian') # ˇ
  end
  
  def test_macCyrillic
    check_both_ways("\u0410", "\x80", 'macCyrillic') # А
    check_both_ways("\u041F", "\x8F", 'macCyrillic') # П
    check_both_ways("\u0420", "\x90", 'macCyrillic') # Р
    check_both_ways("\u042F", "\x9F", 'macCyrillic') # Я
    check_both_ways("\u2020", "\xA0", 'macCyrillic') # †
    check_both_ways("\u0453", "\xAF", 'macCyrillic') # ѓ
    check_both_ways("\u221E", "\xB0", 'macCyrillic') # ∞
    check_both_ways("\u045A", "\xBF", 'macCyrillic') # њ
    check_both_ways("\u0458", "\xC0", 'macCyrillic') # ј
    check_both_ways("\u0455", "\xCF", 'macCyrillic') # ѕ
    check_both_ways("\u2013", "\xD0", 'macCyrillic') # –
    check_both_ways("\u044F", "\xDF", 'macCyrillic') # я
    check_both_ways("\u0430", "\xE0", 'macCyrillic') # а
    check_both_ways("\u043F", "\xEF", 'macCyrillic') # п
    check_both_ways("\u0440", "\xF0", 'macCyrillic') # р
    check_both_ways("\u00A4", "\xFF", 'macCyrillic') # ¤
  end
  
  def test_macIceland
    check_both_ways("\u00C4", "\x80", 'macIceland') # Ä
    check_both_ways("\u00E8", "\x8F", 'macIceland') # è
    check_both_ways("\u00EA", "\x90", 'macIceland') # ê
    check_both_ways("\u00FC", "\x9F", 'macIceland') # ü
    check_both_ways("\u00DD", "\xA0", 'macIceland') # Ý
    check_both_ways("\u00D8", "\xAF", 'macIceland') # Ø
    check_both_ways("\u221E", "\xB0", 'macIceland') # ∞
    check_both_ways("\u00F8", "\xBF", 'macIceland') # ø
    check_both_ways("\u00BF", "\xC0", 'macIceland') # ¿
    check_both_ways("\u0153", "\xCF", 'macIceland') # œ
    check_both_ways("\u2013", "\xD0", 'macIceland') # –
    check_both_ways("\u00FE", "\xDF", 'macIceland') # þ
    check_both_ways("\u00FD", "\xE0", 'macIceland') # ý
    check_both_ways("\u00D4", "\xEF", 'macIceland') # Ô
    #check_both_ways("\uF8FF", "\xF0", 'macIceland') # Apple logo
    check_both_ways("\u02C7", "\xFF", 'macIceland') # ˇ
  end

  def check_utf_16_both_ways(utf8, raw)
    copy = raw.dup
    0.step(copy.length-1, 2) { |i| copy[i+1], copy[i] = copy[i], copy[i+1] }
    check_both_ways(utf8, raw, 'utf-16be')
    check_both_ways(utf8, copy, 'utf-16le')
  end

  def test_utf_16
    check_utf_16_both_ways("abc", "\x00a\x00b\x00c")
    check_utf_16_both_ways("\u00E9", "\x00\xE9");
    check_utf_16_both_ways("\u00E9\u0070\u00E9\u0065", "\x00\xE9\x00\x70\x00\xE9\x00\x65") # épée
    check_utf_16_both_ways("\u677E\u672C\u884C\u5F18", "\x67\x7E\x67\x2C\x88\x4C\x5F\x18") # 松本行弘
    check_utf_16_both_ways("\u9752\u5C71\u5B66\u9662\u5927\u5B66", "\x97\x52\x5C\x71\x5B\x66\x96\x62\x59\x27\x5B\x66") # 青山学院大学
    check_utf_16_both_ways("Martin D\u00FCrst", "\x00M\x00a\x00r\x00t\x00i\x00n\x00 \x00D\x00\xFC\x00r\x00s\x00t") # Martin Dürst
    # BMP
    check_utf_16_both_ways("\u0000", "\x00\x00")
    check_utf_16_both_ways("\u007F", "\x00\x7F")
    check_utf_16_both_ways("\u0080", "\x00\x80")
    check_utf_16_both_ways("\u0555", "\x05\x55")
    check_utf_16_both_ways("\u04AA", "\x04\xAA")
    check_utf_16_both_ways("\u0333", "\x03\x33")
    check_utf_16_both_ways("\u04CC", "\x04\xCC")
    check_utf_16_both_ways("\u00F0", "\x00\xF0")
    check_utf_16_both_ways("\u070F", "\x07\x0F")
    check_utf_16_both_ways("\u07FF", "\x07\xFF")
    check_utf_16_both_ways("\u0800", "\x08\x00")
    check_utf_16_both_ways("\uD7FF", "\xD7\xFF")
    check_utf_16_both_ways("\uE000", "\xE0\x00")
    check_utf_16_both_ways("\uFFFF", "\xFF\xFF")
    check_utf_16_both_ways("\u5555", "\x55\x55")
    check_utf_16_both_ways("\uAAAA", "\xAA\xAA")
    check_utf_16_both_ways("\u3333", "\x33\x33")
    check_utf_16_both_ways("\uCCCC", "\xCC\xCC")
    check_utf_16_both_ways("\uF0F0", "\xF0\xF0")
    check_utf_16_both_ways("\u0F0F", "\x0F\x0F")
    check_utf_16_both_ways("\uFF00", "\xFF\x00")
    check_utf_16_both_ways("\u00FF", "\x00\xFF")
    # outer planes
    check_utf_16_both_ways("\u{10000}", "\xD8\x00\xDC\x00")
    check_utf_16_both_ways("\u{FFFFF}", "\xDB\xBF\xDF\xFF")
    check_utf_16_both_ways("\u{100000}", "\xDB\xC0\xDC\x00")
    check_utf_16_both_ways("\u{10FFFF}", "\xDB\xFF\xDF\xFF")
    check_utf_16_both_ways("\u{105555}", "\xDB\xD5\xDD\x55")
    check_utf_16_both_ways("\u{55555}", "\xD9\x15\xDD\x55")
    check_utf_16_both_ways("\u{AAAAA}", "\xDA\x6A\xDE\xAA")
    check_utf_16_both_ways("\u{33333}", "\xD8\x8C\xDF\x33")
    check_utf_16_both_ways("\u{CCCCC}", "\xDA\xF3\xDC\xCC")
    check_utf_16_both_ways("\u{8F0F0}", "\xD9\xFC\xDC\xF0")
    check_utf_16_both_ways("\u{F0F0F}", "\xDB\x83\xDF\x0F")
    check_utf_16_both_ways("\u{8FF00}", "\xD9\xFF\xDF\x00")
    check_utf_16_both_ways("\u{F00FF}", "\xDB\x80\xDC\xFF")
  end

  def check_utf_32_both_ways(utf8, raw)
    copy = raw.dup
    0.step(copy.length-1, 4) do |i|
      copy[i+3], copy[i+2], copy[i+1], copy[i] = copy[i], copy[i+1], copy[i+2], copy[i+3]
    end
    check_both_ways(utf8, raw, 'utf-32be')
    #check_both_ways(utf8, copy, 'utf-32le')
  end

  def test_utf_32
    check_utf_32_both_ways("abc", "\x00\x00\x00a\x00\x00\x00b\x00\x00\x00c")
    check_utf_32_both_ways("\u00E9", "\x00\x00\x00\xE9");
    check_utf_32_both_ways("\u00E9\u0070\u00E9\u0065",
      "\x00\x00\x00\xE9\x00\x00\x00\x70\x00\x00\x00\xE9\x00\x00\x00\x65") # épée
    check_utf_32_both_ways("\u677E\u672C\u884C\u5F18",
      "\x00\x00\x67\x7E\x00\x00\x67\x2C\x00\x00\x88\x4C\x00\x00\x5F\x18") # 松本行弘
    check_utf_32_both_ways("\u9752\u5C71\u5B66\u9662\u5927\u5B66",
      "\x00\x00\x97\x52\x00\x00\x5C\x71\x00\x00\x5B\x66\x00\x00\x96\x62\x00\x00\x59\x27\x00\x00\x5B\x66") # 青山学院大学
    check_utf_32_both_ways("Martin D\u00FCrst",
      "\x00\x00\x00M\x00\x00\x00a\x00\x00\x00r\x00\x00\x00t\x00\x00\x00i\x00\x00\x00n\x00\x00\x00 \x00\x00\x00D\x00\x00\x00\xFC\x00\x00\x00r\x00\x00\x00s\x00\x00\x00t") # Martin Dürst
    # BMP
    check_utf_32_both_ways("\u0000", "\x00\x00\x00\x00")
    check_utf_32_both_ways("\u007F", "\x00\x00\x00\x7F")
    check_utf_32_both_ways("\u0080", "\x00\x00\x00\x80")
    check_utf_32_both_ways("\u0555", "\x00\x00\x05\x55")
    check_utf_32_both_ways("\u04AA", "\x00\x00\x04\xAA")
    check_utf_32_both_ways("\u0333", "\x00\x00\x03\x33")
    check_utf_32_both_ways("\u04CC", "\x00\x00\x04\xCC")
    check_utf_32_both_ways("\u00F0", "\x00\x00\x00\xF0")
    check_utf_32_both_ways("\u070F", "\x00\x00\x07\x0F")
    check_utf_32_both_ways("\u07FF", "\x00\x00\x07\xFF")
    check_utf_32_both_ways("\u0800", "\x00\x00\x08\x00")
    check_utf_32_both_ways("\uD7FF", "\x00\x00\xD7\xFF")
    check_utf_32_both_ways("\uE000", "\x00\x00\xE0\x00")
    check_utf_32_both_ways("\uFFFF", "\x00\x00\xFF\xFF")
    check_utf_32_both_ways("\u5555", "\x00\x00\x55\x55")
    check_utf_32_both_ways("\uAAAA", "\x00\x00\xAA\xAA")
    check_utf_32_both_ways("\u3333", "\x00\x00\x33\x33")
    check_utf_32_both_ways("\uCCCC", "\x00\x00\xCC\xCC")
    check_utf_32_both_ways("\uF0F0", "\x00\x00\xF0\xF0")
    check_utf_32_both_ways("\u0F0F", "\x00\x00\x0F\x0F")
    check_utf_32_both_ways("\uFF00", "\x00\x00\xFF\x00")
    check_utf_32_both_ways("\u00FF", "\x00\x00\x00\xFF")
    # outer planes
    check_utf_32_both_ways("\u{10000}", "\x00\x01\x00\x00")
    check_utf_32_both_ways("\u{FFFFF}", "\x00\x0F\xFF\xFF")
    check_utf_32_both_ways("\u{100000}","\x00\x10\x00\x00")
    check_utf_32_both_ways("\u{10FFFF}","\x00\x10\xFF\xFF")
    check_utf_32_both_ways("\u{105555}","\x00\x10\x55\x55")
    check_utf_32_both_ways("\u{55555}", "\x00\x05\x55\x55")
    check_utf_32_both_ways("\u{AAAAA}", "\x00\x0A\xAA\xAA")
    check_utf_32_both_ways("\u{33333}", "\x00\x03\x33\x33")
    check_utf_32_both_ways("\u{CCCCC}", "\x00\x0C\xCC\xCC")
    check_utf_32_both_ways("\u{8F0F0}", "\x00\x08\xF0\xF0")
    check_utf_32_both_ways("\u{F0F0F}", "\x00\x0F\x0F\x0F")
    check_utf_32_both_ways("\u{8FF00}", "\x00\x08\xFF\x00")
    check_utf_32_both_ways("\u{F00FF}", "\x00\x0F\x00\xFF")
  end
  
  def test_invalid_ignore
    # arguments only
    assert_nothing_raised { 'abc'.encode('utf-8', invalid: :replace, replace: "") }
    # check handling of UTF-8 ill-formed subsequences
    assert_equal("\x00\x41\x00\x3E\x00\x42".force_encoding('UTF-16BE'),
      "\x41\xC2\x3E\x42".encode('UTF-16BE', 'UTF-8', invalid: :replace, replace: ""))
    assert_equal("\x00\x41\x00\xF1\x00\x42".force_encoding('UTF-16BE'),
      "\x41\xC2\xC3\xB1\x42".encode('UTF-16BE', 'UTF-8', invalid: :replace, replace: ""))
    assert_equal("\x00\x42".force_encoding('UTF-16BE'),
      "\xF0\x80\x80\x42".encode('UTF-16BE', 'UTF-8', invalid: :replace, replace: ""))
    assert_equal(''.force_encoding('UTF-16BE'),
      "\x82\xAB".encode('UTF-16BE', 'UTF-8', invalid: :replace, replace: ""))

    assert_equal("\e$B!!\e(B".force_encoding("ISO-2022-JP"),
      "\xA1\xA1\xFF".encode("ISO-2022-JP", "EUC-JP", invalid: :replace, replace: ""))
    assert_equal("\e$B\x24\x22\x24\x24\e(B".force_encoding("ISO-2022-JP"),
      "\xA4\xA2\xFF\xA4\xA4".encode("ISO-2022-JP", "EUC-JP", invalid: :replace, replace: ""))
    assert_equal("\e$B\x24\x22\x24\x24\e(B".force_encoding("ISO-2022-JP"),
      "\xA4\xA2\xFF\xFF\xA4\xA4".encode("ISO-2022-JP", "EUC-JP", invalid: :replace, replace: ""))
  end

  def test_invalid_replace
    # arguments only
    assert_nothing_raised { 'abc'.encode('UTF-8', invalid: :replace) }
    assert_equal("\xEF\xBF\xBD".force_encoding("UTF-8"),
      "\x80".encode("UTF-8", "UTF-16BE", invalid: :replace))
    assert_equal("\xFF\xFD".force_encoding("UTF-16BE"),
      "\x80".encode("UTF-16BE", "UTF-8", invalid: :replace))
    assert_equal("\xFD\xFF".force_encoding("UTF-16LE"),
      "\x80".encode("UTF-16LE", "UTF-8", invalid: :replace))
    assert_equal("\x00\x00\xFF\xFD".force_encoding("UTF-32BE"),
      "\x80".encode("UTF-32BE", "UTF-8", invalid: :replace))
    assert_equal("\xFD\xFF\x00\x00".force_encoding("UTF-32LE"),
      "\x80".encode("UTF-32LE", "UTF-8", invalid: :replace))

    assert_equal("\uFFFD!",
      "\xdc\x00\x00!".encode("utf-8", "utf-16be", :invalid=>:replace))
    assert_equal("\uFFFD!",
      "\xd8\x00\x00!".encode("utf-8", "utf-16be", :invalid=>:replace))

    assert_equal("\uFFFD!",
      "\x00\xdc!\x00".encode("utf-8", "utf-16le", :invalid=>:replace))
    assert_equal("\uFFFD!",
      "\x00\xd8!\x00".encode("utf-8", "utf-16le", :invalid=>:replace))

    assert_equal("\uFFFD!",
      "\x01\x00\x00\x00\x00\x00\x00!".encode("utf-8", "utf-32be", :invalid=>:replace), "[ruby-dev:35726]")
    assert_equal("\uFFFD!",
      "\x00\xff\x00\x00\x00\x00\x00!".encode("utf-8", "utf-32be", :invalid=>:replace))
    assert_equal("\uFFFD!",
      "\x00\x00\xd8\x00\x00\x00\x00!".encode("utf-8", "utf-32be", :invalid=>:replace))

    assert_equal("\uFFFD!",
      "\x00\x00\x00\xff!\x00\x00\x00".encode("utf-8", "utf-32le", :invalid=>:replace))
    assert_equal("\uFFFD!",
      "\x00\x00\xff\x00!\x00\x00\x00".encode("utf-8", "utf-32le", :invalid=>:replace))
    assert_equal("\uFFFD!",
      "\x00\xd8\x00\x00!\x00\x00\x00".encode("utf-8", "utf-32le", :invalid=>:replace))

    assert_equal("\uFFFD!",
      "\xff!".encode("utf-8", "euc-jp", :invalid=>:replace))
    assert_equal("\uFFFD!",
      "\xa1!".encode("utf-8", "euc-jp", :invalid=>:replace))
    assert_equal("\uFFFD!",
      "\x8f\xa1!".encode("utf-8", "euc-jp", :invalid=>:replace))

    assert_equal("?",
      "\xdc\x00".encode("EUC-JP", "UTF-16BE", :invalid=>:replace), "[ruby-dev:35776]")
    assert_equal("ab?cd?ef",
      "\0a\0b\xdc\x00\0c\0d\xdf\x00\0e\0f".encode("EUC-JP", "UTF-16BE", :invalid=>:replace))

    assert_equal("\e$B!!\e(B?".force_encoding("ISO-2022-JP"),
      "\xA1\xA1\xFF".encode("ISO-2022-JP", "EUC-JP", invalid: :replace))
    assert_equal("\e$B\x24\x22\e(B?\e$B\x24\x24\e(B".force_encoding("ISO-2022-JP"),
      "\xA4\xA2\xFF\xA4\xA4".encode("ISO-2022-JP", "EUC-JP", invalid: :replace))
    assert_equal("\e$B\x24\x22\e(B??\e$B\x24\x24\e(B".force_encoding("ISO-2022-JP"),
      "\xA4\xA2\xFF\xFF\xA4\xA4".encode("ISO-2022-JP", "EUC-JP", invalid: :replace))
  end

  def test_invalid_replace_string
    assert_equal("a<x>A", "a\x80A".encode("us-ascii", "euc-jp", :invalid=>:replace, :replace=>"<x>"))
  end

  def test_undef_replace
    assert_equal("?", "\u20AC".encode("EUC-JP", :undef=>:replace), "[ruby-dev:35709]")
  end

  def test_undef_replace_string
    assert_equal("a<x>A", "a\u3042A".encode("us-ascii", :undef=>:replace, :replace=>"<x>"))
  end

  def test_shift_jis
    check_both_ways("\u3000", "\x81\x40", 'shift_jis') # full-width space
    check_both_ways("\u00D7", "\x81\x7E", 'shift_jis') # ×
    check_both_ways("\u00F7", "\x81\x80", 'shift_jis') # ÷
    check_both_ways("\u25C7", "\x81\x9E", 'shift_jis') # ◇
    check_both_ways("\u25C6", "\x81\x9F", 'shift_jis') # ◆
    check_both_ways("\u25EF", "\x81\xFC", 'shift_jis') # ◯
    check_both_ways("\u6A97", "\x9F\x40", 'shift_jis') # 檗
    check_both_ways("\u6BEF", "\x9F\x7E", 'shift_jis') # 毯
    check_both_ways("\u9EBE", "\x9F\x80", 'shift_jis') # 麾
    check_both_ways("\u6CBE", "\x9F\x9E", 'shift_jis') # 沾
    check_both_ways("\u6CBA", "\x9F\x9F", 'shift_jis') # 沺
    check_both_ways("\u6ECC", "\x9F\xFC", 'shift_jis') # 滌
    check_both_ways("\u6F3E", "\xE0\x40", 'shift_jis') # 漾
    check_both_ways("\u70DD", "\xE0\x7E", 'shift_jis') # 烝
    check_both_ways("\u70D9", "\xE0\x80", 'shift_jis') # 烙
    check_both_ways("\u71FC", "\xE0\x9E", 'shift_jis') # 燼
    check_both_ways("\u71F9", "\xE0\x9F", 'shift_jis') # 燹
    check_both_ways("\u73F1", "\xE0\xFC", 'shift_jis') # 珱
    assert_raise(Encoding::UndefinedConversionError) { "\xEF\x40".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xEF\x7E".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xEF\x80".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xEF\x9E".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xEF\x9F".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xEF\xFC".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xF0\x40".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xF0\x7E".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xF0\x80".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xF0\x9E".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xF0\x9F".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xF0\xFC".encode("utf-8", 'shift_jis') }
    #check_both_ways("\u9ADC", "\xFC\x40", 'shift_jis') # 髜 (IBM extended)
    assert_raise(Encoding::UndefinedConversionError) { "\xFC\x7E".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xFC\x80".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xFC\x9E".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xFC\x9F".encode("utf-8", 'shift_jis') }
    assert_raise(Encoding::UndefinedConversionError) { "\xFC\xFC".encode("utf-8", 'shift_jis') }
    check_both_ways("\u677E\u672C\u884C\u5F18", "\x8f\xbc\x96\x7b\x8d\x73\x8d\x4f", 'shift_jis') # 松本行弘
    check_both_ways("\u9752\u5C71\u5B66\u9662\u5927\u5B66", "\x90\xC2\x8E\x52\x8A\x77\x89\x40\x91\xE5\x8A\x77", 'shift_jis') # 青山学院大学
    check_both_ways("\u795E\u6797\u7FA9\u535A", "\x90\x5F\x97\xD1\x8B\x60\x94\x8E", 'shift_jis') # 神林義博
  end

  def test_windows_31j
    check_both_ways("\u222A", "\x81\xBE", 'Windows-31J') # Union
    check_both_ways("\uFFE2", "\x81\xCA", 'Windows-31J') # Fullwidth Not Sign
    check_both_ways("\u2235", "\x81\xE6", 'Windows-31J') # Because
    check_both_ways("\u2160", "\x87\x54", 'Windows-31J') # Roman Numeral One
    check_both_ways("\u2170", "\xFA\x40", 'Windows-31J') # Small Roman Numeral One
  end

  def test_euc_jp
    check_both_ways("\u3000", "\xA1\xA1", 'euc-jp') # full-width space
    check_both_ways("\u00D7", "\xA1\xDF", 'euc-jp') # ×
    check_both_ways("\u00F7", "\xA1\xE0", 'euc-jp') # ÷
    check_both_ways("\u25C7", "\xA1\xFE", 'euc-jp') # ◇
    check_both_ways("\u25C6", "\xA2\xA1", 'euc-jp') # ◆
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xAF".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xB9".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xC2".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xC9".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xD1".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xDB".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xEB".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xF1".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xFA".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA2\xFD".encode("utf-8", 'euc-jp') }
    check_both_ways("\u25EF", "\xA2\xFE", 'euc-jp') # ◯
    assert_raise(Encoding::UndefinedConversionError) { "\xA3\xAF".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA3\xBA".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA3\xC0".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA3\xDB".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA3\xE0".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA3\xFB".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA4\xF4".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA5\xF7".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA6\xB9".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA6\xC0".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA6\xD9".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA7\xC2".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA7\xD0".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA7\xF2".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xA8\xC1".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xCF\xD4".encode("utf-8", 'euc-jp') }
    assert_raise(Encoding::UndefinedConversionError) { "\xCF\xFE".encode("utf-8", 'euc-jp') }
    check_both_ways("\u6A97", "\xDD\xA1", 'euc-jp') # 檗
    check_both_ways("\u6BEF", "\xDD\xDF", 'euc-jp') # 毯
    check_both_ways("\u9EBE", "\xDD\xE0", 'euc-jp') # 麾
    check_both_ways("\u6CBE", "\xDD\xFE", 'euc-jp') # 沾
    check_both_ways("\u6CBA", "\xDE\xA1", 'euc-jp') # 沺
    check_both_ways("\u6ECC", "\xDE\xFE", 'euc-jp') # 滌
    check_both_ways("\u6F3E", "\xDF\xA1", 'euc-jp') # 漾
    check_both_ways("\u70DD", "\xDF\xDF", 'euc-jp') # 烝
    check_both_ways("\u70D9", "\xDF\xE0", 'euc-jp') # 烙
    check_both_ways("\u71FC", "\xDF\xFE", 'euc-jp') # 燼
    check_both_ways("\u71F9", "\xE0\xA1", 'euc-jp') # 燹
    check_both_ways("\u73F1", "\xE0\xFE", 'euc-jp') # 珱
    assert_raise(Encoding::UndefinedConversionError) { "\xF4\xA7".encode("utf-8", 'euc-jp') }
    #check_both_ways("\u9ADC", "\xFC\xE3", 'euc-jp') # 髜 (IBM extended)
    
    check_both_ways("\u677E\u672C\u884C\u5F18", "\xBE\xBE\xCB\xDC\xB9\xD4\xB9\xB0", 'euc-jp') # 松本行弘
    check_both_ways("\u9752\u5C71\u5B66\u9662\u5927\u5B66", "\xC0\xC4\xBB\xB3\xB3\xD8\xB1\xA1\xC2\xE7\xB3\xD8", 'euc-jp') # 青山学院大学
    check_both_ways("\u795E\u6797\u7FA9\u535A", "\xBF\xC0\xCE\xD3\xB5\xC1\xC7\xEE", 'euc-jp') # 神林義博
  end

  def test_eucjp_ms
    check_both_ways("\u2116", "\xAD\xE2", 'eucJP-ms') # NUMERO SIGN
    check_both_ways("\u221A", "\xA2\xE5", 'eucJP-ms') # SQUARE ROOT
    check_both_ways("\u3231", "\xAD\xEA", 'eucJP-ms') # PARENTHESIZED IDEOGRAPH STOCK
    check_both_ways("\uFF5E", "\xA1\xC1", 'eucJP-ms') # WAVE DASH
  end

  def test_eucjp_sjis
    check_both_ways2("\xa1\xa1", "EUC-JP", "\x81\x40", "Shift_JIS")
    check_both_ways2("\xa1\xdf", "EUC-JP", "\x81\x7e", "Shift_JIS")
    check_both_ways2("\xa1\xe0", "EUC-JP", "\x81\x80", "Shift_JIS")
    check_both_ways2("\xa1\xfe", "EUC-JP", "\x81\x9e", "Shift_JIS")
    check_both_ways2("\xa2\xa1", "EUC-JP", "\x81\x9f", "Shift_JIS")
    check_both_ways2("\xa2\xfe", "EUC-JP", "\x81\xfc", "Shift_JIS")

    check_both_ways2("\xdd\xa1", "EUC-JP", "\x9f\x40", "Shift_JIS")
    check_both_ways2("\xdd\xdf", "EUC-JP", "\x9f\x7e", "Shift_JIS")
    check_both_ways2("\xdd\xe0", "EUC-JP", "\x9f\x80", "Shift_JIS")
    check_both_ways2("\xdd\xfe", "EUC-JP", "\x9f\x9e", "Shift_JIS")
    check_both_ways2("\xde\xa1", "EUC-JP", "\x9f\x9f", "Shift_JIS")
    check_both_ways2("\xde\xfe", "EUC-JP", "\x9f\xfc", "Shift_JIS")

    check_both_ways2("\xdf\xa1", "EUC-JP", "\xe0\x40", "Shift_JIS")
    check_both_ways2("\xdf\xdf", "EUC-JP", "\xe0\x7e", "Shift_JIS")
    check_both_ways2("\xdf\xe0", "EUC-JP", "\xe0\x80", "Shift_JIS")
    check_both_ways2("\xdf\xfe", "EUC-JP", "\xe0\x9e", "Shift_JIS")
    check_both_ways2("\xe0\xa1", "EUC-JP", "\xe0\x9f", "Shift_JIS")
    check_both_ways2("\xe0\xfe", "EUC-JP", "\xe0\xfc", "Shift_JIS")

    check_both_ways2("\xf4\xa1", "EUC-JP", "\xea\x9f", "Shift_JIS")
    check_both_ways2("\xf4\xa2", "EUC-JP", "\xea\xa0", "Shift_JIS")
    check_both_ways2("\xf4\xa3", "EUC-JP", "\xea\xa1", "Shift_JIS")
    check_both_ways2("\xf4\xa4", "EUC-JP", "\xea\xa2", "Shift_JIS") # end of JIS X 0208 1983
    check_both_ways2("\xf4\xa5", "EUC-JP", "\xea\xa3", "Shift_JIS")
    check_both_ways2("\xf4\xa6", "EUC-JP", "\xea\xa4", "Shift_JIS") # end of JIS X 0208 1990

    check_both_ways2("\x8e\xa1", "EUC-JP", "\xa1", "Shift_JIS")
    check_both_ways2("\x8e\xdf", "EUC-JP", "\xdf", "Shift_JIS")
  end

  def test_eucjp_sjis_unassigned
    check_both_ways2("\xfd\xa1", "EUC-JP", "\xef\x40", "Shift_JIS")
    check_both_ways2("\xfd\xa1", "EUC-JP", "\xef\x40", "Shift_JIS")
    check_both_ways2("\xfd\xdf", "EUC-JP", "\xef\x7e", "Shift_JIS")
    check_both_ways2("\xfd\xe0", "EUC-JP", "\xef\x80", "Shift_JIS")
    check_both_ways2("\xfd\xfe", "EUC-JP", "\xef\x9e", "Shift_JIS")
    check_both_ways2("\xfe\xa1", "EUC-JP", "\xef\x9f", "Shift_JIS")
    check_both_ways2("\xfe\xfe", "EUC-JP", "\xef\xfc", "Shift_JIS")
  end

  def test_eucjp_sjis_undef
    assert_raise(Encoding::UndefinedConversionError) { "\x8e\xe0".encode("Shift_JIS", "EUC-JP") }
    assert_raise(Encoding::UndefinedConversionError) { "\x8e\xfe".encode("Shift_JIS", "EUC-JP") }
    assert_raise(Encoding::UndefinedConversionError) { "\x8f\xa1\xa1".encode("Shift_JIS", "EUC-JP") }
    assert_raise(Encoding::UndefinedConversionError) { "\x8f\xa1\xfe".encode("Shift_JIS", "EUC-JP") }
    assert_raise(Encoding::UndefinedConversionError) { "\x8f\xfe\xa1".encode("Shift_JIS", "EUC-JP") }
    assert_raise(Encoding::UndefinedConversionError) { "\x8f\xfe\xfe".encode("Shift_JIS", "EUC-JP") }

    assert_raise(Encoding::UndefinedConversionError) { "\xf0\x40".encode("EUC-JP", "Shift_JIS") }
    assert_raise(Encoding::UndefinedConversionError) { "\xf0\x7e".encode("EUC-JP", "Shift_JIS") }
    assert_raise(Encoding::UndefinedConversionError) { "\xf0\x80".encode("EUC-JP", "Shift_JIS") }
    assert_raise(Encoding::UndefinedConversionError) { "\xf0\xfc".encode("EUC-JP", "Shift_JIS") }
    assert_raise(Encoding::UndefinedConversionError) { "\xfc\x40".encode("EUC-JP", "Shift_JIS") }
    assert_raise(Encoding::UndefinedConversionError) { "\xfc\x7e".encode("EUC-JP", "Shift_JIS") }
    assert_raise(Encoding::UndefinedConversionError) { "\xfc\x80".encode("EUC-JP", "Shift_JIS") }
    assert_raise(Encoding::UndefinedConversionError) { "\xfc\xfc".encode("EUC-JP", "Shift_JIS") }
  end

  def test_iso_2022_jp
    assert_raise(Encoding::InvalidByteSequenceError) { "\x1b(A".encode("utf-8", "iso-2022-jp") }
    assert_raise(Encoding::InvalidByteSequenceError) { "\x1b$(A".encode("utf-8", "iso-2022-jp") }
    assert_raise(Encoding::InvalidByteSequenceError) { "\x1b$C".encode("utf-8", "iso-2022-jp") }
    assert_raise(Encoding::InvalidByteSequenceError) { "\x0e".encode("utf-8", "iso-2022-jp") }
    assert_raise(Encoding::InvalidByteSequenceError) { "\x80".encode("utf-8", "iso-2022-jp") }
    assert_raise(Encoding::InvalidByteSequenceError) { "\x1b$(Dd!\x1b(B".encode("utf-8", "iso-2022-jp") }
    assert_raise(Encoding::UndefinedConversionError) { "\u9299".encode("iso-2022-jp") }
    assert_raise(Encoding::UndefinedConversionError) { "\uff71\uff72\uff73\uff74\uff75".encode("iso-2022-jp") }
    assert_raise(Encoding::InvalidByteSequenceError) { "\x1b(I12345\x1b(B".encode("utf-8", "iso-2022-jp") }
    assert_equal("\xA1\xA1".force_encoding("euc-jp"),
                 "\e$B!!\e(B".encode("EUC-JP", "ISO-2022-JP"))
    assert_equal("\e$B!!\e(B".force_encoding("ISO-2022-JP"),
                 "\xA1\xA1".encode("ISO-2022-JP", "EUC-JP"))
  end
  
  def test_iso_2022_jp_1
    # check_both_ways("\u9299", "\x1b$(Dd!\x1b(B", "iso-2022-jp-1") # JIS X 0212 区68 点01 銙
  end
  
  def test_unicode_public_review_issue_121 # see http://www.unicode.org/review/pr-121.html
    # assert_equal("\x00\x61\xFF\xFD\x00\x62".force_encoding('UTF-16BE'),
    #   "\x61\xF1\x80\x80\xE1\x80\xC2\x62".encode('UTF-16BE', 'UTF-8', invalid: :replace)) # option 1
    assert_equal("\x00\x61\xFF\xFD\xFF\xFD\xFF\xFD\x00\x62".force_encoding('UTF-16BE'),
      "\x61\xF1\x80\x80\xE1\x80\xC2\x62".encode('UTF-16BE', 'UTF-8', invalid: :replace)) # option 2
    assert_equal("\x61\x00\xFD\xFF\xFD\xFF\xFD\xFF\x62\x00".force_encoding('UTF-16LE'),
      "\x61\xF1\x80\x80\xE1\x80\xC2\x62".encode('UTF-16LE', 'UTF-8', invalid: :replace)) # option 2
    # assert_equal("\x00\x61\xFF\xFD\xFF\xFD\xFF\xFD\xFF\xFD\xFF\xFD\xFF\xFD\x00\x62".force_encoding('UTF-16BE'),
    # "\x61\xF1\x80\x80\xE1\x80\xC2\x62".encode('UTF-16BE', 'UTF-8', invalid: :replace)) # option 3
  end

  def test_yen_sign
    check_both_ways("\u005C", "\x5C", "Shift_JIS")
    check_both_ways("\u005C", "\x5C", "Windows-31J")
    check_both_ways("\u005C", "\x5C", "EUC-JP")
    check_both_ways("\u005C", "\x5C", "eucJP-ms")
    check_both_ways("\u005C", "\x5C", "CP51932")
    check_both_ways("\u005C", "\x5C", "ISO-2022-JP")
    assert_equal("\u005C", "\e(B\x5C\e(B".encode("UTF-8", "ISO-2022-JP"))
    assert_equal("\u005C", "\e(J\x5C\e(B".encode("UTF-8", "ISO-2022-JP"))
    assert_equal("\u005C", "\x5C".encode("stateless-ISO-2022-JP", "ISO-2022-JP"))
    assert_equal("\u005C", "\e(J\x5C\e(B".encode("stateless-ISO-2022-JP", "ISO-2022-JP"))
    assert_raise(Encoding::UndefinedConversionError) { "\u00A5".encode("Shift_JIS") }
    assert_raise(Encoding::UndefinedConversionError) { "\u00A5".encode("Windows-31J") }
    assert_raise(Encoding::UndefinedConversionError) { "\u00A5".encode("EUC-JP") }
    assert_raise(Encoding::UndefinedConversionError) { "\u00A5".encode("eucJP-ms") }
    assert_raise(Encoding::UndefinedConversionError) { "\u00A5".encode("CP51932") }

    # FULLWIDTH REVERSE SOLIDUS
    check_both_ways("\uFF3C", "\x81\x5F", "Shift_JIS")
    check_both_ways("\uFF3C", "\x81\x5F", "Windows-31J")
    check_both_ways("\uFF3C", "\xA1\xC0", "EUC-JP")
    check_both_ways("\uFF3C", "\xA1\xC0", "eucJP-ms")
    check_both_ways("\uFF3C", "\xA1\xC0", "CP51932")
  end

  def test_tilde_overline
    check_both_ways("\u007E", "\x7E", "Shift_JIS")
    check_both_ways("\u007E", "\x7E", "Windows-31J")
    check_both_ways("\u007E", "\x7E", "EUC-JP")
    check_both_ways("\u007E", "\x7E", "eucJP-ms")
    check_both_ways("\u007E", "\x7E", "CP51932")
    check_both_ways("\u007E", "\x7E", "ISO-2022-JP")
    assert_equal("\u007E", "\e(B\x7E\e(B".encode("UTF-8", "ISO-2022-JP"))
    assert_equal("\u007E", "\e(J\x7E\e(B".encode("UTF-8", "ISO-2022-JP"))
    assert_equal("\u007E", "\x7E".encode("stateless-ISO-2022-JP", "ISO-2022-JP"))
    assert_equal("\u007E", "\e(J\x7E\e(B".encode("stateless-ISO-2022-JP", "ISO-2022-JP"))
    assert_raise(Encoding::UndefinedConversionError) { "\u203E".encode("Shift_JIS") }
    assert_raise(Encoding::UndefinedConversionError) { "\u203E".encode("Windows-31J") }
    assert_raise(Encoding::UndefinedConversionError) { "\u203E".encode("EUC-JP") }
    assert_raise(Encoding::UndefinedConversionError) { "\u203E".encode("eucJP-ms") }
    assert_raise(Encoding::UndefinedConversionError) { "\u203E".encode("CP51932") }
  end

  def test_nothing_changed
    a = "James".force_encoding("US-ASCII")
    b = a.encode("Shift_JIS")
    assert_equal(Encoding::US_ASCII, a.encoding)
    assert_equal(Encoding::Shift_JIS, b.encoding)
  end
end
