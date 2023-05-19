# Scoreboard:
### We have 4 different Scoreboards:
1. AXI_Req_Scoreboard : It checks the request packet at the AXI_Req_Agent side.
2. AXI_Rsp_Scoreboard : It checks the response packet at the AXI_Rsp_Agent side.
3. HMC_Mem_Scoreboard : It checks the request & response packet at the HMC_Mem_Agent side.
4. HMC_Scoreboard     : It compare between the request packet at AXI_Req_Agent & HMC_Mem_Agent sides, As well as the response packet at AXI_Rsp_Agent & HMC_Mem_Agent sides.
