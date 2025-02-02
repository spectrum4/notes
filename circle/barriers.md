0000000000084380 <CXHCIEndpoint::TransferAsync(CUSBRequest*, unsigned int)>:
   84514:   d5033f9f    dsb sy

0000000000092e50 <CXHCICommandManager::DoCommand(unsigned int, unsigned int, unsigned int, unsigned int, unsigned char*)>:
   92f34:   d5033f9f    dsb sy
   92f74:   d5033fbf    dmb sy

000000000009abb0 <CUSBSerialDevice::CompletionRoutine(CUSBRequest*)>:
   9ac04:   d5033f9f    dsb sy

00000000000a3a50 <CSerialDevice::~CSerialDevice()>:
   a3ab8:   d5033f9f    dsb sy

00000000000a70a0 <ChainBootStub(void const*, unsigned long)>:
   a70dc:   d5033f9f    dsb sy
   a70e0:   d5033fdf    isb

00000000000a70f0 <EnableChainBoot>:
   a7128:   d5033f9f    dsb sy
   a712c:   d5033fdf    isb

00000000000a82f0 <CMemorySystem::Destructor()>:
   a8328:   d5033f9f    dsb sy
   a832c:   d5033fdf    isb
   a833c:   d5033f9f    dsb sy
   a8340:   d5033fdf    isb

00000000000a8790 <InvalidateDataCache>:
   a88bc:   d5033f9f    dsb sy

00000000000a88d0 <InvalidateDataCacheL1Only>:
   a88f0:   d5033f9f    dsb sy

00000000000a8900 <CleanDataCache>:
   a8a2c:   d5033f9f    dsb sy

00000000000a8a40 <InvalidateDataCacheRange>:
   a8a70:   d5033f9f    dsb sy

00000000000a8a80 <CleanDataCacheRange>:
   a8ab0:   d5033f9f    dsb sy

00000000000a8ac0 <CleanAndInvalidateDataCacheRange>:
   a8af0:   d5033f9f    dsb sy

00000000000a8b00 <SyncDataAndInstructionCache>:
   a8b10:   d5033f9f    dsb sy
   a8b14:   d5033fdf    isb

0000000000084050 <CXHCIEndpoint::TransferEvent(unsigned char, unsigned int)>:
   8405c:   d5033fbf    dmb sy

0000000000084900 <CXHCIEndpoint::Transfer(CUSBRequest*, unsigned int)>:
   84998:   d5033fbf    dmb sy

00000000000932a0 <CXHCICommandManager::CommandCompleted(TXHCITRB*, unsigned char, unsigned char)>:
   932d0:   d5033fbf    dmb sy

000000000009a910 <CUSBSerialDevice::Read(void*, unsigned long)>:
   9a92c:   d5033fbf    dmb sy

00000000000a8670 <EnterCritical>:
   a86cc:   d5033fbf    dmb sy

00000000000a8730 <LeaveCritical>:
   a8730:   d5033fbf    dmb sy

00000000000a2ea0 <CSerialDevice::Initialize(unsigned int, unsigned int, unsigned int, CSerialDevice::TParity)>:
   a3028:   d5033f9f    dsb sy    // interrupt handling

00000000000a64a0 <CTimer::RegisterPeriodicHandler(void (*)())>:
   a64c8:   d5033f9f    dsb sy





000000000009cb70 <CBcmPropertyTags::GetTags(void*, unsigned int)>:
   9cc00:   d5033f9f    dsb sy
   9cc38:   d5033fbf    dmb sy

00000000000a55c0 <halt>:
   a55c8:   d5033f9f    dsb sy

00000000000a5980 <CTimer::GetClockTicks()>:
   a5980:   d5033fdf    isb

00000000000a6510 <CTimer::SimpleMsDelay(unsigned int)>:
   a6524:   d5033fdf    isb // just inlined from GetClockTicks
   a6540:   d5033fdf    isb // just inlined from GetClockTicks

00000000000a6570 <CTimer::SimpleusDelay(unsigned int)>:
   a6578:   d5033fdf    isb // just inlined from GetClockTicks
   a6598:   d5033fdf    isb // just inlined from GetClockTicks

00000000000a8e50 <CTranslationTable::CTranslationTable(unsigned long)>:
   a90d8:   d5033f9f    dsb sy





00000000000a12b0 <CScreenDevice::SetStatus(TScreenStatus const&)>:
   a1370:   d5033fbf    dmb sy

00000000000a2970 <CScreenDevice::Write(void const*, unsigned long)>:
   a29f0:   d5033fbf    dmb sy
   a2a2c:   d5033fbf    dmb sy

00000000000a39d0 <CSerialDevice::InterruptStub(void*)>:
   a39e0:   d5033fbf    dmb sy
