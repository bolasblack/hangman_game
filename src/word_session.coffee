_ = require 'lodash'

letterSortedByFrequency = 'E T A O I N S H R D L C U M W F G Y P B V K J X Q Z'.split ' '

module.exports = class WordSession
  constructor: (@wordInfo, @gamer) ->
    @worldLength = @wordInfo.word.length
    @nextTryCharIndex = 0

  suggestChar: ->
    letterSortedByFrequency[@nextTryCharIndex]

  receiveResult: (guessResult) ->
    @lastStat = guessResult
    @nextTryCharIndex += 1

  isWordGuessFinished: ->
    # 如果结果里没有星号了
    return true if not _.contains(@lastStat.word, '*')
    # 如果超过猜测次数了
    return true if @lastStat.wrongGuessCountOfCurrentWord is @gamer.gameInfo.numberOfGuessAllowedForEachWord
    false
