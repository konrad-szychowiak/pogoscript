require 'cupoftea'
script = require './scriptAssertions.pogo'
assert = require 'assert'

should output = script: should output
should throw = script: should throw
with args should output = script: with args should output

spec 'pogo command'
    spec "`process: argv` contains 'pogo', the name of the
          script executed, and the arguments from the command line"
    
        'console: log (process: argv)' with args ['one', 'two'] should output "[ 'pogo',
                                                                                 '086cb9ffe81d17023c281a4789bdf5c45ddc1d76.pogo',
                                                                                 'one',
                                                                                 'two' ]"

    spec "`__filename` should be the name of the script"
        'console: log (__filename)' with args [] should output "ec798ad9d0e16bd17a4ba1cceab4be9591c65bfe.pogo"

    spec "`__dirname` should be the name of the script"
        'console: log (__dirname)' with args [] should output "."

spec 'script'
    spec 'integers'
        spec 'can denote an integer literally'
            'print 1' should output '1'

    spec 'new operator'
        spec 'can be called with no arguments'
            'print (new (Array))' should output '[]'
            
        spec 'new operator can be called with 1 argument'
            'print (new (Date 2010 10 9): value of?)' should output '1289260800000'

    spec 'hash'
        spec "a `true` hash entry does not need it's value specified"
            'print {one}' should output '{ one: true }'
        
        spec 'a hash can have multiple entries, delimited by commas'
            "print {color 'red', size 'large'}" should output "{ color: 'red', size: 'large' }"
        
        spec 'a hash can have multiple entries, delimited by dots'
            "print {color 'red'. size 'large'}" should output "{ color: 'red', size: 'large' }"
        
        spec 'a hash can have multiple entries, delimited by new lines'
            "print {
                 color 'red'
                 size 'large'
             }" should output "{ color: 'red', size: 'large' }"
        
        spec 'hash entries can be written with an equals "=" operator'
            "print {color = 'red', size = 'large'}" should output "{ color: 'red', size: 'large' }"
    
    spec 'lists'
        spec 'an empty list is just []'
            'print []' should output '[]'
        
        spec 'list entries can be delimited with a comma ","'
            'print [1, 2]' should output '[ 1, 2 ]'
        
        spec 'list entries can be delimited with a dot "."'
            'print [1. 2]' should output '[ 1, 2 ]'
        
        spec 'list entries can be delimited with a newline'
            'print [
                 1
                 2
             ]' should output '[ 1, 2 ]'
    
    spec 'functions'
        spec 'definitions'
            spec 'functions can be defined by placing the arguments to the left of the equals sign "="'
                'succ (n) =
                    n + 1
                
                 print (succ (1))' should output '2'
            
            spec 'functions with no arguments'
                spec 'a function can be defined to have no parameters with the exclamation mark "!"'
                    'say hi! =
                        print "hi"
                
                     say hi!' should output "'hi'"
                 
                spec 'a function can be defined to have no parameters with empty parens "()"'
                    'say hi () =
                        print "hi"
                
                     say hi ()' should output "'hi'"
                 
                spec 'a function can be defined to have no parameters with the question mark "?"'
                    'index = 0
                 
                     current index? =
                        index
                
                     print (current index?)
                     index = 10
                     print (current index?)' should output '0
                                                            10'
    
        spec 'splats'
            spec 'a function can be defined with a single splat parameter'
                'foo (args, ...) =
                     print (args)
                 
                 foo 1 2' should output '[ 1, 2 ]'
            
            spec 'a function can be called with more than one splat argument'
                'foo (args, ...) =
                     print (args)
             
                 foo 1 [2, 3] ... [4, 5] ... 6' should output '[ 1, 2, 3, 4, 5, 6 ]'
        
        spec 'optional arguments'
            spec 'functions can take optional arguments, delimited by semi-colons ";"'
                'print; size 10' should output '{ size: 10 }'
    
            spec 'if an optional argument has no value, it is passed as true'
                'print; is red' should output '{ isRed: true }'
            
            spec 'a function can be defined to take an optional argument'
                'open tcp connection; host; port =
                     print (host)
                     print (port)
                 
                 open tcp connection; host "pogoscript.org"; port 80' should output "'pogoscript.org'
                                                                                     80"
            
            spec 'if the optional parameter has no default value and is not passed by the caller,
                  it is defaulted to "undefined"'
                  
                'open tcp connection; host =
                     print (host)
                 
                 open tcp connection!' should output "undefined"
            
            spec 'if the optional parameter has a default value
                  and no optional arguments are passed by the caller,
                  then that default value is used'
                  
                'open tcp connection; port 80 =
                     print (port)
                 
                 open tcp connection!' should output "80"
            
            spec 'if the optional parameter has a default value
                  and other optional arguments are passed by the caller
                  but not that one, then that default value is used'
                  
                'open tcp connection; port 80 =
                     print (port)
                 
                 open tcp connection; host "pogoscript.org"' should output "80"

    spec 'scope'
        spec 'statements can be delimited by dots in parens, the last statement is returned'
            'print (x = 1. x = x + 1. x)' should output '2'
            
        spec 'any variables defined inside the scope are not accessible outside the scope'
            '(x = 1. x = x + 1. x)
             x' should throw 'ReferenceError: x is not defined'