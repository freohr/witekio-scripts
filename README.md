# witekio-scripts

Each script has its own help, with the parameter -h/--help, explaining what it does and which parameter exists

## How to install

### The easy way

Download the `install_scripts.sh` and run it (`--help` will show you the parameters)

This will install the scripts in your home folder in their own `witekio_scripts` folder
```bash
wget https://raw.githubusercontent.com/freohr/witekio-scripts/master/install_scripts.sh
./install_scripts.sh -a -d ~
rm install_scripts.sh
```

### The DIY way

Either clone this repo (if you want to update those scripts easily) or download then extract the archive to your folder of choice.
Then add the folder to your PATH variable (in your `.bashrc`/`.zshrc`/config file for your cli of choice)
