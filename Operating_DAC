// DAC pins
int bit0 = 23;
int bit1 = 25;
int bit2 = 27;
int bit3 = 29;
int bit4 = 31;
int bit5 = 33;
int bit6 = 35;
int bit7 = 37;
int bit8 = 39;
int bit9 = 41;
int bit10 = 43;
int bit11 = 45;

// Trigger
int trigger_pin = 2;
int triggerIn = 0;
int triggerInFF = 0;

// DAC 
unsigned int max_dac_code = pow(2,24) - 1
unsigned int dac_code = 0;

void setup()
{
  pinMode(bit0, OUTPUT);
  pinMode(bit1, OUTPUT);
  pinMode(bit2, OUTPUT);
  pinMode(bit3, OUTPUT);
  pinMode(bit4, OUTPUT);
  pinMode(bit5, OUTPUT);
  pinMode(bit6, OUTPUT);
  pinMode(bit7, OUTPUT);
  pinMode(bit8, OUTPUT);
  pinMode(bit9, OUTPUT);
  pinMode(bit10, OUTPUT);
  pinMode(bit11, OUTPUT);
  
  pinMode(trigger_pin, INPUT);
  
  set_dac_code(dac_code);
  
}


void loop()
{
  triggerIn = digitalRead(trigger_pin);
  if(triggerIn == 1 && triggerInFF == 0)
  {
    triggerInFF = 1;
    dac_code++;
    if (dac_code < max_dac_code)
    {
      set_dac_code(dac_code);
    }
    else
    {
     dac_code = 0;
     set_dac_code(dac_code);
    }
  }
  
  if (triggerIn == 0)
  {
   triggerInFF = 0; 
  }
  
}

void set_dac_code(unsigned int dacCode)
{
	if((dacCode&0x001) ==0x001) digitalWrite(bit0, HIGH);
	else digitalWrite(bit0, LOW);

	if((dacCode&0x002) ==0x002) digitalWrite(bit1, HIGH);
	else digitalWrite(bit1, LOW);

	if((dacCode&0x004) ==0x004) digitalWrite(bit2, HIGH);
	else digitalWrite(bit2, LOW);

	if((dacCode&0x008) ==0x008) digitalWrite(bit3, HIGH);
	else digitalWrite(bit3, LOW);

	if((dacCode&0x010) ==0x010) digitalWrite(bit4, HIGH);
	else digitalWrite(bit4, LOW);

	if((dacCode&0x020) ==0x020) digitalWrite(bit5, HIGH);
	else digitalWrite(bit5, LOW);

	if((dacCode&0x040) ==0x040) digitalWrite(bit6, HIGH);
	else digitalWrite(bit6, LOW);

	if((dacCode&0x080) ==0x080) digitalWrite(bit7, HIGH);
	else digitalWrite(bit7, LOW);

	if((dacCode&0x100) ==0x100) digitalWrite(bit8, HIGH);
	else digitalWrite(bit8, LOW);

	if((dacCode&0x200) ==0x200) digitalWrite(bit9, HIGH);
	else digitalWrite(bit9, LOW);

	if((dacCode&0x400) ==0x400) digitalWrite(bit10, HIGH);
	else digitalWrite(bit10, LOW);

	if((dacCode&0x800) ==0x800) digitalWrite(bit11, HIGH);
	else digitalWrite(bit11, LOW);
}
