## Hidden Markov Model

from [[1]]():

Each state has its own __emission probabilities__, which, for example, models the base composition of exons, introns and the consensus G at the 5′SS.

Each state also has __transition probabilities__, the probabilities of moving from this state to a new state.

![HMM](https://raw.githubusercontent.com/friedue/Notes/master/images/HMM_01.png)

[Casino example](http://learninglover.com/blog/?p=635)

### Baum-Welch algorithm

The Baum–Welch algorithm is used to find the unknown parameters of a hidden Markov model (HMM). [[2]] I.e. given a sequence of observations, generate a transition and emission matrix that may have generated the observations. [[4]]

The BWA makes use of the forward-backward algorithm. [[2]]



### Viterbi path

There are potentially many state paths that could generate the same sequence. We want to find the one with the highest probability. (...) The efficient Viterbi algorithm is guaranteed to find the most probable state path given a sequence and an HMM. [[1]]
The Baum–Welch algorithm uses the well known EM algorithm to find the maximum likelihood estimate of the parameters of a hidden Markov model given a set of observed feature vectors. [[3]]

HMMs don’t deal well with correlations between residues, because they assume that each residue depends only on one underlying state. [[1]]

[interactive spreasheet for teaching forward-backward algorithm](http://www.cs.jhu.edu/~jason/papers/#eisner-2002-tnlp)


----------------------
[1]: http://dx.doi.org/10.1038/nbt1004-1315 "Eddy, S. Nat Biotech (2014)"
[2]: https://en.wikipedia.org/wiki/Baum%E2%80%93Welch_algorithm "Wikipedia: Baum Welch algorithm]"
[3]: https://en.wikipedia.org/wiki/Viterbi_algorithm "Wikipedia: Viterbi algorithm"
[4]: http://biostat.jhsph.edu/bstcourse/bio638/readings/BW.pdf "Baum-Welch Algorithm explained"
