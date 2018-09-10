# CC0, see <http://creativecommons.org/publicdomain/zero/1.0/>

# Fish configuration of Sebastian Wiesner <sebastian@swsnr.de>
#
# TODO:
#
# * Shorten path in prompt like in my Zsh, relative to repo root

# First things first
umask 022

# When fish exits…
function on_exit --on-process-exit %self
    if status is-login
        # …kill sudo timestamps if the shell is a login shell
        sudo -K
    end
end

# Paths, only for login shells
if status is-login
    # Binaries from Python, Ruby and Rust
    set -x PATH ~/Library/Python/*/bin $PATH
    set -x PATH ~/.gem/ruby/*/bin $PATH
    set -x PATH ~/.cargo/bin $PATH

    # Binaries, manpages, etc. from ~/.local
    set -x PATH ~/.local/bin $PATH
    set -x MANPATH /usr/share/man /usr/local/share/man ~/.local/share/man
    set -x INFOPATH /usr/share/info /usr/local/share/info ~/.local/share/info
end

# Environment variables
set -x EDITOR 'code -nw'
set -x BROWSER 'open'
set -x PAGER 'less'
set -x BAT_THEME 'TwoDark'

# Default less options:
#
# -q: Do not beep
# -g: Highlight search results
# -i: Ignore case when searching
# -M: Prompt verbosely
# -R: Print ANSI color sequences
# -S: Cut of long lines instead of wrapping them
# -w: Highlight the first new line after scrolling
# -z: Keep four lines when scrolling
set -x LESS '-q -g -i -M -R -S -w -z-4'

# Setup tools for an interactive shell
if status is-interactive
    # Autojump for fast directory jumping
    set -l autojump_src '/usr/local/share/autojump/autojump.fish'
    if [ -f $autojump_src ]
        source $autojump_src
    end

    # Virtualenv helper
    if command --search 'python3' >/dev/null
        python3 -m virtualfish ^/dev/null | source
    end

    # Prefer bat over less and cat
    if command --search 'bat' >/dev/null
        alias less='bat'
        alias cat='bat'
    end

    # Prefer exa over ls for listings
    if command --search 'exa' >/dev/null
        alias ll='exa --long --git'
        alias la='ll --all'
    else
        alias ll='ls -l'
        alias la='ls -la'
    end

    # Abbreviations (unlike aliases, these are expanded before running)
    abbr --add _ sudo
    abbr --add df df -kh
    abbr --add du du -kh
    abbr --add e eval $EDITOR
    abbr --add g git
    abbr --add gP git pull
    abbr --add gS git stash
    abbr --add gb git branch
    abbr --add gc git commit
    abbr --add gcf git commit --amend
    abbr --add gl git log --pretty=fancy --topo-order
    abbr --add gp git push
    abbr --add gpf git push --force-with-lease
    abbr --add gr git rebase
    abbr --add gs git status
    abbr --add o open
    abbr --add pbc pbcopy
    abbr --add pbp pbpaste
    abbr --add vag vagrant
end
