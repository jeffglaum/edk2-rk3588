
#include "AcpiTables.h"

// Trackpad
Device (TCPD)
{
  Name (_HID, "MSFT8000") 
  Name (_CID, "MSFT8000") 
  Name (_UID, 1) 
  Name (_DEP, Package() 
  {
    \_SB.GPI0,
    \_SB.I2C1,
  })
  
  Method(_CRS, 0x0, NotSerialized)
  {
    Name (RBUF, ResourceTemplate ()
    {
      // OrangePi-5: I2C1_SCL_M4 (pin 18) = Elan SCL, I2C1_SDA_M4 (pin 16) = Elan SDA
      // Elan: I2C slave address 0x15 (7-bit mode), max speed 400 kbit/s
      I2CSerialBus(0x15, ControllerInitiated, 400000, AddressingMode7Bit, "\\_SB.I2C1",,,,)
      // OrangePi-5: GPIO0_D4 (gpio0_port[28]) (pin 22) = Elan GPIO/INT
      GpioInt(Edge, ActiveLow, ExclusiveAndWake, PullUp, 0, "\\_SB.GPI0", ,) {GPIO_PIN_PD4}  
    })
    Return(RBUF)
  }
  
  Method(_DSM, 0x4, NotSerialized)
  {
    // DSM UUID
    If(LEqual(Arg0, ToUUID("3CDFF6F7-4267-4555-AD05-B30A3D8938DE")))
    {
      // Function 0 : Query Function
      If(LEqual(Arg2, Zero))
      {
        // Revision 1
        If(LEqual(Arg1, One))
        {
          Store ("Method _DSM Function Query", Debug)
          Return(Buffer(One) { 0x03 })
        }
      }
      // Function 1 : HID Function
      If(LEqual(Arg2, One))
      {
        Store ("Method _DSM Function HID", Debug)     
        // HID Descriptor Address
        Return(0x0001)
      }
    }
    Else
    {
       Return(Buffer(One) { 0x00 })
    }   
  }
  
} //end of TCPD device