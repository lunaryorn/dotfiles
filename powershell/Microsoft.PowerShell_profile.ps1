# Copyright 2018 Sebastian Wiesner <sebastian@swsnr.de>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Profile for ConsoleHost, ie, not ISE or VSCode shells

# Fancy prompt for console hosts
Import-Module posh-git

# Replace home with ~
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true;
# Git prompt settings, see https://github.com/lunaryorn/playbooks/blob/master/roles/fish/files/functions/fish_right_prompt.fish for fish variant
$GitPromptSettings.BranchIdenticalStatusSymbol.ForegroundColor = [ConsoleColor]::DarkGreen
$GitPromptSettings.BranchColor.ForegroundColor = [ConsoleColor]::DarkCyan
$GitPromptSettings.BeforeStatus.Text = '❬'
$GitPromptSettings.BeforeStatus.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.AfterStatus.Text = '❭'
$GitPromptSettings.AfterStatus.ForegroundColor = [ConsoleColor]::White
$GitPromptSettings.DelimStatus.ForegroundColor = [ConsoleColor]::White
# Symbol and colours for working status summary
$GitPromptSettings.LocalStagedStatusSymbol = '●'
$GitPromptSettings.LocalWorkingStatusSymbol = '+'
$GitPromptSettings.LocalWorkingStatusSymbol.ForegroundColor = [ConsoleColor]::DarkYellow
# Color for working status details
$GitPromptSettings.WorkingColor.ForegroundColor = [ConsoleColor]::DarkMagenta

function prompt {
    $wasSuccessful = $?

    $reset = "$([char]0x1b)[0m"
    $prompt = $reset

    $prompt += "❬$([char]0x1b)[35m$([DateTime]::now.ToString("yyyy-MM-dd HH:mm"))$reset❭"
    $prompt += " ❬$([char]0x1b)[35m$(Get-PromptWorkingDir)$reset❭"
    $prompt += Write-VcsStatus

    $prompt += "`n"
    if ($wasSuccessful) {
        $prompt += "$([char]0x1b)[32m✔"
    }
    else {
        $prompt += "$([char]0x1b)[31;1m!"
    }
    $prompt += "$([char]0x1b)[31m$(if ($PsDebugContext) {' [DBG]'} else {''})"
    $prompt += "$reset$([char]0x1b)[32m $('❯' * ($nestedPromptLevel + 1))$reset "

    $LASTEXITCODE = $origLastExitCode
    $prompt
}

# Line editing and history for console hosts
Import-Module PSReadLine

# Disable audible bell
Set-PSReadlineOption -BellStyle Visual
# Do not save duplicates in history, move cursor to the end of commands
# found in history, save history incrementally and vastly increase history.
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 4000

# Start with Emacs keys, and add custom keybindings
Set-PSReadlineOption -EditMode Emacs
# Emulate history-substring search from Fish
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
# Default to menu-completion
Set-PSReadlineKeyHandler -Chord 'Shift+Tab' -Function Complete
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

# Custom colours for readline highlighting
Set-PSReadlineOption -Colors @{
    ContinuationPrompt = "$([char]0x1b)[0m"
    Emphasis           = "$([char]0x1b)[0m$([char]0x1b)[3m" # Italic
    Error              = "$([char]0x1b)[0m$([char]0x1b)[31;1m" # Bright red
    Selection          = "$([char]0x1b)[0m"
    Default            = "$([char]0x1b)[0m" # No special colour
    Comment            = "$([char]0x1b)[0m$([char]0x1b)[37m" # Gray
    Keyword            = "$([char]0x1b)[0m$([char]0x1b)[1m" # Bold
    String             = "$([char]0x1b)[0m$([char]0x1b)[33m" # Yellow
    Operator           = "$([char]0x1b)[0m$([char]0x1b)[35m" # Magenta
    Variable           = "$([char]0x1b)[0m$([char]0x1b)[33m"
    Command            = "$([char]0x1b)[1m" # Bold
    Parameter          = "$([char]0x1b)[0m$([char]0x1b)[36m" # Cyan
    Type               = "$([char]0x1b)[0m"
    Number             = "$([char]0x1b)[0m$([char]0x1b)[34m" # Blue
    Member             = "$([char]0x1b)[0m"
}
