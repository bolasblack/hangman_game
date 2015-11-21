_ = require 'lodash'
fs = require 'fs'
sysPath = require 'path'

words = _.compact fs.readFileSync(sysPath.join __dirname, '../data/words.txt').toString().split(/\n/)
wordsGroupedByLength = _.groupBy words, 'length'
mostCommonCharsGroupedByLength = _.reduce wordsGroupedByLength, (memo, words, length) ->
  chars = words.join('').toLowerCase()
  memo[length] = _('abcdefghijklmnopqrstuvwxyz'.split '').sortBy (char) ->
    if (matchs = chars.match RegExp char, 'g') then matchs.length else 0
  .reverse().value()
  memo
, {}

module.exports = class WordSession
  constructor: (@wordInfo, @gamer) ->
    @wordLength = @wordInfo.word.length
    @avaliableWords = wordsGroupedByLength[@wordLength]
    @mostCommonChars = mostCommonCharsGroupedByLength[@wordLength]
    @nextTryCharIndex = 0

  suggestChar: ->
    @mostCommonChars[@nextTryCharIndex]

  receiveResult: (guessResult) ->
    @lastStat = guessResult
    @nextTryCharIndex += 1

  isWordGuessFinished: ->
    # 如果结果里没有星号了
    return true if not _.contains(@lastStat.word, '*')
    # 如果超过猜测次数了
    return true if @lastStat.wrongGuessCountOfCurrentWord is @gamer.gameInfo.numberOfGuessAllowedForEachWord
    false
