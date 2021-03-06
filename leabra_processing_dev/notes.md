# Notes
* 2022-01-13
    * note: also possible to use Connection<Layer>, but this would be large diff
    * note: could also use interface "Connectable" so unit, connection, 
    * changes to implement Link inheritance system and DendriteConnection, ReservoirConnection:
        1. add Connection::add_inhibitory() # note no inh for reservoirs
        1. add Connection::add_excitatory() # note no exc for dendrite conn
        1. add to Connection: avg_s_eff, avg_m
        1. OR add avg_s_eff, avg_m to base class
        1. OR use accessors and interfaces instead of direct access: 
            link.post.avg_m -> link.post().avg_m(), Link as interface
        1. AbstractLink -> Link
        1. Link -> UnitLink
        1. Connection -> LayerConnection
        1. Connection as abstract base class w/o pre post layers
* 2022-01-11
    * Could population coding be used to recruit units?
    * D1 receptors: < 500nM; D2 receptors > 1000nM
* 2022-01-09
    * Adeno receptors can modulate presynaptic axon alone, but interacts with dopa receptors on postsynaptic dendrite (ref in Preedy 2017)
    * perhaps add support for "Reservoir" that may be connected to, and can connect to layers/units, and that simulates non-synaptic modulatory inputs -> dopa, 5HT, norad, adeno, 
    * Reservoir may inherit or consists of LeakyIntegrator, but have support for ReservoirSpec in spirit of Leabra framework; network stores reservoirs and cycles them
* 2022-01-07
    * TODO check Andre 2019 for hints on how dACC recruits more units
    * TODO what more is needed now to assemble decision demand model?
    * TODO test partial connection 
        1. with default standard - appears ok
        1. with partial - ok
    * #note - merely creating a connection will affect layer activity, even if the connection is not added to the network. This appears to be due to accessing connections in the network.build() method. This appears also to affect order of activation (since no explicit dealy is set on connections)
* 2022-01-06
   * todo: develop compensatory recruitment of extra units when existing units lose efficacy due to adenosine induced threshold increase
   * perhaps add optional index limits to connection, so can partially connect two populations: from_ix, to_ix, where default is full connection
* 2022-01-05
   * #puzzle: see that weights saturate for random associator test, and do not get less than 4.0 in error (ie all hots are wrong). In python impl can get less than 2 in error after 100 steps
* 2022-01-02
   * Can isolate larger parts of network like BG by implementing an interface with following methods:
      * getinputlayer -> Layer
      * getoutputlayer -> Layer
      * getLayers -> Layer[]
      * getConnections -> Connection[]
* 2022-01-01
   * TODO: mechanism that adapts weights of D1 D2 pathways based on cost, gains (in example tasks, mostly costs are involved, but Wisconsin task uses reward to change rule/a cost to inhibit a rule)
   * perhaps also add weights for dopa, adeno?
   * TODO: add support for dopa, adeno leaky integrators; perhaps impl connection from leaky integrator to layer, and that network stores list of leaky integrators that are cycled?
   * concept of bias modulation via dendrite APs is also a potential mechanism for context selection and sensitive to alpha, beta frequencies (slow alpha inhibits, faster beta excites)
* 2021-12-30
   * to test: make a unitspec that can modulate bias and or leakage based on input activity. This can model differential activation of populations by means of alpha, beta bursts. If possible, change weights on recurrent connections, and perhaps combine with very low leakage to model self-sustaining behaviour
   * check literature for what is plausible mechanisms: leakage, bias modulation 
* 2021-12-29
   * alternative to using unit-dendrite connection to change current rule (if no evidence for this, get problem)
      * context prediction error in pfc drives triggering of context change by means of BG initiated inhibition of current rule and excitation of new rule (Wascom, Frank 2017); dACC and ant. insula excites inh, excitation (or excitement of VTA to induce dopa to BG go, pfc effector pops)
      * when new rule established, this also changes the population representing contex, thus inh the prediction error
* 2021-12-28
   * to use unit-dendrite connection, have to implement:
      * DendriteLink extends Link
      * UnitLink extends Link
      * DendriteConnectionSpec extends ConnectionSpec
      * UnitConnectionSpec extends ConnectionSpec
* 2021-12-19
   * if model D2 mech. it could be due to pfc pushing up SNc activity transiently to activate D2 receptors on inh neurons/other neurons that sustain activity; this pfc activity should then be effortful (and perhaps require glut. excitation via ACC)
   * also need pathway that can detect the -change- from current ctx to new ctx, and thus initiate and sustain the necessary activity to reduce difference/error
* 2021-12-13 
   * TODO add STN population: full projection to GPi and to GPe; random weights from dACC when added; random weights to GPe and GPi?
   * what should the behaviour of the GPe be? If D2 pathway inhibits everything that is -not- the chosen behaviour, then GPe should maybe have an inhibt output to STN for the chosen behaviour, which makes STN excite inhibition for all except chosen in GPi

## Inputs per task
size of input vector: 3 2 2 4 4 10 2 -> 27
### Stop signal task
1. ctx: 001 tctx: 00 pos: 01 shp:1000 color:0100 num:0000 out:01 // right arrow
1. ctx: 001 tctx: 00 pos: 10 shp:0100 color:0100 num:0000 out:10 // left arrow
1. ctx: 001 tctx: 00 pos: 00 shp:0010 color:1000 num:0000 out:11 // stop sign -> conflict/"danger" signal activates dACC and STN

### Demand selection task
**Select stack**
1. ctx: 010 tctx:10 pos: 01 shp:1000 color:0100 num:0000 // choose stack attention to right
1. ctx: 010 tctx:10 pos: 10 shp:1000 color:0001 num:0000 // choose stack attention to left

NB: use tctx (temporal context) to differentiate between selecting stacks and selecting yes, no on task
NB: note that some value need to degrade to make more costly choice less likely

**Do numerical task**

Nb: repeating the same task should make it prepotent, such that effortful inhibition is necessary when task changes (cued by color change) 

Nb: May need temporal context here so not mix up choosing stack and doing task 

**Even number**
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:1000000000 out: 1000 // do num task: even num?
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:0010000000 out: 1000 -> 
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:0000100000 out: 1000
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:0000001000 out: 1000
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:0000000010 out: 1000
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:0100000000 out: 0100
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:0001000000 out: 0100
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:0000010000 out: 0100
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:0000000100 out: 0100
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:1000 num:0000000001 out: 0100

**Less than 5?**
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:0010 num:1000000000 out: 0100 // < 5?
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:0010 num:0100000000 out: 0100
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:0010 num:0010000000 out: 0100
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:0010 num:0001000000 out: 0100
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:0010 num:0000010000 out: 1000
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:0010 num:0000001000 out: 1000
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:0010 num:0000000100 out: 1000
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:0010 num:0000000010 out: 1000
1. ctx: 010 tctx: 01 pos: 10 shp:1000 color:0010 num:0000000001 out: 1000

### Wisconsin task
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0100 num:0000 fb:00
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:1000 num:1000 fb:00 out: ---- // output dept on last rewarded attention target (matching rule)
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:1000 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:1000 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:1000 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0100 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0100 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0100 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0100 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0010 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0010 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0010 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0010 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0001 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0001 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0001 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:1000 color:0001 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:1000 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:1000 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:1000 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:1000 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0100 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0100 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0100 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0100 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0010 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0010 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0010 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0010 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0001 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0001 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0001 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0100 color:0001 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:1000 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:1000 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:1000 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:1000 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0100 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0100 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0100 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0100 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0010 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0010 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0010 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0010 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0001 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0001 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0001 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0010 color:0001 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:1000 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:1000 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:1000 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:1000 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0100 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0100 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0100 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0100 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0010 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0010 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0010 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0010 num:0001 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0001 num:1000 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0001 num:0100 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0001 num:0010 fb:00 out: 
1. ctx: 100 tctx: 00 pos: 00 shp:0001 color:0001 num:0001 fb:00 out: 