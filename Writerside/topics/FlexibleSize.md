# FlexibleSize

**Implementation Stage:** Planned.

A data type which allows the width and height to be set dynamically 
based on the size of parent. Often used to set object size based on 
screen size.

When a value of this data type is represented in this guide, It is 
represented as "\[width\]\[px or %\] W, \[height\]\[px or %\] H"

isWidthFlexible [boolean]
: If the width variable is flexible or not.

isHeightFlexible [boolean]
: If the height variable is flexible or not.

width [float]
: (If isWidthFlexible is `true`) How much percentage of 
  width should this object take based on the parent.<br/>
  If isWidthFlexible is `false`, This is a fixed width value

height [float]
: (If isHeightFlexible is `true`) How much percentage of
  height should this object take based on the parent.<br/>
  If isHeightFlexible is `false`, This is a fixed height value
