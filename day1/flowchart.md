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


