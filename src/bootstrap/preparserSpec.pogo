require 'cupoftea'
require './assertions.pogo'

preparser = require './preparser.pogo'

spec 'preparser'
  spec 'line parser'
    parse = preparser: create line parser!

    spec 'empty line'
      (parse '   ') should contain fields #{is empty, line '   ', is first line}

      spec 'first non emtpy line should be first line'
        (parse 'x') should contain fields #{is first line, line 'x'}

    spec 'line brackets'
      spec 'starts with square bracket'
        (parse ']') should contain fields #{starts with bracket}

      spec 'starts with brace'
        (parse '}') should contain fields #{starts with bracket}

      spec 'starts with paren'
        (parse ')') should contain fields #{starts with bracket}

      spec 'ends with square bracket'
        (parse '[') should contain fields #{ends with bracket}

      spec 'ends with brace'
        (parse '{') should contain fields #{ends with bracket}

      spec 'ends with paren'
        (parse '(') should contain fields #{ends with bracket}

    spec 'new line'
      (parse 'one') should contain fields #{code 'one', indentation '', is first line, line 'one'}

      spec 'and indented line'
        (parse '  two') should contain fields #{code 'two', indentation '  ', is indent, is first line @false, line '  two'}

        spec 'and unindented line'
          (parse 'three') should contain fields #{is unindent}

        spec 'and unindented line after empty line'
          parse ''
          (parse 'three') should contain fields #{is unindent}

      spec 'and line ending in bracket'
        (parse 'two {') should contain fields #{ends with bracket}

        spec 'and line ending in bracket'
          (parse '} three') should contain fields #{starts with bracket}

  spec 'indent stack'
    indent stack = preparser: create indent stack!
    
    spec 'with indent'
      indent stack: indent to '  '

      spec 'it unwinds with one bracket'
        (indent stack: count unindents while unwinding to '') should equal 1

      spec 'it unwinds with two brackets'
        indent stack: indent to '    '
        (indent stack: count unindents while unwinding to '') should equal 2

  spec 'source parser'
    parse = preparser: create file parser!

    spec 'new lines'
      spec 'new lines'
        (parse 'one\ntwo\nthree') should equal 'one.\ntwo.\nthree\n'
    
      spec 'new lines with empty lines'
        (parse 'one\n\ntwo') should equal 'one\n.\ntwo\n'
    
      spec 'starts with empty line'
        (parse '\none\ntwo') should equal '\none.\ntwo\n'
    
    spec 'indentation'
      spec 'one level'
        (parse 'one\n  two\n  three') should equal 'one{\n  two.\n  three}\n'
      
      spec 'one level with empty lines'
        (parse 'one\n  two\n\n  three') should equal 'one{\n  two\n.\n  three}\n'
      
      spec 'one line indented'
        (parse 'one\n  two\nthree') should equal 'one{\n  two}\nthree\n'
      
      spec 'one line indented followed by another statement'
        (parse 'one\n  two\n\nthree') should equal 'one{\n  two\n}.\nthree\n'
      
      spec 'two levels'
        (parse 'one\n  two\n    three\n') should equal 'one{\n  two{\n    three\n}}\n'
            
      spec 'two levels with following args'
        (parse 'one\n  two\n    three\nfour') should equal 'one{\n  two{\n    three}}\nfour\n'

    spec 'indentation with brackets'
      spec 'doesnt insert brace if indent is in brackets'
        (parse 'one{\n  two\n  three\n}\nfour') should equal 'one{\n  two.\n  three\n}.\nfour\n'

      spec 'still unwinds unindent, but not the last one because it has a bracket'
        (parse 'one{\n  two\n  three\n    four\n}\nfive') should equal 'one{\n  two.\n  three{\n    four}\n}.\nfive\n'

      spec 'list with items on each line'
        (parse 'list [\n1\n2\n3\n]') should equal 'list [\n1.\n2.\n3\n]\n'

      spec 'list with items on each indented line'
        (parse 'list [\n  1\n  2\n  3\n]') should equal 'list [\n  1.\n  2.\n  3\n]\n'