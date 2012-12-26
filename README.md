lua-pathmap
===========

Path finding using group oriented programming.  
BSD license.  
For version log, see the individual files.  

To run the example you need to install LÖVE 2D game engine:  
https://love2d.org/

##Why Group Oriented Programming?

In raw data, a complete solved 1000x1000 map requires 1 trillion pixels, which doesn't fit inside memory.  
A map with 1000x1000 resolution requires only 4 million groups.  
Each groups doesn't take a lot of memory since neighbor pixels tend to clump together.  
If a row of pixels all belong to the same group, it takes only two numbers to represent that row.  

This solver uses pixels with maximum 4 directions.  
A group is generated for each direction per pixel that tells "shortest path direction" to other pixels.  

Using group oriented programming with group bitstreams makes it possible to store   
much larger maps in memory, which makes it suitable for advanced game AI.  
For an NxN map, the group oriented approach increases 4N^2.  
The raw data requires one map per pixel, which increases N^4.  

##Short Introduction To Group Oriented Programming

A group is a collection where members can swap positions without having changing the group. 
In programming, we can use this definition by using indexes instead of pointing to objects directly.  
A collection of indexes is called a "group" and there are many alternative formats.  

For low entropy groups, there is a format called "group bitstream" that stores a list of slices.  
Each slice has a start and end, the last item in the slice is the one before the end.  

    {start0, end0, start1, end1, ...}

One advantage of this format is that composite operations usually takes fewer operations than using lists or arrays.  
Groups are composed using Boolean Algebra, which for finite groups consists of AND, OR and EXCEPT.  
