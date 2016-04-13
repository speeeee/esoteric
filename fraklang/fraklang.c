#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

// WAV files only; assume data up to byte 44.

typedef struct { char *name; float freq; } note;
note pn[88] = { { "C4", 261.63 }, { "C4#", 277.18 }, { "D4", 293.66 },
                { "D4#", 311.13 }, { "E4", 329.63 }, { "F4", 349.23 },
                { "F4#", 369.99 }, { "G4", 392 }, { "G4#", 415.3 },
                { "A4", 440 }, { "A4#", 466.16 }, { "B4", 493.88 } };

void write_little_endian(unsigned int word, int num_bytes, FILE *wav_file) {
    unsigned buf;
    while(num_bytes>0) { buf = word & 0xff;
      fwrite(&buf, 1,1, wav_file);
      num_bytes--;
    word >>= 8; } }

void wav_header(FILE *f, int32_t sz, int16_t ch) {
  fwrite("RIFF", 1, 4, f); write_little_endian(36+sz, 4, f);
  fwrite("WAVE", 1, 4, f); fwrite("fmt ", 1, 4, f);
  write_little_endian(16, 4, f);  write_little_endian(1, 2, f);  
  write_little_endian(ch, 2, f); write_little_endian(44100, 4, f);
  write_little_endian((16*44100*ch)/8, 4, f); write_little_endian((16*ch)/8, 2, f); 
  write_little_endian(16, 2, f); 
  fwrite("data", 1, 4, f); write_little_endian(sz, 4, f); }

void out_buf(FILE *f, int16_t *buf, int32_t sz) {
  for(int i=0;i<sz-44;i++) { write_little_endian(buf[i],2,f); } } 

void sine_wave(int16_t *buf, int32_t len, int32_t pos, float freq, float ratio,
               float amp) {
  for(int i=pos; i<len; i++) { float tht = ((float)i/ratio) * M_PI;
    int16_t pt = (int16_t)(sin(tht*freq)*32767.f*amp);
    //if((int32_t)pt+(int32_t)buf[i]>=pow(2,16)/2) { buf[i] = 32766; }
    //else if((int32_t)pt+(int32_t)buf[i]<=-pow(2,16)/2) { buf[i] = -32766; }
    buf[i] = ((int32_t)buf[i]+(int32_t)pt)%32766; } }
    //else { buf[i] += (int16_t)(sin(tht*freq)*32767.f*amp); } } }

void add_waves(int16_t *buf, int32_t len, int32_t pos, float ratio, float *freqs,
               int amt) {
  for(int i=0;i<amt;i++) { sine_wave(buf,len,pos,freqs[i],ratio,1/(float)amt); } }

int main(int argc, char **argv) { FILE *f;
  int16_t buf[44100]; //sine_wave(buf,44100,440.f,44100,0.33);
  //sine_wave(buf,44100,293.66,44100,0.33); sine_wave(buf,44100,369.99,44100,0.33);
  float freqs[3] = { 440.f, 293.66, 369.99 };
  add_waves(buf,44100,0,44100,freqs,3);
  f = fopen("cdjoiw.wav","w"); wav_header(f,44100,1);
  out_buf(f,buf,44100); return 0; }
