OB_stim = {'audio/aba2_ampNorm_whiteNoiseCons.wav','audio/aba2_ampNorm_whiteNoiseCons_amplifed.wav'};

for i=1:length(OB_stim)

   
   %load audio
   [y,freq,dummy] = wavread(OB_stim{i});
   wavedata = y';
   nrchannels = size(wavedata,1);
   InitializePsychSound;
   soundhandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

   %fill primary buffer with waveform... tokens will be copied from this
   PsychPortAudio('FillBuffer', soundhandle, wavedata, 0, 1);
   
   %awave = wavedata(1, startSamp:startSamp+numSamps);
   PsychPortAudio('FillBuffer', soundhandle, wavedata);
   
   %start audio, wait for it to finish
   PsychPortAudio('Start', soundhandle, 1,0,1);
   while 1
       status = PsychPortAudio('GetStatus', soundhandle);
       %wait for playback to finish
       if status.Active == 0
           break;
       end
   end
   pause(12)
   clear wavedata y freq nrchannels soundhandle 
end