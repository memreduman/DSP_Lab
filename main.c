// Emre DUMAN
// Yes or no detection
//
//

#include<stdbool.h>

#include "audio.h"
#include "HP_c.h"
#include "LP_c.h"

#define lowerboundry_NO	305.5005
#define lowerboundry_YES 0.9978
#define upperboundry_NO 3657.042759504685
#define upperboundry_YES 176.4687

#define Fs	24000
#define two_SECONDS_OF_LOOPS (Fs*2)/DMA_BUFFER_SIZE
#define one_SECONDS_OF_LOOPS (Fs*2)/DMA_BUFFER_SIZE
//#define N (DMA_BUFFER_SIZE)

float32_t Lbuffer[DMA_BUFFER_SIZE],y_HP[DMA_BUFFER_SIZE],y_LP[DMA_BUFFER_SIZE];
float32_t Rbuffer[DMA_BUFFER_SIZE];


void firFloat( float32_t *coeffs, float32_t *input, float32_t *output,
       int length, int filterLength )
{
    float32_t acc;     // accumulator for MACs
    float32_t *coeffp; // pointer to coefficients
    float32_t *inputp; // pointer to input samples
    int n;
    int k;
		float32_t insamp[ filterLength - 1 + length ];
    // put the new samples at the high end of the buffer
    memcpy( &insamp[filterLength - 1], input,
            length * sizeof(double) );

    // apply the filter to each input sample
    for ( n = 0; n < length; n++ ) {
        // calculate output n
        coeffp = coeffs;
        inputp = &insamp[filterLength - 1 + n];
        acc = 0;
        for ( k = 0; k < filterLength; k++ ) {
            acc += (*coeffp++) * (*inputp--);
        }
        output[n] = acc;
    }
    // shift input samples back in time for next time
    memmove( &insamp[0], &insamp[length],
            (filterLength - 1) * sizeof(double) );

}

void DMA_HANDLER (void)  /****** DMA Interruption Handler*****/
{
      if (dstc_state(0)){ //check interrupt status on channel 0

					if(tx_proc_buffer == (PONG))
						{
						dstc_src_memory (0,(uint32_t)&(dma_tx_buffer_pong));    //Soucrce address
						tx_proc_buffer = PING; 
						}
					else
						{
						dstc_src_memory (0,(uint32_t)&(dma_tx_buffer_ping));    //Soucrce address
						tx_proc_buffer = PONG; 
						}
				tx_buffer_empty = 1;                                        //Signal to main() that tx buffer empty					
       
				dstc_reset(0);			                                        //Clean the interrup flag
    }
    if (dstc_state(1)){ //check interrupt status on channel 1

					if(rx_proc_buffer == PONG)
					  {
						dstc_dest_memory (1,(uint32_t)&(dma_rx_buffer_pong));   //Destination address
						rx_proc_buffer = PING;
						}
					else
						{
						dstc_dest_memory (1,(uint32_t)&(dma_rx_buffer_ping));   //Destination address
						rx_proc_buffer = PONG;
						}
					rx_buffer_full = 1;   
						
				dstc_reset(1);		
    }
}

void proces_buffer(void) 
{
  int ii;
  uint32_t *txbuf, *rxbuf;

  if(tx_proc_buffer == PING) txbuf = dma_tx_buffer_ping; 
  else txbuf = dma_tx_buffer_pong; 
  if(rx_proc_buffer == PING) rxbuf = dma_rx_buffer_ping; 
  else rxbuf = dma_rx_buffer_pong; 
	
	/************************This block does the processing ***************/
	
  for(ii=0; ii<DMA_BUFFER_SIZE ; ii++)
  {
			//Process
		audio_IN = rxbuf[ii]; //audio_IN is static volatile int32_t audio_IN  defined in audio.h
		//split the channels
		Lbuffer[ii]=0*(float32_t)(audio_IN & 0x0000FFFF);  //I've multipled by 0 here so don't use the left channel
		Rbuffer[ii]=(float32_t) ((audio_IN >>16)& 0x0000FFFF);
	}
	
	//LBuffer & RBuffer now contain 128 values of the audio data each and we can do what we want with them here.
	
	firFloat(HP_h,Rbuffer,y_HP,DMA_BUFFER_SIZE,N_HP); //Apply high-pass filter and save output to the Y_HP array
	firFloat(LP_h,Rbuffer,y_LP,DMA_BUFFER_SIZE,N_LP); //Apply low-pass filter and save output to the Y_LP array
	
	/*
	//now lets put the audio back into the buffer
	for(ii=0; ii<DMA_BUFFER_SIZE ; ii++)
    {
			txbuf[ii]=( (Rbuffer[ii]<<16 & 0xFFFF0000) + ((Lbuffer[ii]) & 0x0000FFFF));
	
	}
	*/
	/*************** End of the processing block ****************************************/
	  tx_buffer_empty = 0;
    rx_buffer_full = 0;
	}


float32_t	sum_power(float32_t *input_array,uint16_t size){
	float32_t sum_power=0;
	for(int i=0; i<size;i++){
		sum_power += input_array[i];
	}
	return sum_power;
}
	
	int main (void) {    //Main function

   init_LED();
   gpio_set(LED_B, HIGH);
   gpio_set(LED_R, HIGH);
   gpio_set(LED_G, HIGH);
   gpio_set_mode(BUTTON,Input);
   long int counter=0;
   bool flag=false;
	 float32_t input_ratio=0;
	 float32_t total_sum_HP=0;
	 float32_t total_sum_LP=0;
		
   audio_init (hz24000, mic_in, dma, DMA_HANDLER);
	 while(1){
	
		if(!gpio_get(BUTTON)){
			gpio_set(LED_R, LOW); //turn on the red light
			flag = true; // start recording
		}
		
		if(flag)
		{
			for(counter=0;counter<two_SECONDS_OF_LOOPS;counter++)
			{
				//process
				while (!(rx_buffer_full && tx_buffer_empty)){}; // wait until buffers are full
				proces_buffer(); // do filtering
				total_sum_LP += sum_power(y_LP,DMA_BUFFER_SIZE); // accumulate the powers of LP
				total_sum_HP += sum_power(y_HP,DMA_BUFFER_SIZE); // accumulate the powers of HP
				
			}
			gpio_set(LED_R, HIGH); // turn off the red light
			flag = false; // stop recording audio
			//Check the input YES or NO according to boundaries
			input_ratio = total_sum_LP/total_sum_HP;
			
			if  (( input_ratio >= lowerboundry_YES ) && ( input_ratio <= upperboundry_YES ))
			{
				// YES IS DETECTED
				//Turn on the leds according to result and flash them for 1 sn
				gpio_set(LED_G, LOW);
				delay_ms(1000);
				gpio_set(LED_G, HIGH);
			}
			else if(( input_ratio >= lowerboundry_NO ) && ( input_ratio <= upperboundry_NO ))
			{
				// NO IS DETECTED
				//Turn on the leds according to result and flash them for 1 sn
				gpio_set(LED_B, LOW);
				delay_ms(1000);
				gpio_set(LED_B, HIGH);
			}
			
			
		}
	 }
}


