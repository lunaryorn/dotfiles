#!/usr/bin/python3
# Copyright 2020 Sebastian Wiesner <sebastian@swsnr.de>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

import json
from subprocess import run
from pathlib import Path


SETTINGS = {
    # Disable telemetry
    "telemetry.enableCrashReporter": False,
    "telemetry.enableTelemetry": False,
    # Colors (follow the system on colors)
    "window.autoDetectColorScheme": True,
    # Fonts
    "editor.fontFamily": '"PragmataPro Liga","Noto Color Emoji"',
    "editor.fontLigatures": True,
    "editor.fontSize": 14,
    "terminal.integrated.fontFamily": "PragmataPro Mono Liga",
    "terminal.integrated.fontSize": 14,
    # Fix terminal colours; this a really stupid default imho
    "terminal.integrated.drawBoldTextInBrightColors": False,
    # Editing
    "editor.rulers": [
        80,
        120,
        160
    ],
    "files.trimTrailingWhitespace": True,
    "files.insertFinalNewline": True,
    # Version control
    "git.confirmSync": False,
    "git.autofetch": True,
}


def update_config():
    config_file = Path.home() / '.config' / 'Code' / 'User' / 'settings.json'
    settings = {}
    if config_file.is_file():
        with config_file.open() as source:
            settings = json.load(source)
    settings.update(SETTINGS)
    with config_file.open('w') as sink:
        json.dump(settings, sink, indent=4)


def main():
    update_config()


if __name__ == '__main__':
    main()
