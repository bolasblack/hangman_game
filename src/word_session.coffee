_ = require 'lodash'
fs = require 'fs'
sysPath = require 'path'

getStringLetterFrequency = (words) ->
  chars = words.join('').toLowerCase()
  _('abcdefghijklmnopqrstuvwxyz'.split '').sortBy (char) ->
    if (matches = chars.match RegExp char, 'g') then matches.length else 0
  .reverse().value()

words = _.compact fs.readFileSync(sysPath.join __dirname, '../data/words.txt').toString().split(/\n/)
wordsGroupedByLength = _.groupBy words, 'length'
mostCommonCharsGroupedByLength = _.reduce wordsGroupedByLength, (memo, words, length) ->
  memo[length] = getStringLetterFrequency words
  memo
, {}

module.exports = class WordSession
  constructor: (@wordInfo, @gamer) ->
    @wordLength = @wordInfo.word.length
    @avaliableWords = wordsGroupedByLength[@wordLength]
    @mostCommonChars = _.clone mostCommonCharsGroupedByLength[@wordLength]
    @usedChars = []

  suggestChar: ->
    return @_suggestByFrequency() if not @lastStat
    return @_suggestByFrequency() if not suggestion = @_suggestByRegExp()
    suggestion

  receiveResult: (guessResult) ->
    @lastStat = guessResult

  isWordGuessFinished: ->
    # 如果已经猜对了
    return true if not _.contains(@lastStat.word, '*')
    # 如果超过猜测次数了
    return true if @lastStat.wrongGuessCountOfCurrentWord is @gamer.gameInfo.numberOfGuessAllowedForEachWord
    false

  _suggestByFrequency: ->
    char = _.first @mostCommonChars
    @_removeCharFromAlternative char
    char

  # 把所有星号替换成可以尝试的字母来匹配单词，然后统计所有匹配到的单词的
  # 相应位置的字母词频，给出建议
  _suggestByRegExp: ->
    pattern = @lastStat.word.replace(/\*/g, "[#{@mostCommonChars.join('')}]").toLowerCase()
    re = RegExp "^#{pattern}$"
    matches = _.compact _.flattenDeep @avaliableWords.map (word) ->
      if (matches = word.match re) then matches.slice(1) else null
    return if _.isEmpty matches
    char = _.first getStringLetterFrequency(matches).filter (char) => char not in @usedChars
    @_removeCharFromAlternative char
    char

  _removeCharFromAlternative: (removingChar) ->
    _.remove @mostCommonChars, (char) -> char is removingChar
    @usedChars.push removingChar
