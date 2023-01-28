# DHCP Discover

### Frame 1 - DHCP Discover

```
0000   ff ff ff ff ff ff dc a6 32 ec fc 3c 08 00 45 00   ........2..<..E.
0010   01 5e 50 6c 00 00 40 11 29 24 00 00 00 00 ff ff   .^Pl..@.)$......
0020   ff ff 00 44 00 43 01 4a 6f ca 01 01 06 00 d0 e3   ...D.C.Jo.......
0030   49 7c 00 00 00 00 00 00 00 00 00 00 00 00 00 00   I|..............
0040   00 00 00 00 00 00 dc a6 32 ec fc 3c 00 00 00 00   ........2..<....
0050   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0060   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0070   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0080   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0090   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00a0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00b0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00c0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00d0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00e0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00f0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0100   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0110   00 00 00 00 00 00 63 82 53 63 35 01 01 37 0e 01   ......c.Sc5..7..
0120   03 2b 3c 42 43 80 81 82 83 84 85 86 87 3c 20 50   .+<BC........< P
0130   58 45 43 6c 69 65 6e 74 3a 41 72 63 68 3a 30 30   XEClient:Arch:00
0140   30 30 30 3a 55 4e 44 49 3a 30 30 32 30 30 31 5d   000:UNDI:002001]
0150   02 00 00 5e 03 01 02 01 61 11 00 52 50 69 34 30   ...^....a..RPi40
0160   31 c0 00 32 ec fc 3c da 06 ff e0 ff               1..2..<.....



Dynamic Host Configuration Protocol (Discover)
    Message type: Boot Request (1)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0xd0e373b8
    Seconds elapsed: 0
    Bootp flags: 0x0000 (Unicast)
        0... .... .... .... = Broadcast flag: Unicast
        .000 0000 0000 0000 = Reserved flags: 0x0000
    Client IP address: 0.0.0.0
    Your (client) IP address: 0.0.0.0
    Next server IP address: 0.0.0.0
    Relay agent IP address: 0.0.0.0
    Client MAC address: Raspberr_ec:fc:3c (dc:a6:32:ec:fc:3c)
    Client hardware address padding: 00000000000000000000
    Server host name not given
    Boot file name not given
    Magic cookie: DHCP
    Option: (53) DHCP Message Type (Discover)
        Length: 1
        DHCP: Discover (1)
    Option: (55) Parameter Request List
        Length: 14
        Parameter Request List Item: (1) Subnet Mask
        Parameter Request List Item: (3) Router
        Parameter Request List Item: (43) Vendor-Specific Information
        Parameter Request List Item: (60) Vendor class identifier
        Parameter Request List Item: (66) TFTP Server Name
        Parameter Request List Item: (67) Bootfile name
        Parameter Request List Item: (128) DOCSIS full security server IP [TODO]
        Parameter Request List Item: (129) PXE - undefined (vendor specific)
        Parameter Request List Item: (130) PXE - undefined (vendor specific)
        Parameter Request List Item: (131) PXE - undefined (vendor specific)
        Parameter Request List Item: (132) PXE - undefined (vendor specific)
        Parameter Request List Item: (133) PXE - undefined (vendor specific)
        Parameter Request List Item: (134) PXE - undefined (vendor specific)
        Parameter Request List Item: (135) PXE - undefined (vendor specific)
    Option: (60) Vendor class identifier
        Length: 32
        Vendor class identifier: PXEClient:Arch:00000:UNDI:002001
    Option: (93) Client System Architecture
        Length: 2
        Client System Architecture: IA x86 PC (0)
    Option: (94) Client Network Device Interface
        Length: 3
        Major Version: 2
        Minor Version: 1
    Option: (97) UUID/GUID-based Client Identifier
        Length: 17
        Client Identifier (UUID): 34695052-3130-00c0-32ec-fc3cda06ffe0
    Option: (255) End
        Option End: 255
```

### Frame 2a - DHCP Offer - router

```
0000   bc d0 74 04 ce 3a b4 b0 24 55 fd b4 08 00 45 00   ..t..:..$U....E.
0010   01 48 a1 f9 00 00 40 11 51 f4 c0 a8 02 01 c0 a8   .H....@.Q.......
0020   02 66 00 43 00 44 01 34 d1 72 02 01 06 00 d0 e3   .f.C.D.4.r......
0030   73 b8 00 00 00 00 00 00 00 00 c0 a8 02 66 c0 a8   s............f..
0040   02 01 00 00 00 00 bc d0 74 04 ce 3a 00 00 00 00   ........t..:....
0050   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0060   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0070   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0080   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0090   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00a0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00b0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00c0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00d0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00e0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00f0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0100   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0110   00 00 00 00 00 00 63 82 53 63 35 01 02 36 04 c0   ......c.Sc5..6..
0120   a8 02 01 33 04 00 00 1c 20 3a 04 00 00 0e 10 3b   ...3.... :.....;
0130   04 00 00 18 9c 01 04 ff ff ff 00 1c 04 c0 a8 02   ................
0140   ff 03 04 c0 a8 02 01 ff 00 00 00 00 00 00 00 00   ................
0150   00 00 00 00 00 00                                 ......


Dynamic Host Configuration Protocol (Offer)
    Message type: Boot Reply (2)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0xd0e373b8
    Seconds elapsed: 0
    Bootp flags: 0x0000 (Unicast)
        0... .... .... .... = Broadcast flag: Unicast
        .000 0000 0000 0000 = Reserved flags: 0x0000
    Client IP address: 0.0.0.0
    Your (client) IP address: 192.168.2.102
    Next server IP address: 192.168.2.1
    Relay agent IP address: 0.0.0.0
    Client MAC address: Apple_04:ce:3a (bc:d0:74:04:ce:3a)
    Client hardware address padding: 00000000000000000000
    Server host name not given
    Boot file name not given
    Magic cookie: DHCP
    Option: (53) DHCP Message Type (Offer)
        Length: 1
        DHCP: Offer (2)
    Option: (54) DHCP Server Identifier (192.168.2.1)
        Length: 4
        DHCP Server Identifier: 192.168.2.1
    Option: (51) IP Address Lease Time
        Length: 4
        IP Address Lease Time: (7200s) 2 hours
    Option: (58) Renewal Time Value
        Length: 4
        Renewal Time Value: (3600s) 1 hour
    Option: (59) Rebinding Time Value
        Length: 4
        Rebinding Time Value: (6300s) 1 hour, 45 minutes
    Option: (1) Subnet Mask (255.255.255.0)
        Length: 4
        Subnet Mask: 255.255.255.0
    Option: (28) Broadcast Address (192.168.2.255)
        Length: 4
        Broadcast Address: 192.168.2.255
    Option: (3) Router
        Length: 4
        Router: 192.168.2.1
    Option: (255) End
        Option End: 255
    Padding: 0000000000000000000000000000
```

### Frame 2b - DHCP Offer - PXE server

```
0000   ff ff ff ff ff ff b8 27 eb 86 ab 24 08 00 45 c0   .......'...$..E.
0010   01 56 9b d2 00 00 40 11 1a 29 c0 a8 02 34 ff ff   .V....@..)...4..
0020   ff ff 00 43 00 44 01 42 69 8f 02 01 06 00 d0 e3   ...C.D.Bi.......
0030   73 b8 00 00 80 00 00 00 00 00 00 00 00 00 00 00   s...............
0040   00 00 00 00 00 00 dc a6 32 ec fc 3f 00 00 00 00   ........2..?....
0050   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0060   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0070   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0080   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0090   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00a0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00b0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00c0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00d0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00e0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00f0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0100   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0110   00 00 00 00 00 00 63 82 53 63 35 01 02 36 04 c0   ......c.Sc5..6..
0120   a8 02 34 3c 09 50 58 45 43 6c 69 65 6e 74 61 11   ..4<.PXEClienta.
0130   00 52 50 69 34 30 31 c0 00 32 ec fc 3c da 06 ff   .RPi401..2..<...
0140   e0 2b 20 06 01 03 0a 04 00 50 58 45 09 14 00 00   .+ ......PXE....
0150   11 52 61 73 70 62 65 72 72 79 20 50 69 20 42 6f   .Raspberry Pi Bo
0160   6f 74 ff ff                                       ot..


Dynamic Host Configuration Protocol (Offer)
    Message type: Boot Reply (2)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0xd0e373b8
    Seconds elapsed: 0
    Bootp flags: 0x8000, Broadcast flag (Broadcast)
    Client IP address: 0.0.0.0
    Your (client) IP address: 0.0.0.0
    Next server IP address: 0.0.0.0
    Relay agent IP address: 0.0.0.0
    Client MAC address: Raspberr_ec:fc:3f (dc:a6:32:ec:fc:3f)
    Client hardware address padding: 00000000000000000000
    Server host name not given
    Boot file name not given
    Magic cookie: DHCP
    Option: (53) DHCP Message Type (Offer)
        Length: 1
        DHCP: Offer (2)
    Option: (54) DHCP Server Identifier (192.168.2.52)
        Length: 4
        DHCP Server Identifier: 192.168.2.52
    Option: (60) Vendor class identifier
        Length: 9
        Vendor class identifier: PXEClient
    Option: (97) UUID/GUID-based Client Identifier
        Length: 17
        Client Identifier (UUID): 34695052-3130-00c0-32ec-fc3cda06ffe0
    Option: (43) Vendor-Specific Information (PXEClient)
        Length: 32
        Option 43 Suboption: (6) PXE discovery control
            Length: 1
            discovery control: 0x03, Disable Broadcast, Disable Multicast
                .... ...1 = Disable Broadcast: Set
                .... ..1. = Disable Multicast: Set
                .... .0.. = Serverlist only: Not set
                .... 0... = Bootstrap override: Not set
        Option 43 Suboption: (10) PXE menu prompt
            Length: 4
            menu prompt: 00505845
                Timeout: 0
                Prompt: PXE
        Option 43 Suboption: (9) PXE boot menu
            Length: 20
            boot menu: 00001152617370626572727920506920426f6f74
                Type: Local boot (0)
                Length: 17
                Description: Raspberry Pi Boot
        PXE Client End: 255
    Option: (255) End
        Option End: 255
```

### Frame 3a - DHCP Request - router

```
0000   ff ff ff ff ff ff dc a6 32 ec fc 3c 08 00 45 00   ........2..<..E.
0010   01 51 50 6e 00 00 40 11 29 2f 00 00 00 00 ff ff   .QPn..@.)/......
0020   ff ff 00 44 00 43 01 3d 0d 1d 01 01 06 00 d0 e3   ...D.C.=........
0030   73 b8 00 00 00 00 00 00 00 00 00 00 00 00 c0 a8   s...............
0040   02 01 00 00 00 00 dc a6 32 ec fc 3c 00 00 00 00   ........2..<....
0050   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0060   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0070   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0080   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0090   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00a0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00b0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00c0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00d0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00e0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
00f0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0100   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0110   00 00 00 00 00 00 63 82 53 63 35 01 03 32 04 c0   ......c.Sc5..2..
0120   a8 02 28 36 04 c0 a8 02 01 3c 20 50 58 45 43 6c   ..(6.....< PXECl
0130   69 65 6e 74 3a 41 72 63 68 3a 30 30 30 30 30 3a   ient:Arch:00000:
0140   55 4e 44 49 3a 30 30 32 30 30 31 61 11 00 52 50   UNDI:002001a..RP
0150   69 34 30 31 c0 00 32 ec fc 3c da 06 ff e0 ff      i401..2..<.....


Dynamic Host Configuration Protocol (Request)
    Message type: Boot Request (1)
    Hardware type: Ethernet (0x01)
    Hardware address length: 6
    Hops: 0
    Transaction ID: 0xd0e373b8
    Seconds elapsed: 0
    Bootp flags: 0x0000 (Unicast)
        0... .... .... .... = Broadcast flag: Unicast
        .000 0000 0000 0000 = Reserved flags: 0x0000
    Client IP address: 0.0.0.0
    Your (client) IP address: 0.0.0.0
    Next server IP address: 192.168.2.1
    Relay agent IP address: 0.0.0.0
    Client MAC address: Raspberr_ec:fc:3c (dc:a6:32:ec:fc:3c)
    Client hardware address padding: 00000000000000000000
    Server host name not given
    Boot file name not given
    Magic cookie: DHCP
    Option: (53) DHCP Message Type (Request)
        Length: 1
        DHCP: Request (3)
    Option: (50) Requested IP Address (192.168.2.40)
        Length: 4
        Requested IP Address: 192.168.2.40
    Option: (54) DHCP Server Identifier (192.168.2.1)
        Length: 4
        DHCP Server Identifier: 192.168.2.1
    Option: (60) Vendor class identifier
        Length: 32
        Vendor class identifier: PXEClient:Arch:00000:UNDI:002001
    Option: (97) UUID/GUID-based Client Identifier
        Length: 17
        Client Identifier (UUID): 34695052-3130-00c0-32ec-fc3cda06ffe0
    Option: (255) End
        Option End: 255
```
