terms = require '../lib/parser/codeGenerator'.code generator ()
create macro directory = require '../lib/macroDirectoryPerf'
macro directory () = create macro directory (terms)

describe 'macro directory'
    md = nil

    before each
        md := macro directory ()
        for each @(letter) in ("abcdefghijklmnopqrstuvwxyx".split '')
            md.add macro (letter, 'x')
        
    it 'looks up a macro'
        for (n = 0, n < 100000000, ++n)
            md.find macro 'a'