## Dual-decision task

This code implements the dual-decision task by Lisi et al (2020), which provide a new model-based approach to measure confidence in perceptual decision making.

### Instructions 

Type `launcher` to launch the experiment. The order of the two tasks (i.e. whether orientation or motion is first) is randomized depending on the number of the participant.

Once launched, the program will prompt for some info, including whether the current session is control or dual-decision condition. In the control task the two decision are independent, whereas in the dual-decision the sign of the second stimulus will depend on the accuracy of the first response; see Lisi et al (2020) for a more detailed explanation of the rationale.

Once you have done few control session with a participant, you can move on to the dual-decision sessions. To do so we need an estimate of the internal noise of the participant. This is calculated automatically once you launch a dual-decision session, using all previous session. Note that in its current implementation all previous consecutive session number must be present; alternatively you can calculate the noise manually using the `check_noise` function. This can be used as
```{matlab}
addpath('./functions')
check_noise('01ml', [1, 2])
```
which will estimate noise for subject `01ml` using data from session 1 and 2. It will also make a plot of the psychometric functions, from which you can judge whether the participant is biased or not. As a rule of thumb, if the interval represented as the orizontal red bar in the plot do not include zero, the participant should not be recalled to do the dual-decision task.

### References 

Lisi, M., Mongillo, G., Milne, G., Dekker, T., & Gorea, A. (2021). Discrete confidence levels revealed by sequential decisions. _Nature human behaviour, 5(2)_, 273–280. [https://doi.org/10.1038/s41562-020-00953-1](https://doi.org/10.1038/s41562-020-00953-1)
