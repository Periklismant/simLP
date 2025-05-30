
HAR experiments:

-The 'similarity comparison' file is the ground truth for syntactic similarity.
-The 'predictive accuracy' file is the ground truth for the f1-score computation.

To compute the f1-score:
(a) add in the LLM-generated definitions the rules concerning the closeX predicates (lines 1--40 from the 'predictive accuracy' file).
(b) replace in the LLM-generated definition the 'thresholds' and 'close' predicates with the corresponding 'closeX' predicate for the 'predictive-accuracy' file.
