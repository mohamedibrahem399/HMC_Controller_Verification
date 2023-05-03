This is the RF_Agent agent, which consists of ( Driver, Sequencer , Monitor ).

We extracted the signals of the register file from the top module and test the top module as a top module of the register file only.
If there is a signal that depends on other blocks, we set to it a fixed value .
This test is only to check whether the agent is ok or not, this is won't affect our work at all.
