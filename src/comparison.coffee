path = require 'path'
_ = require 'underscore'
Q = require 'q'
fs = require('fs')
{resemble} = require 'resemble'

dataUrlHelper = require './image.dataurl.helper'

class Comparison
  constructor: (imgWithEnvs) ->
    @images = imgWithEnvs

  diff: (callback) ->
    defer = Q.defer()
    promise = defer.promise.then callback

    that = @
    fileData = _.values(@images)

    Comparison.compare fileData[0], fileData[1], (diffObj) ->

      if diffObj
        diffBase64 = dataUrlHelper.toData diffObj.getImageDataUrl()
        that.images.diff = new Buffer diffBase64, 'base64'

        _.extend that,
          isSameDimensions: diffObj.isSameDimensions
          misMatchPercentage: Number diffObj.misMatchPercentage
          analysisTime: diffObj.analysisTime

        defer.resolve that.images.diff

    promise

  @compare: (fileAData, fileBData, callback) ->
    defer = Q.defer()
    promise = defer.promise.then callback
    if !fileAData && !fileBData then defer.resolve {}

    resemble(fileAData).compareTo(fileBData).onComplete (data) -> defer.resolve data
    promise

module.exports = Comparison
