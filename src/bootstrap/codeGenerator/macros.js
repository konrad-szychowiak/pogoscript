var cg = require('../../lib/codeGenerator');
var _ = require('underscore');
var errors = require('./errors.js');

var macros = new cg.MacroDirectory();

var createOperator = function(name, arguments) {
  return cg.operator(name[0], arguments);
};

_.each(['/', '-', '>=', '==', '!=', '===', '!==', '<=', '<', '>', '|', '&', '||', '&&', '!'], function(op) {
  macros.addMacro([op], createOperator);
});

var matchMultiOperator = function (name) {
  var firstOp = name[0];
  
  for (var n = 1; n < name.length; n++) {
    if (name[n] != firstOp) {
      return;
    }
  }
  
  return function (name, arguments) {
    return cg.operator(name[0], arguments);
  };
};

_.each(['+', '*', '==='], function(op) {
  macros.addWildCardMacro([op], matchMultiOperator);
});

var createIfExpression = function(name, arguments) {
  var cases = [];
  
  for (var n = 0; n + 1 < arguments.length; n += 2) {
    cases.push({condition: arguments[n], action: arguments[n + 1].body});
  }
  
  var _else;
  
  if (arguments.length % 2 == 1) {
    _else = arguments[arguments.length - 1].body;
  }
  
  return cg.ifCases(cases, _else);
};

var matchIfMacro = function (name) {
  if (/^if(ElseIf)*(Else)?$/.test(cg.concatName(name))) {
    return createIfExpression;
  }
};

macros.addWildCardMacro(['if'], matchIfMacro);

macros.addMacro(['new'], function(name, arguments) {
  var constructor;

  if (arguments[0].isSubExpression) {
    constructor = arguments[0].statements[0];
  } else {
    constructor = arguments[0];
  }

  return cg.newOperator(constructor);
});

var createForEach = function (name, arguments) {
  var collection = arguments[0];
  var block = arguments[1];

  var itemVariable = block.parameters[0];
  
  return cg.forEach(collection, itemVariable, block.body);
};

macros.addMacro(['for', 'each', 'in'], createForEach);

macros.addMacro(['for'], function(name, arguments) {
  var init = arguments[0];
  var test = arguments[1];
  var incr = arguments[2];

  if (!init)
    return errors.addTermWithMessage(arguments[0], 'expected init, as in (n = 0. ...)');

  if (!test)
    return errors.addTermWithMessage(arguments[0], 'expected test, as in (... . n < 10. ...)');

  if (!incr)
    return errors.addTermWithMessage(arguments[0], 'expected incr, as in (... . ... . n = n + 1)');
  
  return cg.forStatement(init, test, incr, arguments[3].body);
});

macros.addMacro(['while'], function(name, arguments) {
  var test;
  if (arguments[0].isSubExpression) {
    test = arguments[0].statements[0];
  } else if (arguments[0].isBlock) {
    test = arguments[0].body.statements[0];
  } else {
    test = arguments[0];
  }
  var statements = arguments[1].body;
  
  return cg.whileStatement(test, statements);
});

macros.addMacro(['and'], function (name, arguments) {
  return cg.operator('&&', arguments);
});

macros.addMacro(['or'], function (name, arguments) {
  return cg.operator('||', arguments);
});

macros.addMacro(['not'], function (name, arguments) {
  return cg.operator('!', arguments);
});

macros.addMacro(['return'], function(name, arguments) {
  return cg.returnStatement(arguments[0]);
});

macros.addMacro(['throw'], function(name, arguments) {
  return cg.throwStatement(arguments[0]);
});

macros.addMacro(['break'], function(name, arguments) {
  return cg.breakStatement();
});

macros.addMacro(['continue'], function(name, arguments) {
  return cg.continueStatement();
});

macros.addMacro(['try', 'catch'], function (name, arguments) {
  return cg.tryStatement(arguments[0].body, arguments[1]);
});

macros.addMacro(['try', 'catch', 'finally'], function (name, arguments) {
  return cg.tryStatement(arguments[0].body, arguments[1], arguments[2].body);
});

macros.addMacro(['try', 'finally'], function (name, arguments) {
  return cg.tryStatement(arguments[0].body, undefined, arguments[1].body);
});

module.exports = macros;