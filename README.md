lua-pathmap
===========

Path finding using group oriented programming.  
BSD license.  
For version log, see the individual files.  

![Screenshot](https://github.com/bvssvni/lua-pathmap/blob/master/screenshot.png)

Example: Download "pathmap-example.love".

To run the example you need to install LÖVE 2D game engine:  
https://love2d.org/

##Group Oriented Programming Uses Less Memory For Large Maps

For an NxN map, using group bitstreams increases memory with 4N^2.  
The raw data requires one map per pixel, which increases memory N^4.  

In raw data, a complete solved 1000x1000 map requires 1 trillion pixels, which doesn't fit inside memory.  
A map with 1000x1000 resolution requires only 4 million groups.  

Each groups doesn't take a lot of memory since neighbor pixels tend to clump together.  
If a row of pixels all belong to the same group, it takes only two numbers to represent that row.  

This solver uses pixels with maximum 4 directions.  
A group is generated for each direction per pixel that tells "shortest path direction" to other pixels.  

Using group oriented programming with group bitstreams makes it possible to store   
much larger maps in memory, which makes it suitable for advanced game AI. 

##Short Introduction To Group Oriented Programming

A group is a collection where members can swap positions without changing the identity of the group.  
We can use this definition by calculating with indexes instead of pointing to objects directly.  

There are many ways of formatting groups.  
For low entropy groups, there is a format called "group bitstream" that stores a list of slices.  
Each slice has a start and end, the last item in the slice is the one before the end.  

    {start0, end0, start1, end1, ...}

One advantage of this format is that composite operations usually takes fewer operations than using lists or arrays.  
Groups are composed using Boolean Algebra, which for finite groups consists of AND, OR and EXCEPT.  
