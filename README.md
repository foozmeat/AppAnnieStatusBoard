# App Annie Status Board

This is a script that generates a sales graph for Panic's Status Board using the App Annie API. It is heavily inspired by [SalesBoard](https://github.com/justin/SalesBoard) by @justin.

### Installation

1. Copy project.yml.sample and edit the values inside to match you're respective install.
2. Open `app_annie_status_board.sh` and update its path to the `app_annie_status_board.rb` script to match where you've installed it
3. Open `de.rheinfabrik.appanniestatusboard.plist` and update its `ProgramArguments` value to match where you are storing the salesboard.sh file you just updated in step 3.
4. Copy de.rheinfabrik.appanniestatusboard.plist to `~/Library/LaunchAgents` 
5. Open Termimal and run `launchctl load ~/Library/LaunchAgents/de.rheinfabrik.appanniestatusboard.plist`. This should generate the first version of your json file.
6. Go to Dropbox and get a shareable link for the JSON file that is output and add it to Status Board on your iPad.

### Support

Run into an issue? Throw an issue up on GitHub. Better yet, throw up a pull request with a fix.
