# Bash scripts

Contains some bash scripts with convenient functions.   
For each script there are appropriate examples given.  
Each script has a -h or --help option for an explanation of the script.  

Inside each subfolder you will find an 'example\*' folder, these contain a _tutorial_ file. Open it with a text editor and follow the steps to learn how the scripts work.

So far implemented:  
- Various compilation methods for \*.tex files  
- Multiple file manipulation for insertion/swapping of headers  
- aligning code for better readability (implemented for python)

Once the scripts have been downloaded, the permissions most likely need to be changed to be executable on your computer.

Recommended way of usage:  
- Copy the scripts in `/some/directory/with/scripts/`
- Edit your `~/.bashrc` and add the following line:  
- `PATH=/some/directory/with/scripts:$PATH`
- Now the scripts can be executed in any directory with `scriptname.sh [-options] args`, no ./scriptname required.
- if you have take the nested directories you can also add these lines in your `~/.bashrc`
```
for dir in ~/scripts/bash/*; do
    if [ -d "$dir" ]; then
        PATH="$PATH:$dir"
    fi
done
```
- then you can execute all the scripts in each subfolder wherever you are
 
 
For feedback or ideas contact "lissner@mechbau.uni-stuttgart.de"
