# copying_printers_from_one_mac_another

Starting from: 
- https://www.papercut.com/kb/Main/CopyingPrinterConfigOnTheMac

I've updated the script to copy printers and config from an old Apple Mac to the new one.

## How to use
### Pre-requisit
1. Make sure the Printer Setup Utility is closed.
2. Verify that Remote Login is enabled on the Mac that currently has the printers:
   - System Preferences > Sharing > Remote Login
3. Verify that the user, on the Mac that currently has the printers, has the admin privilege
   - Open terminal and try to run: `sudo ls -l /etc/cups`
   
### Download the script
```
$ cd
$ git clone https://github.com/vlauciani/copying_printers_from_one_mac_another.git
$ cd copying_printers_from_one_mac_another
$ sh ./pull-printer-config.sh
```

