cg = require './codeGenerator/codeGenerator'.code generator ()
require './assertions.pogo'

describe 'unary operator expression'
    it 'as expression'
        op expr = cg.new unary operator expression (operator: '%%', expression: {variable ['a']})

        (op expr.expression ()) should contain fields {
            is method call
            object {variable ['a']}
            name ['%%']
            method arguments []
        }
    
    it 'as expression with macro'
        op expr = cg.new unary operator expression (operator: '!', expression: {variable ['a']})
        
        (op expr.expression ()) should contain fields {
            is operator
            operator '!'
            operator arguments [{variable ['a']}]
        }

    it 'as hash entry will be semantic failure'
        op expr = cg.new unary operator expression (operator: '%', expression: {variable ['a']})
        
        (op expr.hash entry ()) should contain fields {
          is semantic failure
        }
