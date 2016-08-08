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
const unsigned long DATA_LOG_DELAY = 50; // ms - milliseconds
const unsigned long READ_DATA_HALF_PERIOD = 2; // us - microsecond
const unsigned long DAC_SETTLE_TIME = 1; // us - microsecond

const unsigned int MAX_DAC_CODE = 4095;
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
int triggerNC = 52;

// Indicator
int led = 13;


unsigned int dac_code = MAX_DAC_CODE;
unsigned int dac_code_ff = 0;
unsigned int nReady = 1;
unsigned int adc_word = 0;
unsigned int adc_word_buffer[MAX_SAMPLES];
unsigned int adc_value = 0;
unsigned int adc_psw = 0;

void setup()
{
  Serial.begin(115200);
  
  pinMode(gain_pin, OUTPUT);
  pinMode(dout_pin, INPUT);
  pinMode(sclk_pin, OUTPUT);
  pinMode(filter_pin, OUTPUT);
  pinMode(npdrst_pin, OUTPUT);

  pinMode(n_pin, INPUT);
  
  pinMode(led, OUTPUT);
  
  pinMode(triggerNC, OUTPUT);
  
  digitalWrite(npdrst_pin, HIGH);
  digitalWrite(gain_pin, GAIN_SETTING);
  digitalWrite(filter_pin, FILTER_SETTING); 
}


void loop()
{
        
        startConversion = digitalRead(n_pin);
        if (startConversion == 1 && startConversionFF == 0) // Reset
	{
                startConversionFF = 1;
		dac_code = 0;
                dac_code_ff = 0;
                digitalWrite(led, HIGH);
	}
	
	while (dac_code < MAX_DAC_CODE)
	{
		  digitalWrite(npdrst_pin, HIGH);
		
		  for (int i = 0; i < MAX_SAMPLES; i++)
		  {
		  	adc_word_buffer[i] = operate_adc(dac_code);
		  }
		
		  digitalWrite(npdrst_pin, LOW);
                  
                  
                  for (int i = 0; i < MAX_SAMPLES; i++)
		  {
		  	adc_value = (adc_word_buffer[i] >> 8);
	                adc_psw = adc_word_buffer[i] & 0x000000FF;
	                print_adc_data(dac_code, adc_value, adc_psw);
                        delay(DATA_LOG_DELAY);
		  }

                  triggerNextCode();
                  dac_code++;
		  delayMicroseconds(DAC_SETTLE_TIME);
	}
        startConversionFF = 0;
        digitalWrite(led, LOW);

        
}

void triggerNextCode()
{
  digitalWrite(triggerNC, HIGH);
  delay(10);
  digitalWrite(triggerNC, LOW);
}

unsigned int operate_adc(unsigned int dac_code)
{
	while(nReady)
	{
		nReady = digitalRead(dout_pin);
	}
	nReady = 1;
	adc_word = read_adc();
        return adc_word;
        
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
        Serial.println("]#"); // Gobetweeno
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
