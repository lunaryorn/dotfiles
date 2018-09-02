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

# TODO: Make sure to trust all relevant repositories here

$oldModules = @(
    # Superseded by ZLocation
    'Jump.Location'
)

[array]$toRemove = Compare-Object `
    $oldModules (Get-Module | Select-Object -ExpandProperty Name) `
    -ExcludeDifferent -IncludeEqual | Select-Object -ExpandProperty InputObject

if ($toRemove.Count -gt 0) {
    Remove-Module $toRemove
}

# YAML support for powershell
Install-Module 'powershell-yaml' -Scope CurrentUser
# Colourful ls
Install-Module 'Get-ChildItemColor' -Scope CurrentUser
# autojump/z for powershell
Install-Module 'ZLocation' -Scope CurrentUser
# Adds git status information to powershell prompt, min 1.0, for core compatibility
Install-Module 'posh-git' -Scope CurrentUser -AllowPrerelease -MinimumVersion '1.0.0-beta2'
# Better line editing for powershell, min 2.0 for core compatibility
Install-Module 'PSReadLine' -Scope CurrentUser -AllowPrerelease -MinimumVersion '2.0.0-beta2'
