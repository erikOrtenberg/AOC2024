[Great song](https://www.youtube.com/watch?v=BJhF0L7pfo8&pp=ygUMc2VhIHNoYW50eSAy)

## DAY 1 PART 1

### OVERALL STRUCTURE

              +--------------+
              |              |
Column 1 ---> | Merge Sorter |-------\
              |              |        \ +--------------+      +----------------------+
              +--------------+         \|              |      |                      |
                                        |  Vector Sub  |----> | Vector Sum Reduction |----> RESULT!
              +--------------+         /|              |      |                      |
              |              |        / +--------------+      +----------------------+
Column 2 ---> | Merge Sorter |-------/
              |              |
              +--------------+

### MERGE SORTER


Use a recursive if-generate statement. All inputs and outputs are collected and sent out from the top layer. 
The recursion will look like this:
                                                    output top half
                                          /------------------------------\   
                        +--------------+ /      +-----------+ ---> ...    \     
                 top    |              |//----> | M. Sorter | <-------     \    
               /------->| Merge Sorter |/ <---- +-----------+ ---> ...      \             
              /  half   |              |\ <---- +-----------+ ---> ...       \ +------------------+           \\
             /          +--------------+ \----> | M. Sorter | <-------        \|                  |  Output    \\
Input vector |                                  +-----------+ ---> ...         |  Comparitor and  |=============\\    
             |                                  +-----------+ ---> ...         |     Inserter     |=============//    
             \          +--------------+ /----> | M. Sorter | <-------        /|                  |  Vector    //
              \  bottom |              |/ <---- +-----------+ ---> ...       / +------------------+           // 
               \------->| Merge Sorter |\ <---- +-----------+ ---> ...      /              
                 half   |              |\\----> | M. Sorter | <-------     /                
                        +--------------+ \      +-----------+ ---> ...    /      
                                          \------------------------------/
                                                    output bottom half


## DAY 1 PART 2

### OVERALL STRUCTURE
Each unit matches one value from column 1 with every occurance in column 2. This count is then output and multiplied with the input.

                        |                                                 
               Column 2 | Stream                                         
                       \|/                                               
                  +-----------+                                          
                  |           |                +-----------+                         
 Column 1[0]      |  Systolic | Output count   |           |              +-------------------------+                        
    ------+------>|   Array   |--------------->|           |              |                         | Output                   
          |       |    Unit   |                |   Mult    |-----+------->|   Vector Sum Reduction  |------->                        
          |       |           |      +-------->|           |     |        |                         |                  
          |       +-----------+      |         |           |     |        +-------------------------+            
          |             |            |         +-----------+     |                    
          +-------------|------------+                           |       
                       \|/                                       |       
                  +-----------+                                  |       
                  |           |                +-----------+     |                    
 Column 1[1]      |  Systolic | Output count   |           |     |                                
    ------+------>|   Array   |--------------->|           |     |                             
          |       |    Unit   |                |   Mult    |-----+                         
          |       |           |      +-------->|           |     |                          
          |       +-----------+      |         |           |     |                    
          |             |            |         +-----------+     |                     
          +-------------|------------+                           |       
                       \|/                                       |       
                                                                 |
                   ... ... ...                                   |
                                                                 |
                        |                                        |        
                        |                                        |       
                       \|/                                       |       
                  +-----------+                                  |       
                  |           |                +-----------+     |                    
 Column 1[1000]   |  Systolic | Output count   |           |     |                                
    ------+------>|   Array   |--------------->|           |     |                             
          |       |    Unit   |                |   Mult    |-----+                         
          |       |           |      +-------->|           |                               
          |       +-----------+      |         |           |                         
          |                          |         +-----------+                          
          +--------------------------+                                  
