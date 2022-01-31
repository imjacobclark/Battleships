#  Battleships - built with SpriteKit

This was built for a fun coding competition at work. I spent no time implementing best practices in this repo, I hacked together a solution around a busy schedule with next to no knowledge of SpriteKit ;-) 

The core game is built API first with a core set of rules and a representation of the grid as a 100 element array. Each array element contains various properties, such as ship occupying the position, whether it has been destroyed, what its x and y coords are.

Methods exist to support strikes, determining whether the game has won and an AI to take turns against with varying levels of difficulty. 

