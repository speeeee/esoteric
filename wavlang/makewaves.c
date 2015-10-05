#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

// data at byte 44.

void write_little_endian(unsigned int word, int num_bytes, FILE *wav_file)
{
    unsigned buf;
    while(num_bytes>0)
    {   buf = word & 0xff;
        //printf("%i,", buf);
        fwrite(&buf, 1,1, wav_file);
        num_bytes--;
    word >>= 8;
    }
}

int main(int argc, char **argv) {
  FILE *e; e = fopen("test-in.wav", "rb");
  fseek(e, 0, SEEK_END); long lsz = ftell(e);
  rewind(e); fseek(e, 44, SEEK_SET); short *buffer;
  buffer = malloc(sizeof(short)*(lsz-44)/2);
  size_t res = fread(buffer, 2, lsz, e);
  fclose(e); 

  FILE *f; f = fopen("test-out.wav", "w");
  fwrite("RIFF", 1, 4, f);
  write_little_endian(36 + 2*lsz, 4, f);
  fwrite("WAVE", 1, 4, f);

  fwrite("fmt ", 1, 4, f);
  write_little_endian(16, 4, f);  
  write_little_endian(1, 2, f);  
  write_little_endian(1, 2, f);
  write_little_endian(44100, 4, f);
  write_little_endian(88200, 4, f);
  write_little_endian(2, 2, f); 
  write_little_endian(16, 2, f); 

  float amplitude = 32000;
  float phase = 0;
  float nphase = 0;

  int *data = malloc(sizeof(int)*((lsz-44)/2));
  for(int i=0; i<(lsz-44)/2; i++) {
    //nphase += data[i] = asin(buffer[i+44]/amplitude); }
    float freq_radians_per_sample = asin(buffer[i]/amplitude)-phase; 
    float freq_Hz = freq_radians_per_sample*44100/(2*M_PI);
    float frpsn = (freq_Hz)*2*M_PI/44100; nphase += frpsn;
    phase += freq_Hz*2*M_PI/44100; data[i] = (int)(amplitude*sin(nphase)); }



  fwrite("data", 1, 4, f);
  write_little_endian(lsz, 4, f);
  for(int i=0; i<(lsz-44); i++) {
    write_little_endian((unsigned int)(data[i/2]),2,f); }
  fclose(f);

  return 0; }
