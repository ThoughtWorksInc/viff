_ = require 'underscore'

Viff = require './viff.js'
processArgs = require './process.argv.js'
consoleStatus = require './console.status.js'
imgGen = require './image.generator'

config = processArgs process.argv

return console.log config if _.isString config

count = config.maxInstance ? 1

cases = Viff.constructCases config.browsers, config.envHosts, config.paths
testGroups = Viff.split cases, count
resolvedCases = []
exceptions = []

imgGen.reset()
consoleStatus.logBefore()

for group in testGroups
  viff = new Viff config.seleniumHost

  viff.on 'afterEach', (_case, duration, fex, tex) ->
    imgGen.generateByCase _case if duration != 0
    consoleStatus.logAfterEach _case, duration, fex, tex, exceptions

  viff.run group, ([cases, duration]) ->
    resolvedCases = resolvedCases.concat cases
    unless --count
      imgGen.generateReport resolvedCases
      consoleStatus.logAfter resolvedCases, duration, exceptions
