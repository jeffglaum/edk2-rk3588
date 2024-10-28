
#include "AcpiTables.h"

// Trackpad
Device (TCPD)
{
  Name (_HID, "MSHW0238") 
  Name (_CID, "PNP0C50") 
  Name (_UID, 1) 
  Name (_DEP, Package() 
  {
    \_SB.GPI2,
    \_SB.I2C1,
  })
  
  Method(_CRS, 0x0, NotSerialized)
  {
    Name (RBUF, ResourceTemplate ()
    {
      // OrangePi-5: I2C1_SCL_M4 (pin 18) = Elan SCL, I2C1_SDA_M4 (pin 16) = Elan SDA
      // Elan: I2C slave address 0x15 (7-bit mode), max speed 400 kbit/s
      I2CSerialBus(0x15, ControllerInitiated, 400000, AddressingMode7Bit, "\\_SB.I2C1",,,,)
      // OrangePi-5: GPIO2_D4 / gpio2_port[28] (pin 22) = Elan GPIO/INT
      GpioInt(Edge, ActiveLow, ExclusiveAndWake, PullUp, 0, "\\_SB.GPI2", ,) {GPIO_PIN_PD4}  
    })
    Return(RBUF)
  }


  Method (_DSM, 0x4, Serialized)
  {
    // ACPI DSM UUID for HIDI2C
    If (Arg0 == ToUUID("3CDFF6F7-4267-4555-AD05-B30A3D8938DE"))
    {
      // Function 0: Query function, return based on revision
      If (Arg2 == 0)
      {
        // DSM Revision
        If (Arg1 == 1)
        {
          // Revision 1: Function 1 supported
          Return(Buffer(One) { 0x03 })  // indicates supports Function index 1
        }
      }
      // Function 1 : HID Function
      ElseIf (Arg2 == 1)
      {
        // HID Descriptor Address.
        Return(0x0000)
      }
    }

    // No other GUIDs supported
    Return(Buffer(One) { 0x00 })
  }
} //end of TCPD device