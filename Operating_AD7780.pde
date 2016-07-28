/*
EVAL board pin order (physically top to bottom)
LK10 = GAIN
LK9 = NC
LK8 = DOUT
LK7 = SCLK
LK6 = FILTER
LK11 = !PDRST

http://www.analog.com/media/en/technical-documentation/data-sheets/AD7780.pdf

http://www.analog.com/media/en/technical-documentation/evaluation-documentation/UG-078.pdf

*/

const unsigned char GAIN_SETTING = 1; // gain on chip = x1
const unsigned char FILTER_SETTING = 0; // fast settling filter
const unsigned char DATA_WIDTH = 32;
const unsigned long POWER_UP_TIME = 1; // ms - millisecond
const unsigned long POWER_DOWN_TIME = 1; // ms - millisecond
const unsigned long READ_DATA_HALF_PERIOD = 2; // us - microsecond
const unsigned long DAC_SETTLE_TIME = 1; // us - microsecond
const unsigned int MAX_DAC_CODE = 4096;
const unsigned int MAX_SAMPLES = 10;

// ADC pins
int gain_pin = 7;
int dout_pin = 6;
int sclk_pin = 5;
int filter_pin = 4;
int npdrst_pin = 3;

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

// Start DAQ pins
int n_pin = 84;
int startConversion = 0;
int startConversionFF = 0;


unsigned int dac_code = MAX_DAC_CODE;
unsigned int dac_code_ff = 0;
unsigned int nReady = 1;
unsigned int adc_word = 0;
unsigned int adc_value = 0;
unsigned int adc_psw = 0;

void setup()
{
  Serial.begin(9600);
  
  pinMode(gain_pin, OUTPUT);
  pinMode(dout_pin, INPUT);
  pinMode(sclk_pin, OUTPUT);
  pinMode(filter_pin, OUTPUT);
  pinMode(npdrst_pin, OUTPUT);
  
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


  pinMode(n_pin, INPUT);
  
  digitalWrite(npdrst_pin, HIGH);
  digitalWrite(gain_pin, GAIN_SETTING);
  digitalWrite(filter_pin, FILTER_SETTING); 
}


void loop()
{
        /*
	if (Serial.available() > 0)
	{
                char debug = Serial.read();
                Serial.print("Received: ");
                Serial.println(debug);
                if (debug == '+')
                {
                  digitalWrite(npdrst_pin, LOW);
                }
                else
                {
                
                  digitalWrite(npdrst_pin, HIGH); 
                  delay(POWER_UP_TIME);
                  //delay(FILTER_SETTLE_TIME);
                  
  		  operate_adc(0); // Debugging
                  Serial.println("\nEnded operate command");
                }
	}
        */

	/*
	if (Serial.available() > 0) // Reset
	{
		dac_code = 0;
                dac_code_ff = 0;
		set_dac_code(dac_code);
                
	}
        */
        startConversion = digitalRead(n_pin);
        if (startConversion == 1 && startConversionFF == 0) // Reset
	{
                startConversionFF = 1;
		dac_code = 0;
                dac_code_ff = 0;
		set_dac_code(dac_code);
	}
	
	while (dac_code < MAX_DAC_CODE)
	{
                if (Serial.available() > 0) // Exit
	        {
                  char entry = Serial.read();
                  if (entry == 'x') 
                  {
                   dac_code = MAX_DAC_CODE; 
                  }
                }
                else
                {
		  digitalWrite(npdrst_pin, HIGH);
		  //delay(POWER_UP_TIME);
		
		  for (int i = 0; i < MAX_SAMPLES; i++)
		  {
		  	operate_adc(dac_code);
		  }
		
		  digitalWrite(npdrst_pin, LOW);
		  //delay(POWER_DOWN_TIME);
		
		  set_dac_code(dac_code);
		  delayMicroseconds(DAC_SETTLE_TIME);
		
		  dac_code++;
                }
	}
        startConversionFF = 0;
	//
}

void operate_adc(unsigned int dac_code)
{
	while(nReady)
	{
		nReady = digitalRead(dout_pin);
	}
        //Serial.print("nReady: ");
        //Serial.println(nReady);
	nReady = 1;
	adc_word = read_adc();
	adc_value = (adc_word >> 8);
	adc_psw = adc_word & 0x000000FF;

        
	print_adc_data(dac_code, adc_value, adc_psw);
        
}

void print_adc_data(unsigned int dacCode, unsigned int adcValue, unsigned int adcPsw)
{        
	if (dacCode == 0 && dac_code_ff == 0)
	{
                Serial.print("#S|LOGDATA|["); // Gobetweeno
		Serial.print("DAC Code, ADC Value, PSW");
                Serial.println("]#"); // Gobetweeno
                dac_code_ff = 1;
	}
        Serial.print("#S|LOGDATA|["); // Gobetweeno
	Serial.print(dacCode);
	Serial.print(",");
	Serial.print(adcValue, BIN);
	Serial.print(",");
	Serial.print(adcPsw, BIN);
	//Serial.print("\n");
        Serial.println("]#"); // Gobetweeno
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

unsigned int read_adc()
{
	unsigned int data = 0;
	
	digitalWrite(sclk_pin, LOW);
	
	for(int i = 0; i < DATA_WIDTH; i++)
	{
		delayMicroseconds(READ_DATA_HALF_PERIOD);
		digitalWrite(sclk_pin, HIGH);
                
		data = data << 1;
                data = data | digitalRead(dout_pin);
		
                if (i < DATA_WIDTH - 1) // leave the clock high for the LSB of whole adc_word
                {
		  delayMicroseconds(READ_DATA_HALF_PERIOD);
		  digitalWrite(sclk_pin, LOW);
                }
	}
	

	return data; 
}
