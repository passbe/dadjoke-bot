# dadjoke-bot
An IRC bot that tells some pretty lame jokes.

1. git clone
2. cd dadjoke-bot
3. bundle install
4. Configure `config.yaml` to connect to your IRC server
5. `ruby bot.rb -c config.yaml -j jokes.db`

Now you can type `!about` for bot information and `!hitme` for endless jokes.

## Contributing jokes
Help us expand our list of lame jokes by submitting a pull request with additions to `jokes.db`.
