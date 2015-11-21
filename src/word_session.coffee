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

log = (str...) ->
  return if process.env.NODE_ENV isnt 'debug'
  console.log str...

module.exports = class WordSession
  constructor: (@wordInfo, @gamer) ->
    @wordLength = @wordInfo.word.length
    @avaliableWords = wordsGroupedByLength[@wordLength]
    @mostCommonChars = _.clone mostCommonCharsGroupedByLength[@wordLength]
    @usedChars = []

  suggestChar: ->
    if not @lastStat
      suggest = @_suggestByFrequency()
      log '************ 初次建议', suggest
      suggest
    else if not suggestion = @_suggestByRegExp()
      suggest = @_suggestByFrequency()
      log '************ 备选词库枯竭', suggest, '已用字母', JSON.stringify(@usedChars)
      suggest
    else
      log '************ 正则方案建议', suggestion, '已用字母', JSON.stringify(@usedChars)
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
    pattern = @lastStat.word.replace(/\*/g, "([#{@mostCommonChars.join('')}])").toLowerCase()
    re = RegExp "^#{pattern}$"
    log '************ 正则', re
    matches = _.compact _.flattenDeep @avaliableWords.map (word) ->
      if wordMatches = word.match re then wordMatches.slice(1) else null
    return if _.isEmpty matches
    avaliableChars = getStringLetterFrequency(matches).filter (char) => char not in @usedChars
    log '************ 正则可用字母', JSON.stringify avaliableChars
    char = _.first avaliableChars
    @_removeCharFromAlternative char
    char

  _removeCharFromAlternative: (removingChar) ->
    _.remove @mostCommonChars, (char) -> char is removingChar
    @usedChars.push removingChar
