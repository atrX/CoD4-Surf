# CoD4 Surf Mod

## Notes
This mod requires "CoD4x Server" to run. You can aquire this server patch from http://revmods.me/forum/86-cod4x-server/


## License
This software is released under the GNU General Public License v3.0


## Installation
### Backend
> Place the contents of "web_backend" into your web server's directory accessible via http://localhost/sys/cod4/ (or you can go through the GSC files in /surf to change the path)

> Open "config.php" and edit the values inside

### Frontend
> Place the contents of "web_frontend" anywhere you'd like (perferably http://localhost/surf/)

> Open "config.php" and edit the values inside

### SQL Database
> Import the provided "cod4_surf.sql" file into a database of your choice (preferably a newly created, empty one)

### B3 Plugin
> Place "surf.py" in "%b3%/b3/extplugins"

> Open up your b3 config file (eg: "%b3%/b3/conf/b3.xml") and place the following line in the plugins section:

``` xml
<plugin name="surf"/>
```

### Mod
> Upload "atrx_surf" (and preferably rename) to your mods folder

> Upload "atrx_surf" (and preferably rename) to your redirect (make sure to only include "mod.ff" and "surf.iwd" here)

> Make sure to set the correct dvars in your config (check "surf/_dvar.gsc")
