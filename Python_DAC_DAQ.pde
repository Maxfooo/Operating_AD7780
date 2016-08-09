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

Serial communication code: vascop
Source: https://github.com/vascop/Python-Arduino-Proto-API-v2

*/


#include <Globals.h>
#include <String.h>

void setup()
{
 Serial.begin(SERIAL_RATE);
 Serial.setTimeout(SERIAL_TIMEOUT);
  
  pinMode(gain_pin, OUTPUT);
  pinMode(dout_pin, INPUT);
  pinMode(sclk_pin, OUTPUT);
  pinMode(filter_pin, OUTPUT);
  pinMode(npdrst_pin, OUTPUT);
  
  pinMode(triggerNC, OUTPUT);
  
  digitalWrite(npdrst_pin, HIGH);
  digitalWrite(gain_pin, GAIN_SETTING);
  digitalWrite(filter_pin, FILTER_SETTING); 
  
  zeroFillBuffer();
}

void loop()
{
  switch (readData()) 
  {
    /*******************************/
    // Test connection
    /*******************************/
    case 0:
      Serial.println("Connected");
      break;
    
    /*******************************/
    // Operate ADC
    /*******************************/
    case 1:
      if (dac_code >= MAX_DAC_CODE)
      {
       conversionDone = 1;
       Serial.println("Done");
      }
      else
      {
        conversionDone = 0;
        current_sample = 0;
        digitalWrite(npdrst_pin, HIGH);
        for (int i = 0; i < MAX_SAMPLES; i++)
        {
  	    adc_word_buffer[i] = operate_adc(dac_code);
        }
        digitalWrite(npdrst_pin, LOW);
      
        Serial.println("Converted");
        triggerNextCode();
        dac_code++;
      }
      
      break;
    
    /*******************************/
    // Transmit sample data
    /*******************************/    
    case 2: 
    
      if (current_sample >= MAX_SAMPLES)
      {
        Serial.println("NoSample");
      }
      else
      {
        adc_value = (adc_word_buffer[current_sample] >> 8);
	adc_psw = adc_word_buffer[current_sample] & 0x000000FF;
        current_sample++;
        print_adc_data(dac_code-1, adc_value, adc_psw);
      }
      
      break;
      
    /*******************************/
    // Reset
    /*******************************/
    case 3:
      conversionDone = 1;
      dac_code = 0;
      current_sample = 0;
      zeroFillBuffer();
      Serial.println("Reset");
      break;
      
    /*******************************/
    // Progress readback
    /*******************************/
    case 4:
      Serial.println(conversionDone);
      break;
    
    /*******************************/
    // Dummy (this needs to be here)
    /*******************************/
    case 99:
      break;
      
    default:
      Serial.println("Default");
      break;
      
    
  }
}

char readData() 
{
  Serial.println("w");
  while(1) {
      if(Serial.available() > 0) {
          return Serial.parseInt();
      }
  }
}

void triggerNextCode()
{
  digitalWrite(triggerNC, HIGH);
  delay(10);
  digitalWrite(triggerNC, LOW);
}

void print_adc_data(unsigned int dacCode, unsigned int adcValue, unsigned int adcPsw)
{        
        String dacCodeStr = String(dacCode);
        String adcValueStr = String(adcValue, BIN);
        String adcPswStr = String(adcPsw, BIN);
        String outStr = dacCodeStr + "," + adcValueStr + "," + adcPsw;
	Serial.println(outStr);
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

void zeroFillBuffer()
{
  for(int i = 0; i < MAX_SAMPLES; i++)
  {
   adc_word_buffer[i] = 0; 
  }
}
