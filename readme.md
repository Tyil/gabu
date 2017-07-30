# Gabu
An RSS feed watcher for trackers.

## Installation
Make sure you have perl installed and the dependencies. After that you can
clone the directory to wherever you please. You can use the makefile to install
it properly.

```
git clone https://github.com/tyil/gabu ~/.local/src
cd $_
make install
```

### Dependencies
- `LWP::Protocol::https` (if you want to use feeds over HTTPS)
- `LWP::UserAgent`
- `Term::ANSIColor`
- `XML::RSS::Parser`
- `YAML::Tiny`

The easiest way to install these is by using `cpanm`. Refer to your
distribution's documentation on how to get this installed if you do not have it
yet. If you have it available, install them using the `cpanfile` provided with
Gabu:

```
cpanm --installdeps --notest .
```

## Configuration
Edit the YAML file at `/etc/gabu.yaml` to your leisure. Most importantly, make
sure you have a proper URL defined for the feed(s) you want to keep track of.

### Timeout
By default, the script runs continuously, and goes through all feeds after 5
minutes. If you set the `timeout` to `0`, it will only run once, then exit. Any
value higher than `0` will make the script wait for so many seconds before
starting over.

### Regexes
The `regexes` key for a given feed are directly dropped into Perl. As such, if
you want to match certain characters literally, such as `(`, you must escape
them appropriately, in this case as `\(`.

Note that the regexes are tested with the `i` flag to make them case
insensitive. The `x` flag is also applied, making whitespace insignificant (and
allows for comments in the regex). If you need to match a space, you must make
it a special character class, like `[ ]`.

## Running
Simply run `gabu` after setting up the configuration. If you did not run `make
install`, you have to make sure the `gabu.pl` file is executable with `chmod +x
src/gabu.pl`, then run it with `./src/gabu.pl`.

### Reloading
You can reload the configuration without restarting gabu by sending a `SIGUSR1`
to the process.

## License
This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.

