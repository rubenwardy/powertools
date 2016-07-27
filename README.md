# Powertools

Created by rubenwardy. CC0.


## Down stack digger

Punch a node. That node and N-1 nodes below it will be dug

N = stack count of tool

For example, if you have 5 conditional digger objects, you will dig 5 nodes
straight down from the node you punch, including the node you punch.

## Conditional down stack digger

Punch a node. That node and N-1 nodes below it will be dug, providing that the
punched node is of type X.

N = stack count of tool
X = type of the stack next to the tool used

For example, if you have 5 conditional digger objects, you will dig 5 nodes
straight down from the node you punch, including the node you punch.
If you have a dirt item to the right of the tool in the hotbar, then the tool
will only work if you punch a dirt node.
If you have an empty slot, it will work with any node.
