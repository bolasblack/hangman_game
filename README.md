# hangman game

项目的目的是提供一个框架，让大家可以不用分心做其他事情，专心愉快地测试自己的算法

文件说明：

* `player_info.example.json` 配置玩家信息的文件，实际文件名应该是 `player_info.json`
* `src/word_session` 用来给出字母建议的类， `Gamer` 会为每个单词实例化一个 `WordSession`
* `src/gamer` 除了推荐字母的算法以外，主要逻辑就在这里，递归地猜测所有单词的所有字母
* `src/game_table` 一个专门用来请求服务器的类，如果只想要在本地测试，那么直接重写这个类就好了
* `src/index` 入口文件，读取配置文件和开始游戏的地方
