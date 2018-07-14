# Karma
What goes around comes around again, probably.

A collection of *actIds* in a probabilistic cycle ...


## Including Karma in your Perl project
#### As a source file
All of the functional source code is located in 'Karma.pm'. By downloading and adding it to your project's directory, it can be included with `use Karma`, or `require "<path>/Karma.pm"`.

#### As a CPAN module
Download the .tar.gz (which doesn't exist yet), unzip, and 
```
perl Makefile.PL
make
make install
```

## Motivation
#### Specifically, consider the task of vocabulary building.
Years ago, I maintained a list of words in a plaintext file. As I added more and more words to the top of the file, naturally, older words fell out of the short distance haphazard scrolling would be willing to take me. The rate at which I added words thus matched the increasing impossibility of efficient revision. Still, I would add words, for to recognise their significance and write them down *somewhere* would be an act of learning, if only minor; 
so the file still existed, though in a strange write-only limbo.

What goes around ... having went around, never sees the light of day again.

Somewhat of a failure, but not having become useless, whenever I added a word I was forced to ponder how things could have worked better. One of the questions I came to ask was *"In which order should I be reviewing these words?"* In true programming spirit, I decided that all this thinking was too much for me, and I should get a computer to do it in my stead.
So, I designed Karma to answer, specifically, ***which word should I review next?***

#### In general
Now, this problem has extended its arms into not merely vocabulary matters, though this was the source of my introspection. During my vocabulary-enlightenment, I have become particularly cognisant of my profound ~~habit~~ ability to produce large amounts of categorically sorted text which I only ever add to, never really looking back into unless there is something particular I am seeking. Even so, I purport to have learnt some of these things merely by having understood them once.

In some cases, it's all well and good to spew out piles of text into an abyss. To be able to write something under the if only hypothetical restraint that "someday, I may look back upon this, and I must absolutely understand at that time all that I do now" is surely an important step in learning. But in the cases where I want what I write down to come back around to me at some point, this is where I hope to use this project.

## Tools and Analysis
In the /tools/ folder, the MATLAB script simulateIndexGenerator.m can be used to generate images such as, 

for T(x) := x^2

![fat-tailed](./images/fat-tailed.svg)

for T(x) := ((1/pi) \* asin(2\*x^2 - 1) + 1/2)^b

![thin-tailed](./images/thin-tailed.svg)

TODO list:
- [X] Tick off the first item of this list.
- [ ] Summarise *Motivation* section. ~~Particularly, the latter half of *In general*.~~
- [ ] Insert MATLAB images, maybe some additional documentation about indexGenerator. Do this under *Tools*. Add xlabel and ylabel?
- [ ] Try to come up with a good description of what a *probabalistic cycle* is, and stick it at the top somewhere.
- [ ] Use `h2xs -AX -n Karma.pm` to create a CPAN-standard tarball, and upload it.
    - This will require the complicitness of version number in both the tar, and in the gist.
- [ ] Spell-check. Capitalisation of titles?
- [ ] Find and destroy any inline TODO flags.
