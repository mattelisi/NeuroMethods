## Instrumental learning task

This is a child-friendly version of the instrumental learning task used by Pessiglione et al. (2006).

### Instructions

In order to run, make sure the script `ilt2.m` and the folders 'img' and 'functions' are in teh current working directory. You may also want to check that the screen settings (monitors width and viewing distance); these are currently set to these defaults

```{matlab}
%----------------------------------------------------------------------------------------
% Screen setup info: change these accordingto the monitor and viewing distance used
scr.subDist = 90;   % subject distance (cm)
scr.width   = 300;  % monitor width (mm)
```

Setting these to match your setup ensure that the size of stimuli appears as intended.

In order to run this type `ilt2` in the coomand line. You will be then asked to type in some information, and whether you would like to see the "intro" (this is a short guided demonstration of the task that was used to more easily explain it to children). It should look like this:

```
>> ilt2

 Subject number (set 0 to test without storing data):  1


   Please type the following informations
        initials / identifier:  ML
        age:  99
        gender (m/f):  m

 Skip intro? y/n [n]:n


PTB-INFO: This is Psychtoolbox-3 for GNU/Linux X11, under Matlab 64-Bit (Version 3.0.18 - Build date: Jun 27 2022).
PTB-INFO: OS support status: Linux 5.15.0-46-generic Supported.
PTB-INFO: Type 'PsychtoolboxVersion' for more detailed version information.
PTB-INFO: Most parts of the Psychtoolbox distribution are licensed to you under terms of the MIT License, with
PTB-INFO: some restrictions. See file 'License.txt' in the Psychtoolbox root folder for the exact licensing conditions.
```

In the task, you can respond (choosingwhich door to open) by clicking with the mouse on the symbols above the doors.

### References

Pessiglione, M., Seymour, B., Flandin, G., Dolan, R. J., & Frith, C. D. (2006). Dopamine-dependent prediction errors underpin reward-seeking behaviour in humans. _Nature_, 442(7106), 1042–1045. [https://doi.org/10.1038/nature05051](https://doi.org/10.1038/nature05051)
