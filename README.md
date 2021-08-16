![icon](icon.png)

# Obsidian Plugin Downloader

### Demo Video

https://user-images.githubusercontent.com/1992842/129498054-6426ec90-5c12-4907-a5a0-f03988b15914.mp4

### What?

This is a script to search, download and maintain a local repository of Obsidian plugins, which can be used as a reference for other developers.

### Why?

As an absolute beginner to TypeScript, and a lover of [Obsidian](https://obsidian.md/) I often want to take a look at how someone has achieved a certain feature, called on an API, etc. A quick way to do that is by searching through the existing codebase of the ever growing library of plugins out there.

### Setup

1. First, set up your environment to have `jq`, `fzf`, and `gh`. On macOS the simplest way to do that is with Homebrew: `brew install jq fzf gh`.
2. Copy the `obsidian-plugin-downloader.sh` script to a directory in your `$PATH`
3. Make sure it's executable (`chmod +x obsidian-plugin-downloader.sh`)
4. You can adjust the `$OUTDIR` variable to set the destination directory of your choice (default: `~/Downloads/obsidian-plugins`)

### Run

1. Open a Terminal window (bash, zsh, etc)
2. Type `obsidian-plugin-downloader.sh`
3. The list of plugins should be displayed. You can type in the search field at the top to filter the list—both the names and descriptions of the plugins are searchable.
4. Choose one or more to download. You can move with the arrow keys, use <kbd>&lt;TAB&gt;</kbd> to select/deselect, or press <kbd>⌃A</kbd> / <kbd>⌃S</kbd> to select/deselect all.
5. Make your selections and press <kbd>&lt;ENTER&gt;</kbd>
6. Plugins should be downloaded!

> The script will automatically check to see if you have the latest version of the plugin, and will download newer versions as needed.

### Next...

It's nice to have a tool like [`ripgrep`](https://github.com/BurntSushi/ripgrep) to search through the code if you are looking for API references etc.
