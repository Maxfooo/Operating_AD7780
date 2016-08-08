

#ifndef SERIAL_RATE
#define SERIAL_RATE         115200
#endif

#ifndef SERIAL_TIMEOUT
#define SERIAL_TIMEOUT      5
#endif

#ifndef GAIN_SETTING
#define GAIN_SETTING 1
#endif 

#ifndef FILTER_SETTING
#define FILTER_SETTING 0
#endif 

#ifndef DATA_WIDTH
#define DATA_WIDTH 32
#endif 

#ifndef POWER_UP_TIME
#define POWER_UP_TIME 1
#endif 

#ifndef READ_DATA_HALF_PERIOD
#define READ_DATA_HALF_PERIOD 2
#endif 

#ifndef DAC_SETTLE_TIME
#define DAC_SETTLE_TIME 1
#endif 

#ifndef MAX_DAC_CODE
#define MAX_DAC_CODE 4096
#endif 

#ifndef MAX_SAMPLES
#define MAX_SAMPLES 10
#endif 

// ADC pins
int gain_pin = 7;
int dout_pin = 6;
int sclk_pin = 5;
int filter_pin = 4;
int npdrst_pin = 3;

// Start DAQ pins
int triggerNC = 52; // trigger next code pin
unsigned int dac_code = 0;
unsigned int nReady = 1;
unsigned int adc_word = 0;
unsigned int adc_word_buffer[MAX_SAMPLES];
unsigned int adc_value = 0;
unsigned long adc_average = 0;
unsigned int adc_psw = 0;
unsigned int current_sample = 0;
unsigned int conversionDone = 1;
