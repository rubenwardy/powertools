# Powertools

Adds tools to make map editing easier.  
Created by rubenwardy. CC0.

## Column Digger

Punch a node. The node you punch and stackcount - 1 nodes below
(or above if up digger) it will be dug, where stackcount is the stack number
of the digger tool. There are also conditional versions that only dig if
conditions are met.

* **Down Column Digger** - no conditions, works on any punchable node
* **Conditional (Start) Down Column Digger** - only works if the punched node
	matches the itemstack to the right of the tool (use to stop accidental digging)
* **Conditional (Same) Down Column Digger** - only digs nodes that are the same
	as the itemstack to the right of the tool

## Column Replacer

Punch a node. The node you punch and stackcount - 1 nodes below
(or above if up digger) it will be replaced with nodes of the type of the
itemstack to the right of the tool.

* **Down Column Replacer** - no condition, works on any punchable node
* **Up Column Replacer** - works up, rather than down

## Floor Filler

Punch a node. A floor will be placed starting at the node position just before
the node you punched. So if you punch the side of a wall, a floor will be placed
at that level. If you punch the top of a node, a floor will be placed
one node above that node. The material used will be the itemstack to the right.
Only air is replaced. Each tool in the stack gives you roughly a radius of 10.
So 5 tools will allow you to build a floor 50 nodes outwards (in a diamond pattern).

* **Floor Filler** - no condition, works on any punchable node

## TODO

* Return dug items when using Down Column Digger
* placer/replacer that only places over air
* up column diggers
* Honour node protection
* Survival version
	* when placing, take from stack to the right.
	* When digging, limit stack count
	* Craft recipes
