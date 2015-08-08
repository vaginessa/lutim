# Lutim

## What Lutim means?
It means Let's Upload That Image.

## What does it do?
It stores images and allows you to see them, download them or share them on social networks. From version 0.5, the gif images can be displayed as animated gifs in Twitter, but you need a HTTPS server (Twitter requires that. Lutim detects if you have a HTTPS server and displays an static image twitter card if you don't);

Images are indefinitly stored unless you request that they will be deleted at first view or after 24 hours / one week / one month / one year.

## License
Lutim is licensed under the terms of the AGPL. See the LICENSE file.

## Official instance
You can see it working at https://lut.im.

## Logo
Lutim's logo is an adaptation of [Lutin](http://commons.wikimedia.org/wiki/File:Lutin_by_godo.jpg) by [Godo](http://godoillustrateur.wordpress.com/), licensed under the terms of the CC-BY-SA 3.0 license.

![Lutim's logo](https://lut.im/img/Lutim_small.png)

## Dependencies
* Carton : Perl dependencies manager, it will get what you need, so don't bother for Perl modules dependencies (but you can read the file `cpanfile` if you want).

```shell
sudo cpan Carton
```

or

```shell
sudo apt-get install carton
```

* But, on another hand, some modules that Carton will install need to be compiled. So you will need some tools:

```shell
sudo apt-get install build-essential
```

### Thumbnails and animated gifs in Twitter dependancy
If you want to provide thumbnails of uploaded images or have animated gifs in Twitter, you have to install the *ImageMagick* image manipulation software (<http://www.imagemagick.org/>) and the Image::Magick CPAN module.

On Debian, you can do:
```shell
sudo apt-get install perlmagick
```

## Twitter integration
If you want to share images of your Lutim instance on Twitter, you have to register your site at <https://cards-dev.twitter.com/validator>.

## Other social networks integration
It seems that you only need to put the Lutim' social page link (the one with `?t`) in your post and it will be automatically embedded.

## Installation
After installing Carton :
```shell
git clone https://git.framasoft.org/luc/lutim.git
cd lutim
carton install
cp lutim.conf.template lutim.conf
vi lutim.conf
```

## Configuration
The `lutim.conf.template` is self-documented but here is the options that you can set:

* **hypnotoad :** address and port to listen to, user and group which runs hypnotoad (if you run Lutim with a different user from what is defined here, be sure that the user which launchs hypnotoad is able to setuid/setgid to the defined user/group, otherwise it will not work and you'll have 100% CPU consumption. Launch hypnotoad with the root user or with the user which is defined here);
* **contact :**  write something which make people able to contact you (contact form URL, email address, whatever);
* **secrets :**  an array of random string. Used by Mojolicious for encrypting session cookies.
* **piwik_img :**  the Piwik image provides you records of visits without javascript (better privacy than js and cookies);
* **length :**  length of the random string part of image's URL (default is 8);
* **provis_step :**  Lutim provisions random strings for image's URL per pack of `provis_step` (default is 5);
* **provisioning :**  number of random strings to provision (default is 100);
* **hosted_by :**  if someone hosts your Lutim instance, you can add some HTML (a logo for example) to make it appear on index page;
* **tweet_card_via :**  a Twitter account which will appear on Twitter cards;
* **max_file_size :**  well, this is explicit (default is 10Mio = 10485760 octets);
* **https :**  1 if you want to provide secure images URLs (default is 0) DEPRECATED, PASS A `X-Forwarded-Proto` HEADER TO LUTIM FROM YOUR REVERSE PROXY INSTEAD;
* **token_length :**  length of the secret token used to allow people to delete their images when they want;
* **stats_day_num :**  when you generate statistics with `script/lutim cron stats`, you will have stats for the last `stats_day_num` days (default is 365);
* **keep_ip_during :**  when you delete IP addresses of image's senders with `script/lutim cron cleanbdd`, the IP addresses of images older than `keep_ip_during` days will be deleted (default is 365);
* **broadcast_message :**  put some string (not HTML) here and this message will be displayed on all Lutim pages (not in JSON responses);
* **allowed_domains :**  array of authorized domains for API calls. Example: `['http://1.example.com', 'http://2.example.com']`. If you want to authorize everyone to use the API: `['\*']`.
* **default_delay :**  what is the default time limit for files? Valid values are 0, 1, 7, 30 and 365;
* **max_delay :**  if defined, the images will be deleted after that delay (in days), even if they were uploaded with "no delay" (or value superior to max_delay) option and a warning message will be displayed on homepage;
* **always_encrypt :**  if set to 1, all images will be encrypted.
* **delete_no_longer_viewed_files :**  if set, the images which have not been viewed since `delete_no_longer_viewed_files` days will be deleted by the `script/lutim cron cleanfiles` command

## Usage

### Starting Lutim from Command line
```
carton exec hypnotoad script/lutim
```

### Starting Lutim with the init script
```
cp utilities/lutim.init /etc/init.d/lutim
cp utilities/lutim.default /etc/default/lutim
chmod +x /etc/init.d/lutim
chown root:root /etc/init.d/lutim /etc/default/lutim
vim /etc/default/lutim

/etc/init.d/lutim start
```

### Starting Lutim with systemd
```
cp utilities/lutim.service /etc/systemd/system/
vi /etc/systemd/system/lutim.service
systemctl daemon-reload
systemctl start lutim.service
```

### Starting Lutim with the Upstart script
* ``cp utilities/lutim_upstart.conf /etc/init/lutim.conf``
* ``cp utilities/lutim.default /etc/default/lutim``
* modify path to the Lutim-root in /etc/default/lutim
* ``start lutim``

## Update
```
git pull
carton install
carton exec hypnotoad script/lutim
```

Yup, that's all (Mojolicious magic), it will listen at "http://127.0.0.1:8080".

For more options (interfaces, user, etc.), change the configuration in `lutim.conf` (have a look at http://mojolicio.us/perldoc/Mojo/Server/Hypnotoad#SETTINGS for the available options).

***Warning!!!***

If you want to update to Lutim **0.3**, from a previous version, you'll have to modify the database.

```
sqlite3 lutim.db
PRAGMA writable_schema = 1;
UPDATE SQLITE_MASTER SET SQL = 'CREATE TABLE lutim ( short TEXT PRIMARY KEY, path TEXT, footprint TEXT, enabled INTEGER, mediatype TEXT, filename TEXT, counter INTEGER, delete_at_first_view INTEGER, delete_at_day INTEGER, created_at INTEGER, created_by TEXT, last_access_at INTEGER, mod_token TEXT)' WHERE NAME = 'lutim';
PRAGMA writable_schema = 0;
```

***Warning!!!***

If you want to update to Lutim **0.5**, from a previous version, you'll have to modify the database.

```
sqlite3 lutim.db
PRAGMA writable_schema = 1;
UPDATE SQLITE_MASTER SET SQL = 'CREATE TABLE lutim ( short TEXT PRIMARY KEY, path TEXT, footprint TEXT, enabled INTEGER, mediatype TEXT, filename TEXT, counter INTEGER, delete_at_first_view INTEGER, delete_at_day INTEGER, created_at INTEGER, created_by TEXT, last_access_at INTEGER, mod_token TEXT, width INTEGER, height INTEGER)' WHERE NAME = 'lutim';
PRAGMA writable_schema = 0;
```

## Reverse proxy
You can use a reverse proxy like Nginx or Varnish (or Apache with the mod_proxy module). The web is full of tutos.

Here's a valid *Nginx* configuration:
```
server {
    listen 80;
    root /path/to/lutim/public;

    # This is important for user's privacy !
    access_log off;
    error_log /var/log/nginx/lutim.error.log;

    # This is important ! Make it OK with your Lutim configuration
    client_max_body_size 40M;

    location ~* ^/(img|css|font|js)/ {
        try_files $uri @lutim;
        add_header Expires "Thu, 31 Dec 2037 23:55:55 GMT";
        add_header Cache-Control "public, max-age=315360000";

        # HTTPS only header, improves security
        #add_header Strict-Transport-Security "max-age=15768000";
    }

    location / {
        try_files $uri @lutim;

        # HTTPS only header, improves security
        #add_header Strict-Transport-Security "max-age=15768000";
    }

    location @lutim {
        # Adapt this to your configuration
        # My advice: put a varnish between nginx and Lutim, it's really useful when images are widely viewed
        proxy_pass  http://127.0.0.1:8080;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # If you want to log the remote port of the image senders, you'll need that
        proxy_set_header X-Remote-Port $remote_port;

        proxy_set_header X-Forwarded-Proto $scheme;

        # We expect the downsteam servers to redirect to the right hostname, so don't do any rewrites here.
        proxy_redirect     off;
    }
}
```

If you use Lutim under a subdirectory like `/lutim/`, change the `prefix` configuration option and prefix the nginx locations with `/lutim` (or whatever you choose).

## Cron jobs
Lutim have commands which can be used in cron jobs.

To see what commands are available:
```shell
carton exec script/lutim cron
```

### Statistics
To generate statistics which can be viewed at the address `/stats` (we need to reload hypnotoad after the stats generation):
```shell
carton exec script/lutim cron stats && carton exec hypnotoad script/lutim
```

### Delete IP adresses from database
To automatically delete the IP addresses of image's senders after a configurable delay:
```shell
carton exec script/lutim cron cleanbdd
```

### Delete expired files
To automatically delete files which availability delay is over (when you choose that your image will be deleted after 24h / one week / etc.)
If `delete_no_longer_viewed_files`, the files not viewed since `delete_no_longer_viewed_files` days will be deleted too.
```shell
carton exec script/lutim cron cleanfiles
```

### Watch the size of the files directory
To execute an action when the files directory is heavier than `max_total_size`.
The available actions are `warn` and `stop-upload`:
* `warn` prints a message on the standard out (which is normally mailed to you by `cron`) ;
* `stop-upload` prints a message on the standard out and creates the `stop-upload` file which prevents uploading and put a warn on Lutim interface ;
* **DANGEROUS OPTION!!!** `delete` prints a message on the standard out and delete older images until the files directory goes under quota.

If the files directory go under quota, the `stop-upload` file is deleted. If you want to manually prevents uploading, create a file named `stop-upload.manual`.

```shell
carton exec script/lutim cron watch
```

## Broadcast message
Set a string in the `broadcast_message` option of `lutim.conf` and reload the server with:
```shell
carton exec hypnotoad script/lutim
```

It may take a few reloads of page before the message is displayed.

## Encryption
Lutim does encryption on the server if asked to, but does not store the key.

The encryption is made on the server since Lutim is made to be usable even without javascript. If you want to add client-side encryption for javascript-enabled browsers, patches are welcome.

## API
You can add images by using the API. Here's the parameters of the `POST` request to `/` adress:.

|name      |type  |description                                                                 |optional/mandatory|default|
|----------|------|----------------------------------------------------------------------------|------------------|-------|
|format    |string|`json` if you want to get a json response, otherwise it will send a web page|optional          |html   |
|file      |file  |the image file                                                              |mandatory         |no default|
|delete-day|int   |number of days you want the image to stay                                   |optional          |0 (undefinitely) or the configured maximum delay of the server|
|first-view|int   |if not 0, the image will be deleted at first view                           |optional          |0      |


Exemple with curl:
```shell
curl -F "format=json" -F "file=@/tmp/snap0001.jpg" http://lut.im
```

You can allow people to use your instance of Lutim from other domains.
Add the allowed domains as an array in the `allowed_domains` conf option. Put '`[\*]`' if you want to allow all domains.

### Response
```
{
'success': True,
'msg': {
    'real_short': 'abc',
    'short': 'abc/def',
    'token': 'ghijkl',
    'thumb': None,
    'filename': 'myimage.png'
    }
}
```
| parameter | type         | role    |
|-----------|--------------|---------|
|   sucess  | True/False   | upload-status |
|   msg     | dict         |         |
|real_short | string       | image identifier|
| short     | string       | ``real_short`` + encryption key |
| token     | string       |         |
| thumb     |              |         |
| filename  | string       | filename of the uploaded image |

## Shutter integration
See where Shutter (<http://en.wikipedia.org/wiki/Shutter_%28software%29>) keeps its plugins on your computer.
On my computer, it's in `/usr/share/shutter/resources/system/upload_plugins/upload`.

Then:
```
sudo cp utilities/Shutter.pm /usr/share/shutter/resources/system/upload_plugins/upload/Lutim.pm
```

And restart Shutter if it was running.

Of course, this plugin is configured for the official instance of Lutim (<http://lut.im>), feel free to edit it for your own instance.

## [Screencloud](https://github.com/olav-st/screencloud) integration

`Preferences` -> `Online Services` -> `More services` -> `Install from URL`
```
https://github.com/Thor77/screencloud-lutim/archive/master.zip
```
Double-click the plugin in `Preferences` -> `Online Services` for configuration!
Please report issues [here](https://github.com/Thor77/screencloud-lutim/issues).

## Internationalization
Lutim comes with English, French and Spanish languages. It will choose the language to display from the browser's settings.

There is a [project on Transifex](https://www.transifex.com/projects/p/lutim/) if you want to help translating Lutim. There is also the `templates/manifest.webapp.ep` file which contains multiple languages sentences.

Thank you :smile:

## Others projects dependancies
Lutim is written in Perl with the [Mojolicious](http://mojolicio.us) framework, uses the [Twitter bootstrap](http://getbootstrap.com) framework to look not too ugly, [JQuery](http://jquery.com) and [JQuery File Uploader](https://github.com/danielm/uploader/) (slightly modified) to add some modernity, [Raphaël](http://raphaeljs.com/) and [morris.js](http://www.oesmith.co.uk/morris.js/) for stats graphs and [freezeframe.js](http://freezeframe.chrisantonellis.com/) (slightly modified) to be able to freeze animated gifs in twitter card.

Licenses for the icons fonts are in `public/font/LICENSE.txt`.

## Main developers
* Luc Didry, aka Sky (<http://www.fiat-tux.fr>), core developer, @framasky on [Twitter](https://twitter.com/framasky) and on [Diaspora*](https://framasphere.org/public/framasky)
* Dattaz (<http://dattaz.fr>), webapp developer, [@dat_taz](https://twitter.com/dat_taz)

## Contributors
* Jean-Bernard Marcon, aka Goofy (<https://github.com/goofy-bz>)
* Jean-Christophe Bach (<https://github.com/jcb>)
* Florian Bigard, aka Chocobozzz (<https://github.com/Chocobozzz>)
* Sandro CAZZANIGA, aka Kharec (<http://sandrocazzaniga.fr>), [@Kharec](https://twitter.com/Kharec)
* Laura Arjona Reina (<https://wiki.debian.org/LauraArjona>), spanish translation
* Thor77 (<http://thor77.org>)
