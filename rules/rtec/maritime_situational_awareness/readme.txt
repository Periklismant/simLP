
MSA experiments:

-The 'similarity comparison' file is the ground truth for syntactic similarity. This file does not include the rules used as examples in the initial prompts.
-The 'predictive accuracy' file is the ground truth for the f1-score computation. This file includes the rules that were omitted for the 'similarity comparison' file.

Note that the definitions of movingSpeed, underWay, changingSpeed and drifting are not included in either file:
- underWay is used as an example in our prompting method.
- movingSpeed is used only as input for the definition of underWay
- changingSpeed is used only in an optimization condition. 
- drifting has a complex natural language description, resulting in lower-quality rules. 
