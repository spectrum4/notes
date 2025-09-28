Circle vs Spectrum4 XHCI / PCIe differences

Possible issues

1) Command TRB points to memory that is not in coherent region
2) Timing issue (spectrum4 not waiting somewhere)
3) Spectrum4 has enabled some power saving feature breaking stuff
4) Alignment issue
5) Error in command issued etc
6) Missing setup (e.g. of transfer ring)
7) Missing XHCI MMIO setup (e.g. during probe)
