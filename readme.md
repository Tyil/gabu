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
- `XML::RSS::Parser`
- `YAML::Tiny`
- `LWP::UserAgent`
- `LWP::Protocol::https` (if you want to use feeds over HTTPS)

## Configuration
Edit the YAML file at `/etc/gabu.yaml` to your leisure. Most importantly, make
sure you have a proper URL defined for the feed(s) you want to keep track of.

## Running
Simply run the `gabu` file after setting up the configuration

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

