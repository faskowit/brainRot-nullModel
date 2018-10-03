brainRot-nullModel
==============================

A method to get null parcellations on the FreeSurfer surface. This is achieved by projecting the parcellation to a sphere, and randomly rotating in the sphere space. Additionally, the 'black hole' created by the corpus callosum and subcortical structures is filled with labels that were rotated into the actual 'black hole' area<sup>1</sup>. 

The spherical rotation is adapted from Salim Arslan's [parcel evaluation](https://github.com/sarslancs/parcellation-survey-eval) code. A related project is the [spin-test](https://github.com/spin-test/spin-test) repo. 

### What does this code do?

Heres a look at the [Destrieux](https://surfer.nmr.mgh.harvard.edu/fswiki/CorticalParcellation) atlas projected to a sphere, in the un-rotated space:

![fig1](./data/before_rotation.png)

This sphere is then rotated randomly in the x, y, and z direction:

![fig2](./data/brainRot_1.png)

And finally we put the original 'black hole' back and fill the rotated 'black hole' with labels rotated too far into the original invalid space:

![fig3](./data/brainRot_2.png)

### About filling the rotated back hole
<sup>1</sup> Deciding which labels to use to fill the rotated black hole is tricky business. Does any label that touches the orignal area get _popped_ and transfered to a new area? Here, we calculated the percentage of contact with the 'black hole' that each label makes. Then, beginning with the label that overlaps most with the invalid area, we calculate how moving that label to the new space would affect the distribution of label sizes (across whole parcellation). We pick the number of labels to move based on the new parcellation that best perserves (i.e. least distant from) the original distribution of label sizes.

<sub> This material is based upon work supported by the National Science Foundation Graduate Research Fellowship under Grant No. 1342962. Any opinion, findings, and conclusions or recommendations expressed in this material are those of the authors(s) and do not necessarily reflect the views of the National Science Foundation. </sub>
