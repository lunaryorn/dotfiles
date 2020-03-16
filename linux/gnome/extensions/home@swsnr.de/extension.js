/* extension.js
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/* exported init */

const { St, GLib, GObject, Gio, Clutter } = imports.gi;

const Main = imports.ui.main;
const Me = imports.misc.extensionUtils.getCurrentExtension();
const PanelMenu = imports.ui.panelMenu;
const PopupMenuItem = imports.ui.popupMenu.PopupMenuItem;

const l = (message) => log(`${Me.metadata.name}: ${message}`);

/**
 * Spawn command.
 *
 * Taken from <https://github.com/andyholmes/andyholmes.github.io/blob/master/articles/asynchronous-programming-in-gjs.md#spawning-processes>
 */
const execCommand = (argv) =>
    new Promise((resolve, reject) => {
        // There is also a reusable Gio.SubprocessLauncher class available
        const proc = new Gio.Subprocess({
            argv: argv,
            // There are also other types of flags for merging stdout/stderr,
            // redirecting to /dev/null or inheriting the parent's pipes
            flags: Gio.SubprocessFlags.STDOUT_PIPE
        });

        // Classes that implement GInitable must be initialized before use, but
        // an alternative in this case is to use Gio.Subprocess.new(argv, flags)
        //
        // If the class implements GAsyncInitable then Class.new_async() could
        // also be used and awaited in a Promise.
        proc.init(null);

        // communicate_utf8() returns a string, communicate() returns a
        // a GLib.Bytes and there are "headless" functions available as well
        proc.communicate_utf8_async(null, null, (proc, res) => {
            try {
                resolve(proc.communicate_utf8_finish(res)[1]);
            } catch (e) {
                reject(e);
            }
        });
    });


// TODO: Use soup instead of CLI tool
const get_routes = () => execCommand(['home']).then((output) => {
    l(`Got routes: ${output}`);
    return output.trim().split('\n');
});


const HomeIndicator = GObject.registerClass(
    { GTypeName: 'HomeIndicator' },
    class HomeIndicator extends PanelMenu.Button {
        _init() {
            super._init(0.0, `${Me.metadata.name} Indicator`, false);

            this.routes = null;

            this.label = new St.Label({ text: '🚆 n.a.' });
            this.label.clutter_text.y_align = Clutter.ActorAlign.CENTER;
            this.actor.add_child(this.label);
        }

        show_routes(routes) {
            l(`showing routes: ${routes}`);
            this.menu.removeAll();
            if (routes) {
                this.label.set_text(routes[0]);
                routes.slice(1).forEach((route) => {
                    this.menu.addMenuItem(new PopupMenuItem(route))
                });
            } else {
                this.label.set_text('🚆 n.a.');
                this.menu.addMenuItem(new PopupMenuItem('no more routes'))
            }
        }

        show_error(error) {
            l(`error: ${error}`);
            this.label.set_text(`Error: ${error}`);
            this.menu.removeAll();
        }
    }
);


class Extension {
    constructor() {
        this.indicator = null;
        this.refresh_source_id = null;
        this.refresh_again = true;
    }

    enable() {
        l('enabled');
        if (this.indicator === null) {
            this.indicator = new HomeIndicator();
            Main.panel.addToStatusArea(`${Me.metadata.name} Indicator`, this.indicator);

            get_routes().then(
                (routes) => this.indicator.show_routes(routes),
                (error) => this.indicator.show_error(error));

            this.refresh_again = true;
            this.refresh_source_id = GLib.timeout_add_seconds(60, () => {
                get_routes();
                return this.refresh_again;
            });
        }
    }

    disable() {
        l('disabled');
        if (this.indicator !== null) {
            this.refresh_again = false;
            GLib.source_remove(this.refresh_source_id);
            this.indicator.destroy();
            this.indicator = null;
        }
    }
}

function init() {
    return new Extension();
}
