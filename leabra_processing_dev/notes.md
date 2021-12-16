# Notes
* 2021-12-13 
   * TODO add STN population: full projection to GPi and to GPe; random weights from dACC when added; random weights to GPe and GPi?
   * what should the behaviour of the GPe be? If D2 pathway inhibits everything that is -not- the chosen behaviour, then GPe should maybe have an inhibt output to STN for the chosen behaviour, which makes STN excite inhibition for all except chosen in GPi

## Inputs per task
### Stop signal task
1. ctx: 001 pos: 01 shp:1000 color:0100 num:0000 out:01 // right arrow
1. ctx: 001 pos: 10 shp:0100 color:0100 num:0000 out:10 // left arrow
1. ctx: 001 pos: 00 shp:0010 color:1000 num:0000 out:11 // stop sign -> conflict/"danger" signal activates dACC and STN

### Demand selection task
**Select stack**
1. ctx: 010 pos: 01 shp:1000 color:0100 num:0000 // choose stack attention to right
1. ctx: 010 pos: 10 shp:1000 color:0001 num:0000 // choose stack attention to left

NB: note that some value need to degrade to make more costly choice less likely

**Do numerical task**

Nb: repeating the same task should make it prepotent, such that effortful inhibition is necessary when task changes (cued by color change) 

Nb: May need temporal context here so not mix up choosing stack and doing task 

**Even number**
1. ctx: 010 pos: 10 shp:1000 color:1000 num:1000000000 out: 1000 // do num task: even num?
1. ctx: 010 pos: 10 shp:1000 color:1000 num:0010000000 out: 1000 -> 
1. ctx: 010 pos: 10 shp:1000 color:1000 num:0000100000 out: 1000
1. ctx: 010 pos: 10 shp:1000 color:1000 num:0000001000 out: 1000
1. ctx: 010 pos: 10 shp:1000 color:1000 num:0000000010 out: 1000
1. ctx: 010 pos: 10 shp:1000 color:1000 num:0100000000 out: 0100
1. ctx: 010 pos: 10 shp:1000 color:1000 num:0001000000 out: 0100
1. ctx: 010 pos: 10 shp:1000 color:1000 num:0000010000 out: 0100
1. ctx: 010 pos: 10 shp:1000 color:1000 num:0000000100 out: 0100
1. ctx: 010 pos: 10 shp:1000 color:1000 num:0000000001 out: 0100

**Less than 5?**
1. ctx: 010 pos: 10 shp:1000 color:0010 num:1000000000 out: 0100 // < 5?
1. ctx: 010 pos: 10 shp:1000 color:0010 num:0100000000 out: 0100
1. ctx: 010 pos: 10 shp:1000 color:0010 num:0010000000 out: 0100
1. ctx: 010 pos: 10 shp:1000 color:0010 num:0001000000 out: 0100
1. ctx: 010 pos: 10 shp:1000 color:0010 num:0000010000 out: 1000
1. ctx: 010 pos: 10 shp:1000 color:0010 num:0000001000 out: 1000
1. ctx: 010 pos: 10 shp:1000 color:0010 num:0000000100 out: 1000
1. ctx: 010 pos: 10 shp:1000 color:0010 num:0000000010 out: 1000
1. ctx: 010 pos: 10 shp:1000 color:0010 num:0000000001 out: 1000

### Wisconsin task
1. ctx: 100 pos: 00 shp:1000 color:0100 num:0000
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[1, 0, 0, 0] num:[1, 0, 0, 0] out: ---- // output dept on last rewarded attention target (matching rule)
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[1, 0, 0, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[1, 0, 0, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[1, 0, 0, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 1, 0, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 1, 0, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 1, 0, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 1, 0, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 0, 1, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 0, 1, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 0, 1, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 0, 1, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 0, 0, 1] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 0, 0, 1] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 0, 0, 1] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[1, 0, 0, 0] color:[0, 0, 0, 1] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[1, 0, 0, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[1, 0, 0, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[1, 0, 0, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[1, 0, 0, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 1, 0, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 1, 0, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 1, 0, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 1, 0, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 0, 1, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 0, 1, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 0, 1, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 0, 1, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 0, 0, 1] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 0, 0, 1] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 0, 0, 1] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 1, 0, 0] color:[0, 0, 0, 1] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[1, 0, 0, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[1, 0, 0, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[1, 0, 0, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[1, 0, 0, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 1, 0, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 1, 0, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 1, 0, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 1, 0, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 0, 1, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 0, 1, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 0, 1, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 0, 1, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 0, 0, 1] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 0, 0, 1] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 0, 0, 1] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 1, 0] color:[0, 0, 0, 1] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[1, 0, 0, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[1, 0, 0, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[1, 0, 0, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[1, 0, 0, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 1, 0, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 1, 0, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 1, 0, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 1, 0, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 0, 1, 0] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 0, 1, 0] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 0, 1, 0] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 0, 1, 0] num:[0, 0, 0, 1] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 0, 0, 1] num:[1, 0, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 0, 0, 1] num:[0, 1, 0, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 0, 0, 1] num:[0, 0, 1, 0] out: 
1. ctx: 100 pos: 00  shp:[0, 0, 0, 1] color:[0, 0, 0, 1] num:[0, 0, 0, 1] out: 